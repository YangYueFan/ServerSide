// Generated automatically by Perfect Assistant Application
// Date: 2017-09-20 19:30:47 +0000
import PackageDescription
let package = Package(
	name: "PerfectTemplate",
	targets: [],
	dependencies: [

        .Package(url: "https://github.com/PerfectlySoft/Perfect-HTTPServer.git", majorVersion: 3),
        //Request请求日志过滤器
//        .Package(url: "https://github.com/dabfleming/Perfect-RequestLogger.git", majorVersion: 0, minor: 2),
//        //将日志写入指定文件
//        .Package(url: "https://github.com/PerfectlySoft/Perfect-Logger.git", majorVersion: 3),
        //MySql数据库依赖包
        .Package(url:"https://github.com/PerfectlySoft/Perfect-MySQL.git", majorVersion: 3),
	]
)
