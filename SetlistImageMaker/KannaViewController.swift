
import UIKit

import APIKit
import Kanna



// Arrayの要素
class element {
    var day  = ""
    var hour = ""
    var temperature: Double = 0
}


class KannaViewController: UIViewController {

    /// 最終データのArray
    /// var finalData:     [element] = []
    /// 昨日のデータのArray
    var yesterdayData: [element] = []
    /// 今日のデータのArray
    var todayData:     [element] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        execute()
    }
    
    
    func execute() {
        
        // DispatchGroupとQueueを生成
        let group  = DispatchGroup()
        let queue1 = DispatchQueue(label: "hoge.fuga.queue1")
        let queue2 = DispatchQueue(label: "hoge.fuga.queue2")
        
        // キューとグループを紐付ける
        queue1.async(group: group) {
            // 札幌のアメダス（昨日）
            guard let url = URL(string: "http://www.jma.go.jp/jp/amedas_h/yesterday-14163.html") else {
                fatalError("Error: URL")
            }
            let data           = self.getHtml(url: url)
            self.yesterdayData = self.parseHtml(day: "yesterday", data: data)
        }
        
        queue2.async(group: group) {
            // 札幌のアメダス（今日）
            guard let url = URL(string: "http://www.jma.go.jp/jp/amedas_h/today-14163.html") else {
                fatalError("Error: URL")
            }
            let data       = self.getHtml(url: url)
            self.todayData = self.parseHtml(day: "today", data: data)
        }
        
        // タスクが全て完了したらメインスレッド上で処理を実行する
        group.notify(queue: DispatchQueue.main) {
            // 今日のArrayと昨日のArrayを結合
            let finalData = self.yesterdayData + self.todayData
            // 編集してUITextViewに表示
            var s = ""
            for e in finalData {
                s += e.day + "-" + e.hour + "h: " + String(e.temperature) + "\n"
            }
            
            // 完成(なにが？？)
            print(s)
            
            // self.activityIndicator.stopAnimating()
        }
        
    }
    
    
    func getHtml(url: URL) -> Data {
        do {
            return try Data(contentsOf: url)
        } catch {
            fatalError("fail to download")
        }
    }
    
    
    /// スクレイピング
    /// - parameter day: "today"/"yesterday"
    /// - parameter data: Data
    /// - returns [element]
    
    func parseHtml(day: String, data: Data) -> [element] {
        
        // KannaでHTMLDocumentを生成
        guard let doc = HTML(html: data, encoding: String.Encoding.utf8) else {
            fatalError("Error: HTML")
        }
        
        var retData: [element] = []
        
        // HTMLの<table>の時刻の列を基準にLoopし、該当行の気温の列をKannaでスクレイピング
        for i in (1...24) {
            let node = doc.xpath("//*[@id='tbl_list']//tr[td[1][text()='\(i)']]/td[2]")
            
            if let nodeFirst = node.first, let content = nodeFirst.content, let value = Double(content) {
                // 値が入っている場合のみ取得
                let e = element()
                
                e.day         = day
                e.hour        = String(i)
                e.temperature = value
                retData.append(e)
            }
        }
        
        return retData
        
    }
    
}


