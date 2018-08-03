//
//  ChatRounts.swift
//  PerfectTemplate
//
//  Created by 科技部iOS on 2018/7/27.
//

import PerfectLib
import PerfectHTTP
import PerfectHTTPServer

public class ChatRounts {
    
    class public func  configure(routes: inout Routes) {
        // 添加接口,请求方式,路径
        
        // MARK: - 搜索
        routes.add(method: .post , uri: "/searchFriend") { (request, response) in
            response.setHeader( .contentType, value: "text/html")          //响应头
            response.setHeader(.connection, value: "Keep-alive")
            ChatRounts.handle_IM_searchFriend(request: request, response: response)
        }
        
        // MARK: - 添加好友
        routes.add(method: .post , uri: "/addFriend") { (request, response) in
            response.setHeader( .contentType, value: "text/html")          //响应头
            response.setHeader(.connection, value: "Keep-alive")
            ChatRounts.handle_IM_addFriend(request: request, response: response)
        }
        
        // MARK: - 好友列表
        routes.add(method: .post , uri: "/friendList") { (request, response) in
            response.setHeader( .contentType, value: "text/html")          //响应头
            response.setHeader(.connection, value: "Keep-alive")
            ChatRounts.handle_IM_friendList(request: request, response: response)
        }
    }
    
    // MARK: - 搜索
    class func handle_IM_searchFriend(request : HTTPRequest, response : HTTPResponse){
        
//        if MoodRounts.cheakUser(request: request, response: response)  == false {
//            return;
//        }
        guard let userID = request.param(name: "userID") else {
            Account.returnData(response: response, status: -1, message: "缺少 userID", jsonDic: nil)
            return
        }
        guard let friendPhone = request.param(name: "friendPhone") else {
            Account.returnData(response: response, status: -1, message: "缺少 friendPhone", jsonDic: nil)
            return
        }
        
        let result = DataBaseManager().custom(sqlStr: "Call searchFriend('\(friendPhone)','\(userID)')")
        var resultArray = [Dictionary<String, String>]()
        result.mysqlResult?.forEachRow(callback: { (row) in
            var dic = [String:String]()
            dic["fID"]          = row[0]
            dic["fName"]        = row[1]
            dic["fImgUrl"]      = row[2]
            dic["fPhone"]       = row[3]
            dic["fSex"]         = row[4]
            dic["fAge"]         = row[5]
            dic["fIsAdd"]       = row[6]
            resultArray.append(dic)
        })
        if resultArray.count > 0 {
            Account.returnData(response: response, status: 1, message: "成功", jsonDic: resultArray)
        }else{
            Account.returnData(response: response, status: -1, message: "没找到该用户", jsonDic: nil)
        }
    }
    // MARK: -  添加好友
    class func handle_IM_addFriend(request : HTTPRequest, response : HTTPResponse){

        guard let userID = request.param(name: "userID") else {
            Account.returnData(response: response, status: -1, message: "缺少 userID", jsonDic: nil)
            return
        }
        guard let friendID = request.param(name: "friendID") else {
            Account.returnData(response: response, status: -1, message: "缺少 friendID", jsonDic: nil)
            return
        }
        
        
        let result = DataBaseManager().custom(sqlStr: "Call addFriend('\(userID)','\(friendID)')")
        var temp = 0
        
        result.mysqlResult?.forEachRow(callback: { (row) in
            temp = Int(row[0]!)!
        })
        Account.returnData(response: response, status: temp, message: temp == 1 ? "成功":"失败", jsonDic: nil)
    }
    
    // MARK: - 好友列表
    class func handle_IM_friendList (request : HTTPRequest, response : HTTPResponse){
        guard let userID = request.param(name: "userID") else {
            Account.returnData(response: response, status: -1, message: "缺少 userID", jsonDic: nil)
            return
        }

        let result = DataBaseManager().custom(sqlStr: "Call friendList('\(userID)'")
        var resultArray = [Dictionary<String, String>]()
        result.mysqlResult?.forEachRow(callback: { (row) in
            var dic = [String:String]()
            dic["fUserID"]      = row[0]
            dic["fName"]        = row[1]
            dic["fImgUrl"]      = row[2]
            dic["fPhone"]       = row[3]
            dic["fSex"]         = row[4]
            dic["fAge"]         = row[5]
            resultArray.append(dic)
        })
        Account.returnData(response: response, status: 1, message: "成功", jsonDic: resultArray)
    }
    
}
