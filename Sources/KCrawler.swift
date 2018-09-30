//
//  KCrawler.swift
//  ServerSide
//
//  Created by 科技部iOS on 2018/9/26.
//

// 参考：https://www.jianshu.com/p/2fd69be73188


import Foundation

class KCrawler {

    //传入的主url
    private var url:String
    //输出结果
    internal var results = ""
    
    
    // 初始化 传入一个URL
    init(url:String){
        self.url = url
    }
    
    
    // 开始爬取数据
    internal func start(){
        do{
            try handleData(urlString: url)
        }catch{
            debugPrint(error)
        }
    }
    
    
    
    private func handleData(urlString:String) throws {
        
        if let url = URL(string:urlString) {
            
            debugPrint("开始获取信息")
            
            DispatchQueue.global().sync{
                do{
                    //通过创建Scanner
                    let scanner = Scanner(string: try String(contentsOf:url))
                    
                    var (head,foot) = ("<div id=\"app\">","<script>")
                    let content = self.scanWith(head:head,foot:foot,scanner:scanner)
                    
                    var contents  = content.components(separatedBy:"<section id=")
                    contents.removeFirst()
                    
                    var data = ""
                    for (_, item) in contents.enumerated() {
                        (head,foot) = ("<a href=","</a>")
                        let itemString = self.scanWith(head: head, foot: foot, string: item)
                        
                        let href = self.scanWith(head: "<a href=", foot: "</a>", string: itemString).replacingOccurrences(of: "\"", with: "")
                        let crown = self.scanWith(head: "<div class=\"item-poster\" style=\"background-image: ", foot: "\">", string: itemString).replacingOccurrences(of: "\"", with: "")
                        let rank_word = self.scanWith(head: "<span class=\"item-title\">", foot: "</span>", string: itemString)
                        let rank_tag = self.scanWith(head: "<span>", foot: "</span>", string: itemString)
                        
                        data += "{\"crown\":\"\(urlString)\(crown)\",\"rank_word\":\"\(rank_word)\",\"rank_tag\":\"\(rank_tag)\",\"href\":\"\(href)\"},"
                        
                    }
                    
                    results += "\"code\":\(200),\"data\":[\(data)]"
                    
                }catch{
                    debugPrint(error)
                }
            }
            
            debugPrint("获取信息结束")
            
            results = results.replace(of: ",", with: "")
            results = results.count > 0 ? "{\(results)}" : ""
            
        }else{
            throw crawlerError(msg:"查询URL初始化失败")
        }
    }
    
    
    // html截取
    func scanWith(head:String,foot:String,scanner:Scanner)->String
    {
        var str:NSString?
        
        scanner.scanUpTo(head, into: nil)
        scanner.scanUpTo(foot, into: &str)
        
        return str == nil ? "" : str!.replacingOccurrences(of: head, with: "")
    }
    
    // 字符串截取
    func scanWith(head:String,foot:String,string:String)->String
    {
        
        let range = string.range(of: head)
        guard range != nil else {
            return ""
        }
        let startIndex = range!.upperBound
        
        let range1 = Range(uncheckedBounds: (lower: string.startIndex, upper: string.endIndex))
        let endRange = string.range(of: foot, options: .backwards, range: range1, locale: Locale(identifier: "<"))
        let endIndex = endRange!.lowerBound
        
        let searchRange = Range(uncheckedBounds: (startIndex, endIndex))
        
        let endString = string.substring(with: searchRange)
        return endString
    }
    
}


//自定义一个错误处理
public struct crawlerError:Error
{
    var message:String
    
    init(msg:String)
    {
        message = msg
    }
}


extension String
{
    //去掉字符串(空格之类的)
    func trim(string:String) -> String
    {
        return self == "" ? "" : self.trimmingCharacters(in: CharacterSet(charactersIn: string))
    }
    //替换从末尾出现的第一个指定字符串
    func replace(of pre:String,with next:String)->String
    {
        return replacingOccurrences(of: pre, with: next, options: String.CompareOptions.backwards, range: index(endIndex, offsetBy: -2)..<endIndex)
    }
    
}



