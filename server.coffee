app = require('express')();
express = require('express');
server = require('http').createServer(app);
io = require('socket.io').listen(server);
net = require('net');
fs = require('fs');
path = require('path');
spawn = require('child_process').spawn;
zip = new require('node-zip')()


# trial data
logFile = 'log/NSC_LOG.txt'
currentLogFile = logFile;
trial_name = "";
trial_length = 0;
animal_number = "";
trial_date = "";
trial_time = "";
trial_active = false;
console.log("started")
trial_start_time = new Date().getTime()

logDir = './log/'
host = 'localhost'
port = 12345
connected = false

if (process.argv.length <= 2)
   console.log('No server & port specified. The format is node server [\'ip\'] [\'port\'].  Connecting on localhost:12345')
else 
   host = process.argv[2]
   if (process.argv.length>=4)
      port = process.argv[3]

logData = ((file, data) ->
        fs.appendFile(file, data.toString(), ((err) -> 
                if (err) 
                        throw err)))
        


# connect to Neuro-Sand-Cube on port 12345

nscConnect = (->
        console.log('Attempting to connect to NSC server ...')
        exports.client = net.connect(port,host,(  -> 
                console.log('client connected')
                fs.writeFileSync(logFile, '')  # clear out the log file each time a connection is made             
                connected = true
                exports.client.on('data', ((data) ->  
                        if (exports.trial_active)
                                logData(currentLogFile, data)))))
        exports.client.on('error',(() ->
                console.log('error connecting to Neuro-Sand-Cube server.  Retrying...')
                connected = false))
        exports.client.on('close',( -> 
                console.log('Connection closed.')
                connected = false
                nscConnect()))
        exports.client.on('timeout', -> nscDisconnect())
        exports.client.on('end', () ->  
                connected = false
                nscDisconnect()))

nscConnect()

nscDisconnect = ( ->
        console.log('Disconnected from NSC server...')
        nscConnect())


server.listen(8000)

## routes
#
#

app.use(express.bodyParser())
app.use(express.static(__dirname + '/public'))
app.get('/',((req, res) ->
        #console.log("trial_active: " + exports.trial_active);
        #if (trial_active)
        #        res.sendfile(__dirname + '/console.html')
        #else
        #        res.sendfile(__dirname + '/trial.html')))
        res.sendfile(__dirname + '/index.html')))
#app.post('/console',consoleRequest )
app.post('/console',((req, res) -> consoleRequest(req, res)))

consoleRequest = ((req, res) ->
        res.sendfile(__dirname + '/console.html')
        if (req.body.trial_name?)
                console.log(req.body)
                exports.trial_name = req.body.trial_name
                exports.trial_length = parseInt(req.body.trial_length)
                exports.animal_number = req.body.animal_number
                exports.trial_date = req.body.trial_date
                exports.trial_time = req.body.trial_time
                startTrial(trial_name, animal_number, trial_length, trial_date, trial_time))
app.post('/trial',((req, res) ->
        #endTrial()
        res.sendfile(__dirname + '/trial.html')))
app.post('/logs',((req, res) ->
        res.sendfile(__dirname + '/logs.html')))

        
#app.get('/logs/:index', ((req, res) -> req.params.index))			      	
app.get('/log/:index', ((req, res) ->
        if (req.params.index < 0)
                
                l = __dirname + '/' + logDir
                #console.log(l)
                #zip.folder(l)
                #data = zip.generate()
                #res.attachment("all")
                #res.setHeader('Content-disposition', 'attachment; filename=' + "all")
                #res.write(data)
                #res.end()
                #files = fs.readdirSync(logDir)
                #file = files[req.params.index]
                #file = __dirname + '/' + logDir + file
                #zip = spawn('compact', ['/C', file]) # __dirname + '/' + 'log/'
                #res.contentType('zip')
                #zip.stdout.on('data', (data) ->
                #        res.write(data))
                #zip.stderr.on('data', (data) ->
                #        console.log('zip stderr: ' +data))
                #zip.on('exit', (code) ->
                #        if (code != 0)
                #                res.statusCode = 500
                #                console.log('zip exited with code ' +code)
                #                res.end()
                #        else
                #                res.end())
        else
                files = fs.readdirSync(logDir)
                file = files[req.params.index]
                file = __dirname + '/' + logDir + file
                filename = path.basename(file)
                console.log(file)
                console.log(filename)
                #file = __dirname + logDir + filename
                res.attachment(filename)
                res.setHeader('Content-disposition', 'attachment; filename=' + filename)
                filestream = fs.createReadStream(file)
                filestream.on('data', (chunk) -> res.write(chunk))
                filestream.on('end',  ->
                        res.end())))

io.sockets.on('connection', ((socket) ->
        exports.socket = socket
        exports.client.on('data', ((data) ->  
                socket.emit('nsc',data.toString()))) 
        setInterval( (() -> socket.emit('connection', { "connected" : connected })) , 5000)
        socket.on('command', ((data) ->
                console.log(JSON.stringify(data))
                exports.client.write(JSON.stringify(data))))
        socket.on('stop_trial', ((data) ->
                endTrial()))
        socket.on('trial', ((data) ->
                console.log(JSON.stringify(data))
                trial_name = data.trial_name
                trial_length = parseInt(data.trial_length)
                animal_number = data.animal_number
                trial_date = data.trial_date
                trial_time = data.trial_time
                startTrial(trial_name, animal_number, trial_length, trial_date, trial_time)
                ))
        socket.on('trial_progress_request', sendTrialTimeUpdate)
        socket.on('logs_request', () ->
                sendLogFiles()
                )))

sendLogFiles = (() ->
        files = fs.readdirSync(logDir)
        exports.socket.emit('logs', files))
        #for (i in files)
        #        
        #)

createLogFileName = (() ->
        console.log(exports.trial_date)
        trial_time = exports.trial_time.replace(":","-")
        currentLogFile = "log/" + exports.trial_date + "_" + trial_time + "_" + exports.trial_name + "_" + exports.animal_number + ".txt")

#create a log file, start the trial and set a timer for when the trial will be over
# uses a timer that runs every minute, but checks time by using Date().getTime()

exports.tick = 0
interval = 1000*60
exports.trialTimer = null
startTrial = ((trial_name, animal_number, trial_length, trial_date, trial_time) ->
        createLogFileName()
        console.log('startTrial')
        exports.trial_start_time = new Date().getTime()
        exports.tick = 0
        exports.trial_active = true
        console.log("\nTrial " + trial_name + " started.\n")
        exports.trialTimer = setTimeout( trialTimeTimer, interval))

endTrial = ( () ->
        if (exports.trialTimer != null)
                clearTimeout(exports.trialTimer);
        exports.tick = 0
        exports.trial_active = false
        console.log("Trial ended."))

trialTimeTimer = (() ->
                exports.tick=exports.tick+1
                now = new Date().getTime();
                diffStart = now - exports.trial_start_time;
                nextTime = exports.trial_start_time + (exports.tick+1)*interval
                diff = nextTime-now
                if (exports.tick < exports.trial_length)
                        exports.trialTimer = setTimeout(trialTimeTimer, diff)
                else
                        exports.trialTimer = null
                        endTrial()
                 sendTrialTimeUpdate())

sendTrialTimeUpdate = ( () ->
        obj = {}
        obj.trial_active = exports.trial_active
        endTime = exports.trial_start_time + exports.trial_length*interval
        obj.trial_time = endTime - new Date().getTime()
        if (obj.trial_time < 0)
                obj.trial_time = 0;
        exports.socket.emit('trial_progress',obj))


                        