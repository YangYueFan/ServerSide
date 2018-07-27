//
//  MoodRounts.swift
//  PerfectTemplate
//
//  Created by 科技部iOS on 2018/6/8.
//
import PerfectLib
import PerfectHTTP
import PerfectHTTPServer

public class MoodRounts {
    
    static let table_Mood           = "Mood"
    static let table_MoodComment    = "MoodComment"
    static let table_MoodLike       = "MoodLike"
    //MARK: 注册路由
    class public func configure(routes: inout Routes) {
        // 添加接口,请求方式,路径
        
        
        // MARK: - 获取Mood
        routes.add(method: .post , uri: "/getMoodList") { (request, response) in
            MoodRounts.handle_mood_GetMoodList(request: request, response: response)
        }
        
        
        // MARK: - 发布心情
        routes.add(method: .post, uri: "/issueHeart") { (request, response) in
            MoodRounts.handle_mood_issueHeart(request: request, response: response)
        }
        
        
        // MARK: - 点赞
        routes.add(method: .post, uri: "/addLike") { (request, response) in
            MoodRounts.handle_mood_AddLike(request: request, response: response)
        }
        
        
        // MARK: - 关注
        routes.add(method: .post, uri: "/followMoodUser") { (request, response) in
            MoodRounts.handle_Mood_follow(request: request, response: response)
        }
        
        
        // MARK: - 获取单独心情
        routes.add(method: .post, uri: "/getMood") { (request, response) in
            MoodRounts.handle_Mood_getAlone(request: request, response: response)
        }
        
        
        // MARK: - 获取评论
        routes.add(method: .post, uri: "/getMoodComment") { (request, response) in
            MoodRounts.handle_Mood_getMoodComment(request: request, response: response)
        }
        
        // MARK: - 发布评论
        routes.add(method: .post, uri: "/addMoodComment") { (request, response) in
            MoodRounts.handle_Mood_addMoodComment(request: request, response: response)
        }
        
        routes.add(method: .post, uri: "/deleteMoodComment") { (request, response) in
            MoodRounts.handle_Mood_deleteMoodComment(request: request, response: response)
        }
        
        
        // MARK: - 删除心情
        routes.add(method: .post, uri: "/deleteMood") { (request, response) in
            MoodRounts.handle_Mood_delete(request: request, response: response)
        }
        // MARK: - 获取用户主页信息
        routes.add(method: .post, uri: "/getMoodUserInfo") { (request, response) in
            MoodRounts.handle_Mood_getMoodUserInfo(request: request, response: response)
        }
        
        
        
        // MARK: - 所有"/moodRes"开头的URL都映射到了物理路径
        routes.add(method: .get, uri: "/moodRes/**") { (request, response) in
            // 获得符合通配符的请求路径
            request.path = request.urlVariables[routeTrailingWildcardKey]!
            
            // 用文档根目录初始化静态文件句柄
            let handler = StaticFileHandler(documentRoot: Dir(Dir.workingDir.path + "Mood_File").path)
            // 用我们的根目录和路径
            // 修改集触发请求的句柄
            
            handler.handleRequest(request: request, response: response)
        }
        routes.add(method: .post, uri: "/moodRes/**") { (request, response) in
            // 获得符合通配符的请求路径
            request.path = request.urlVariables[routeTrailingWildcardKey]!
            
            // 用文档根目录初始化静态文件句柄
            let handler = StaticFileHandler(documentRoot: Dir(Dir.workingDir.path + "Mood_File").path)
            // 用我们的根目录和路径
            // 修改集触发请求的句柄
            
            handler.handleRequest(request: request, response: response)
        }
    }
    
    
    // MARK: - 处理获取Mood列表
    static func handle_mood_GetMoodList(request : HTTPRequest ,response : HTTPResponse)  {
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
        var myId = request.param(name: "myId")
        if myId == nil {
            myId = userID
        }
    
        let result = DataBaseManager().custom(sqlStr: "Call getMoodList('\(userID)','\(type)','\(pageIndex)','\(pageSize)','\(myId!)')")
        var resultArray = [Dictionary<String, String>]()
        result.mysqlResult?.forEachRow(callback: { (row) in
            var dic = [String:String]()
            dic["moodId"]           = row[0]
            dic["moodContent"]      = row[1]
            dic["moodPhotosUrl"]    = row[2]
            dic["moodAddTime"]      = row[3]
            dic["moodUserId"]       = row[4]
            dic["moodVideoUrl"]     = row[5]
            dic["moodVideoImageUrl"] = row[6]
            dic["moodUserName"]     = row[7]
            dic["moodUserIcon"]     = row[8]
            dic["moodCommentNum"]   = row[9]
            dic["moodLikeNum"]      = row[10]
            dic["isMyLike"]         = row[11]
            dic["isFollowing"]      = row[12]
            resultArray.append(dic)
        })
        Account.returnData(response: response, status: 1, message: "成功", jsonDic: resultArray)
        
    }
    
    
    
    // MARK: - 发布心情
    static func handle_mood_issueHeart(request : HTTPRequest ,response : HTTPResponse)  {
        response.setHeader( .contentType, value: "text/html")          //响应头
        if MoodRounts.cheakUser(request: request, response: response)  == false {
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
            let path = MoodRounts.saveMoodRes(request: request,userId: userID)
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
    static func handle_mood_AddLike(request : HTTPRequest ,response : HTTPResponse) {
        response.setHeader( .contentType, value: "text/html")          //响应头
        let userID = request.param(name: "userID")!
        if MoodRounts.cheakUser(request: request, response: response)  == false {
            return;
        }
        guard let moodId = request.param(name: "moodId") else {
            Account.returnData(response: response, status: -1, message: "缺少 moodId", jsonDic: nil)
            return
        }
        guard let type = request.param(name: "type") else {
            Account.returnData(response: response, status: -1, message: "缺少 type", jsonDic: nil)
            return
        }
        
        let _ = DataBaseManager().custom(sqlStr: "Call moodAddLike('\(userID)','\(moodId)','\(type)')")
        if type == "0" {
            Account.returnData(response: response, status: 1, message: "取消点赞成功", jsonDic: nil)
        }else{
            Account.returnData(response: response, status: 1, message: "点赞成功", jsonDic: nil)
        }
    }
    
    
    // MARK: - 关注
    static func handle_Mood_follow(request: HTTPRequest, response: HTTPResponse)  {
        response.setHeader( .contentType, value: "text/html")          //响应头
        let userID = request.param(name: "userID")!
        if MoodRounts.cheakUser(request: request, response: response)  == false {
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
    
    // MARK: - 删除Mood
    static func handle_Mood_delete(request: HTTPRequest, response: HTTPResponse)  {
        response.setHeader( .contentType, value: "text/html")          //响应头
        
        if MoodRounts.cheakUser(request: request, response: response)  == false {
            return;
        }
        guard let moodID = request.param(name: "moodID") else {
            Account.returnData(response: response, status: -1, message: "缺少 moodID", jsonDic: nil)
            return
        }

        var dic = [String : String]()
        let result = DataBaseManager().custom(sqlStr: "Call getMood('\(moodID)')")
        result.mysqlResult?.forEachRow(callback: { (data) in
            dic["moodPhotosUrl"]    = data[2]
            dic["moodVideoUrl"]     = data[5]
            dic["moodVideoImageUrl"] = data[6]
        })
        if dic.count > 0 {
            //删除本地资源
            MoodRounts.deletelocalRes(dic: dic)
        }
        
        let _ = DataBaseManager().custom(sqlStr: "Call deleteMood('\(moodID)')")
        Account.returnData(response: response, status: 1, message: "删除成功", jsonDic: nil)
        
    }
    
    
    // MARK: - 获取Mood评论
    static func handle_Mood_getMoodComment(request: HTTPRequest, response: HTTPResponse)  {
        response.setHeader( .contentType, value: "text/html")          //响应头
        if MoodRounts.cheakUser(request: request, response: response)  == false {
            return;
        }
        guard let moodID = request.param(name: "moodID") else {
            Account.returnData(response: response, status: -1, message: "缺少 moodID", jsonDic: nil)
            return
        }

        var arr = [[String : String]]()
        let result = DataBaseManager().custom(sqlStr: "Call getMoodComment('\(moodID)')")
        result.mysqlResult?.forEachRow(callback: { (data) in
            //id    moodID    content    type    toUserID    toUserName    cAddTime
            var dic = [String : String]()
            dic["cId"]          = data[0]
            dic["cUserID"]      = data[1]
            dic["cUserName"]    = data[2]
            dic["moodID"]       = data[3]
            dic["content"]      = data[4]
            dic["type"]         = data[5]
            dic["toUserID"]     = data[6]
            dic["toUserName"]   = data[7] != nil ? data[7] : ""
            dic["cAddTime"]     = data[8]
            dic["cImgUrl"]      = data[9]
            arr.append(dic)
        })
        Account.returnData(response: response, status: 1, message: "获取Mood评论成功", jsonDic: arr)
    }
    
    
    // MARK: - 发布Mood评论
    static func handle_Mood_addMoodComment(request: HTTPRequest, response: HTTPResponse)  {
        response.setHeader( .contentType, value: "text/html")          //响应头
        if MoodRounts.cheakUser(request: request, response: response)  == false {
            return;
        }
        let userID = request.param(name: "userID")!
        guard let moodID = request.param(name: "moodID") else {
            Account.returnData(response: response, status: -1, message: "缺少 moodID", jsonDic: nil)
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
            DataBaseManager().custom(sqlStr: "Call addMoodComment('\(moodID)','\(userID)','\(content)','\(type)','\("")','\("")')") :
            DataBaseManager().custom(sqlStr: "Call addMoodComment('\(moodID)','\(userID)','\(content)','\(type)','\(request.param(name: "toUserID")!)','\(request.param(name: "toUserName")!)')")
        Account.returnData(response: response, status: 1, message: "评论成功", jsonDic: nil)
    }
    
    //MARK: - 删除评论
    static func handle_Mood_deleteMoodComment(request: HTTPRequest, response: HTTPResponse) {
        response.setHeader( .contentType, value: "text/html")          //响应头
        if MoodRounts.cheakUser(request: request, response: response)  == false {
            return;
        }
        guard let cID = request.param(name: "commentID") else {
            Account.returnData(response: response, status: -1, message: "缺少 commentID", jsonDic: nil)
            return
        }
        let result = DataBaseManager().custom(sqlStr: "Call deleteMoodComment('\(cID)')")
        if result.success {
            Account.returnData(response: response, status: 1, message: "成功", jsonDic: nil)
        }else{
            Account.returnData(response: response, status: 0, message: "失败", jsonDic: nil)
        }
    }
    
    
    // MARK: - 获取单独的Mood
    static func handle_Mood_getAlone(request: HTTPRequest, response: HTTPResponse)  {
        response.setHeader( .contentType, value: "text/html")          //响应头
        
        guard let moodID = request.param(name: "moodID") else {
            Account.returnData(response: response, status: -1, message: "缺少 moodID", jsonDic: nil)
            return
        }
        
        var dic = [String : String]()
        let result = DataBaseManager().custom(sqlStr: "Call getMood('\(moodID)')")
        result.mysqlResult?.forEachRow(callback: { (row) in
            dic["moodId"]           = row[0]
            dic["moodContent"]      = row[1]
            dic["moodPhotosUrl"]    = row[2]
            dic["moodAddTime"]      = row[3]
            dic["moodUserId"]       = row[4]
            dic["moodVideoUrl"]     = row[5]
            dic["moodVideoImageUrl"] = row[6]
            dic["moodUserName"]     = row[7]
            dic["moodUserIcon"]     = row[8]
            dic["moodCommentNum"]   = row[9]
            dic["moodLikeNum"]      = row[10]
            dic["isMyLike"]         = row[11]
            dic["isFollowing"]      = row[12]
        })
        Account.returnData(response: response, status: 1, message: "成功", jsonDic: dic)
    }
    
    // MARK: - 获取用户主页信息
    class func handle_Mood_getMoodUserInfo(request: HTTPRequest, response: HTTPResponse) {
        guard let userID = request.param(name: "userID") else {
            Account.returnData(response: response, status: -1, message: "缺少 userID", jsonDic: nil)
            return
        }
        var dic = [String : String]()
        let result = DataBaseManager().custom(sqlStr: "Call getMoodUserInfo('\(userID)')")
        result.mysqlResult?.forEachRow(callback: { (row) in
            dic["userId"]           = userID
            dic["userName"]         = row[0]
            dic["imgUrl"]           = row[1]
            dic["LikeCount"]        = row[2]
            dic["FollowCount"]     = row[3]
            dic["MoodCount"]        = row[4]
        })
        Account.returnData(response: response, status: 1, message: "成功", jsonDic: dic)
    }
    
    
    
    // MARK: -  保存头像
    class func saveMoodRes(request:HTTPRequest,userId:String) -> String {
        // 通过操作fileUploads数组来掌握文件上传的情况
        // 如果这个POST请求不是分段multi-part类型，则该数组内容为空
        if let uploads = request.postFileUploads, uploads.count > 0 {
            // 创建路径用于存储已上传文件
            let fileDir = Dir(Dir.workingDir.path + "Mood_File")
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
                        paths.append("moodRes/" + upload.fileName)
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
        if dic["moodPhotosUrl"]!.count > 0  {
            let pathArr : [String] = dic["moodPhotosUrl"]!.components(separatedBy: ",")
            for str in pathArr {
                let path = str.substring(from: String.Index.init(encodedOffset: 7))
                let file = File.init(Dir.workingDir.path + "Mood_File" + path)
                file.delete()
            }
        }
        
        //如果有视频  删除视频资源
        if dic["moodVideoUrl"]!.count > 0  {
            let path = dic["moodVideoUrl"]!.substring(from: String.Index.init(encodedOffset: 7))
            let file = File.init(Dir.workingDir.path + "Mood_File" + path)
            file.delete()
        }
        //如果有视频默认图片  删除默认图片
        if dic["moodVideoImageUrl"]!.count > 0  {
            let path = dic["moodVideoImageUrl"]!.substring(from: String.Index.init(encodedOffset: 7))
            let file = File.init(Dir.workingDir.path + "Mood_File" + path)
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
