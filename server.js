// Generated by CoffeeScript 1.3.3
(function() {
  var app, host, io, net, nscConnect, nscDisconnect, port, server;

  app = require('express')();

  server = require('http').createServer(app);

  io = require('socket.io').listen(server);

  net = require('net');

  host = 'localhost';

  port = 12345;

  if (process.argv.length <= 2) {
    console.log('No server & port specified. The format is node server \'ip\' \'port\'.  Connecting on localhost:12345');
  } else {
    host = process.argv[2];
    if (process.argv.length >= 4) {
      port = process.argv[3];
    }
  }

  nscConnect = (function() {
    console.log('Attempting to connect to NSC server ...');
    exports.client = net.connect(port, host, function() {
      return console.log('client connected');
    });
    exports.client.on('error', (function() {
      return console.log('error connecting to Neuro-Sand-Cube server.  Retrying...');
    }));
    exports.client.on('close', (function() {
      console.log('Connection closed.');
      return nscConnect();
    }));
    exports.client.on('timeout', function() {
      return nscDisconnect();
    });
    return exports.client.on('end', function() {
      return nscDisconnect();
    });
  });

  nscConnect();

  nscDisconnect = (function() {
    console.log('Disconnected from NSC server...');
    return nscConnect();
  });

  server.listen(8000);

  app.get('/', (function(req, res) {
    return res.sendfile(__dirname + '/index.html');
  }));

  io.sockets.on('connection', (function(socket) {
    exports.client.on('data', (function(data) {
      return socket.emit('nsc', data.toString());
    }));
    return socket.on('command', (function(data) {
      console.log(JSON.stringify(data));
      return exports.client.write(JSON.stringify(data));
    }));
  }));

}).call(this);
