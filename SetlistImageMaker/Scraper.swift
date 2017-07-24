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
        
        guard let encodedArtist = encodeString(str: self.artistQuery) else { return }
        
        // DispatchGroupとQueueを生成
        let group = DispatchGroup()
        let queue1 = DispatchQueue(label: "hoge.fuga.queue1")
        let queue2 = DispatchQueue(label: "hoge.fuga.queue2")

        // 取得の多い方を使う
        var site1data: [String] = []
        var site2data: [String] = []
        
        // タスク1
        queue1.async(group: group) {
            
            guard let url = self.createFirstURL(artist: encodedArtist) else { return }
            guard let data = self.getHtml(url: url) else { return }
            guard let result = self.parseHtml(data: data, xpath: self.parameter[0].xpath) else { return }
            
            site1data = result
            
        }
        
        
        queue2.async(group: group) {
            
            /* phase 1 */
            guard let url1    = self.createSecondURL(artist: encodedArtist) else { return }
            guard let data1   = self.getHtml(url: url1) else { return }
            guard let result1 = self.parseHtml(data: data1, xpath: self.parameter[1].xpath) else { return }
            
            // 文字IDをもとにさらにコール
            print("Phase 1 done: ", result1)
            
            /* phase 2 */
            guard let id      = self.fetchArtistID(target: result1) else { return }
            guard let url2    = self.createThirdURL(artistNo: id) else { return }
            guard let data2   = self.getHtml(url: url2) else { return }
            guard let result2 = self.parseHtml(data: data2, xpath: self.parameter[2].xpath) else { return }
            
            print("Phase 2 done: \(result2)")

            site2data = result2
            
        }
        
        
        // タスクが全て完了したらメインスレッド上で処理を実行する
        group.notify(queue: DispatchQueue.main) {
            
            print("サイト1: \(site1data.count)件, サイト2: \(site2data.count)件")
            
            let result = site1data.count > site2data.count ? site1data : site2data
            completion(result)
        }
        
        
    } // func execute 終了
    
    
    // 解説
    // このメソッド内にある Data(contentsOf: URL)は、ヘッダー情報が404を含むとき、nilを返す。
    // 当該サイト1は検索結果が0件のとき、404を返すので、マジ注意。
    
    func getHtml(url: URL) -> Data? {
        return try? Data(contentsOf: url)
    }
    
    /// スクレイピング
    func parseHtml(data: Data, xpath: String) -> [String]? {
        
        // KannaでHTMLDocumentを生成
        guard let doc = HTML(html: data, encoding: String.Encoding.utf8) else { return nil }
        
        var retData: [String] = []
        
        let node = doc.xpath(xpath)
        
        node.forEach{ retData.append($0.content!) }
        
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
        
        // print("生成文字列: ", result)
        
        return URL(string: result) ?? nil
        
    }
    
    // ほんますまん
    private func createThirdURL(artistNo: Int) -> URL? {
        
        var result  = ""
        
        let baseURL = parameter[2].url
        
        result += "\(baseURL)\(artistNo)"
        
        // print("生成文字列: ", result)
        
        return URL(string: result) ?? nil
        
    }
    
    // 取得したa href文字列からアーティストIDを抽出
    private func fetchArtistID(target: [String]) -> Int? {
        
        let res = target.first?.components(separatedBy: NSCharacterSet.decimalDigits.inverted).flatMap{Int($0)}.first
        
        // print(res)
        
        return res
        
    }
    
}
