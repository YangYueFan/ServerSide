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
        UserRoutes.configure(routes: &routes)               //注册用户信息接口路由
        userConfigure(routes: &routes)                          //注册路由
        server.addRoutes(routes)                            //路由添加进服务
        
        var routes_mood = Routes.init(baseUri: "/moodApi")  //创建Mood路由器
        MoodRounts.configure(routes: &routes_mood)          //注册Mood接口路由
        server.addRoutes(routes_mood)                       //添加到服务
    
        
        var routes_Chat = Routes.init(baseUri: "/chatApi")  //创建chat路由器
        ChatRounts.configure(routes: &routes_Chat)          //注册chat接口路由
        server.addRoutes(routes_Chat)                       //添加到服务
        
        var routes_Push = Routes.init(baseUri: "/pushApi")  //创建Push路由器
        PushRoutes.configure(routes: &routes_Push)          //注册Push接口路由
        server.addRoutes(routes_Push)                       //添加到服务
        
        var routes_One = Routes.init(baseUri: "/oneApi")  //创建Push路由器
        OneRounts.configure(routes: &routes_One)          //注册Push接口路由
        server.addRoutes(routes_One)                       //添加到服务
        
        
        
//        var routes_Crawler = Routes.init(baseUri: "/pc")  //创建Push路由器
//        routes_Crawler.add(uri: "/data") { (request, response) in
//            //在请求中创建并开始爬一次
//            let pc = KCrawler.init(url: "https://m.douban.com/movie/nowintheater?loc_id=108288")
//            // 开始爬虫
//            pc.start()
//            //如果有爬到数据，就添加到Response中返回
//            response.setHeader(.contentType, value: "text/html;charset=UTF-8")
//            response.appendBody(string: pc.results.count > 0 ? pc.results : "")
//            response.completed()
//        }
//        server.addRoutes(routes_Crawler)                       //添加到服务
        
        

        
        
        server.serverPort = port                            //端口
        server.documentRoot = root                          //根目录
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
    fileprivate func userConfigure(routes: inout Routes) {

        // 添加接口,请求方式,路径

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
            handler.handleRequest(request: request, response: response)
        }
        //*********************************************************************
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
        routes.add(method: .post, uri: "/file/**") { (request, response) in
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

