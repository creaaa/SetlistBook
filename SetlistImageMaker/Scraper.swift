
import Kanna

struct Scraper {
    
    // let urlStr =
    // "http://www.uta-net.com/search/?Keyword=indigo+la+end&x=0&y=0&Aselect=1&Bselect=3"
    // "http://www.uta-net.com/search/?Aselect=1&Keyword=aiko&Bselect=3&x=0&y=0"

    
    func execute(url: URL, completion: @escaping ([String]) -> Void) {
        
        var result: [String] = []
        
        // result = []
        
        // DispatchGroupとQueueを生成
        // let queue1 = DispatchQueue(label: "hoge.fuga.queue1")
        
        // キューとグループを紐付ける
        DispatchQueue.global().async {
            
            // guard let url = URL(string: urlStr) else { return }
            
            let data = self.getHtml(url: url)
            
            result = self.parseHtml(data: data)
            
            DispatchQueue.main.async {
                completion(result)
            }
            
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
    
    func parseHtml(data: Data) -> [String] {
        
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



