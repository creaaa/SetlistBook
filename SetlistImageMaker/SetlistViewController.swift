
import UIKit

struct Song {
    let name: String
}

final class SetlistViewController: UIViewController {
    
    // 本編の曲数
    var numOfSong = 0
    // アンコールの曲数(アンコール1, アンコール2...)
    var numOfEncoreSongs: [Int] = [0]
    
    lazy var songNames: [String]         = Array(repeating: "", count: self.numOfSong)
    lazy var encoreSongNames: [[String]] = Array(repeating: Array<String>(),
                                                 count: self.numOfEncoreSongs.count)
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func tap(_ sender: Any) {
        print("うえー")
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.tableView.delegate   = self
        self.tableView.dataSource = self
        
        self.tableView.isEditing  = true
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 44
        
    }

}

extension SetlistViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
}



extension SetlistViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
            case 0:
                return 1
            case 1:
                return self.numOfSong + 1 // 最後のセルにボタンが来る
            case 2:
                return self.numOfEncoreSongs[0] + 1 + 1 // 曲を追加ボタン + 投稿ボタン
            default:
                fatalError()
        }
        
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        // ライブ本編
        if indexPath.section == 1 && indexPath.row == numOfSong {
            let cell = UITableViewCell()
            cell.textLabel?.text = "タップして曲名を入力"
            return cell
        }
        // アンコール1
        if indexPath.section == 2 {
            if indexPath.row == numOfEncoreSongs[0] {
                let cell = UITableViewCell()
                cell.textLabel?.text = "タップして曲名を入力"
                return cell
            } else if indexPath.row == numOfEncoreSongs[0] + 1 {
                let cell = UITableViewCell(style: .default, reuseIdentifier: "Btn")
            }
        }
        
        let cell = UITableViewCell()
        cell.textLabel?.text = "曲名がきます1"
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        switch section {
            case 0:
                return "公演情報"
            case 1:
                return "セットリスト"
            case 2:
                return "アンコール　#1"
            default:
                fatalError("never executed")
        }
        
    }
    
    
    // <移動系>
    
    // 並び替え可能なセルの指定
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        
        if indexPath.section == 0 { return false }
        if indexPath.section == 1, indexPath.row == self.numOfSong  { return false }
        if indexPath.section == 2 {
            if indexPath.row == self.numOfEncoreSongs[0] ||
               indexPath.row == self.numOfEncoreSongs[0] + 1 { return false }
        }
        if indexPath.section == 3 { return false }

        return true
        
    }
    
    
    // セルの並び替えが発動した時の処理
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        print("un")
    }
    
    
    // <delete / insert 系>
    
    // 実装されてなくてもよい。その場合、すべてのセルは[編集可能]だとみなされる(暗黙的に true が指定される。)
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 3 { return false }
        return true
    }
    
    
    // (※ isEditingがtrueの場合 かつ canEditRowAtでfalseになっていない場合 のみ意味を成す = アイコンが出現する)
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) ->UITableViewCellEditingStyle {
        
        // ライブ本編
        if indexPath.section == 0 {
            return .insert
        }
        // ライブ本編
        if indexPath.section == 1 && indexPath.row == self.numOfSong {
            return .insert
        }
        // アンコール1
        if indexPath.section == 2 {
            if indexPath.row == self.numOfEncoreSongs[0] { return .insert }
        }
        
        return .delete
        
    }
    
    // delete / insert 発動時
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
            case .delete:
                print("きえた")
            case .insert:
                print("ふえた")
                tableView.insertRows(at: [indexPath], with: .automatic)
            case .none:
                print("なんもねえ")
        }
    }
    
    
    
}



/*
extension SetlistViewController: TableViewCellDelegate {
    
    // nextボタンでここが発動するとき、
    // tableViewが表示されない
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        let statusBarHeight = UIApplication.shared.statusBarFrame.height
        let textFieldHeight: CGFloat = 40
        
        let y = textField.superview?.superview?.frame.origin.y
        
        let topMargin = statusBarHeight + textFieldHeight
        
        suggestTableView =
            UITableView(frame: CGRect(x: 0, y: 100 + y!,
                                      width: self.view.frame.width,
                                      height: self.view.frame.height - topMargin))
        suggestTableView.delegate   = self
        suggestTableView.dataSource = self
        suggestTableView.backgroundColor = UIColor(white: 0, alpha: 0.5)
        suggestTableView.allowsSelection = false
        suggestTableView.tag = 100
        
        self.selectedCellNo = (textField.superview?.superview as! TableViewCell).tag
        
        self.view.addSubview(suggestTableView)
        
        loadViewIfNeeded()
        
        return true
        
    }
    
    func textFieldDidEndEditing(cell: TableViewCell) {
        
        if let _ = self.suggestTableView {
            self.suggestTableView.removeFromSuperview()
        }
        
        self.songNames[cell.tag - 1] = cell.textField.text!
        print(cell.textField.text!)
    }
    
    func textFieldNextButtonTapped(cell: TableViewCell) {
        
        if let _ = self.suggestTableView {
            self.suggestTableView.removeFromSuperview()
        }
        
        let nextCellTag = cell.tag + 1
        let indexPath   = IndexPath(row: nextCellTag - 1, section: 1)
        
        if let cell = self.tableView.cellForRow(at: indexPath) as? TableViewCell {
            cell.textField.becomeFirstResponder()
        }
        
    }
    
}
*/




