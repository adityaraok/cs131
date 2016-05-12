# -*- coding: utf-8 -*-
"""
Created on Thu Mar  1 17:51:18 2016

@author: aditya
"""


import time
import sys
import json
import logging


from twisted.web.client import getPage
from twisted.internet import reactor,protocol
from twisted.protocols.basic import LineReceiver
from twisted.application import service, internet



GOOGLE_PLACE_API_KEY = ""
GOOGLE_PLACE_API_PREFIX = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?"

"""
Define a dictionary

"""
servers = {
	"Alford" :   {"ip":"localhost", "port": 8000},
	"Bolden" :   {"ip":"localhost", "port": 8001},
	"Hamilton" : {"ip":"localhost", "port": 8002},
	"Parker" :   {"ip":"localhost", "port": 8003},
	"Welsh" :   {"ip":"localhost", "port": 8004}
}

neighbors = {
	"Alford" :   ["Parker", "Welsh"],
	"Bolden" :   ["Parker", "Welsh"],
	"Hamilton" : ["Parker"],
	"Parker" :   ["Alford", "Bolden", "Hamilton"],
	"Welsh" :   ["Alford", "Bolden"]
}

class ProxyHerdProtocol(LineReceiver):
  def __init__(self, factory):
    self.factory = factory

  def connectionMade(self):
    self.factory.num_of_connections += 1
    logging.info("Connection established. Total: {0}".format(self.factory.num_of_connections))
    
    
  
  def lineReceived(self, line):
	logging.info("Message received: {0}".format(line))
	parameters = line.split(" ")
	# IAMAT
	if (parameters[0] == "IAMAT"):
		self.parseIAMAT(line)
	# WHATSAT
	elif (parameters[0] == "WHATSAT"):
		self.parseWHATSAT(line)
	# AT
	elif (parameters[0] == "AT"):
		self.parseAT(line)
	# ERROR
	else:
		logging.error("invalid message received")
		self.transport.write("? {0}\n".format(line))
	return
 
  def invalidMessage(self, line, appendix = ""):
    logging.info("Invalid command: " + line + " " + appendix)
    self.transport.write("? " + line + "\n")
    return
 
  def parseIAMAT(self, line):
    command_args = line.split()
    if len(command_args) != 4:
      self.invalidMessage(line)
      return

    clientID = command_args[1]
    clientTime = command_args[3]
    
    try:
      timeDiff = time.time() - float(clientTime)
    except Exception, exception:
      self.invalidMessage(line, "IAMAT: Invalid input parameter")
      return

    if timeDiff >= 0:
      response = "AT {0} +{1} {2}".format(self.factory.server_name, timeDiff, ' '+(command_args[1:]))
    else:
      response = "AT {0} {1} {2}".format(self.factory.server_name, timeDiff, ' '+(command_args[1:]))

    self.transport.write(response + "\n")
    logging.info("Responded to IAMAT with: " + response)
    

    if (clientID in self.factory.clients) and (clientTime <= self.factory.clients[clientID]["time"]):
      logging.info("Duplicate or outdated AT info " + line)
      return
    self.factory.clients[clientID] = {"response": response, "time": clientTime}


    self.propagate(response)
    
  def parseWHATSAT(self, line):
    command_args = line.split()
    if len(command_args) != 4:
      self.invalidMessage(line)
      return
    
    clientID = command_args[1]
    try:
      radius = int(command_args[2])
      limit = int(command_args[3])
    except Exception, exception:
      self.invalidMessage(line, "WHATSAT: Invalid input parameter")
      return

    if radius > 50 or limit > 20:
      self.invalidMessage(line, "WHATSAT: radius or limit exceeded.")
      return
    if not (clientID in self.factory.clients):
      self.invalidMessage(line, "WHATSAT: client ID not found.")
      return
      #server response
    ATresponse = self.factory.clients[clientID]["response"]

    try:
      clientLocation = ATresponse.split()[4]
      queryLocation = clientLocation.replace('+', ' +').replace('-', ' -').strip().replace(' ', ',')

      queryRequest = "{0}location={1}&radius={2}&sensor=false&key={3}".format(GOOGLE_PLACE_API_PREFIX, queryLocation, str(radius), GOOGLE_PLACE_API_KEY)
      logging.info("Querying Google places URL: {0}".format(queryRequest))
      queryResponse = getPage(queryRequest)
      queryResponse.addCallback(callback = lambda x:(self.processGooglePlacesRequest(x, ATresponse, limit, queryRequest)))
    except Exception, exception:
      logging.error('ERROR: Google API request or user input is invalid: ' + str(exception))
      
  def processGooglePlacesRequest(self, queryResponse, ATresponse, limit, queryRequest):
    logging.debug("Google places response: " + queryResponse)
    responseObject = json.loads(queryResponse)
    results = responseObject["results"]
    responseObject["results"] = results[0:limit]
    logMessage = "{0}\n{1}\n\n".format(ATresponse, json.dumps(responseObject, indent=4))
    self.transport.write(logMessage)
    logging.info("Responded to IAMAT with: " + ATresponse + "; and Google Places query: " + queryRequest)
    
  def parseAT(self, line):
    command_args = line.split()
    if len(command_args) != 7:
      self.command_args(line)
      return

    clientID = command_args[3]
    clientTime = command_args[5]
    if (clientID in self.factory.clients) and (clientTime <= self.factory.clients[clientID]["time"]):
      logging.info("Clock skew error " + line)
      return

    self.factory.clients[clientID] = {"response": ' '+(command_args[:-1]), "time": clientTime}
    logging.info("Added/Updated {0} : {1}".format(clientID, self.factory.clients[clientID]["response"]))
    
    #generate at message
    self.UpdateLocation(self.factory.clients[clientID]["response"])
    return
    
  def UpdateLocation(self,ATmessage):
		for neighbor in neighbors[self.factory.server_name]:
			reactor.connectTCP(servers[neighbor], ProxyHerdClient(ATmessage))
			logging.info("Location update message sent from {0} to {1}".format(self.factory.server_name, neighbor))
		return
      
      
class ProxyServer(protocol.ServerFactory):
  def __init__(self, server_name, server_port):
    self.server_name = server_name
    self.server_port = server_port
    self.num_of_connections = 0
    self.clients = {}
    self.connectedServers = {}

    self.logFile = "server-" + self.server_name + ".log"
    logging.basicConfig(filename = self.logFile, level = logging.DEBUG, filemode = 'a', format='%(asctime)s %(message)s')
    logging.info('{0}:{1} server started'.format(self.server_name, self.server_port))

  def buildProtocol(self, addr):
    return ProxyHerdProtocol(self)

  def stopFactory(self):
    logging.info("{0} stopping server".format(self.server_name))

class ProxyHerdClientProtocol(LineReceiver):
  def __init__ (self, factory):
    self.factory = factory

  def connectionMade(self):
    self.factory.responseObject.connectedServers[self.factory.server_name] = self.factory
    logging.info("Connected from client: {0} to server: {1}".format(self.factory.responseObject.server_name, self.factory.server_name))
    self.sendLine(self.factory.startupMessage)

  def connectionLost(self, reason):
    if self.factory.server_name in self.factory.responseObject.connectedServers:
      del self.factory.responseObject.connectedServers[self.factory.server_name]
      logging.info("Unable to connect from client: {0} to server: {1}".format(self.factory.responseObject.server_name, self.factory.server_name)) 
    return

class ProxyHerdClient(protocol.ClientFactory):
  def __init__(self, responseObject, server_name, startupMessage):
    # cyclic reference
    self.responseObject = responseObject
    self.server_name = server_name
    self.startupMessage = startupMessage
    return

  def buildProtocol(self, addr):
    self.protocol = ProxyHerdClientProtocol(self)
    return self.protocol

  def sendAtMsg(self, atMsg):
    try:
      self.protocol.sendLine(atMsg)
    except Exception, e:
      logging.error("Error: client sendAtMsg error: " + str(e))
    return
  

  def clientConnectionLost(self, connector, reason):
    if self.server_name in self.responseObject.connectedServers:
      del self.responseObject.connectedServers[self.server_name]
      logging.info("Connection from client: {0} to server: {1} lost.".format(self.responseObject.server_name, self.server_name))
    return

  def clientConnectionFailed(self, connector, reason):
    logging.info("Connection from client: {0} to server: {1} failed.".format(self.responseObject.server_name, self.server_name))
    return


def main():
  if len(sys.argv) != 2:
    print "ERROR: Incorrect number of arguments"
    exit()
  
    if sys.argv[1] in servers:
      factory = ProxyServer(sys.argv[1], servers[sys.argv[1]]["port"])
      reactor.listenTCP(servers[sys.argv[1]]["port"], factory)
      reactor.run()
    else:
      print "ERROR: Servers must be among Alford, Bolden, Hamilton, Welsh, Parker"


if __name__ == '__main__':
    main()