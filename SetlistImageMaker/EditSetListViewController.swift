
import UIKit

final class EditSetListViewController: UIViewController {

    @IBOutlet weak var tableView:  UITableView!
    @IBOutlet weak var prevButton: UIBarButtonItem!
    
    // weak var suggestTableView:     UITableView!
    
    @IBOutlet weak var suggestTableView: UITableView!
    
    
    // 遷移前画面から渡されてきた「曲名リスト」のコピー。
    // モーダル終了時受け戻される。
    var songNames: [String]!
    var songNo:    Int!
    var encoreNo:  Int!
    
    // 曲名候補が入る
    var suggestSongList: [String] =
        ["1. 想いきり", "2. 見せかけのラブソング", "3. 猫にも愛を", "4. プレイバック", "5. エーテル"]

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        print("受け渡されてきた曲名リスト: ", self.songNames)
        
        tableView.delegate   = self
        tableView.dataSource = self
        
        suggestTableView.delegate   = self
        suggestTableView.dataSource = self
        
        if self.songNo == 0 {
            self.prevButton.isEnabled = false
        }
        
        tableView.sizeToFit()

    }
    
    
    @IBAction func cencelButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButtonTapped(_ sender: UIBarButtonItem) {
        
        guard let navVC = self.presentingViewController as? UINavigationController,
            let parentVC = navVC.topViewController as? SetListViewController else {
                self.dismiss(animated: true, completion: nil)
                return
        }
        
        let indexPath = IndexPath(row: 0, section: 0)
        
        guard let cell = self.tableView.cellForRow(at: indexPath) as? SongNameTableViewCell else {
            self.dismiss(animated: true, completion: nil)
            return
        }
        
        if self.songNo >= self.songNames.count {
            self.songNames.append("")
        }
        
        self.songNames[self.songNo] = cell.textField.text!
        
        if self.title == "SetList" {
            parentVC.songNames = self.songNames
        } else if let _ = self.encoreNo {
            parentVC.encoreSongNames[encoreNo - 1] = self.songNames
        } else {
            fatalError()
        }
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func prevSongButtonTapped(_ sender: UIBarButtonItem) {
        
        // 配列に1個追加
        if self.songNo >= self.songNames.count {
            self.songNames.append("")
            print("足した")
        }
        
        // モデル更新
        let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! SongNameTableViewCell
        self.songNames[songNo] = cell.textField.text!
        print("現在の配列: \(self.songNames)")
        
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
        if self.songNo >= self.songNames.count {
            self.songNames.append("")
            print("足した")
        }
        
        // モデル更新
        let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! SongNameTableViewCell
        self.songNames[songNo-1] = cell.textField.text!
        print("現在の配列: \(self.songNames)")
        
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
        
        print("f")
        
        
        if tableView.tag == 2 {
            
            // 固定化された「曲入力セル」
            let songNameCell =
                // これ、(0,0)セルが画面外にあるとぬるぽする！なんでだよ
                // ここのselfは必須。考えたらわかるな??
                self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! SongNameTableViewCell
            
            // セル自分自身
            let cell = tableView.cellForRow(at: indexPath)
            
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
                return 30 // self.suggestSongList.count
            default:
                fatalError()
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        switch tableView.tag {
            
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TextFieldCell") as! SongNameTableViewCell
            cell.textField.placeholder = "#\(self.songNo! + 1): 曲名を入力"
            if !self.songNames.isEmpty {
                if self.songNo < self.songNames.count {
                    cell.textField.text = self.songNames[self.songNo]
                } else {
                    cell.textField.text = nil
                }
            }
            cell.delegate = self
            return cell
        case 2:
            let cell = UITableViewCell()
            cell.textLabel?.text = self.suggestSongList[indexPath.row % 5]
            return cell
        default:
                fatalError()
        }
        
    }
    
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
    
    /*
    func inputFromHistory(sender: UITapGestureRecognizer) {
        
        self.suggestTableView.removeFromSuperview()
        self.suggestTableView = nil
        
        if let cell = sender.view as? UITableViewCell {
            let ip = IndexPath(row: 0, section: 0)
            if let c = self.tableView.cellForRow(at: ip) as? SongNameTableViewCell {
                c.textField.text = cell.textLabel?.text
            }
        }
        
        resignFirstResponder()
    }
    */
    
}


extension EditSetListViewController: TableViewCellDelegate {
    
    /*
    private func yieldSuggestTableView(_ textField: UITextField) {
        
        let statusBarHeight = UIApplication.shared.statusBarFrame.height
        let textFieldHeight: CGFloat = 40
        
        let y = textField.superview?.superview?.frame.origin.y
        
        let topMargin = statusBarHeight + textFieldHeight
        
        let tableView =
            UITableView(frame: CGRect(x: 0, y: 105 + y!,
                                      width: self.view.frame.width,
                                      height: self.view.frame.height - topMargin))
        
        tableView.delegate   = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor(white: 0, alpha: 0.5)
        tableView.allowsSelection = false
        tableView.tag = 100
        
        self.suggestTableView = tableView
        
        self.view.addSubview(tableView)
    
    }
    */
    
    // nextボタンでここが発動するとき、tableViewが表示されない
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        // yieldSuggestTableView(textField)
        return true
    }
    
    func textFieldDidEndEditing(cell: UITableViewCell) {
        if let _ = self.suggestTableView {
            self.suggestTableView.removeFromSuperview()
        }
    }
    
    func textFieldNextButtonTapped(cell: UITableViewCell) {
        nextSongButtonTapped(UIBarButtonItem())
    }
    
}


