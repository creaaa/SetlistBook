
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
    var yesterdayData: [String] = []
    /// 今日のデータのArray
    var todayData:     [String] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        execute()
    }
    
    
    func execute() {
        
        // DispatchGroupとQueueを生成
        let group  = DispatchGroup()
        let queue1 = DispatchQueue(label: "hoge.fuga.queue1")
        
        // キューとグループを紐付ける
        queue1.async(group: group) {
            // 札幌のアメダス（昨日）
            
            let urlStr =
            // "http://www.uta-net.com/search/?Keyword=indigo+la+end&x=0&y=0&Aselect=1&Bselect=3"
            "http://www.uta-net.com/search/?Aselect=1&Keyword=aiko&Bselect=3&x=0&y=0"
            
            
            guard let url = URL(string: urlStr) else {
                fatalError("Error: URL")
            }
            let data           = self.getHtml(url: url)
            self.yesterdayData = self.parseHtml(day: "yesterday", data: data)
        }
        
        // タスクが全て完了したらメインスレッド上で処理を実行する
        group.notify(queue: DispatchQueue.main) {
            // 今日のArrayと昨日のArrayを結合
            let finalData = self.yesterdayData + self.todayData
            // 編集してUITextViewに表示

            // 完成(なにが？？)
            
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
    
    func parseHtml(day: String, data: Data) -> [String] {
        
        // KannaでHTMLDocumentを生成
        guard let doc = HTML(html: data, encoding: String.Encoding.utf8) else {
            fatalError("Error: HTML")
        }
        
        var retData: [String] = []
        
        // HTMLの<table>の時刻の列を基準にLoopし、該当行の気温の列をKannaでスクレイピング
        
        // let node = doc.xpath("//*[@summary='曲一覧1']/tbody/tr[td[@class='side td1']]")
        // let node = doc.xpath("//*[@summary='曲一覧1']/tbody/tr/td[@class='side td1']")
        let node = doc.xpath("//td[@class='side td1']")
        
        node.forEach{ print($0.content!); retData.append($0.content!) }
        
        
        return retData
        
    }
    
}



