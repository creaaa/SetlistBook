import Kanna

struct Scraper {
    
    // let urlStr =
    // "http://www.uta-net.com/search/?Keyword=indigo+la+end&x=0&y=0&Aselect=1&Bselect=3"
    // "http://www.uta-net.com/search/?Aselect=1&Keyword=aiko&Bselect=3&x=0&y=0"
    
    let artistQuery: String
    let parameter: [(url: String, xpath: String)]
    
    init(artistQuery: String, parameter: [(url: String, xpath: String)]) {
        self.artistQuery = artistQuery
        self.parameter   = parameter
    }
    
    func execute(completion: @escaping ([String]) -> Void) {
        
        // 条件1: アーティスト名に変更があったこと
        // 条件2: artist名のエンコードに成功したこと
        // 条件3: エンコードしたartist名を元に、適正なURLの生成に成功したこと
        // この3条件をすべて見たしたとき、再フェッチをする
        
        guard let encodedArtist = encodeString(str: self.artistQuery),
              let url1 = createFirstURL(artist: encodedArtist) else {
            return
        }
        
        DispatchQueue.global().async {
            
            if let data = self.getHtml(url: url1) {
                
                if let result = self.parseHtml(data: data, xpath: self.parameter[0].xpath) {
                    DispatchQueue.main.async {
                        completion(result)
                        print("最初のサイトで検索終了")
                        return
                    }
                }
                
                // 解説
                // ↑の getHTML内で呼ばれる Data(contentsOf: URL)は、
                // ヘッダー情報が404を含むとき、nilを返す。
                // 当該サイトは検索結果が0件のとき、404を返すので、
                // その場合に限り、次のサイトでの検索に移行する。
                // 反対に、結果が1件でもあれば、当該サイト内で検索終了。以上が ここまで ↑ の処理。
                // これ以降 ↓ は、次サイトに移行するときの処理。
                guard let url2 = self.createSecondURL(artist: encodedArtist) else {
                    return
                }
                
                if let data = self.getHtml(url: url2) {
                    if let result = self.parseHtml(data: data, xpath: self.parameter[1].xpath) {
                        // 文字IDをもとにさらにコール
                        print("途中！", result)
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
    
    
    // スクレイピングの前準備用
    // URL文字列をエンコードして返す。
    // エンコードに失敗した場合nilが返るので、この値を再フェッチするかどうかの条件判定にも用いる。
    private func encodeString(str: String) -> String? {
        let characterSet = CharacterSet.alphanumerics
        return (str as NSString).addingPercentEncoding(withAllowedCharacters: characterSet)
    }
    
    // ユーザー入力されたアーティストに応じたURLを発行
    private func createFirstURL(artist: String) -> URL? {
        
        var result  = ""
        
        let baseURL = parameter[0].url  //
        
        result += "\(baseURL)&Keyword=\(artist)"
        
        return URL(string: result) ?? nil
        
    }
    
    // ↑ と同じなんだ。許してくれ。
    private func createSecondURL(artist: String) -> URL? {
        
        var result  = ""
        
        let baseURL = parameter[1].url  //"http://songmeanings.com/query/"
        
        result += "\(baseURL)?query=\(artist)&type=artists"
        
        print("生成文字列: ", result)
        
        return URL(string: result) ?? nil
        
    }
    
    // ほんますまん
    private func createThirdURL(artistNo: String) -> URL? {
        
        var result  = ""
        
        let baseURL = parameter[2].url
        
        result += "\(baseURL)\(artistNo)"
        
        print("生成文字列: ", result)
        
        return URL(string: result) ?? nil
        
    }
    
}
