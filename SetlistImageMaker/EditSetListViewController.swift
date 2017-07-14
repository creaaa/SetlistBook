
import UIKit

class EditSetListViewController: UIViewController {

    override func viewDidLoad() {
        
        super.viewDidLoad()

    }
    
    /*
    func inputFromHistory(sender: UITapGestureRecognizer) {
        if let cell = sender.view as? UITableViewCell {
            let ip = IndexPath(row: selectedCellNo! - 1, section: 1)
            if let c = self.tableView.cellForRow(at: ip) as? TableViewCell {
                c.textField.text = cell.textLabel?.text
            }
        }
        self.suggestTableView.removeFromSuperview()
    }
    */
    
    
}

//
//if tableView.tag == 100 {
//    let cell = UITableViewCell(style: .default, reuseIdentifier: "SuggestCell")
//    cell.textLabel?.text = "ksg"
//    cell.addGestureRecognizer(
//        UITapGestureRecognizer(target: self,
//                               action: #selector(inputFromHistory(sender:))))
//    return cell
//}
