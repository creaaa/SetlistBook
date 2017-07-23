
import UIKit
import RealmSwift

final class EditSetListViewController: UIViewController {

    var realm = try! Realm()

    @IBOutlet weak var tableView:        UITableView!
    @IBOutlet weak var suggestTableView: UITableView!
    
    @IBOutlet weak var prevButton:       UIBarButtonItem!
    
    
    /*
    // 遷移前画面から渡されてきた「曲名リスト」のコピー。
    // モーダル終了時受け戻される。
    var songNames: Songs!
    var songNo:    Int!
    var encoreNo:  Int!
    */
    
    // 本編orアンコールの曲リスト
    // 前画面から受け渡される
    var setlist: Songs!
    var songNo:  Int!
    

    // 前画面から来るかもしれない、曲名リスト
    var suggestSongList: [String]?

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        print("受け渡されてきた曲名リスト: ", self.setlist)
        print("きてるべ \(self.suggestSongList ?? ["やっぱきてない"])")
        
        tableView.delegate   = self
        tableView.dataSource = self
        
        suggestTableView.delegate   = self
        suggestTableView.dataSource = self
        
        if self.songNo == 0 {
            self.prevButton.isEnabled = false
        }
        
    }
    
    
    //////////////
    // nav bar  //
    //////////////
    
    @IBAction func cencelButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButtonTapped(_ sender: UIBarButtonItem) {
        
        let indexPath = IndexPath(row: 0, section: 0)

        let cell = self.tableView.cellForRow(at: indexPath) as! SongNameTableViewCell
        
        if self.songNo >= self.setlist.songs.count {
            try! realm.write {
                self.setlist.songs.append(Song(songName: ""))
                print("足した")
            }
        }
        
        try! realm.write {
            self.setlist.songs[self.songNo].name = cell.textField.text!
            realm.add(self.setlist)
        }
        
        self.dismiss(animated: true, completion: nil)
 
    }
    
    //////////////
    // toolbar  //
    //////////////
    
    @IBAction func prevSongButtonTapped(_ sender: UIBarButtonItem) {
        
        // 配列に1個追加
        if self.songNo >= self.setlist.songs.count {
            try! realm.write {
                self.setlist.songs.append(Song(songName: ""))
                print("足した")
            }
        }
        
        
        // モデル更新
        /*
        let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! SongNameTableViewCell
        self.songNames[songNo] = cell.textField.text!
        print("現在の配列: \(self.songNames)")
        */
 
        
        try! realm.write {
            let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! SongNameTableViewCell
            self.setlist.songs[songNo].name = cell.textField.text!
        }
        
        self.songNo! -= 1
        
        // ビュー
        self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
        
        if self.songNo == 0 {
            self.prevButton.isEnabled = false
        } else {
            self.prevButton.isEnabled = true
        }
 
    }
    
    
    @IBAction func nextSongButtonTapped(_ sender: UIBarButtonItem) {
        
        self.songNo! += 1
        
        // 配列に1個追加
        if self.songNo >= self.setlist.songs.count {
            try! realm.write {
                self.setlist.songs.append(Song(songName: ""))
                print("足した")
            }
        }
        
        // モデル更新
        try! realm.write {
            let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! SongNameTableViewCell
            self.setlist.songs[songNo-1].name = cell.textField.text!
        }
        
        // ビュー
        self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
        
        if self.songNo == 0 {
            self.prevButton.isEnabled = false
        } else {
            self.prevButton.isEnabled = true
        }
        
    }
    
}


extension EditSetListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView.tag == 2 {
            
            // 固定化された「曲入力セル」
            let songNameCell =
                // これ、(0,0)セルが画面外にあるとぬるぽする！なんでだよ
                // ここのselfは必須。考えたらわかるな??
                self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! SongNameTableViewCell
            
            // セル自分自身
            let cell = tableView.cellForRow(at: indexPath)
            // ハイライトさせない
            tableView.deselectRow(at: indexPath, animated: true)
            
            // 曲名を転記
            songNameCell.textField.text = cell?.textLabel?.text
        }
    }
    
}


extension EditSetListViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch tableView.tag {
            case 1:
                return 1
            case 2:
                return self.suggestSongList?.count ?? 0
            default:
                fatalError()
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch tableView.tag {
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "TextFieldCell") as! SongNameTableViewCell
                cell.textField.placeholder = "#\(self.songNo! + 1): 曲名を入力"
                
                /*
                if !self.songNames.isEmpty {
                    if self.songNo < self.songNames.count {
                        cell.textField.text = self.songNames[self.songNo]
                    } else {
                        cell.textField.text = nil
                    }
                }
                */
                
                if self.songNo < self.setlist.songs.count {
                    cell.textField.text = self.setlist.songs[self.songNo].name
                } else {
                    cell.textField.text = nil
                }
                
                cell.delegate = self
                
                return cell
            
            case 2:
                let cell = UITableViewCell()
                cell.textLabel?.text = self.suggestSongList?[indexPath.row] ?? ""
                return cell
            default:
                fatalError()
        }
    }
    
    /*
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
     */
 
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        switch tableView.tag {
        case 1:
            return "曲名(必須)"
        case 2:
            return "Probably..."
        default:
            fatalError("never executed")
        }
    }
    
}


extension EditSetListViewController: TableViewCellDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldDidEndEditing(cell: UITableViewCell) {
    }
    
    func textFieldNextButtonTapped(cell: UITableViewCell) {
        nextSongButtonTapped(UIBarButtonItem())
    }
    
}


