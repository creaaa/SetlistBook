
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
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func prepareForReuse() {
        // self.textField.text = ""
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






