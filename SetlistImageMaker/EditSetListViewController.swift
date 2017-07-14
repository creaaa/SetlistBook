
import UIKit

final class EditSetListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    weak var suggestTableView:    UITableView!
    
    // 遷移前画面から渡されてきた「曲名リスト」のコピー。モーダル終了時受け戻される。
    var songList: [String]!
    
    var songNo: Int!
    
    // 曲名候補が入る
    var suggestSongList: [String] =
        ["想いきり", "見せかけのラブソング", "猫にも愛を", "プレイバック", "エーテル"]
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        tableView.delegate   = self
        tableView.dataSource = self

    }
    
    
    @IBAction func cencelButtonTapped(_ sender: Any) {
        
        if let navVC = self.presentingViewController as? UINavigationController,
           let parentVC = navVC.topViewController as? SetListViewController {
                parentVC.songNames.append("unk")
        }
        
        self.dismiss(animated: true, completion: nil)
        
        print("cancel!")
        
    }
    
    @IBAction func doneButtonTapped(_ sender: UIBarButtonItem) {
        
        if let navVC = self.presentingViewController as? UINavigationController,
            let parentVC = navVC.topViewController as? SetListViewController {
                let indexPath = IndexPath(row: 0, section: 0)
                    if let cell = self.tableView.cellForRow(at: indexPath) as? SongNameTableViewCell {
                        var ary = parentVC.songNames
                        if self.songNo >= ary.count {
                            ary.append("")
                        }
                        ary[self.songNo]   = cell.textField.text!
                        parentVC.songNames = ary
                    }
        }
        
        self.dismiss(animated: true, completion: nil)
        print("done!")
        
    }
    
}


extension EditSetListViewController: UITableViewDelegate {
    
}

extension EditSetListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView.tag == 100 {
            return self.suggestSongList.count
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView.tag == 100 {
            let cell = UITableViewCell(style: .default, reuseIdentifier: "SuggestCell")
            cell.textLabel?.text = self.suggestSongList[indexPath.row]
            cell.addGestureRecognizer(
                UITapGestureRecognizer(target: self,
                                       action: #selector(inputFromHistory(sender:))))
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TextFieldCell") as! SongNameTableViewCell
        cell.textField.placeholder = "#\(self.songNo! + 1): 曲名を入力"
        cell.delegate = self
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if tableView.tag == 100 {
            return "Probably..."
        }
            
        switch section {
        case 0:
            return "曲名(必須)"
        default:
            fatalError("never executed")
        }
    }
    
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
    
}


extension EditSetListViewController: TableViewCellDelegate {
    
    // nextボタンでここが発動するとき、
    // tableViewが表示されない
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
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
        
        return true
        
    }
    
    
    func textFieldDidEndEditing(cell: SongNameTableViewCell) {
        
        if let _ = self.suggestTableView {
            self.suggestTableView.removeFromSuperview()
        }
        
        print(cell.textField.text!)
        
    }
    
    
    func textFieldNextButtonTapped(cell: SongNameTableViewCell) {
        
        if let _ = self.suggestTableView {
            self.suggestTableView.removeFromSuperview()
        }
        
        let nextCellTag = cell.tag + 1
        let indexPath   = IndexPath(row: nextCellTag - 1, section: 1)
        
        if let cell = self.tableView.cellForRow(at: indexPath) as? SongNameTableViewCell {
            cell.textField.becomeFirstResponder()
        }
        
    }
    
}










