//
//  DataBaseManager.swift
//  PerfectTemplate
//
//  Created by 科技部iOS on 2018/4/10.
//

import PerfectMySQL


//MARK: 数据库信息
let mysql_host = "47.100.98.169"
let mysql_user = "root"
let mysql_password = "1350280yyF"
let mysql_database = "MyAppSQL"

let table_account   = "UserInfo"
let table_Token     = "UserToken"
let table_item      = "HomeItem"
open class DataBaseManager {
    
    
    
    fileprivate var mysql: MySQL
    internal init() {
        mysql = MySQL.init() //创建MySQL对象
        guard connectedDataBase() else { //开启MySQL连接
            return
        }
        
    }
    
    //MARK: 开启连接
    private func connectedDataBase() -> Bool {
        mysql.setOption(.MYSQL_SET_CHARSET_NAME, "utf8")
        
        let connected = mysql.connect(host: mysql_host, user: mysql_user, password: mysql_password, db: mysql_database)
        
        guard connected else {
            print("MySQL连接失败" + mysql.errorMessage())
            return false
        }
        print("MySQL连接成功")
        return true
    }
    
    
    
    //MARK: 执行SQL语句
    /// 执行SQL语句
    ///
    /// - Parameter sql: sql语句
    /// - Returns: 返回元组(success:是否成功 result:结果)
    @discardableResult
    func mysqlStatement(_ sql: String) -> (success: Bool, mysqlResult: MySQL.Results?, errorMsg: String) {
        guard mysql.selectDatabase(named: mysql_database) else { //指定database
            let msg = "未找到\(mysql_database)数据库"
            print(msg)
            return (false, nil, msg)
        }
        let successQuery = mysql.query(statement: sql) //sql语句
        guard successQuery else {
            let msg = "SQL失败: \(sql)"
            print(msg)
            return (false, nil, msg)
        }
        let msg = "SQL成功: \(sql)"
        print(msg)
        return (true, mysql.storeResults(), msg) //sql执行成功
    }
    
    
    
    
    /// 增
    ///
    /// - Parameters:
    /// - tableName: 表
    /// - key: 键 (键,键,键)
    /// - value: 值 ('值', '值', '值')
    func insertDatabaseSQL(tableName: String, key: String, value: String) -> (success: Bool, mysqlResult: MySQL.Results?, errorMsg: String){
        let SQL = "INSERT INTO \(tableName) (\(key)) VALUES (\(value))"
        return mysqlStatement(SQL)
    }
    
    
    
    /// 删
    ///
    /// - Parameters:
    /// - tableName: 表
    /// - key: 键
    /// - value: 值
    func deleteDatabaseSQL(tableName: String, key: String, value: String) -> (success: Bool, mysqlResult: MySQL.Results?, errorMsg: String) {
        let SQL = "DELETE FROM \(tableName) WHERE \(key) = '\(value)'"
        return mysqlStatement(SQL)
    }
    
    
    
    /// 改
    ///
    /// - Parameters:
    /// - tableName: 表
    /// - keyValue: 键值对( 键='值', 键='值', 键='值' )
    /// - whereKey: 查找key
    /// - whereValue: 查找value
    func updateDatabaseSQL(tableName: String, keyValue: String, whereKey: String, whereValue: String) -> (success: Bool, mysqlResult: MySQL.Results?, errorMsg: String) {
        let SQL = "UPDATE \(tableName) SET \(keyValue) WHERE \(whereKey) = '\(whereValue)'"
        return mysqlStatement(SQL)
    }
    
    
    
    /// 查所有
    ///
    /// - Parameters:
    /// - tableName: 表
    /// - key: 键
    func selectAllDatabaseSQL(tableName: String) -> (success: Bool, mysqlResult: MySQL.Results?, errorMsg: String) {
        let SQL = "SELECT * FROM \(tableName)"
        return mysqlStatement(SQL)
    }
    
    
    /// 查
    ///
    /// - Parameters:
    /// - tableName: 表
    /// - keyValue: 键值对
    func selectAllDataBaseSQLwhere(tableName: String, keyValue: String) -> (success: Bool, mysqlResult: MySQL.Results?, errorMsg: String) {
        let SQL = "SELECT * FROM \(tableName) WHERE \(keyValue)"
        return mysqlStatement(SQL)
    }
    /// 查
    ///
    /// - Parameters:
    /// - tableName: 表
    /// - keyValue: 键值对
    func selectKeyDataBaseSQLwhere(tableName: String, whereKeyValue: String ,selectKey: String) -> (success: Bool, mysqlResult: MySQL.Results?, errorMsg: String) {
        let SQL = "SELECT \(selectKey) FROM \(tableName) WHERE \(whereKeyValue)"
        return mysqlStatement(SQL)
    }
    
    /// 查tableName所有字段名
    ///
    /// - Parameters:
    /// - tableName: 表
    /// - keyValue: 键值对
    func selectAllcolumnNamewhere(tableName: String) -> (success: Bool, mysqlResult: MySQL.Results?, errorMsg: String) {
        let SQL = "select COLUMN_NAME from information_schema.COLUMNS where table_name = '\(tableName)'"
        return mysqlStatement(SQL)
    }
    
    
    func custom(sqlStr:String) -> (success: Bool, mysqlResult: MySQL.Results?, errorMsg: String) {
        return mysqlStatement(sqlStr)
    }
    
    
    //获取tableName表中所有数据
    func mysqlGetHomeDataResult(tableName:String) -> [Dictionary<String, String>]? {
        
        var columns = [String]()
        let columnResult = selectAllcolumnNamewhere(tableName: tableName)
        columnResult.mysqlResult?.forEachRow(callback: { (row) in
            if columns.contains(row[0]!) == false{
                columns.append(row[0]!)
            }
        })
        
        let result = selectAllDatabaseSQL(tableName: tableName)
        var resultArray = [Dictionary<String, String>]()
        var dic = [String:String]()
        result.mysqlResult?.forEachRow(callback: { (row) in
            for index in 0..<columns.count {
                if columns[index] != "Password" {
                    dic[columns[index]] = row[index]
                }
            }
            resultArray.append(dic)
        })
        
        return resultArray
    }
    
}


