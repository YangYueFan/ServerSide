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

    
    /// 注册推送
    ///
    /// - Parameters:
    ///   - request: <#request description#>
    ///   - response: <#response description#>
    class func receiveDeviceId(request: HTTPRequest, response: HTTPResponse) {
        guard let deviceId = request.param(name: "deviceid") else {
            response.status = .badRequest
            return response.completed()
        }
        guard let userAccount = request.param(name: "userAccount") else {
            response.status = .badRequest
            return response.completed()
        }
        
        let result = DataBaseManager().custom(sqlStr: "Call addPushDevice('\(deviceId)','\(userAccount)')")
        if result.success {
            debugPrint("Adding device id:" + deviceId + " account:" + userAccount)
            Account.returnData(response: response, status: 0, message: "成功", jsonDic: nil)
        }else{
            Account.returnData(response: response, status: -1, message: "失败", jsonDic: nil)
        }
        
        
        
    }
    
    
    
    /// 获取推送ID
    ///
    /// - Parameters:
    ///   - request: <#request description#>
    ///   - response: <#response description#>
    class func listDeviceIds(request: HTTPRequest, response: HTTPResponse) {
        let userAccount = request.param(name: "userAccount")
        if (userAccount != nil) {
            let result = DataBaseManager().custom(sqlStr: "SELECT * FROM Push_Device WHERE userPhone = '" + userAccount! + "')")
            if result.success {
                Account.returnData(response: response, status: 0, message: "成功", jsonDic: nil)
            }else{
                Account.returnData(response: response, status: -1, message: "失败", jsonDic: nil)
            }
        }else{
            let result = DataBaseManager().custom(sqlStr: "SELECT id,deviceID,userPhone,userID FROM Push_Device")
            var arr = [[String:String]]()
            result.mysqlResult?.forEachRow(callback: { (data) in
                var dic = [String:String]()
                dic["id"] = data[0]
                dic["deviceID"] = data[1]
                dic["account"] = data[2]
                dic["userID"] = data[3]
                arr.append(dic)
            })
             Account.returnData(response: response, status: 0, message: "成功", jsonDic: arr)
        }
    }
    
    
    
    /// 推送到设备
    ///
    /// - Parameters:
    ///   - request: <#request description#>
    ///   - response: <#response description#>
    class func notifyDevices(request: HTTPRequest, response: HTTPResponse) {
        guard let deviceIds = request.param(name: "deviceIds") else {
            Account.returnData(response: response, status: -1, message: "缺少 deviceIds 参数", jsonDic: nil)
            return
        }
        var notifBody = "Hello!"
        let title = request.param(name: "title")
        if  title != nil {
            notifBody = title!
        }
        
        debugPrint("Sending notification to all devices: \(deviceIds)")
        let arr = deviceIds.components(separatedBy: ",")
        
        var url = request.param(name: "url")
        if url != nil {
            if url!.hasPrefix("http") == false {
                url = "http://47.100.98.169:8888/api/res/" + url!
            }
        }
            
        NotificationPusher(apnsTopic: notificationsTestId)
            .pushAPNS(configurationName: notificationsTestId,
                      deviceTokens: arr,
                      notificationItems: [.alertBody(notifBody),
                                          .sound("default"),
                                          .mutableContent,
                                          .badge(1),
                                          .alertLaunchImage(url == nil ? "" : url! ),
                                          .category("myNotificationCategory")])
            { (responses) in
                debugPrint("\(responses)")
                response.completed()
        }
        
        
        
    }
}




public class Rounts_Push {
    //MARK: - 注册路由
    class public func configure(routes: inout Routes) {
        

        routes.add(method: .get, uri: "/add") { (request, response) in
            Rounts_Push.handle_add(request: request, response: response)
        }
        
        routes.add(method: .get, uri: "/notify") { (request, response) in
            Rounts_Push.handle_Push(request: request, response: response)
        }
        
        routes.add(method: .get, uri: "/list") { (request, response) in
            Rounts_Push.handle_list(request: request, response: response)
        }
        
    }
    

    static func handle_add(request : HTTPRequest ,response : HTTPResponse)  {
        NotificationsExample.receiveDeviceId(request: request, response: response)
    }
    

    static func handle_Push(request : HTTPRequest ,response : HTTPResponse)  {
        NotificationsExample.notifyDevices(request: request, response: response)
    }
    
 
    static func handle_list(request : HTTPRequest ,response : HTTPResponse)  {
        NotificationsExample.listDeviceIds(request: request, response: response)
    }
    
}
