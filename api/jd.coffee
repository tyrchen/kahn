mongojs = require 'mongojs'
_ = require 'lodash'


db = mongojs 'directory'
employees = db.collection 'employees'
db_settings = db.collection 'settings'
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
            console.log "Docs: #{docs}"
            if docs.length <= 0
                res.send {}
                return

            doc = docs[0]
            employees.findOne {preferred_name: doc.manager}, {uid:1}, (err, doc1) ->
                doc['manager_uid'] = doc1.uid
                res.send doc

    app.get '/directory/groups/:name', (req, res, next) ->
        uid = req.params.name.replace '.json', ''

        options = _id: 0
        data =
            total: 0
            members: null
        employees.find {uid: uid}, options, (err, docs) ->
            if docs <= 0
                res.send {}
                return

            doc = docs[0]
            name = doc.preferred_name
            order = preferred_name: 1

            employees.find({manager: name}, options).sort order, (err, docs) ->
                if docs
                    data.total = docs.length
                    if req.params.uid
                        data.members = _.pluck docs, 'uid'
                    else
                        data.members = docs
                res.send data

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

    app.get '/directory/gnats-monitored-group.json', (req, res, next) ->
        options = _id: 0

        db_settings.find {type: 'gnats-monitor-group'}, options, (err, docs) ->
            if docs.length == 1
                res.send docs[0].value
            else
                res.send []


