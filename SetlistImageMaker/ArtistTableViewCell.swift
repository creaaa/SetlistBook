
import UIKit

class ArtistTableViewCell: UITableViewCell {

    @IBOutlet weak var textField: UITextField!
    weak var delegate: TableViewCellDelegate!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.textField.returnKeyType = .done
        self.textField.delegate      = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}

extension ArtistTableViewCell: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.textField.resignFirstResponder() // これだけでDidEndEditing呼ばれます
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        self.delegate.textFieldDidEndEditing(cell: self)
        return true
    }
    
}
