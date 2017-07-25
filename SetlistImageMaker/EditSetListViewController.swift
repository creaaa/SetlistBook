
import UIKit
import RealmSwift

final class EditSetListViewController: UIViewController {

    var realm = try! Realm()

    @IBOutlet weak var tableView:        UITableView!
    @IBOutlet weak var suggestTableView: UITableView!
    
    @IBOutlet weak var prevButton: UIBarButtonItem!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var nextButton: UIBarButtonItem!
    
    
    // 本編orアンコールの曲リスト
    // 前画面から受け渡される
    var setlist: Setlist! // 注: まえはここ Songs! 型だった
    
    // 本編の編集なのか、アンコールの編集なのか...
    // section: 0 → 本編, 1 → アンコール1, 2 → アンコール2...
    var songNo: (section: Int, no: Int)!
    

    // 前画面から来るかもしれない、曲名リスト
    var suggestSongList: [String]?

    
    // 許してくれ...編集中のセトリ群を返す
    // 「本編」か、「アンコール1」か、「アンコール2」か, と、こんな具合
    var editingSongs: Songs {
        
        switch self.songNo.section {
        case 0:
            return self.setlist.mainSongs.first!
        case let encore:
            return self.setlist.encores[encore - 1]
        }
        
    }
    
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        print("受け渡されてきた曲名リスト: ", self.setlist)
        print("きてるべ \(self.suggestSongList ?? ["やっぱきてない"])")
        
        tableView.delegate   = self
        tableView.dataSource = self
        
        self.tableView.rowHeight  = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 92
        
        suggestTableView.delegate   = self
        suggestTableView.dataSource = self
        
        if self.songNo.no == 0 {
            self.prevButton.isEnabled = false
        }
        
        let att = [
            NSForegroundColorAttributeName: UIColor.black,
            NSFontAttributeName: UIFont(name: "HigashiOme-Gothic", size: 16) as Any
        ]
        
        self.prevButton.setTitleTextAttributes(att, for: .normal)
        self.doneButton.setTitleTextAttributes(att, for: .normal)
        self.nextButton.setTitleTextAttributes(att, for: .normal)
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    //////////////
    // nav bar  //
    //////////////
    
    @IBAction func cencelButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    var canFinish: Bool {
        
        let indexPath = IndexPath(row: 0, section: 0)
        let cell = self.tableView.cellForRow(at: indexPath) as! SongNameTableViewCell
        
        let result = cell.textField.text != nil && cell.textField.text != ""

        return result
        
    }
    
    
    @IBAction func doneButtonTapped(_ sender: UIBarButtonItem) {
        
        guard canFinish else {
            createSimpleAlert(title: "Error", message: "input song name.")
            return
        }
        
        let indexPath = IndexPath(row: 0, section: 0)
        let cell = self.tableView.cellForRow(at: indexPath) as! SongNameTableViewCell
        
        if self.songNo.no >= self.editingSongs.songs.count {
            try! realm.write {
                self.editingSongs.songs.append(Song(songName: ""))
                print("足した")
            }
        }
        
        try! realm.write {
            self.editingSongs.songs[self.songNo.no].name = cell.textField.text!
            realm.add(self.setlist)
        }
        
        self.dismiss(animated: true, completion: nil)
 
    }
    
    //////////////
    // toolbar  //
    //////////////
    
    @IBAction func prevSongButtonTapped(_ sender: UIBarButtonItem) {
        
        // ナンセンスに思えるが、便宜を取った
        guard canFinish else {
            createSimpleAlert(title: "Error", message: "input song name.")
            return
        }
        
        // 配列に1個追加
        if self.songNo.no >= self.editingSongs.songs.count {
            try! realm.write {
                self.editingSongs.songs.append(Song(songName: ""))
                print("足した")
            }
        }
 
        try! realm.write {
            let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! SongNameTableViewCell
            self.editingSongs.songs[songNo.no].name = cell.textField.text!
        }
        
        self.songNo.no -= 1
        
        // ビュー
        self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
        
        if self.songNo.no == 0 {
            self.prevButton.isEnabled = false
        } else {
            self.prevButton.isEnabled = true
        }
 
    }
    
    
    @IBAction func nextSongButtonTapped(_ sender: UIBarButtonItem) {
        
        guard canFinish else {
            createSimpleAlert(title: "Error", message: "input song name.")
            return
        }
        
        self.songNo.no += 1
        
        // 配列に1個追加
        if self.songNo.no >= self.editingSongs.songs.count {
            try! realm.write {
                self.editingSongs.songs.append(Song(songName: ""))
                print("足した")
            }
        }
        
        // モデル更新
        try! realm.write {
            let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! SongNameTableViewCell
            self.editingSongs.songs[songNo.no-1].name = cell.textField.text!
        }
        
        // ビュー
        self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
        
        if self.songNo.no == 0 {
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
            case 1:  // 曲名入力用テーブル
                let cell = tableView.dequeueReusableCell(withIdentifier: "TextFieldCell") as! SongNameTableViewCell
                
                cell.textLabel?.font = UIFont(name: "HigashiOme-Gothic", size: 14)
                cell.textField.placeholder = "#\(self.songNo.no + 1): input song name"
                
                if self.songNo.no < self.editingSongs.songs.count {
                    cell.textField.text = self.editingSongs.songs[self.songNo.no].name
                } else {
                    cell.textField.text = nil
                }
                
                cell.delegate = self
                
                return cell
            
            case 2:  // 曲名出力テーブル
                let cell = UITableViewCell()
                
                cell.textLabel?.font = UIFont(name: "HigashiOme-Gothic", size: 14)
                cell.textLabel?.text = self.suggestSongList?[indexPath.row] ?? ""
                
                return cell
            default:
                fatalError()
        }
    }
    
 
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        switch tableView.tag {
        case 1:
            return "song name(required)"
        case 2:
            return "suggestion"
        default:
            fatalError("never executed")
        }
    }
    
    /*
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let label = UILabel(frame: CGRect(x:100, y:0, width: tableView.bounds.width, height: 50))
        
        label.text = {
            
            switch tableView.tag {
                case 1:
                    return "song name(required)"
                case 2:
                    return "suggestion"
                default:
                    fatalError("never executed")
            }
            
        }()
        
        label.font = UIFont(name: "HigashiOme-Gothic", size: 14)
        
        return label
        
    }
    */
    
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


