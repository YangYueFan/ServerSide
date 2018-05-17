//
//  ProductRoutes.swift
//  PerfectTemplate
//
//  Created by 科技部iOS on 2018/3/31.
//


import PerfectHTTP


public func userRoutes() -> Routes {
    
    var routes = Routes()
    routes.add(method: .post, uri: "/userLogin") { (requset, response) in
        UserLoginHandler.userLoginHandler(request: requset, response)
    }
    return routes
    
}
