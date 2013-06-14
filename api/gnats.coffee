mongojs = require 'mongojs'
_ = require 'lodash'


db = mongojs 'gnats'
issues = db.collection 'issues'
items_per_page = 40

module.exports = (app) ->
    app.get '/gnats.json', (req, res, next) ->
          res.send
                status: 1

    app.get '/gnats/groups/:name', (req, res, next) ->
        # not implemented
        res.send
            status: 1

    app.put 'gnats/issues/:number', (req, res, next) ->
        number = req.params.number.replace '.json', ''
        name = req.body.name
        value = req.body.value

        if name isnt 'comment' and name isnt 'status'
            res.send 304,
                status: 0
                message: 'Not updated due to unrecognized field'
            return

        item = issues.findOne {number: "#{number}"}, (err, doc) ->
            if not doc
                res.send 404,
                    status: 0
                    message: 'Cannot find PR ' + number

            data = {}
            data[name] = value
            issues.update {number:"#{number}"}, {$set: data}, (err) ->
                res.send
                    status: 1



    app.get '/gnats/:name', (req, res, next) ->
        uid = req.params.name.replace '.json', ''

        options =
          _id: 0
          audit_trail: 0
          crawled: 0

        order = level: 1

        issues.find({$or: [responsible: uid, dev_owner: uid]}, options).sort order, (err, doc) ->
            res.send doc



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

