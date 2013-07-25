mongojs = require 'mongojs'
_ = require 'lodash'
moment = require 'moment'


db = mongojs 'gnats'
issues = db.collection 'issues'
progresses = db.collection 'progresses'
items_per_page = 40

module.exports = (app) ->
    app.get '/gnats.json', (req, res, next) ->
        res.send
            status: 1

    app.get '/gnats/groups/:name', (req, res, next) ->
        # not implemented
        res.send
            status: 1

    app.put '/gnats/issues/:number', (req, res, next) ->
        number = req.params.number.replace '.json', ''
        name = req.body.name
        value = req.body.value

        if name isnt 'comment' and name isnt 'status'
            res.send 304,
                status: 0
                message: 'Not updated due to unrecognized field'
            return

        issues.findOne {number: "#{number}"}, (err, doc) ->
            if not doc
                res.send 404,
                    status: 0
                    message: 'Cannot find PR ' + number
                return

            data = {}
            data[name] = value
            issues.update {number:"#{number}"}, {$set: data}, (err) ->
                res.send
                    status: 1

    app.get '/gnats/progresses/:name/recent.json', (req, res, next) ->
        team = req.params.name
        query = team: team
        options = limit: 7
        order = day: -1
        progresses.find(query, options).sort order, (err, doc) ->
            res.send doc

    app.get '/gnats/progresses/:name/:day', (req, res, next) ->
        day = new Date(req.params.day.replace '.json', '')
        team = req.params.name
        progresses.find {day: day, team: team}, (err, doc) ->
            res.send doc


    app.post '/gnats/progresses/:number', (req, res, next) ->
        number = req.params.number.replace '.json', ''
        uid = req.body.uid
        progress = req.body.progress
        team = req.body.team


        issues.find {number: "#{number}"}, (err, issues) ->
            if issues.length <= 0
                res.send 404,
                    status: 0
                    message: 'Cannot find PR ' + number
                return

            issue = issues[0]

            today = new Date(moment(new Date()).format('YYYY-MM-DD'))
            query = {day: today, team: team}
            progresses.find query, (err, docs) ->
                item = {
                    uid: uid, number: number, title: issue.title,
                    level: issue.level, platform: issue.platform,
                    category: issue.category, progress: progress
                }
                if docs.length <= 0
                    updates = {}
                    updates[number] = item
                    new_doc = {day: today, team: team, updates: updates}
                    progresses.insert new_doc, (err) ->
                        res.send
                            status: 1
                        return

                doc = docs[0]
                doc.updates[number] = item
                progresses.update query, doc, (err) ->
                    res.send
                        status: 1




    app.get '/gnats/:name', (req, res, next) ->
        uid = req.params.name.replace '.json', ''

        options =
            _id: 0
            audit_trail: 0
            crawled: 0

        order = level: 1

        condition = $or: [{dev_owner:uid}, {responsible: uid}, {worker: uid}]

        if req.params.all
            query = condition
        else
            query = $and: [condition, {state: $not: /closed/}]

        issues.find(query, options).sort order, (err, docs) ->
            res.send docs



    app.get '/gnats/search.json', (req, res, next) ->
        # not implemented
        t = req.params.term.trim()
        if not t
            res.send []

        term = new RegExp t
        options = _id: 0
        query = "$or": [{uid: term}, {preferred_name: term}, {cube: term}, {extension: term}, {mobile: term}, {phone: term}]

        employees.find query, options, (err, docs) ->
            res.send docs

