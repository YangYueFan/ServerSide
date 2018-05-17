//
//  HTTPServer.swift
//  PerfectTemplatePackageDescription
//
//  Created by 科技部iOS on 2018/3/29.
//

import PerfectLib
import PerfectHTTP
import PerfectHTTPServer

open class NetworkServerManager {
    
    fileprivate var server: HTTPServer
    internal init(root: String, port: UInt16) {
        
        server = HTTPServer.init()                          //创建HTTPServer服务器
        var routes = Routes.init(baseUri: "/api")           //创建路由器
        configure(routes: &routes)                          //注册路由
        server.addRoutes(routes)                            //路由添加进服务
        server.serverPort = port                            //端口
        server.documentRoot = root                          //根目录
        server.serverName = "localhost"
        server.setResponseFilters([(Filter404(), .high)])   //404过滤
    
        
    }
    
    //MARK: 开启服务
    open func startServer() {
        
        do {
            print("启动HTTP服务器")
            try server.start()
        } catch PerfectError.networkError(let err, let msg) {
            print("网络出现错误：\(err) \(msg)")
        } catch {
            print("网络未知错误")
        }
        
    }
    
    //MARK: 注册路由
    fileprivate func configure(routes: inout Routes) {

        // 添加接口,请求方式,路径

        //*********************************************************************
        // 登录get
        routes.add(method: .get , uri: "/userLogin") { (request, response) in
            Account.handle_User_Login(request: request, response: response)
        }
        // 登录post
        routes.add(method: .post , uri: "/userLogin") { (request, response) in
            Account.handle_User_Login(request: request, response: response)
        }
        
        
        
        //*********************************************************************
        // 获取验证码get
        routes.add(method: .get, uri: "/userGetCode") { (request, response) in
            Account.handle_User_GetCode(request: request, response: response)
        }
        // 获取验证码post
        routes.add(method: .post, uri: "/userGetCode") { (request, response) in
            Account.handle_User_GetCode(request: request, response: response)
        }
        
        
        
        
        //*********************************************************************
        // 注册get
        routes.add(method: .get, uri: "/userRegister") { (request, response) in
            Account.handle_User_Register(request: request, response: response)
        }
        // 注册post
        routes.add(method: .post, uri: "/userRegister") { (request, response) in
            Account.handle_User_Register(request: request, response: response)
        }
        
        
        
        
        //*********************************************************************
        // 上传头像post
        routes.add(method: .post, uri: "/uploadIcon") { (request, response) in
            Account.handle_User_UploadIcon(request: request, response: response)
        }
        

        
        
        //*********************************************************************
        //所有"/res"开头的URL都映射到了物理路径  
        routes.add(method: .get, uri: "/res/**") { (request, response) in
            // 获得符合通配符的请求路径
            request.path = request.urlVariables[routeTrailingWildcardKey]!
            
            // 用文档根目录初始化静态文件句柄
            let handler = StaticFileHandler(documentRoot: Dir(Dir.workingDir.path + "IMG_Files").path)
            // 用我们的根目录和路径
            // 修改集触发请求的句柄

            handler.handleRequest(request: request, response: response)
        }
        
        //所有"/res"开头的URL都映射到了物理路径
        routes.add(method: .post, uri: "/res/**") { (request, response) in
            // 获得符合通配符的请求路径
            request.path = request.urlVariables[routeTrailingWildcardKey]!
            
            // 用文档根目录初始化静态文件句柄
            let handler = StaticFileHandler(documentRoot: Dir(Dir.workingDir.path + "IMG_Files").path)
            // 用我们的根目录和路径
            // 修改集触发请求的句柄
            print(Dir(Dir.workingDir.path + "file/HTML").path)
            handler.handleRequest(request: request, response: response)
        }
        routes.add(method: .get, uri: "/file/**") { (request, response) in
            // 获得符合通配符的请求路径
            request.path = request.urlVariables[routeTrailingWildcardKey]!
            print(Dir(Dir.workingDir.path + "file/HTML").path)
            // 用文档根目录初始化静态文件句柄
            let handler = StaticFileHandler(documentRoot: Dir(Dir.workingDir.path + "file/HTML").path)
            // 用我们的根目录和路径
            // 修改集触发请求的句柄
            handler.handleRequest(request: request, response: response)
        }
        
        
        //*********************************************************************
        
        routes.add(method: .post, uri: "/getHomeData") { (request, response) in
            Account.handle_Get_Items(request: request, response: response)
        }
        routes.add(method: .get, uri: "/getHomeData") { (request, response) in
            Account.handle_Get_Items(request: request, response: response)
        }
        
    }
    
    //MARK: 通用响应格式
    func baseResponseBodyJSONData(status: Int, message: String, data: Any!) -> Dictionary<String, Any> {
        
        var result = Dictionary<String, Any>()
        result.updateValue(status, forKey: "status")
        result.updateValue(message, forKey: "message")
        if (data != nil) {
            result.updateValue(data, forKey: "data")
        }else{
            result.updateValue("", forKey: "data")
        }
        return result
        
    }
    
    //MARK: 通用响应格式
    class func baseResponseBodyJSON(status: Int, message: String, data: Any!) -> Dictionary<String, Any> {
        
        var result = Dictionary<String, Any>()
        result.updateValue(status, forKey: "status")
        result.updateValue(message, forKey: "message")
        if (data != nil) {
            result.updateValue(data, forKey: "data")
        }else{
            result.updateValue("", forKey: "data")
        }
        return result
        
    }
    
    //MARK: 404过滤
    struct Filter404: HTTPResponseFilter {
        
        func filterBody(response: HTTPResponse, callback: (HTTPResponseFilterResult) -> ()) {
            callback(.continue)
        }
        
        func filterHeaders(response: HTTPResponse, callback: (HTTPResponseFilterResult) -> ()) {
            if case .notFound = response.status {
                response.setBody(string: "404 file \"\(response.request.path)\" not found ")
                response.setHeader(.contentLength, value: "\(response.bodyBytes.count)")
                callback(.done)
                
            } else {
                callback(.continue)
            }
        }
        
    }
    
}

