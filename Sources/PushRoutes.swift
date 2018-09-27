//
//  PsuhRoutes.swift
//  ServerSide
//
//  Created by 科技部iOS on 2018/9/4.
//


import PerfectLib
import PerfectHTTP
import PerfectHTTPServer
import PerfectNotifications

class NotificationsExample {
    var deviceIds = [String]()
    
    func receiveDeviceId(request: HTTPRequest, response: HTTPResponse) {
        guard let deviceId = request.param(name: "deviceid") else {
            response.status = .badRequest
            return response.completed()
        }
        debugPrint("Adding device id:\(deviceId)")
        if !deviceIds.contains(deviceId) {
            deviceIds.append(deviceId)
        }
        try? response.setBody(json: ["msg":"success"]).completed()
    }
    
    func listDeviceIds(request: HTTPRequest, response: HTTPResponse) {
        try? response.setBody(json: ["deviceIds":self.deviceIds]).completed()
    }
    
    func notifyDevices(request: HTTPRequest, response: HTTPResponse) {
        debugPrint("Sending notification to all devices: \(deviceIds)")
        NotificationPusher(apnsTopic: notificationsTestId)
            .pushAPNS(configurationName: notificationsTestId,
                      deviceTokens: deviceIds,
                      notificationItems: [
                        .alertBody("Hello!"),
                        .sound("default")]) {
                            responses in
                            debugPrint("\(responses)")
                            response.completed()
        }
    }
}


let example = NotificationsExample()

public class PushRoutes {
    //MARK: - 注册路由
    class public func configure(routes: inout Routes) {
        

        routes.add(method: .get, uri: "/add") { (request, response) in
            PushRoutes.handle_add(request: request, response: response)
        }
        
        routes.add(method: .get, uri: "/notify") { (request, response) in
            PushRoutes.handle_notify(request: request, response: response)
        }
        
        routes.add(method: .get, uri: "/list") { (request, response) in
            PushRoutes.handle_list(request: request, response: response)
        }
        
    }
    

    static func handle_add(request : HTTPRequest ,response : HTTPResponse)  {
        example.receiveDeviceId(request: request, response: response)
    }
    

    static func handle_notify(request : HTTPRequest ,response : HTTPResponse)  {
        example.notifyDevices(request: request, response: response)
    }
    
 
    static func handle_list(request : HTTPRequest ,response : HTTPResponse)  {
        example.listDeviceIds(request: request, response: response)
    }
    
}
