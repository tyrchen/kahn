mongojs = require 'mongojs'
_ = require 'lodash'


db = mongojs 'gnats'
issues = db.collection 'issues'
items_per_page = 40

module.exports = (app) ->
    app.get '/gnats.json', (req, res, next) ->
          res.send
                status: 1

    app.get 'gnats/groups/:name', (req, res, next) ->
        # not implemented
        res.send
            status: 1

    app.get 'gnats/:name', (req, res, next) ->
        uid = req.params.name.replace '.json', ''

        options =
          _id: 0
          audit_trail: 0
          crawled: 0

        issues.find {responsible: uid}, options, (err, doc) ->
            res.send doc


    app.get 'gnats/search.json', (req, res, next) ->
        # not implemented
        t = req.params.term.trim()
        if not t
            res.send []

        term = new RegExp t
        options = _id: 0
        query = "$or": [{uid: term}, {preferred_name: term}, {cube: term}, {extension: term}, {mobile: term}, {phone: term}]

        employees.find query, options, (err, docs) ->
            res.send docs

