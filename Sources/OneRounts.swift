//
//  OneRounts.swift
//  ServerSide
//
//  Created by 科技部iOS on 2018/9/27.
//
import PerfectLib
import PerfectHTTP
import PerfectHTTPServer

public class OneRounts {
    
    //MARK: 注册路由
    class public func configure(routes: inout Routes) {
        routes.add(uri: "/OneLike") { (request, response) in
            OneRounts.handle_One_Like(request: request, response: response)
        }
        
        routes.add(uri: "/addOneComment") { (request, response) in
            OneRounts.handle_One_addComment(request: request, response: response)
        }
        
        routes.add(uri: "/getOneData") { (request, response) in
            OneRounts.handle_One_getData(request: request, response: response)
        }
    }
    
    
    class func handle_One_Like(request : HTTPRequest ,response : HTTPResponse) {
        guard let userID = request.param(name: "userID") else {
            Account.returnData(response: response, status: -1, message: "缺少 userID", jsonDic: nil)
            return
        }
        
        guard let oneID = request.param(name: "oneID") else {
            Account.returnData(response: response, status: -1, message: "缺少 oneID", jsonDic: nil)
            return
        }
        
        let result = DataBaseManager().custom(sqlStr: "Call changeOneLike('\(userID)','\(oneID)')")
        if result.success {
            Account.returnData(response: response, status: 1, message: "成功", jsonDic: nil)
        }else{
            Account.returnData(response: response, status: -1, message: "失败", jsonDic: nil)
        }
        
    }
    
    
    
    class func handle_One_addComment(request : HTTPRequest ,response : HTTPResponse) {
        guard let userID = request.param(name: "userID") else {
            Account.returnData(response: response, status: -1, message: "缺少 userID", jsonDic: nil)
            return
        }
        
        guard let oneID = request.param(name: "oneID") else {
            Account.returnData(response: response, status: -1, message: "缺少 oneID", jsonDic: nil)
            return
        }
        
        guard let comment = request.param(name: "comment") else {
            Account.returnData(response: response, status: -1, message: "缺少 comment", jsonDic: nil)
            return
        }
        
        let result = DataBaseManager().custom(sqlStr: "Call addOneComment('\(oneID)','\(userID)','\(comment)')")
        if result.success {
            Account.returnData(response: response, status: 1, message: "成功", jsonDic: nil)
        }else{
            Account.returnData(response: response, status: -1, message: "失败", jsonDic: nil)
        }
        
    }
    
    
    class func handle_One_getData(request : HTTPRequest ,response : HTTPResponse) {
        guard let userID = request.param(name: "userID") else {
            Account.returnData(response: response, status: -1, message: "缺少 userID", jsonDic: nil)
            return
        }
        
        guard let oneID = request.param(name: "oneID") else {
            Account.returnData(response: response, status: -1, message: "缺少 oneID", jsonDic: nil)
            return
        }
        var commentArr = [[String:String]]()
        
        let result1 = DataBaseManager().custom(sqlStr: "Call getOneData('\(oneID)','\(userID)')")
        result1.mysqlResult?.forEachRow(callback: { (data) in
//            debugPrint(data)
            var dic = [String:String]()
            dic["id"] = data[0]
            dic["oneID"] = data[1]
            dic["userID"] = data[2]
            dic["commentText"] = data[3]
            dic["iconUrl"] = data[5]
            commentArr.append(dic)
        })
        var dataDic = [String:Any]()
        
        let result2 = DataBaseManager().custom(sqlStr: "Call getOneLike('\(oneID)','\(userID)')")
        result2.mysqlResult?.forEachRow(callback: { (data) in
//            debugPrint(data)
            dataDic["isMyLike"] = data[0]
            dataDic["likeNum"] = data[1]
        })
        dataDic["commentArr"] = commentArr
        Account.returnData(response: response, status: 1, message: "成功", jsonDic: dataDic)
    }
}
