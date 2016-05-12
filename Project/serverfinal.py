# -*- coding: utf-8 -*-
"""
Created on Sun Mar  6 03:42:38 2016

@author: aditya
"""


from twisted.internet import reactor, protocol
from twisted.protocols.basic import LineReceiver
from twisted.web.client import getPage


import time
import datetime
import logging
import re
import sys
import json

GOOGLE_API_KEY = "AIzaSyCkVXFM0uFZWopQXFBZD2za5LA0-OeRWRE"
GOOGLE_API_URL = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?"

servers = {
	"Alford" : 5090,
	"Bolden" : 5091,
	"Hamilton" : 5092,
	"Parker" : 5093,
	"Welsh" : 5094
}

neighbors = {
	"Alford" : ["Parker", "Welsh"],
	"Bolden" : ["Parker", "Welsh"],
	"Hamilton" : ["Parker"],
	"Parker" : ["Alford", "Bolden", "Hamilton"],
	"Welsh" : ["Alford", "Bolden"]
}

class ProxyServerHerdProtocol(LineReceiver):
	def __init__(self, factory):
		self.factory = factory

	def connectionMade(self):
		self.factory.num_connections = self.factory.num_connections + 1
		logging.info("Connection established. Total: {0}".format(
			self.factory.num_connections))

	def lineReceived(self, line):
		logging.info("Line received: {0}".format(line))
		connection_args = line.split(" ")
		# IAMAT
		if (connection_args[0] == "IAMAT"):
			self.parseIAMAT(line)
		# WHATSAT
		elif (connection_args[0] == "WHATSAT"):
			self.parseWHATSAT(line)
		# AT
		elif (connection_args[0] == "AT"):
			self.parseAT(line)
		# ERROR
		else:
			logging.error("Invalid command")
			self.transport.write("? {0}\n".format(line))
		return

	def parseIAMAT(self, line):
         connection_args = line.split(" ")
         if len(connection_args) != 4:
			logging.error("IAMAT ERROR: command: {0}".format(line))
			self.transport.write("? {0}\n".format(line))
			return
         clientID=connection_args[1] 
         clientTime=connection_args[3]
         time_diff =  time.time() - float(clientTime)

		# Server response
         if time_diff >= 0:
			response = "AT {0} +{1} {2}".format(self.factory.server_name,time_diff,' '.join(connection_args[1:]))
         else:
			response = "AT {0} {1} {2}".format(self.factory.server_name,time_diff, ' '.join(connection_args[1:]))

         if clientID in self.factory.clients:
			logging.info("Updated client: {0}".format(clientID))
         else:
			logging.info("Added New client: {0}".format(clientID))

         self.factory.clients[clientID] = {"client_info":response, "time":clientTime}
         logging.info("Server response: {0}".format(response))
         self.transport.write("{0}\n".format(response))
         self.factory.clients[clientID] = {"client_info": response, "time": clientTime}
         logging.info("Send location update to neighbors")
         self.updateLocation(response)
         
	def invalidMessage(self, line, appendix = ""):
          logging.info("Invalid command: " + line + " " + appendix)
          self.transport.write("? " + line + "\n")
          return

	def parseWHATSAT(self, line):
            components = line.split()
            if len(components) != 4:
              self.invalidMessage(line)
              return
            
            clientId = components[1]
            try:
              radius = int(components[2])
              limit = int(components[3])
            except Exception, exception:
              self.invalidMessage(line, "WHATSAT: Invalid input parameter")
              return
        
            if radius > 50 or limit > 20:
              self.invalidMessage(line, "WHATSAT: range or item limit exceeded.")
              return

            if not (clientId in self.factory.clients):
              self.invalidMessage(line, "WHATSAT: client ID not found.")
              return
        
            atMsg = self.factory.clients[clientId]["client_info"]
        
            try:
              queryPosition = atMsg.split()[4]
              #logging.info("After query position"+str(atMsg))
              #queryPosition = clientPos.replace('+', ' +').replace('-', ' -').split()
              queryPosition = re.sub(r'[-]', ' -', queryPosition)
              queryPosition = re.sub(r'[+]', ' +', queryPosition).split(" ")
              #logging.info("After query position 2"+str(queryPosition[2]))
              queryPos = queryPosition[1] + "," + queryPosition[2]                    
              
              logging.info(str(queryPos))
              
              queryUrl = GOOGLE_API_URL+"location="+str(queryPos)+"&radius="+str(radius)+"&sensor=false&key="+GOOGLE_API_KEY
              #"{0}location={1}&radius={2}&sensor=false&key={3}".format(GOOGLE_API_URL, queryPos, str(radius), GOOGLE_API_KEY)
              logging.info("Google places query URL: {0}".format(queryUrl))
              logging.info(str(queryUrl))
              queryResponse = getPage(str(queryUrl))
              queryResponse.addCallback(callback = lambda x:(self.parseGoogleResults(x, atMsg, limit, queryUrl)))
            except Exception, exception:
              logging.error('Error: Google API query failed; or illegal user input: ' + str(exception))

	def parseGoogleResults(self, queryResponse, atMsg, limit, queryUrl):
            logging.debug("Google places query reply: " + queryResponse)
            APIresponse_json = json.loads(queryResponse)
            results = APIresponse_json["results"]
            APIresponse_json["results"] = results[0:limit]
            returnMsg = "{0}\n{1}\n\n".format(atMsg, json.dumps(APIresponse_json, indent=4))
            self.transport.write(returnMsg)
            logging.info("Responded to IAMAT with: " + atMsg + "; and Google Places query: " + queryUrl)
  
	def parseAT(self, line):
		connection_args = line.split()
		#if len(connection_args) != 7:
			#logging.error("AT ERROR: Invalid command: {0}".format(line))
			#self.transport.write("? {0}\n".format(line))
			#return

		#AT=connection_args[0]
		server=connection_args[1]

		clientID=connection_args[3] 
 
		clientTime =connection_args[5] 

		if (clientID in self.factory.clients) and (clientTime <= self.factory.clients[clientID]["time"]):
			logging.info("Duplicate or outdated update {0}".format(server))
			return
		self.factory.clients[clientID] = {"client_info": ' '.join(connection_args[0:7]),"time": clientTime}

		logging.info("Added {0} : {1}".format(clientID, self.factory.clients[clientID]["client_info"]))
		self.updateLocation(self.factory.clients[clientID]["client_info"])
		return



	def updateLocation(self, message):
		for neighbor in neighbors[self.factory.server_name]:
			reactor.connectTCP('localhost', servers[neighbor], ProxyHerdClient(message))
			logging.info("Location update sent from {0} to {1}".format(self.factory.server_name, neighbor))
		return

	def connectionLost(self, reason):
		self.factory.num_connections = self.factory.num_connections - 1
		logging.info("Connection lost. Total: {0}".format(self.factory.num_connections))

class ProxyHerdServer(protocol.ServerFactory):
	def __init__(self, server_name):
		self.server_name = server_name
		self.port_number = servers[self.server_name]
		self.clients = {}
		self.num_connections = 0
		#log_file = self.server_name + "_" + re.sub(r'[:T]', '_', datetime.datetime.utcnow().isoformat().split('.')[0]) + ".log"
		#logging.basicConfig(log_file = log_file, level=logging.DEBUG)
		self.log_file = "server-" + self.server_name + ".log"
		logging.basicConfig(filename = self.log_file, level = logging.DEBUG, filemode = 'a', format='%(asctime)s %(message)s')
		logging.info('{0}:{1} server started'.format(self.server_name, self.port_number))

	def buildProtocol(self, addr):
		return ProxyServerHerdProtocol(self)

	def stopFactory(self):
		logging.info("{0} server shutdown".format(self.server_name))


class ClientProtocol(LineReceiver):
	def __init__ (self, factory):
		self.factory = factory

	def connectionMade(self):
		self.sendLine(self.factory.message)
		self.transport.loseConnection()

class ProxyHerdClient(protocol.ClientFactory):
	def __init__(self, message):
		self.message = message

	def buildProtocol(self, addr):
		return ClientProtocol(self)


def main():
	if len(sys.argv) != 2:
		print "Error: arguments error"
		exit()
	factory = ProxyHerdServer(sys.argv[1])

	reactor.listenTCP(servers[sys.argv[1]], factory)
	reactor.run()

if __name__ == '__main__':
    main()