//
//  ProductRoutes.swift
//  PerfectTemplate
//
//  Created by 科技部iOS on 2018/3/31.
//

import PerfectLib
import PerfectHTTP
import PerfectHTTPServer

public class UserRoutes {
    
    //MARK: 注册路由
    class public func configure(routes: inout Routes) {
        
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
        // 注册get
        routes.add(method: .get, uri: "/userRegister") { (request, response) in
            Account.handle_User_Register(request: request, response: response)
        }
        // 注册post
        routes.add(method: .post, uri: "/userRegister") { (request, response) in
            Account.handle_User_Register(request: request, response: response)
        }
        
        //*********************************************************************
        // 用户完善信息
        routes.add(method: .get, uri: "/userCompleteInfo") { (request, response) in
            Account.handle_User_CompleteInfo(request: request, response: response)
        }
        routes.add(method: .post, uri: "/userCompleteInfo") { (request, response) in
            Account.handle_User_CompleteInfo(request: request, response: response)
        }
        
        
        
        //*********************************************************************
        // 上传头像post
        routes.add(method: .post, uri: "/uploadIcon") { (request, response) in
            Account.handle_User_UploadIcon(request: request, response: response)
        }
    }
    
}

