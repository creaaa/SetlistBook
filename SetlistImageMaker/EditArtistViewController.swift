
import UIKit
import RealmSwift

final class EditArtistViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    // 前画面から受け渡されるモデル
    var setlist: Setlist!
    
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButtonTapped(_ sender: UIBarButtonItem) {
        
        /*
        guard let navVC = self.presentingViewController as? UINavigationController,
            let parentVC = navVC.topViewController as? SetListViewController else {
                self.dismiss(animated: true, completion: nil)
                return
        }
        */
        
        guard let artistCell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? ArtistTableViewCell,
              let placeCell  = self.tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? ArtistTableViewCell,
              let dateCell   = self.tableView.cellForRow(at: IndexPath(row: 0, section: 2)) as? ArtistTableViewCell else {
              self.dismiss(animated: true, completion: nil)
              return
        }
        
        
        if artistCell.textField.text == "" || artistCell.textField.text == nil {
            
            let alert = UIAlertController(title: "Save Failed...", message: "Input artist name.", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK",     style: .default, handler: nil))

            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
            }
            
            return
            
        }
        
        
        try! Realm().write {
            
            if let artist = artistCell.textField.text, artist != "" {
                self.setlist.artist = artist
            }
            
            self.setlist.place = nil

            if let place = placeCell.textField.text, place != "" {
                self.setlist.place = place
            }
            
            self.setlist.date = nil
            
            if let date = dateCell.textField.text, date != "" {
                self.setlist.date = DateUtils.dateFromString(string: date, format: "YYYY-MM-dd")
            }
            
            
            try! Realm().add(self.setlist)
            
        }
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        tableView.delegate   = self
        tableView.dataSource = self
        
        self.tableView.rowHeight  = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 44
        
        print("受け渡されてきたsetlist: \(self.setlist)")
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
 
}


extension EditArtistViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
}

extension EditArtistViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int { return 3 }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return 1 }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            as! ArtistTableViewCell
        
        switch indexPath.section {
            case 0:
                cell.textField.placeholder = "input artist name"
                cell.textField.text = self.setlist.artist
            case 1:
                cell.textField.placeholder = "Input live info"
                cell.textField.text = self.setlist.place
            case 2:
                cell.textField.placeholder = "input date"
                if let date = self.setlist.date {
                    cell.textField.text = DateUtils.stringFromDate(date: date, format: "YYYY-MM-dd")
                }
            default:
                fatalError("never executed")
        }
        
        cell.textField.tag = indexPath.section + 1
        cell.delegate = self

        return cell
        
    }

    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        switch section {
            case 0:
                return "artist name"
            case 1:
                return "place"
            case 2:
                return "date"
            default:
                fatalError()
        }
        
    }
}

extension EditArtistViewController: TableViewCellDelegate {
    
    func textFieldDidEndEditing(cell: UITableViewCell) {
    }
    
}



