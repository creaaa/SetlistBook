
import UIKit

protocol TableViewCellDelegate {
     func textFieldDidEndEditing(cell: TableViewCell)
}

final class TableViewCell: UITableViewCell {

    @IBOutlet weak var textField: UITextField!

    var delegate: TableViewCellDelegate!

    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        textField.delegate = self
        
        makeKeyboard()
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func prepareForReuse() {
        // self.textField.text = ""
    }
    
    func makeKeyboard(){
        // 仮のサイズでツールバー生成
        let kbToolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 40))
        kbToolBar.barStyle = .default  // スタイルを設定
        
        kbToolBar.sizeToFit()  // 画面幅に合わせてサイズを変更
        
        // スペーサー
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        
        // 閉じるボタン
        let commitButton = UIBarButtonItem(barButtonSystemItem: .done,
                                           target: self,
                                           action: #selector(commitButtonTapped))
        
        kbToolBar.items = [spacer, commitButton]
        self.textField.inputAccessoryView = kbToolBar
    }
    
    func commitButtonTapped(){
        textField.resignFirstResponder()
        
    }

}

extension TableViewCell: UITextFieldDelegate {
    
    // ただのキーボードキャンセル処理
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.textField.resignFirstResponder() // これだけでDidEndEditing呼ばれます
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.delegate.textFieldDidEndEditing(cell: self)
    }
    
}






