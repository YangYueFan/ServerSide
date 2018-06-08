//
//  LiveRounts.swift
//  PerfectTemplate
//
//  Created by 科技部iOS on 2018/6/8.
//
import PerfectLib
import PerfectHTTP
import PerfectHTTPServer

public class LiveRounts {
    
    static let table_Live           = "Live"
    static let table_LiveComment    = "LiveComment"
    static let table_LiveLike       = "LiveLike"
    //MARK: 注册路由
    class public func configure(routes: inout Routes) {
        // 添加接口,请求方式,路径
        
        //*********************************************************************
        // 获取Live
        routes.add(method: .get , uri: "/getLiveList") { (request, response) in
            LiveRounts.handle_live_GetLiveList(request: request, response: response)
        }
        routes.add(method: .post , uri: "/getLiveList") { (request, response) in
            LiveRounts.handle_live_GetLiveList(request: request, response: response)
        }
        
        //*********************************************************************
        routes.add(method: .post, uri: "/issueHeart") { (request, response) in
            LiveRounts.handle_live_issueHeart(request: request, response: response)
        }
        
        //*********************************************************************
        //所有"/liveRes"开头的URL都映射到了物理路径
        routes.add(method: .get, uri: "/liveRes/**") { (request, response) in
            // 获得符合通配符的请求路径
            request.path = request.urlVariables[routeTrailingWildcardKey]!
            
            // 用文档根目录初始化静态文件句柄
            let handler = StaticFileHandler(documentRoot: Dir(Dir.workingDir.path + "Live_File").path)
            // 用我们的根目录和路径
            // 修改集触发请求的句柄
            
            handler.handleRequest(request: request, response: response)
        }
        //所有"/res"开头的URL都映射到了物理路径
        routes.add(method: .post, uri: "/liveRes/**") { (request, response) in
            // 获得符合通配符的请求路径
            request.path = request.urlVariables[routeTrailingWildcardKey]!
            
            // 用文档根目录初始化静态文件句柄
            let handler = StaticFileHandler(documentRoot: Dir(Dir.workingDir.path + "Live_File").path)
            // 用我们的根目录和路径
            // 修改集触发请求的句柄
            
            handler.handleRequest(request: request, response: response)
        }
    }
    
    static func handle_live_GetLiveList(request : HTTPRequest ,response : HTTPResponse)  {
        response.setHeader( .contentType, value: "text/html")          //响应头
        
        guard let userID = request.param(name: "userID") else {
            Account.returnData(response: response, status: -1, message: "缺少 userID", jsonDic: nil)
            return
        }
        guard let apiToken = request.param(name: "apiToken") else {
            Account.returnData(response: response, status: -1, message: "缺少 apiToken", jsonDic: nil)
            return
        }
        if Account.checkToken(userID: userID, token: apiToken) == false{
            Account.returnData(response: response, status: -1, message: "userAccount/apiToken错误", jsonDic: nil)
            return
        }
        
        //type : 0 全部 ，1 我发布的， 2 我认识的 ， 3 我收藏的
        guard let type = request.param(name: "type") else {
            Account.returnData(response: response, status: -1, message: "缺少 type", jsonDic: nil)
            return
        }
        let result = DataBaseManager().custom(sqlStr: "Call getLiveList('\(userID)','\(type)')")
        var resultArray = [Dictionary<String, String>]()
        result.mysqlResult?.forEachRow(callback: { (row) in
            var dic = [String:String]()
            dic["liveId"] = row[0]
            dic["liveContent"] = row[1]
            dic["livePhotosUrl"] = row[2]
            dic["liveAddTime"] = row[3]
            dic["liveVideoUrl"] = row[4]
            dic["liveVideoImageUrl"] = row[5]
            resultArray.append(dic)
        })
        Account.returnData(response: response, status: 1, message: "成功", jsonDic: resultArray)
        
    }
    
    
    static func handle_live_issueHeart(request : HTTPRequest ,response : HTTPResponse)  {
        response.setHeader( .contentType, value: "text/html")          //响应头
        
        guard let userID = request.param(name: "userID") else {
            Account.returnData(response: response, status: -1, message: "缺少 userID", jsonDic: nil)
            return
        }
        guard let apiToken = request.param(name: "apiToken") else {
            Account.returnData(response: response, status: -1, message: "缺少 apiToken", jsonDic: nil)
            return
        }
        if Account.checkToken(userID: userID, token: apiToken) == false{
            Account.returnData(response: response, status: -1, message: "userAccount/apiToken错误", jsonDic: nil)
            return
        }
        guard let content = request.param(name: "content") else {
            Account.returnData(response: response, status: -1, message: "缺少 content", jsonDic: nil)
            return
        }
        guard let type = request.param(name: "type") else {
            Account.returnData(response: response, status: -1, message: "缺少 type", jsonDic: nil)
            return
        }
        
        
        if type == "1" {
            let result = DataBaseManager().custom(sqlStr: "Call issueHeart('\(userID)','\(content)','\("")','\("")','\("")')")
            if result.success {
                Account.returnData(response: response, status: 1, message: "上传成功", jsonDic: nil)
            }else{
                Account.returnData(response: response, status: -1, message: "上传失败", jsonDic: nil)
            }
        }else if type == "2"{
            //保存图片、视频资源
            let path = LiveRounts.saveLiveRes(request: request,userId: userID)
            if path == "" {
                Account.returnData(response: response, status: -1, message: "上传失败", jsonDic: nil)
                return
            }else{
                let result = DataBaseManager().custom(sqlStr: "Call issueHeart('\(userID)','\(content)','\(path)','\("")','\("")')")
                if result.success {
                    Account.returnData(response: response, status: 1, message: "上传成功", jsonDic: nil)
                }else{
                    Account.returnData(response: response, status: -1, message: "上传失败", jsonDic: nil)
                }
            }
        }
    }
    
    
    
    
    
    
    /// 保存头像
    ///
    /// - Parameters:
    ///   - request:
    ///   - userAccount: 用户名
    /// - Returns: 图片路径 或 ""
    class func saveLiveRes(request:HTTPRequest,userId:String) -> String {
        // 通过操作fileUploads数组来掌握文件上传的情况
        // 如果这个POST请求不是分段multi-part类型，则该数组内容为空
        
        if let uploads = request.postFileUploads, uploads.count > 0 {
            
            // 创建路径用于存储已上传文件
            let fileDir = Dir(Dir.workingDir.path + "Live_File")
            do {
                try fileDir.create()
            } catch {
                print(error)
            }
            
            var paths = [String]()
            for upload in uploads{
                
                let thisFile = File(upload.tmpFileName) //临时位置
                do {
                    // 将文件转移走，如果目标位置已经有同名文件则进行覆盖操作。
                    let file = try thisFile.moveTo(path: fileDir.path + upload.fileName, overWrite: true)
                    if file.path.count > 0 {
                        paths.append("/liveRes/" + upload.fileName)
                    }else{
                        return ""
                    }
                } catch {
                    print(error)
                }
            }
            return paths.joined(separator: ",")
        }
        return ""
    }

}
