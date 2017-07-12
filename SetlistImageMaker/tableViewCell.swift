
import UIKit

protocol TableViewCellDelegate: class {
     func textFieldDidEndEditing(cell: TableViewCell)
}

final class TableViewCell: UITableViewCell {

    @IBOutlet weak var textField: UITextField!

    weak var delegate: TableViewCellDelegate!

    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        textField.returnKeyType = .done
        textField.delegate = self
        
        makeKeyboard()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
  
    private func makeKeyboard() {
        
        // 仮のサイズでツールバー生成
        let kbToolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 40))
        kbToolBar.barStyle = .default  // スタイルを設定
        
        kbToolBar.sizeToFit()  // 画面幅に合わせてサイズを変更
        
        // スペーサー(これがないと他要素が左詰めされる、それでいいなら別にいらない)
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        
        // 閉じるボタン
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done,
                                           target: self,
                                           action: #selector(doneButtonTapped))
        
        
        let nextButton = UIBarButtonItem(title:  "next",
                                           style:  .done,
                                           target: self,
                                           action: #selector(nextButtonTapped))
        
        kbToolBar.items = [doneButton, spacer, nextButton]
        
        self.textField.inputAccessoryView = kbToolBar
        
    }
    
    func doneButtonTapped() {
        textField.resignFirstResponder()
    }

    func nextButtonTapped() {
        print("next")
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
    
    // 1文字入力完了するごとに呼ばれる
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        print("うんうん")
        
        
        
        return false
    }
    
    
}






