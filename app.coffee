restify = require 'restify'

app = restify.createServer()

app.use restify.acceptParser(app.acceptable)
app.use restify.queryParser()
app.use restify.bodyParser()
# app.use restify.jsonp()

require('./api')(app)

app.get '/', (req, res, next) ->
    res.send
        status: 1


app.listen 6080, ->
    console.log 'ready on %s!', app.url
