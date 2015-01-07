express = require("express")
http = require("http")
path = require("path")
favicon = require("serve-favicon")
logger = require("morgan")
cookieParser = require("cookie-parser")
bodyParser = require("body-parser")
yhat = require('yhat')
yh = yhat.init("greg", "fCVZiLJhS95cnxOrsp5e2VSkk0GfypZqeRCntTD1nHA", "http://cloud.yhathq.com/")
app = express()

# view engine setup
app.set "views", path.join(__dirname, "views")
app.set "view engine", "hbs"

# uncomment after placing your favicon in /public
#app.use(favicon(__dirname + '/public/favicon.ico'));
app.use logger("dev")
app.use bodyParser.json()
app.use bodyParser.urlencoded(extended: false)
app.use cookieParser()
app.use require("less-middleware")(path.join(__dirname, "public"))
app.use express.static(path.join(__dirname, "public"))

app.use "/", (req, res) ->
  res.render "index", { title: "ChatBot" }

# catch 404 and forward to error handler
app.use (req, res, next) ->
  err = new Error("Not Found")
  err.status = 404
  next err

# error handlers

# development error handler
# will print stacktrace
if app.get("env") is "development"
  app.use (err, req, res, next) ->
    res.status err.status or 500
    res.render "error", { message: err.message, error: err }

# production error handler
# no stacktraces leaked to user
app.use (err, req, res, next) ->
  res.status err.status or 500
  res.render "error", { message: err.message, error: {} }

port = parseInt(process.env.PORT, 10) or 3000
app.set "port", port
server = http.createServer(app)

io = require("socket.io")(server)

io.on "connection", (socket) ->

  socket.on "chat", (data) ->
    console.log "CHAT DATA: " + JSON.stringify(data)
    yh.predict "ChatBot", data, (err, response) ->
      text = response.result.reply
      socket.emit "chat", { name: "bot", "text": text }
    socket.emit "chat", data

  socket.on "disconnect", ->
    console.log "#{socket.id} has left the building!"

server.listen port
console.error "Listening on port " + server.address().port
