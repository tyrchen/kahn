module.exports = (app) ->
    require('./jd')(app)
    require('./gnats')(app)
    require('./pr_stats')(app)