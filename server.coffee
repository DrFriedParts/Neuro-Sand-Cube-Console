app = require('express')();
express = require('express');
server = require('http').createServer(app);
io = require('socket.io').listen(server);
net = require('net');
fs = require('fs');
path = require('path');

logFile = 'log/NSC_LOG.txt'

host = 'localhost'
port = 12345
connected = false

if (process.argv.length <= 2)
   console.log('No server & port specified. The format is node server [\'ip\'] [\'port\'].  Connecting on localhost:12345')
else 
   host = process.argv[2]
   if (process.argv.length>=4)
      port = process.argv[3]


# connect to Neuro-Sand-Cube on port 12345

nscConnect = (-> 
           console.log('Attempting to connect to NSC server ...')
           exports.client = net.connect(port,host,(  -> 
                                                        console.log('client connected')
                                                        fs.writeFile(logFile, '')  # clear out the log file each time a connection is made                                                         
                                                        connected = true))
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

app.get('/',((req, res) ->
				  		res.sendfile(__dirname + '/index.html')))

app.get('/log', ((req, res) ->
                        file = __dirname + logFile
                        filename = path.basename(file);
                        res.attachment(filename)
                        res.setHeader('Content-disposition', 'attachment; filename=' + filename)
                        filestream = fs.createReadStream(file)
                        filestream.on('data',  (chunk) ->
                                      res.write(chunk))
                        filestream.on('end',  ->
                                      res.end())
))


exports.client.on('data', ((data) ->  
                                     fs.appendFile(logFile, data.toString())))

io.sockets.on('connection', ((socket) ->
             exports.client.on('data', ((data) ->  
                                                  socket.emit('nsc',data.toString()))) 
             setInterval( (() -> socket.emit('connection', { "connected" : connected })) , 5000)
             socket.on('command', ((data) ->
                                            console.log(JSON.stringify(data))
                                            exports.client.write(JSON.stringify(data))))))

	          
