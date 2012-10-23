Neuro-Sand-Cube-Console
=======================

Web server and monitoring console for the Neuro-Sand-Cube environment

## Overview

The Neuro-Sand-Cube (NSC) is a cyber-physical system (CPS) based on an augmented version of the Platinum Arts Studio Sandbox, which is itself based on the Cube 2 engine. It was designed to assist neuroscientists with CPS-based research.

This console runs independent of the CPS and displays real-time event data streaming out of the NSC

No security is desired or implemented. The intention is ease-of-use above all. Therefore, the console is designed for operation inside private networks only.


## Primary Authors

Theunis Kotze

Jonathan Friedman, PhD

## Installation
To run the web server, [nodejs](http://nodejs.org) needs to be installed.  
With nodejs installed, issue the following command in the directory where you cloned Neuro-Sand-Cube-Console to take care of all the remaining dependecies:  
```> npm install```

If you are going to edit coffeescript code, you will need to install coffeescript:
```> npm install -g coffee-script```

## Usage

If any changes have been made to server.coffee, compile it to javascript:  
```> coffee server.coffee```  

To run the web server:  
```> node server [host] [port]```

The above commands starts a web server, which connects to a Neuro-Sand-Cube server on ```host:port``` (default = ```localhost:12345```). The server will continuously attempt to connect, until a connection is made. 
Once the server is up and running, clients on the network can connect to the webserver via http on port 8000.  For example, to connect to the server from the same machine, the user would enter ```http://locahost:8000``` into a web browser.  If the server is hosted on a computer with the domain name ```network-pc```, the user would enter ```http://network-pc:8000``` into the browser.

At the moment, the Neuro-Sand-Cube-Console has limited functionality.  The last 30 messages received from the Neuro-Sand-Cube server is logged, as well as a table of states along with the latest values of those states.  The user can also send commands to the Neuro-Sand-Cube server, these are described in the Neuro-Sand-Cube readme.

Note that the computer on which the web server runs acts as client to the Neuro-Sand-Cube server, the client to the web-server does not make a connection to the Neuro-Sand-Cube server.  This should be kept in mind when setting up the Neuro-Sand-Cube configuration file.