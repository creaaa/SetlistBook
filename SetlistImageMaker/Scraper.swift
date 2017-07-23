
import Kanna

struct Scraper {
    
    // let urlStr =
    // "http://www.uta-net.com/search/?Keyword=indigo+la+end&x=0&y=0&Aselect=1&Bselect=3"
    // "http://www.uta-net.com/search/?Aselect=1&Keyword=aiko&Bselect=3&x=0&y=0"

    func execute(url: URL, completion: @escaping ([String]) -> Void) {
        
        // DispatchGroupとQueueを生成
        
        // キューとグループを紐付ける
        DispatchQueue.global().async {
            guard let data = self.getHtml(url: url),
                  let result = self.parseHtml(data: data) else { return }
            
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }
    
    
    func getHtml(url: URL) -> Data? {
        return try? Data(contentsOf: url)
    }
    
    /// スクレイピング
    func parseHtml(data: Data) -> [String]? {
        
        // KannaでHTMLDocumentを生成
        guard let doc = HTML(html: data, encoding: String.Encoding.utf8) else { return nil }
        
        var retData: [String] = []
        
        let node = doc.xpath("//td[@class='side td1']")
        
        node.forEach{ print($0.content!); retData.append($0.content!) }
        
        return retData
        
    }
    
}



