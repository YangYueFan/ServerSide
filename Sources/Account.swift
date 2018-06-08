//
//  Account.swift
//  PerfectTemplate
//
//  Created by 科技部iOS on 2018/4/11.
//

import PerfectLib
import PerfectHTTP
import PerfectHTTPServer
import Foundation



//账号处理
open class Account{
    
    static let table_account = "UserInfo"
    
    // 处理User登录
    static func handle_User_Login (request : HTTPRequest ,response : HTTPResponse){
        //标配
        var status = 1
        var message = "成功"
        var jsonDic = [String:Any]()
        response.setHeader( .contentType, value: "text/html")          //响应头
        
        //获取登录信息
        guard let userAccount = request.param(name: "userAccount") else {
            status = -1
            message = "请输入正确手机号码"
            jsonDic = [String:Any]()
            Account.returnData(response: response, status: status, message: message, jsonDic: jsonDic)
            return
        }
        guard let userPassword = request.param(name: "userPassword") else {
            status = -1
            message = "请输入密码"
            jsonDic = [String:Any]()
            Account.returnData(response: response, status: status, message: message, jsonDic: jsonDic)
            return
        }
        print(request.uri + "\n" + request.params().description)
        
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.locale = Locale.init(identifier: "zh_CN")
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let uuid = UUID.init(formatter.string(from: Date())).string
        print(uuid)
        
        let result = DataBaseManager().custom(sqlStr: "Call userLogin('\(userAccount)','\(userPassword)','\(uuid)','\(formatter.string(from: Date()))')")
        
        result.mysqlResult?.forEachRow(callback: { (data) in
            print(data)
            if data.count > 1 {
                jsonDic["Phone"]        = data[0]
                jsonDic["UserID"]       = data[1]
                jsonDic["Name"]         = data[2]
                jsonDic["imgUrl"]       = data[3]
                jsonDic["ClassType"]    = data[4]
                jsonDic["Sex"]          = data[5]
                jsonDic["Age"]          = data[6]
                jsonDic["apiToken"]     = data[7]
                jsonDic["isLogined"]    = data[8]
            }else{
                message = data[0]!
            }
        })
        if jsonDic.count != 0 {
            
            self.returnData(response: response, status: status, message: message, jsonDic: jsonDic)
            
        }else{
            self.returnData(response: response, status: -1, message: message, jsonDic: jsonDic)
        }  
    }
    

    // 处理User注册
    static func handle_User_Register (request : HTTPRequest ,response : HTTPResponse){
        //标配
        var status = 1
        var message = "成功"
        let jsonDic = [String:Any]()
        response.setHeader( .contentType, value: "text/html")          //响应头
        
        //获取登录信息
        guard let userAccount = request.param(name: "userAccount") else {
            status = -1
            message = "请输入正确手机号码"
            Account.returnData(response: response, status: status, message: message, jsonDic: jsonDic)
            return
        }
        guard let userPassword1 = request.param(name: "userPassword1") else {
            status = -1
            message = "请输入密码"
            Account.returnData(response: response, status: status, message: message, jsonDic: jsonDic)
            return
        }
        guard let userPassword2 = request.param(name: "userPassword2") else {
            status = -1
            message = "请输入确认密码"
            Account.returnData(response: response, status: status, message: message, jsonDic: jsonDic)
            return
        }
        
        guard userPassword1 == userPassword2 else{
            status = -1
            message = "两次密码不一致"
            Account.returnData(response: response, status: status, message: message, jsonDic: jsonDic)
            return
        }
        
        guard let _ = request.param(name: "code") else {
            status = -1
            message = "请输入验证码"
            Account.returnData(response: response, status: status, message: message, jsonDic: jsonDic)
            return
        }
 
        print(request.uri + "\n" + request.params().description)

        let result = DataBaseManager().custom(sqlStr: "Call resgisterUser('\(userAccount)','\(userPassword1)')")
        var returnValue = 0
        result.mysqlResult?.forEachRow(callback: { (data) in
            returnValue = Int(data[0]!)!
        })
        if returnValue != 0 {
            self.returnData(response: response, status: status, message: "注册成功" , jsonDic: jsonDic)
        }else{
            self.returnData(response: response, status: -1, message: "该账号已存在", jsonDic: jsonDic)
        }
        
        
        
    }
    
    
    // 处理上传头像
    static func handle_User_UploadIcon (request : HTTPRequest ,response : HTTPResponse){
        
        guard let userAccount = request.param(name: "userAccount") else {
            self.returnData(response: response, status: -1, message: "缺少 userAccount", jsonDic: nil)
            return
        }
        guard let apiToken = request.param(name: "apiToken") else {
            self.returnData(response: response, status: -1, message: "缺少 apiToken", jsonDic: nil)
            return
        }
        if Account.checkToken(account: userAccount, token: apiToken) == false{
            self.returnData(response: response, status: -1, message: "userAccount/apiToken错误", jsonDic: nil)
            return
        }
        let imgUrl = self.saveIconImage(request: request, userAccount: userAccount)
        if imgUrl != "" {
            self.returnData(response: response, status: 0, message: "上传成功" , jsonDic: ["imgUrl" : imgUrl])
        }else{
            self.returnData(response: response, status: -1, message: "上传失败" , jsonDic: nil)
        }
        
    }
    
    // 用户完善信息
    static func handle_User_CompleteInfo(request : HTTPRequest, response : HTTPResponse ) {
        //标配
        response.setHeader( .contentType, value: "text/html")          //响应头
    
        var jsonDic = [String:Any]()
        
        guard let apiToken = request.param(name: "apiToken") else {
            self.returnData(response: response, status: -1, message: "缺少 apiToken", jsonDic: nil)
            return
        }
        guard let userAccount = request.param(name: "userAccount") else {
            self.returnData(response: response, status: -1, message: "缺少 userAccount", jsonDic: nil)
            return
        }
        guard let name = request.param(name: "name") else {
            self.returnData(response: response, status: -1, message: "缺少 name", jsonDic: nil)
            return
        }
        guard let age = request.param(name: "age") else {
            self.returnData(response: response, status: -1, message: "缺少 age", jsonDic: nil)
            return
        }
        guard let sex = request.param(name: "sex") else {
            self.returnData(response: response, status: -1, message: "缺少 sex", jsonDic: nil)
            return
        }
        if Account.checkToken(account: userAccount, token: apiToken) == false{
            self.returnData(response: response, status: -1, message: "userAccount/apiToken错误", jsonDic: nil)
            return
        }
        
        let result = DataBaseManager().custom(sqlStr: "Call completeInfo('\(userAccount)','\(name)','\(sex)','\(age)')")
        var returnValue = 0
        result.mysqlResult?.forEachRow(callback: { (data) in
            returnValue = Int(data[0]!)!
        })
        let _ = self.saveIconImage(request: request, userAccount: userAccount)
        if returnValue != 0 {
            let result = DataBaseManager().custom(sqlStr: "Call getUserInfo('\(userAccount)')")
            
            result.mysqlResult?.forEachRow(callback: { (data) in
                print(data)
                if data.count > 1 {
                    jsonDic["Age"]          = data[0]
                    jsonDic["UserID"]       = data[1]
                    jsonDic["Name"]         = data[2]
                    jsonDic["imgUrl"]       = data[3]
                    jsonDic["ClassType"]    = data[4]
                    jsonDic["Sex"]          = data[5]
                    jsonDic["Age"]          = data[6]
                    jsonDic["apiToken"]     = data[7]
                    jsonDic["isLogined"]    = data[8]
                }
            })

            self.returnData(response: response, status: 0, message: "提交成功", jsonDic: jsonDic)
            
        }else{
            self.returnData(response: response, status: -1, message: "提交失败", jsonDic: nil)
        }
        
        
    }
    
    // 获取首页数据
    static func handle_Get_Items (request : HTTPRequest ,response : HTTPResponse){
        var jsonDic = [String:Any]()
        response.setHeader( .contentType, value: "text/html")          //响应头
        
        guard let apiToken = request.param(name: "apiToken") else {
            self.returnData(response: response, status: -1, message: "缺少 apiToken", jsonDic: nil)
            return
        }
        guard let userAccount = request.param(name: "userAccount") else {
            self.returnData(response: response, status: -1, message: "缺少 userAccount", jsonDic: nil)
            return
        }
        
        if Account.checkToken(account: userAccount, token: apiToken) == false{
            self.returnData(response: response, status: -1, message: "userAccount/apiToken错误", jsonDic: nil)
            return
        }
        
        let result = DataBaseManager().selectAllDatabaseSQL(tableName: table_item)
        var adArr = [[String:Any]]()
        var itemArr = [[String:Any]]()
        result.mysqlResult?.forEachRow(callback: { (element) in
            var data = [String:Any]()
            data["itemId"] = element[0]
            data["itemImageUrl"] = element[2]
            data["itemName"] = element[1]
            data["itemType"] = element[3]
            if element[3] == "1" || element[3] == "01"{
                adArr.append(data)
            }else{
                itemArr.append(data)
            }
        })
        jsonDic["ad"] = adArr
        jsonDic["items"] = itemArr
        Account.returnData(response: response, status: 1, message: "成功", jsonDic: jsonDic)
    }
    
    
    
    
    /// 处理数据返回
    ///
    /// - Parameters:
    ///   - response: response
    ///   - status: 状态码
    ///   - message: 信息
    ///   - jsonDic: 返回数据
    class func returnData(response:HTTPResponse ,status:Int ,message:String ,jsonDic:Any!) {
        do{
            try response.setBody(json: NetworkServerManager.baseResponseBodyJSON(status: status, message: message, data: jsonDic)).setHeader(.contentType, value: "application/json")
            response.completed()
        }catch{
            print(error)
        }
    }
    

    
    /// 检查token与账户是否对应
    ///
    /// - Parameters:
    ///   - account: 账号
    ///   - token: token
    /// - Returns: 返回数据
    class func checkToken(account:String ,token:String) -> Bool {
        let result = DataBaseManager().selectAllDataBaseSQLwhere(tableName: table_Token, keyValue: "Account = " + account + " AND Token = '" + token + "'")
        return result.mysqlResult?.numRows() != nil ? ((result.mysqlResult?.numRows()) != nil) : false
    }
    
    /// 检查token与账户是否对应
    ///
    /// - Parameters:
    ///   - userID: userID
    ///   - token: token
    /// - Returns: 返回数据
    class func checkToken(userID:String ,token:String) -> Bool {
        let result = DataBaseManager().selectAllDataBaseSQLwhere(tableName: table_Token, keyValue: "uID = " + userID + " AND Token = '" + token + "'")
        return result.mysqlResult?.numRows() != nil ? ((result.mysqlResult?.numRows()) != nil) : false
    }
    
    
    
    /// 保存头像
    ///
    /// - Parameters:
    ///   - request:
    ///   - userAccount: 用户名
    /// - Returns: 图片路径 或 ""
    class func saveIconImage(request:HTTPRequest, userAccount : String ) -> String {
        // 通过操作fileUploads数组来掌握文件上传的情况
        // 如果这个POST请求不是分段multi-part类型，则该数组内容为空
        
        if let uploads = request.postFileUploads, uploads.count > 0 {
            
            // 创建路径用于存储已上传文件
            let fileDir = Dir(Dir.workingDir.path + "IMG_Files")
            do {
                try fileDir.create()
            } catch {
                print(error)
            }
            
            for upload in uploads{
                
                let thisFile = File(upload.tmpFileName)
                do {
                    // 查询旧头像并删除
                    let result = DataBaseManager().selectKeyDataBaseSQLwhere(tableName: Account.table_account, whereKeyValue: "Account = '\(userAccount)'", selectKey: "imgUrl")
                    
                    result.mysqlResult?.forEachRow(callback: { (element) in
                        let oldUrl = element[0]! as String
                        if oldUrl.count > 0 {
                            let oldFileName = oldUrl.substring(from: String.Index.init(encodedOffset: 5))
                            let oldFile = File.init(fileDir.path + oldFileName)
                            oldFile.delete()
                        }
                    })
                    
                    // 将文件转移走，如果目标位置已经有同名文件则进行覆盖操作。
                    let file = try thisFile.moveTo(path: fileDir.path + upload.fileName, overWrite: true)
                    let _ = DataBaseManager().updateDatabaseSQL(tableName: Account.table_account, keyValue: "imgUrl = '/res/\(upload.fileName)'" , whereKey: "Account", whereValue: (userAccount))
                    if file.path.count > 0 {
                        return "/res/" + upload.fileName
                    }else{
                        return ""
                    }
                } catch {
                    print(error)
                }
            }
        }
        return ""
    }
    
    
}
