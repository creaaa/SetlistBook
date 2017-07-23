
import UIKit

final class ArtistTableViewCell: UITableViewCell {

    @IBOutlet weak var textField: UITextField!
              weak var delegate:  TableViewCellDelegate!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.textField.returnKeyType = .done
        self.textField.delegate      = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // くそだせぇ..
    var date: Date?
    

}


extension ArtistTableViewCell: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        // セルがアーティスト・場所なら何もせず、日時の場合のみピッカーを表示
        guard textField.tag == 3 else { return }
        
        let datePickerView  = UIDatePicker()
        datePickerView.datePickerMode = .date
        
        textField.inputView = datePickerView
        
        // ピッカー
        let frame = CGRect(x: 0.0, y: 0.0,
                           width: 375, height: 40.0)
        let pickerToolBar = UIToolbar(frame: frame)
        
        //ボタンの設定
        //右寄せのためのスペース設定
        let spaceBarBtn = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                          target: self, action: nil)
        
        //完了ボタンを設定
        let toolBarBtn  = UIBarButtonItem(title: "Done", style: .done,
                                          target: self, action: #selector(doneButtonTapped(sender:)))
        
        //ツールバーにボタンを表示
        pickerToolBar.items = [spaceBarBtn, toolBarBtn]
        
        textField.inputAccessoryView = pickerToolBar
        
        /// くそだせぇ
        // self.date = Date()
        
        datePickerView.addTarget(self, action: #selector(valueChanged(sender:)), for: .valueChanged)
        
    }
    
    func valueChanged(sender: UIDatePicker) {
        self.date = sender.date
        self.textField.text = DateUtils.stringFromDate(date: sender.date, format: "yyyy/MM/dd")
    }
    
    // 日付ピッカーに付随する完了ボタンの方ね。
    func doneButtonTapped(sender: UIBarButtonItem) {
        self.textField.text = DateUtils.stringFromDate(date: self.date ?? Date(), format: "yyyy/MM/dd")
        
        self.textField.resignFirstResponder() // これだけでDidEndEditing呼ばれます
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.textField.resignFirstResponder() // これだけでDidEndEditing呼ばれます
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        self.delegate.textFieldDidEndEditing(cell: self)
        return true
    }
    
}
