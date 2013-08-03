mongojs = require 'mongojs'
_ = require 'lodash'
moment = require 'moment'


db = mongojs 'gnats'
pr_stats = db.collection 'pr_stats'


module.exports = (app) ->
    app.get '/pr_stats.json', (req, res, next) ->
        pr_stats.find {}, (err, docs) ->
            res.send docs

    app.post '/pr_stats.json', (req, res, next) ->
        name = req.params.name
        category = req.params.category
        expr = req.params.expr

        pr_stats.update {name: name}, {$set: category: category, expr: expr}, {upsert: true}
        res.send
            status: 1

    app.del '/pr_stats.json', (req, res, next) ->
        name = req.params.name
        pr_stats.remove {name: name}, 1
        res.send
            status: 1
