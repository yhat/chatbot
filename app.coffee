# express stuff
express = require("express")
http = require("http")
path = require("path")
favicon = require("serve-favicon")
logger = require("morgan")
cookieParser = require("cookie-parser")
bodyParser = require("body-parser")
app = express()

# yhat stuff
yhat = require('yhat')
yh = yhat.init(process.env["YHAT_USERANME"], process.env["YHAT_APIKEY"], "http://cloud.yhathq.com/")

# setup express configurations
#
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


# we only have 1 route
app.use "/", (req, res) ->
  res.render "index", { title: "ChatBot" }

# Default error handling for Express
#
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

# setup the server
port = parseInt(process.env.PORT, 10) or 3000
app.set "port", port
server = http.createServer(app)

io = require("socket.io")(server)

io.on "connection", (socket) ->

  socket.on "chat", (data) ->
    # make a prediction on Yhat using the newest chat message. chat messages 
    # should look like this `{ text: "here" }`
    yh.predict "ChatBot", data, (err, response) ->
      if err
        console.log "[ERROR]: #{err}"
        return
      try
        text = response.result.reply
      catch
        text = "...ops something went wrong"
      console.log "CHAT DATA: " + JSON.stringify(data)
      socket.emit "chat", { name: "bot", "text": text }
    # ping the chat message back out to the client. this seems a little 
    # backward but it saves us from having to create messages twice
    socket.emit "chat", data

  socket.on "disconnect", ->
    console.log "#{socket.id} has left the building!"

# start listening and print out what port we're on for sanity's sake
server.listen port
console.error "Listening on port " + server.address().port
