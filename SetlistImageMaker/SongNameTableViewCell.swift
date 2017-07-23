
import UIKit

@objc protocol TableViewCellDelegate: NSObjectProtocol {
    @objc optional func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool
    func textFieldDidEndEditing(cell: UITableViewCell)
    @objc optional func textFieldNextButtonTapped(cell: UITableViewCell)
}

final class SongNameTableViewCell: UITableViewCell {

    @IBOutlet weak var textField: UITextField!

    weak var delegate: TableViewCellDelegate!

    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        self.textField.returnKeyType = .done
        self.textField.delegate = self
        
        makeKeyboard()
        
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
        
        /*
        let nextButton = UIBarButtonItem(title:  "next",
                                         style:  .done,
                                         target: self,
                                         action: #selector(nextButtonTapped))
        */
        
        kbToolBar.items = [spacer, doneButton]
        
        self.textField.inputAccessoryView = kbToolBar
        
    }
    
    func doneButtonTapped() {
        textField.resignFirstResponder()
    }

    
    func nextButtonTapped() {
        print("next")
        self.delegate.textFieldNextButtonTapped?(cell: self)
    }
    
}


extension SongNameTableViewCell: UITextFieldDelegate {
    
    // 開始時
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        _ = self.delegate.textFieldShouldBeginEditing?(textField)
        return true
    }
    
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
        
        return true // ここfalseにすると、キー押しても文字入力されなくなるな..?
    }
    
    
    
}

