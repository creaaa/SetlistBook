import Kanna

struct Scraper {
    
    // let urlStr =
    // "http://www.uta-net.com/search/?Keyword=indigo+la+end&x=0&y=0&Aselect=1&Bselect=3"
    // "http://www.uta-net.com/search/?Aselect=1&Keyword=aiko&Bselect=3&x=0&y=0"
    
    let parameter: [(url: URL, xpath: String)]
    
    init(parameter: [(url: URL, xpath: String)]) {
        self.parameter = parameter
    }
    
    func execute(completion: @escaping ([String]) -> Void) {
        
        // DispatchGroupとQueueを生成
        
        // キューとグループを紐付ける
        DispatchQueue.global().async {
            
            /*
            guard let data = self.getHtml(url: url),
                let result = self.parseHtml(data: data, xpath: xpath) else { return }
            
            DispatchQueue.main.async {
                completion(result)
            }
            */
            
            if let data = self.getHtml(url: self.parameter[0].url) {
                
                if let result = self.parseHtml(data: data, xpath: self.parameter[0].xpath) {
                    DispatchQueue.main.async {
                        completion(result)
                        print("最初のサイトで検索終了")
                    }
                }
                
                // 解説
                // ↑の getHTML内で呼ばれる Data(contentsOf: URL)は、
                // ヘッダー情報が404を含むとき、nilを返す。
                // 当該サイトは検索結果が0件のとき、404を返すので、
                // その場合に限り、次のサイトでの検索に移行する。
                // 反対に、結果が1件でもあれば、当該サイト内で検索終了。以上が ここまで ↑ の処理。
                // これ以降 ↓ は、次サイトに移行するときの処理。
            } else {
                
                if let data = self.getHtml(url: self.parameter[1].url) {
                    if let result = self.parseHtml(data: data, xpath: self.parameter[1].xpath) {
                        DispatchQueue.main.async {
                            completion(result)
                            print("2番めのサイトで検索終了")
                        }
                    }
                }
            }
        }  // async {} 終了
    }      // func execute 終了
    
    
    func getHtml(url: URL) -> Data? {
        return try? Data(contentsOf: url)
    }
    
    /// スクレイピング
    func parseHtml(data: Data, xpath: String) -> [String]? {
        
        // KannaでHTMLDocumentを生成
        guard let doc = HTML(html: data, encoding: String.Encoding.utf8) else { return nil }
        
        var retData: [String] = []
        
        // xpath
        // "//td[@class='side td1']"
        
        let node = doc.xpath(xpath)
        
        node.forEach{ print($0.content!); retData.append($0.content!) }
        
        return retData
        
    }
    
}
