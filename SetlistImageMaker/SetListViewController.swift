
import UIKit
import RealmSwift

final class SetListViewController: UIViewController {
    
    var realm = try! Realm()
    
    /* Model */

    // セルをタップして遷移してきた場合は、既存の値が↓の初期値を上書きする
    // +(add)ボタンを押して遷移してきた場合は、↓の空虚な値を使う
    var setlist = Setlist()
    
    // オンライン取得した曲名リスト
    // リクエストを抑えるため可能な限り使いまわす
    var proactiveSongNames: [String]?
    
    //////////////
    
    /* View */
    
    weak var suggestTableView: UITableView!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func doneButtonTapped(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: "Action?", message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Share on Twitter", style: .default, handler: tweet))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive,  handler: nil))
        
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    func tweet(action: UIAlertAction) {
        let vc = LoginViewController()
        present(vc, animated: true, completion: nil)
    }
    
    @IBAction func addEncoreButtonTapped(_ sender: UIBarButtonItem) {
        
        try! realm.write {
            self.setlist.encores.append(Songs())
            print(self.setlist.encores)
        }
        
        self.tableView.reloadData()
        
    }
    
    
    private func fetchSongNames(url: URL) {
        
        // これ、なぜか返り値が代入されないので....
        // self.proactiveSongNames = Scraper().execute(url: url)
        
        Scraper().execute(url: url) { result in
            self.proactiveSongNames = result
        }
        
    }
    
    // ユーザー入力されたアーティストに応じたURLを発行
    private func createURL(artist: String) -> URL? {
        
        var result: String = ""
        
        let baseURL = "http://www.uta-net.com/search/?Aselect=1"
        
        result += "\(baseURL)&Keyword=\(artist)"
        
        //let urlStr = "http://www.uta-net.com/search/?Aselect=1&Keyword=aiko&Bselect=3&x=0&y=0"
        
        return URL(string: result) ?? nil
        
    }
    
    ////////////////
    // Life Cycle //
    ////////////////
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.tableView.delegate   = self
        self.tableView.dataSource = self
        
        self.tableView.isEditing  = true
        
        self.tableView.rowHeight  = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 44
        
        print("受け渡されてきたセトリ: \(self.setlist)")
        
    }
    
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
    
        let str = self.setlist.artist as NSString
        
        let characterSet = CharacterSet.alphanumerics
        let encodedStr   = str.addingPercentEncoding(withAllowedCharacters: characterSet)
        
        if let encodedStr = encodedStr,
            let url = createURL(artist: encodedStr),
            self.setlist.artist != "",
            self.proactiveSongNames == nil {
            fetchSongNames(url:url)
        } else {
            print("あかん")
        }
        
        
        if let selectedRow = self.tableView.indexPathForSelectedRow {
            self.tableView.deselectRow(at: selectedRow, animated: true)
        }

        print("main songs: ",   self.setlist.mainSongs)
        // print("encore songs: ", self.setlist.encores)
        
        self.tableView.reloadData()
        
    }
    
}


///////////////

extension SetListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        cellTapped(indexPath)
    }
    
    fileprivate func cellTapped(_ indexPath: IndexPath) {
    
        switch indexPath.section {
            
            // アーティスト / 会場 / 日付
            case 0:
                
                guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "EditArtist")
                    as? UINavigationController else { return }
                
                guard let editVC = vc.viewControllers.first as? EditArtistViewController else { return }
                    
                editVC.title  = "アーティスト / 公演情報"
                editVC.setlist = self.setlist

                self.present(vc, animated: true, completion: nil)
                
            // 本編 / アンコール
            default:
                
                guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "EditSetList")
                    as? UINavigationController else { return }

                guard let editVC = vc.viewControllers.first as? EditSetListViewController  else { return }
                
                editVC.songNo    = indexPath.row
                
                if let proactiveSongNames = self.proactiveSongNames {
                    editVC.proactiveSongNames = proactiveSongNames
                }
                
                // 本編の編集ならば
                if indexPath.section == 1 {
                    
                    guard let mainSongs = self.setlist.mainSongs.first else { return }
                    
                    editVC.setlist = mainSongs //self.setlist.mainSongs.first!
                    
                    editVC.title   = "SetList"
                    
                } else {  // アンコールの編集ならば
                    // ex. アンコール #1 なら、[0]の配列が渡される
                    
                    let encoreSongs = self.setlist.encores[indexPath.section-2]
                    
                    editVC.setlist  = encoreSongs //self.setlist.encores[indexPath.section - 2]
                    
                    editVC.title    = "Encore #\(indexPath.section - 1)"
                    
                }
                
                self.present(vc, animated: true, completion: nil)
            
        }
    }
}


extension SetListViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2 + self.setlist.encores.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        
            // アーティスト名・公演情報
            case 0:
                return 1
            // 本編
            case 1:
        
                // +1 = 最後のセルに曲追加ボタンが来る
                // return self.setlist.mainSongs.first!.songs.count + 1
                
                // こうも書ける、けどこれ以降全部変えなきゃだめなのでやめた
                let count = self.setlist.mainSongs.first?.songs.count
                return count.map{$0 + 1} ?? 0
            
            
            ////////////
            // encore //
            ////////////
            
            // 最後以外のアンコール
            case (2..<1 + self.setlist.encores.count):
                
                if self.setlist.encores[section-2].songs.isEmpty {
                    return 1
                } else {
                    return self.setlist.encores[section-2].songs.count + 1 // + 曲追加ボタン
                }
            
            // 最後のアンコール
            case (1 + self.setlist.encores.count):  // 最後のアンコール
                return self.setlist.encores[section-2].songs.count + 1 // + 曲追加ボタン + 投稿ボタン

            default:
                fatalError()
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        // アーティスト・公演情報
        if indexPath.section == 0 {
            
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "ArtistCell")
            cell.textLabel?.text = self.setlist.artist // ?? "タップして情報を入力"
            
            var str = ""
            str.append(self.setlist.place ?? "")
            if str != "" { str.append(" / ") }
            
            if let date = self.setlist.date {
                str.append(DateUtils.stringFromDate(date: date, format: "YYYY-MM-dd")) // ?? "")
            }
            
            cell.detailTextLabel?.text = str != "" ? str : nil
            
            return cell
            
        }
        
        // ライブ本編
        if indexPath.section == 1 {
            let cell = UITableViewCell()
            if indexPath.row == self.setlist.mainSongs.first!.songs.count {
                cell.textLabel?.text = "タップして曲名を入力"
                return cell
            } else {
                print("row: \(indexPath.row)")
                cell.textLabel?.text = self.setlist.mainSongs.first!.songs[indexPath.row].name
                return cell
            }
        }
    
        // 最後のアンコールセクションなら
        if indexPath.section == self.setlist.encores.count + 1 {
            
            // 曲追加ボタン
            if indexPath.row == self.setlist.encores.last!.songs.count {
                let cell = UITableViewCell()
                cell.textLabel?.text = "タップして曲名を入力"
                return cell
            // 確認画面遷移ボタン
            }
            
            /*
            else if indexPath.row == self.encoreSongNames[numOfEncore-1].count + 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "Btn")!
                return cell
            }
            */
            
            else {
                let cell = UITableViewCell()
                print("name: \(self.setlist.encores.last!.songs)")
                cell.textLabel?.text = self.setlist.encores.last!.songs[indexPath.row].name
                return cell
            }
            
            
        }
        
        
        // 最後以外のアンコールセクション
        let cell = UITableViewCell()
        
        if !self.setlist.encores[indexPath.section-2].isEmpty {
            
            if indexPath.row != self.setlist.encores[indexPath.section-2].songs.count {
                cell.textLabel?.text =
                    self.setlist.encores[indexPath.section-2].songs[indexPath.row].name
            } else {
                cell.textLabel?.text = "タップして曲名を入力"
            }
            
        } else {
            cell.textLabel?.text = "タップして曲名を入力"
        }

        return cell
        
    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        switch section {
            case 0:
                return "アーティスト名 / 公演情報"
            case 1:
                return "本編"
            case let encore:
                return "アンコール #\(encore - 1)"
        }
        
    }
    
    
    // <移動系>
    
    // 並び替え可能なセルの指定
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        
        // アーティスト名・公演情報
        if indexPath.section == 0 { return false }
        
        // 本編
        if indexPath.section == 1 {
            if indexPath.row == self.setlist.mainSongs.first!.songs.count {
                return false
            } else {
                return true
            }
        }

        
        // 最後以外のアンコール
        // まさか、editabaleじゃないと、移動もできない疑惑。。。？？
        // まじだった。editable = false なセルは、このメソッドが呼ばれない。
        // すなわち、実装は canEditAtからやらなくてはいけない。
        if case (2..<1 + self.setlist.encores.count) = indexPath.section {
            if indexPath.row < self.setlist.encores[indexPath.section-2].songs.count {
                return true
            } else {
                return false
            }
        }

        // 最後のアンコールセクション
        if case (1 + self.setlist.encores.count) = indexPath.section {
            guard self.setlist.encores.count > 0 else { return false }
            if indexPath.row == self.setlist.encores[setlist.encores.count-1].songs.count ||
                indexPath.row == self.setlist.encores[setlist.encores.count-1].songs.count + 1 {
                return false
            } else {
                return true
            }
        }
        
        fatalError()
        
    }
    
    // セルの並び替えが発動した(指が離れた瞬間)時の処理(モデルの変更)
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath,
                   to destinationIndexPath: IndexPath) {
        
        // ここに書く
        
        // 本編
        if sourceIndexPath.section == 1 {
            
            // swapは、lazyな配列だとなぜかコンパイルエラーになる。
            // 加え、同じ要素同士をswapすると実行時エラー。エラーチェック必須。頼むよ
            
            // let tmp = self.setlist.mainSongs.remove(at: sourceIndexPath.row)
            // self.setlist.mainSongs.insert(tmp, at: destinationIndexPath.row)

            try! realm.write {
                // writeの中で書かないと実行時エラー
                setlist.mainSongs.first!.songs.move(from: sourceIndexPath.row, to: destinationIndexPath.row)
            }
        }

        
        // 最後以外のアンコール
        else if case (2..<1 + self.setlist.encores.count) = sourceIndexPath.section {
            
            /*
            let tmp = self.setlist.encores[sourceIndexPath.section-2].songs.remove(at: sourceIndexPath.row)
            self.setlist.encores[sourceIndexPath.section-2].songs.insert(tmp, at: destinationIndexPath.row)
            */
            
            try! realm.write {
                setlist.encores[destinationIndexPath.section-2].songs.move(from: sourceIndexPath.row, to: destinationIndexPath.row)
            }
            
            print(self.setlist.encores[sourceIndexPath.section-2])
            
        }
        
        
        // 最後のアンコール
        else if case (1 + self.setlist.encores.count) = sourceIndexPath.section {
            
            try! realm.write {
                self.setlist.encores[sourceIndexPath.section-2].songs.move(from: sourceIndexPath.row, to: destinationIndexPath.row)
            }
            
            print(self.setlist.encores[sourceIndexPath.section-2])

        }

        self.tableView.reloadData()
        
    }
    
    // セルの移動範囲に制限を課す
    // ドラッグし、各セルの上を通過する瞬間に毎回呼ばれる。
    // 例) (0,0)から(0,3)へもっていくときは、(0,1)ぶん,(0,2)ぶん,(0,3)ぶんの3回呼ばれる
    func tableView(_ tableView: UITableView,
                   targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath,
                   toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        
        // 本編
        if sourceIndexPath.section == 1 {
            
            // アーティスト名・公演情報へ移動しようとした場合
            if proposedDestinationIndexPath.section == 0 {
                return IndexPath(row: 0, section: 1)
            }
            
            // 「タップして曲を追加」は固定
            else if proposedDestinationIndexPath.section == 1 {
                print("destination: \(proposedDestinationIndexPath.section), \(proposedDestinationIndexPath.row)")
                if proposedDestinationIndexPath.row == self.setlist.mainSongs.first!.songs.count {
                    return IndexPath(row: self.setlist.mainSongs.first!.songs.count - 1, section: 1)
                }
            }
            
            // アンコールへ移動しようとした場合
            else if proposedDestinationIndexPath.section > 1 {
                return IndexPath(row: self.setlist.mainSongs.first!.songs.count - 1, section: 1)
            }
            
        }
        
        // 最後以外のアンコール
        else if case (2..<1 + self.setlist.encores.count) = sourceIndexPath.section {
            
            // 「タップして曲を追加」は固定
            if proposedDestinationIndexPath.section == sourceIndexPath.section {
                if proposedDestinationIndexPath.row ==
                    self.setlist.encores[sourceIndexPath.section-2].songs.count {
                    let ip = IndexPath(row: proposedDestinationIndexPath.row - 1,
                                     section: sourceIndexPath.section)
                    return ip
                }
            }
            
            if proposedDestinationIndexPath.section != sourceIndexPath.section {
                
                // 自分より「上」にいこうとしたら
                if proposedDestinationIndexPath.section < sourceIndexPath.section {
                    return IndexPath(row: 0, section: sourceIndexPath.section)
                // 自分より「下」にいこうとしたら
                } else {
                    let ip = IndexPath(row: self.setlist.encores[sourceIndexPath.section-2].songs.count - 1, section: sourceIndexPath.section)
                    return ip
                }
            }
        }
        
        // 最後のアンコール
        else if case (1 + self.setlist.encores.count) = sourceIndexPath.section {
            
            // 「タップして曲を追加」は固定
            if proposedDestinationIndexPath.section == sourceIndexPath.section {
                
                if proposedDestinationIndexPath.row == self.setlist.encores[sourceIndexPath.section-2].songs.count ||
                    proposedDestinationIndexPath.row == setlist.encores[sourceIndexPath.section-2].songs.count + 1
                    {
                    let ip = IndexPath(row: self.setlist.encores[sourceIndexPath.section-2].songs.count - 1, section: sourceIndexPath.section)
                    return ip
                }
                
            }
            
            if proposedDestinationIndexPath.section != sourceIndexPath.section {
                return IndexPath(row: 0, section: sourceIndexPath.section)
            }
        }
        
        return proposedDestinationIndexPath
        
    }
    
    
    // <delete / insert 系>
    
    // 実装されてなくてもよい。その場合、すべてのセルは[編集可能]だとみなされる(暗黙的に true が指定される。)
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        switch indexPath.section {
            
            case 0:
                return true
                
            case 1:
                return true
            
            // 最後以外のアンコール・セクション
            case (2..<1 + self.setlist.encores.count):
                return true
            
            case (1 + self.setlist.encores.count):  // 最後のアンコール
                guard self.setlist.encores.count > 0 else { return false }
                return true
                
            default:
                fatalError()
        }
    }
    
    
    // (※ isEditingがtrueの場合 かつ canEditRowAtでfalseになっていない場合 のみ意味を成す = アイコンが出現する)
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) ->UITableViewCellEditingStyle {
        
        // アーティスト名＆公演情報
        if indexPath.section == 0 {
            return .insert
        }
        // ライブ本編
        if indexPath.section == 1 {
            
            if indexPath.row == self.setlist.mainSongs.first!.songs.count {
                return .insert
            } else {
                return .delete
            }
        }
        
        // 最後以外のアンコール・セクション
        if case (2..<1 + self.setlist.encores.count) = indexPath.section {
            if indexPath.row == self.setlist.encores[indexPath.section-2].songs.count {
                return .insert
            } else {
                return .delete
            }
        }
        
        // 最後のアンコール・セクション
        if case (1 + self.setlist.encores.count) = indexPath.section {
            if indexPath.row == self.setlist.encores[indexPath.section-2].songs.count {
                    return .insert
            }
            return .delete
        }
        
        fatalError()
        
    }
    
    
    // insertのボタンを押すと、(_:commit:forRowAt:)が呼び出されます．
    // delete / insert 発動時
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
            case .delete:
            
                try! realm.write {
                    switch indexPath.section {
                        case 1:
                            self.setlist.mainSongs.first!.songs.remove(objectAtIndex: indexPath.row)
                        print("けした")
                        default:
                            self.setlist.encores[indexPath.section-2].songs.remove(objectAtIndex: indexPath.row)
                    }
                }
            
                self.tableView.reloadData()
            
            case .insert:
                cellTapped(indexPath)
            case .none:
                break
        }
    }
    
}


