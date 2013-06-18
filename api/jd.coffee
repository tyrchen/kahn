mongojs = require 'mongojs'
_ = require 'lodash'


db = mongojs 'directory'
employees = db.collection 'employees'
teams = db.collection 'teams'
items_per_page = 40

module.exports = (app) ->

    app.get '/directory.json', (req, res, next) ->
        res.send
            status: 1

    app.get '/directory/employees.json', (req, res, next) ->
        employees.find().count (err, count) ->
            data =
                total: count
                items: null

            if req.params.page
                data.page = parseInt req.params.page
            else
                data.page = 1

            options = {_id: 0, limit: items_per_page, skip: (data.page - 1) * items_per_page}

            employees.find {}, options, (err, docs) ->
                if docs
                    data.items = docs
                res.send data

    app.get '/directory/employees/:name', (req, res, next) ->
        uid = req.params.name.replace '.json', ''

        options = _id: 0
        employees.find {uid: uid}, options, (err, docs) ->
            if docs.length <= 0
                res.send {}
                return

            doc = docs[0]
            teams.find {members: uid}, {slug:1}, (err, teams) ->
                doc['team'] = ''
                if teams.length > 0
                    doc['team'] = teams[0].slug
                res.send doc

    app.get '/directory/teams/:slug', (req, res, next) ->
        slug = req.params.slug.replace '.json', ''
        options = members: 1
        data =
            total: 0
            members: null

        teams.find {slug: slug}, options, (err, docs) ->
            if docs.length <= 0
                res.send {}
                return

            members = docs[0].members
            order = preferred_name: 1
            employees.find({uid: {$in: members}}).sort order, (err, docs) ->
                if docs
                    data.total = docs.length
                    if req.params.uid
                        data.members = _.pluck docs, 'uid'
                    else
                        data.members = docs
                res.send data

    app.post '/directory/teams/:slug', (req, res, next) ->
        slug = req.params.slug.replace '.json', ''
        name = req.body.name
        members = _.map req.body.members.split(','), (item) ->
            return item.trim()
        item = {name: name, slug: slug, members: members, created_at: new Date()}
        teams.update {slug: slug}, item, {upsert: true}, (err) ->
            res.send
                status: 1

    app.get '/directory/search.json', (req, res, next) ->
        t = req.params.term.trim()
        if not t
            res.send []

        term = new RegExp t
        options = _id: 0
        query = "$or": [{uid: term}, {preferred_name: term}, {cube: term}, {extension: term}, {mobile: term}, {phone: term}]

        employees.find query, options, (err, docs) ->
            res.send docs

    app.get '/directory/snapshots.json', (req, res, next) ->
        # this API doesn't work till now
        db.getCollectionNames (err, names) ->
            data = _.map _.without(names, 'directory'), (item) -> item.replace('snapshot')

            res.send data

    app.get '/directory/gnats-monitored-members.json', (req, res, next) ->
        options = members: 1

        teams.find {}, options, (err, docs) ->
            if docs.length > 0
                res.send _.flatten(docs, 'members')
            else
                res.send []


