//
//  main.swift
//  PerfectTemplate
//
//  Created by Kyle Jessup on 2015-11-05.
//	Copyright (C) 2015 PerfectlySoft, Inc.
//
//===----------------------------------------------------------------------===//
//
// This source file is part of the Perfect.org open source project
//
// Copyright (c) 2015 - 2016 PerfectlySoft Inc. and the Perfect project authors
// Licensed under Apache License v2.0
//
// See http://perfect.org/licensing.html for license information
//
//===----------------------------------------------------------------------===//
//
import PerfectLib
import PerfectHTTP
import PerfectHTTPServer
import PerfectNotifications
//9Q98PA88U2
//MyClient
//TRZRC745Z4



let notificationsTestId = "com.Ken.MyClient"                        // 应用程序名称，我们用这个名称来配置，但是不一定非得是这个形式
let apnsTeamIdentifier = "TRZRC745Z4"                               //团队编号
let apnsKeyIdentifier = "9Q98PA88U2"                                //授权码
let apnsPrivateKey = "/Users/kejibuios/Desktop/Project/ServerSide/AuthKey_9Q98PA88U2.p8"          //私有钥匙文件

//配置
NotificationPusher.addConfigurationAPNS(name: notificationsTestId,
                                        production: false, //false : dev环境    true : 生产环境
                                        keyId: apnsKeyIdentifier,
                                        teamId: apnsTeamIdentifier,
                                        privateKeyPath: apnsPrivateKey)





//HTTP服务
let networkServer = NetworkServerManager(root: "webroot", port: 8888)
networkServer.startServer()

// An example request handler.
// This 'handler' function can be referenced directly in the configuration below.
func handler(request: HTTPRequest, response: HTTPResponse) {
	// Respond with a simple message.
    response.setHeader(.contentType, value: "text/html")
    response.appendBody(string: "<html><title>Title</title><body>嘻嘻哈哈</body></html>")
    // Ensure that response.completed() is called when your processing is done.
    
    response.completed()
}




// Configuration data for an example server.
// This example configuration shows how to launch a server
// using a configuration dictionary.




let confData = [
	"servers": [
		// Configuration data for one server which:
		//	* Serves the hello world message at <host>:<port>/
		//	* Serves static files out of the "./webroot"
		//		directory (which must be located in the current working directory).
		//	* Performs content compression on outgoing data when appropriate.
		[
			"name":"localhost",
			"port":8181,
			"routes":[
				["method":"get", "uri":"/", "handler":handler],
				["method":"get", "uri":"/**", "handler":PerfectHTTPServer.HTTPHandler.staticFiles,
				 "documentRoot":"./webroot",
				 "allowResponseFilters":true]
			],
			"filters":[
				[
				"type":"response",
				"priority":"high",
				"name":PerfectHTTPServer.HTTPFilter.contentCompression,
				]
			]
		]
	]
]

do {
	// Launch the servers based on the configuration data.
	try HTTPServer.launch(configurationData: confData)
} catch {
	fatalError("\(error)") // fatal error launching one of the servers
}

