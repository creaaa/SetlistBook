
import UIKit

struct Song {
    let name: String
}

final class SetlistViewController: UIViewController {

    var numOfSongs = 1
    lazy var songNames: [String] = Array(repeating: "", count: self.numOfSongs)
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func tap(_ sender: Any) {
            print("うえー")
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.tableView.delegate   = self
        self.tableView.dataSource = self
        
        self.tableView.isEditing = false
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 44
        
    }
    
}

extension SetlistViewController: UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
}

extension SetlistViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
            case 0:
                return 1
            case 1:
                return self.numOfSongs + 1 // 最後のセルにボタンが来る
            default:
                return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if indexPath.section == 1, indexPath.row == numOfSongs { // = 最後のセル
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddSongCell")!
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            as! TableViewCell
        
        cell.textField.text = self.songNames[indexPath.row]
        cell.tag = indexPath.row + 1
        cell.textField.placeholder = cell.tag.description + "."
        
        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        switch section {
            case 0:
                return "公演情報"
            case 1:
                return "セットリスト"
            default:
                fatalError("never executed")
        }
        
    }
    
    
    
    // セルが削除が可能なことを伝えるメソッド
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) ->UITableViewCellEditingStyle {
        return tableView.isEditing ? .insert : .none
    }

    
    // <移動系>
    
    // 並び替え可能なセルの指定(今回は"すべて")
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 0 { return false }
        if indexPath.section == 1, indexPath.row == self.numOfSongs  { return false }
        
        return true
    }
    
    
    // セルの並び替えが発動した時の処理
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        print("un")
    }
    
    ////
    
    // <delete / insert 系>
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 0 { return false }
        if indexPath.section == 1, indexPath.row == self.numOfSongs  { return false }

        return true
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


extension SetlistViewController: TableViewCellDelegate {
    
    func textFieldDidEndEditing(cell: TableViewCell) {
        self.songNames[cell.tag - 1] = cell.textField.text!
        print(cell.textField.text!)
    }
    
}





