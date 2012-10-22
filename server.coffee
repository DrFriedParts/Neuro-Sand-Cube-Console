app = require('express')();
server = require('http').createServer(app);
io = require('socket.io').listen(server);
net = require('net');

host = 'localhost'
port = 12345

if (process.argv.length <= 2)
   console.log('No server & port specified. The format is node server \'ip\' \'port\'.  Connecting on localhost:12345')
else 
   host = process.argv[2]
   if (process.argv.length>=4)
      port = process.argv[3]


# connect to Neuro-Sand-Cube on port 12345

nscConnect = (-> 
           console.log('Attempting to connect to NSC server ...')
           exports.client = net.connect(port,host, () -> console.log('client connected'))
           exports.client.on('error',(() ->
                             console.log('error connecting to Neuro-Sand-Cube server.  Retrying...')))
           exports.client.on('close',( -> 
                                        console.log('Connection closed.')
                                        nscConnect()))
           exports.client.on('timeout', -> nscDisconnect())
           exports.client.on('end', () ->  
                                        nscDisconnect()))

nscConnect()

nscDisconnect = ( ->
					console.log('Disconnected from NSC server...')
					nscConnect())



server.listen(8000)

app.get('/',((req, res) ->
				  		res.sendfile(__dirname + '/index.html')))


io.sockets.on('connection', ((socket) ->
			 exports.client.on('data', ((data) ->  
			 			 	   		  socket.emit('nsc',data.toString()))) 
			 socket.on('command', ((data) ->
											console.log(JSON.stringify(data))
											exports.client.write(JSON.stringify(data))))))

	          
