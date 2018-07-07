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
        
        
        // MARK: - 获取Live
        routes.add(method: .post , uri: "/getLiveList") { (request, response) in
            LiveRounts.handle_live_GetLiveList(request: request, response: response)
        }
        
        
        // MARK: - 发布心情
        routes.add(method: .post, uri: "/issueHeart") { (request, response) in
            LiveRounts.handle_live_issueHeart(request: request, response: response)
        }
        
        
        // MARK: - 点赞
        routes.add(method: .post, uri: "/addLike") { (request, response) in
            LiveRounts.handle_live_AddLike(request: request, response: response)
        }
        
        
        // MARK: - 关注
        routes.add(method: .post, uri: "/followLiveUser") { (request, response) in
            LiveRounts.handle_Live_follow(request: request, response: response)
        }
        
        
        // MARK: - 获取单独心情
        routes.add(method: .post, uri: "/getLive") { (request, response) in
            LiveRounts.handle_Live_getAlone(request: request, response: response)
        }
        
        
        // MARK: - 获取评论
        routes.add(method: .post, uri: "/getLiveComment") { (request, response) in
            LiveRounts.handle_Live_getLiveComment(request: request, response: response)
        }
        
        // MARK: - 发布评论
        routes.add(method: .post, uri: "/addLiveComment") { (request, response) in
            LiveRounts.handle_Live_addLiveComment(request: request, response: response)
        }
        
        routes.add(method: .post, uri: "/deleteLiveComment") { (request, response) in
            LiveRounts.handle_Live_deleteLiveComment(request: request, response: response)
        }
        
        
        // MARK: - 删除心情
        routes.add(method: .post, uri: "/deleteLive") { (request, response) in
            LiveRounts.handle_Live_delete(request: request, response: response)
        }
        
        
        
        // MARK: - 所有"/liveRes"开头的URL都映射到了物理路径
        routes.add(method: .get, uri: "/liveRes/**") { (request, response) in
            // 获得符合通配符的请求路径
            request.path = request.urlVariables[routeTrailingWildcardKey]!
            
            // 用文档根目录初始化静态文件句柄
            let handler = StaticFileHandler(documentRoot: Dir(Dir.workingDir.path + "Live_File").path)
            // 用我们的根目录和路径
            // 修改集触发请求的句柄
            
            handler.handleRequest(request: request, response: response)
        }
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
    
    
    // MARK: - 处理获取Live列表
    static func handle_live_GetLiveList(request : HTTPRequest ,response : HTTPResponse)  {
        response.setHeader( .contentType, value: "text/html")          //响应头
        
        guard let userID = request.param(name: "userID") else {
            Account.returnData(response: response, status: -1, message: "缺少 userID", jsonDic: nil)
            return
        }
        //type : 0 全部 ，1 我发布的， 2 我认识的 ， 3 我收藏的
        guard let type = request.param(name: "type") else {
            Account.returnData(response: response, status: -1, message: "缺少 type", jsonDic: nil)
            return
        }
        guard let pageIndex = request.param(name: "pageIndex") else {
            Account.returnData(response: response, status: -1, message: "缺少 pageIndex", jsonDic: nil)
            return
        }
        guard let pageSize = request.param(name: "pageSize") else {
            Account.returnData(response: response, status: -1, message: "缺少 pageSize", jsonDic: nil)
            return
        }
    
        let result = DataBaseManager().custom(sqlStr: "Call getLiveList('\(userID)','\(type)','\(pageIndex)','\(pageSize)')")
        var resultArray = [Dictionary<String, String>]()
        result.mysqlResult?.forEachRow(callback: { (row) in
            var dic = [String:String]()
            dic["liveId"]           = row[0]
            dic["liveContent"]      = row[1]
            dic["livePhotosUrl"]    = row[2]
            dic["liveAddTime"]      = row[3]
            dic["liveUserId"]       = row[4]
            dic["liveVideoUrl"]     = row[5]
            dic["liveVideoImageUrl"] = row[6]
            dic["liveUserName"]     = row[7]
            dic["liveUserIcon"]     = row[8]
            dic["liveCommentNum"]   = row[9]
            dic["liveLikeNum"]      = row[10]
            dic["isMyLike"]         = row[11]
            dic["isFollowing"]      = row[12]
            resultArray.append(dic)
        })
        Account.returnData(response: response, status: 1, message: "成功", jsonDic: resultArray)
        
    }
    
    
    
    // MARK: - 发布心情
    static func handle_live_issueHeart(request : HTTPRequest ,response : HTTPResponse)  {
        response.setHeader( .contentType, value: "text/html")          //响应头
        if LiveRounts.cheakUser(request: request, response: response)  == false {
            return;
        }
        guard let content = request.param(name: "content") else {
            Account.returnData(response: response, status: -1, message: "缺少 content", jsonDic: nil)
            return
        }
        guard let type = request.param(name: "type") else {
            Account.returnData(response: response, status: -1, message: "缺少 type", jsonDic: nil)
            return
        }
        let userID = request.param(name: "userID")!
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
    
    
    // MARK: -  处理点赞或取消点赞
    static func handle_live_AddLike(request : HTTPRequest ,response : HTTPResponse) {
        response.setHeader( .contentType, value: "text/html")          //响应头
        let userID = request.param(name: "userID")!
        if LiveRounts.cheakUser(request: request, response: response)  == false {
            return;
        }
        guard let liveId = request.param(name: "liveId") else {
            Account.returnData(response: response, status: -1, message: "缺少 liveId", jsonDic: nil)
            return
        }
        guard let type = request.param(name: "type") else {
            Account.returnData(response: response, status: -1, message: "缺少 type", jsonDic: nil)
            return
        }
        
        let _ = DataBaseManager().custom(sqlStr: "Call liveAddLike('\(userID)','\(liveId)','\(type)')")
        if type == "0" {
            Account.returnData(response: response, status: 1, message: "取消点赞成功", jsonDic: nil)
        }else{
            Account.returnData(response: response, status: 1, message: "点赞成功", jsonDic: nil)
        }
    }
    
    
    // MARK: - 关注
    static func handle_Live_follow(request: HTTPRequest, response: HTTPResponse)  {
        response.setHeader( .contentType, value: "text/html")          //响应头
        let userID = request.param(name: "userID")!
        if LiveRounts.cheakUser(request: request, response: response)  == false {
            return;
        }
        guard let fUserId = request.param(name: "fUserId") else {
            Account.returnData(response: response, status: -1, message: "缺少 fUserId", jsonDic: nil)
            return
        }
        guard let type = request.param(name: "type") else {
            Account.returnData(response: response, status: -1, message: "缺少 type", jsonDic: nil)
            return
        }
        let _ = DataBaseManager().custom(sqlStr: "Call follow('\(userID)','\(fUserId)','\(type)')")
        if type == "0" {
            Account.returnData(response: response, status: 1, message: "取消关注成功", jsonDic: nil)
        }else{
            Account.returnData(response: response, status: 1, message: "关注成功", jsonDic: nil)
        }
    }
    
    // MARK: - 删除Live
    static func handle_Live_delete(request: HTTPRequest, response: HTTPResponse)  {
        response.setHeader( .contentType, value: "text/html")          //响应头
        
        if LiveRounts.cheakUser(request: request, response: response)  == false {
            return;
        }
        guard let liveID = request.param(name: "liveID") else {
            Account.returnData(response: response, status: -1, message: "缺少 liveID", jsonDic: nil)
            return
        }

        var dic = [String : String]()
        let result = DataBaseManager().custom(sqlStr: "Call getLive('\(liveID)')")
        result.mysqlResult?.forEachRow(callback: { (data) in
            dic["livePhotosUrl"]    = data[2]
            dic["liveVideoUrl"]     = data[5]
            dic["liveVideoImageUrl"] = data[6]
        })
        if dic.count > 0 {
            //删除本地资源
            LiveRounts.deletelocalRes(dic: dic)
        }
        
        let _ = DataBaseManager().custom(sqlStr: "Call deleteLive('\(liveID)')")
        Account.returnData(response: response, status: 1, message: "删除成功", jsonDic: nil)
        
    }
    
    
    // MARK: - 获取Live评论
    static func handle_Live_getLiveComment(request: HTTPRequest, response: HTTPResponse)  {
        response.setHeader( .contentType, value: "text/html")          //响应头
        if LiveRounts.cheakUser(request: request, response: response)  == false {
            return;
        }
        guard let liveID = request.param(name: "liveID") else {
            Account.returnData(response: response, status: -1, message: "缺少 liveID", jsonDic: nil)
            return
        }

        var arr = [[String : String]]()
        let result = DataBaseManager().custom(sqlStr: "Call getLiveComment('\(liveID)')")
        result.mysqlResult?.forEachRow(callback: { (data) in
            //id    liveID    content    type    toUserID    toUserName    cAddTime
            var dic = [String : String]()
            dic["cId"]          = data[0]
            dic["cUserID"]      = data[1]
            dic["cUserName"]    = data[2]
            dic["liveID"]       = data[3]
            dic["content"]      = data[4]
            dic["type"]         = data[5]
            dic["toUserID"]     = data[6]
            dic["toUserName"]   = data[7] != nil ? data[7] : ""
            dic["cAddTime"]     = data[8]
            dic["cImgUrl"]      = data[9]
            arr.append(dic)
        })
        Account.returnData(response: response, status: 1, message: "获取Live评论成功", jsonDic: arr)
    }
    
    
    // MARK: - 发布Live评论
    static func handle_Live_addLiveComment(request: HTTPRequest, response: HTTPResponse)  {
        response.setHeader( .contentType, value: "text/html")          //响应头
        if LiveRounts.cheakUser(request: request, response: response)  == false {
            return;
        }
        let userID = request.param(name: "userID")!
        guard let liveID = request.param(name: "liveID") else {
            Account.returnData(response: response, status: -1, message: "缺少 liveID", jsonDic: nil)
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
        
        //评论 1   回复 2
        let _ = type == "1" ?
            DataBaseManager().custom(sqlStr: "Call addLiveComment('\(liveID)','\(userID)','\(content)','\(type)','\("")','\("")')") :
            DataBaseManager().custom(sqlStr: "Call addLiveComment('\(liveID)','\(userID)','\(content)','\(type)','\(request.param(name: "toUserID")!)','\(request.param(name: "toUserName")!)')")
        Account.returnData(response: response, status: 1, message: "评论成功", jsonDic: nil)
    }
    
    //MARK: - 删除评论
    static func handle_Live_deleteLiveComment(request: HTTPRequest, response: HTTPResponse) {
        response.setHeader( .contentType, value: "text/html")          //响应头
        if LiveRounts.cheakUser(request: request, response: response)  == false {
            return;
        }
        guard let cID = request.param(name: "commentID") else {
            Account.returnData(response: response, status: -1, message: "缺少 commentID", jsonDic: nil)
            return
        }
        let result = DataBaseManager().custom(sqlStr: "Call deleteLiveComment('\(cID)')")
        if result.success {
            Account.returnData(response: response, status: 1, message: "成功", jsonDic: nil)
        }else{
            Account.returnData(response: response, status: 0, message: "失败", jsonDic: nil)
        }
    }
    
    
    // MARK: - 获取单独的Live
    static func handle_Live_getAlone(request: HTTPRequest, response: HTTPResponse)  {
        response.setHeader( .contentType, value: "text/html")          //响应头
        
        guard let liveID = request.param(name: "liveID") else {
            Account.returnData(response: response, status: -1, message: "缺少 liveID", jsonDic: nil)
            return
        }
        
        var dic = [String : String]()
        let result = DataBaseManager().custom(sqlStr: "Call getLive('\(liveID)')")
        result.mysqlResult?.forEachRow(callback: { (row) in
            dic["liveId"]           = row[0]
            dic["liveContent"]      = row[1]
            dic["livePhotosUrl"]    = row[2]
            dic["liveAddTime"]      = row[3]
            dic["liveUserId"]       = row[4]
            dic["liveVideoUrl"]     = row[5]
            dic["liveVideoImageUrl"] = row[6]
            dic["liveUserName"]     = row[7]
            dic["liveUserIcon"]     = row[8]
            dic["liveCommentNum"]   = row[9]
            dic["liveLikeNum"]      = row[10]
            dic["isMyLike"]         = row[11]
            dic["isFollowing"]      = row[12]
        })
        Account.returnData(response: response, status: 1, message: "成功", jsonDic: dic)
    }
    
    
    
    // MARK: -  保存头像
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
                        paths.append("liveRes/" + upload.fileName)
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
    
    // MARK : - 删除本地资源文件
    class func deletelocalRes(dic:[String:String]) {
        //如果有图片  删除图片资源
        if dic["livePhotosUrl"]!.count > 0  {
            let pathArr : [String] = dic["livePhotosUrl"]!.components(separatedBy: ",")
            for str in pathArr {
                let path = str.substring(from: String.Index.init(encodedOffset: 7))
                let file = File.init(Dir.workingDir.path + "Live_File" + path)
                file.delete()
            }
        }
        
        //如果有视频  删除视频资源
        if dic["liveVideoUrl"]!.count > 0  {
            let path = dic["liveVideoUrl"]!.substring(from: String.Index.init(encodedOffset: 7))
            let file = File.init(Dir.workingDir.path + "Live_File" + path)
            file.delete()
        }
        //如果有视频默认图片  删除默认图片
        if dic["liveVideoImageUrl"]!.count > 0  {
            let path = dic["liveVideoImageUrl"]!.substring(from: String.Index.init(encodedOffset: 7))
            let file = File.init(Dir.workingDir.path + "Live_File" + path)
            file.delete()
        }
    }
    
    // MARK: - 检测用户名ID 与Token 是否匹配 （增加安全性）token由登录接口获取
    class func cheakUser(request:HTTPRequest,response:HTTPResponse) -> Bool {
        guard let userID = request.param(name: "userID") else {
            Account.returnData(response: response, status: -1, message: "缺少 userID", jsonDic: nil)
            return false
        }
        guard let apiToken = request.param(name: "apiToken") else {
            Account.returnData(response: response, status: -1, message: "缺少 apiToken", jsonDic: nil)
            return false
        }
        if Account.checkToken(userID: userID, token: apiToken) == false{
            Account.returnData(response: response, status: -1, message: "userID/apiToken错误", jsonDic: nil)
            return false
        }
        return true
    }
    

}
