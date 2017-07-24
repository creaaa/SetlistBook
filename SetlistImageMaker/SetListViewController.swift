
import UIKit
import RealmSwift

final class SetListViewController: UIViewController {
    
    var realm = try! Realm()
    
    /* Model */

    // セルをタップして遷移してきた場合は、既存の値が↓の初期値を上書きする
    // +(add)ボタンを押して遷移してきた場合は、↓の空虚な値を使う
    var setlist = Setlist()
    
    // オンライン取得した曲名リスト
    var suggestSongList: [String]?
    
    // 再フェッチが必要かどうかを管理するための変数
    // Setlistオブジェクト(Realm由来)のプロパティはプロパティオブザーバーが使えないため、
    // しゃあなしもう1個変数を増やした
    var currentArtist = ""
    

    //////////////
    
    /* View */
    
    weak var suggestTableView: UITableView!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var addEncoreButton: UIBarButtonItem!
    
    @IBAction func doneButtonTapped(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    // TODO: -ツイート機能つける段になったらコメントインしてね
    /*
    func cancelButtonTapped(_ sender: UIBarButtonItem) {
        
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
    */
    

    @IBAction func addEncoreButtonTapped(_ sender: UIBarButtonItem) {
        
        try! realm.write {
            self.setlist.encores.append(Songs())
            print(self.setlist.encores)
        }
        
        self.tableView.reloadData()
        
    }
    
    
    private func fetchSongNames() {
        
        let url1 = "http://www.uta-net.com/search/?Aselect=1"
        let url2 = "http://songmeanings.com/query/"
        let url3 = "http://songmeanings.com/artist/view/songs/"
        
        let param1  = (url1, "//td[@class='side td1']")
        
        // let param2  = (url2, "//td[@width='90%']/a")
        
        // 1件だけ取れる. muse だと取れない
        // let param2  = (url2, "//td[@width='90%']/a[@title='Muse']")
        
        // できた
        let param2  = (url2, "//tbody/tr[1]/td[1]/a/@href")
        
        let param3  = (url3, "//tbody//td[1]")
        
        let scraper = Scraper(artistQuery: self.setlist.artist, parameter: [param1, param2, param3])
        
        scraper.execute() { result in
            self.suggestSongList = result
        }
        
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
        
        let att = [
            NSForegroundColorAttributeName: UIColor.black,
            NSFontAttributeName: UIFont(name: "HigashiOme-Gothic", size: 16) as Any
        ]
        
        self.addEncoreButton.setTitleTextAttributes(att, for: .normal)
        
    }

    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        if let selectedRow = self.tableView.indexPathForSelectedRow {
            self.tableView.deselectRow(at: selectedRow, animated: true)
        }
        
        self.tableView.reloadData()
        
        // これ、relodaDataの後でもいいよな...?
        
        // 判定なくなってる！たせ
        if currentArtist != self.setlist.artist {
            fetchSongNames()
        }
        
        // ここで現在のアーティスト名をセット(↑の条件判定の"後"にやらないとダメ)
        self.currentArtist = self.setlist.artist
        
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
                    
                // editVC.title  = "アーティスト / 公演情報"
                editVC.setlist = self.setlist

                self.present(vc, animated: true, completion: nil)
                
            // 本編 / アンコール
            default:
                
                guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "EditSetList")
                    as? UINavigationController else { return }

                guard let editVC = vc.viewControllers.first as? EditSetListViewController else { return }
                
                // (本編・#5), (アンコール1：#2),,,みたいな感じ
                editVC.songNo  = (indexPath.section - 1, indexPath.row)
                editVC.setlist = self.setlist
                
                if let suggestSongList = self.suggestSongList {
                    editVC.suggestSongList = suggestSongList
                }
                
                // 本編の編集ならば
                if indexPath.section == 1 {
                    editVC.title   = "Edit SetList"
                } else {  // アンコールの編集ならば
                    // ex. アンコール #1 なら、[0]の配列が渡される
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
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "ArtistCell", for: indexPath)
                 
            cell.textLabel?.text = self.setlist.artist != "" ?
                self.setlist.artist : "input live info"
            
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
            cell.textLabel?.font = UIFont(name: "HigashiOme-Gothic", size: 14)
            
            
            if indexPath.row == self.setlist.mainSongs.first!.songs.count {
                cell.textLabel?.text = "input song name"
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

                cell.textLabel?.font = UIFont(name: "HigashiOme-Gothic", size: 14)

                
                cell.textLabel?.text = "input song name"
//                cell.textLabel?.font = UIFont(name: "HigashiOme-Gothic", size: 14)

                return cell
            }
            
            else {
                let cell = UITableViewCell()
                print("name: \(self.setlist.encores.last!.songs)")
                
                cell.textLabel?.font = UIFont(name: "HigashiOme-Gothic", size: 14)

                cell.textLabel?.text = self.setlist.encores.last!.songs[indexPath.row].name
                //cell.textLabel?.font = UIFont(name: "HigashiOme-Gothic", size: 14)
                
                return cell
            }
            
        }
        
        
        // 最後以外のアンコールセクション
        let cell = UITableViewCell()
        cell.textLabel?.font = UIFont(name: "HigashiOme-Gothic", size: 14)

        if !self.setlist.encores[indexPath.section-2].isEmpty {
            
            if indexPath.row != self.setlist.encores[indexPath.section-2].songs.count {
                cell.textLabel?.text =
                    self.setlist.encores[indexPath.section-2].songs[indexPath.row].name
            } else {
                cell.textLabel?.text = "input song name"
            }
            
        } else {
            cell.textLabel?.text = "input song name"
        }

        return cell
        
    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        switch section {
            case 0:
                return "live info"
            case 1:
                return "setlist"
            case let encore:
                return "encore #\(encore - 1)"
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


