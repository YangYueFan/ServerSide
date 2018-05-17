//
//  ProductHandler.swift
//  PerfectTemplate
//
//  Created by 科技部iOS on 2018/3/31.
//

import PerfectLib
import PerfectHTTP

public class UserLoginHandler {
    
    static func userLoginHandler(request: HTTPRequest, _ response:HTTPResponse) {
        
        var userAccount = ""
        var userPassword = ""
        
        if  let account = request.param(name: "account"){
            userAccount = account
        }
        if  let password = request.param(name: "password"){
            userPassword = password
        }
        
        if userAccount != "" && userPassword != "" {
            
        }
        
        
    }
    
    
}
