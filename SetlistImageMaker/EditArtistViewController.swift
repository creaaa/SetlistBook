
import UIKit

final class EditArtistViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    // 前画面から受け渡されるモデル
    var artist: String!
    var place:  String!
    
    
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButtonTapped(_ sender: UIBarButtonItem) {
        
        guard let navVC = self.presentingViewController as? UINavigationController,
            let parentVC = navVC.topViewController as? SetListViewController else { return }
        
        var indexPath = IndexPath(row: 0, section: 0)
            
        guard let cell1 = self.tableView.cellForRow(at: indexPath) as? ArtistTableViewCell else {
            return
        }
        
        parentVC.artistInfoNames.artist = cell1.textField.text!
            
        indexPath = IndexPath(row: 0, section: 1)
        
        guard let cell2 = self.tableView.cellForRow(at: indexPath) as? ArtistTableViewCell else {
            return
        }
        
        parentVC.artistInfoNames.place = cell2.textField.text!

        self.dismiss(animated: true, completion: nil)
        
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        tableView.delegate   = self
        tableView.dataSource = self
        
        
        self.tableView.rowHeight  = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 44
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

extension EditArtistViewController: UITableViewDelegate {
    
}

extension EditArtistViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            as! ArtistTableViewCell
        
        if indexPath.section == 0 {
            cell.textField.placeholder = "アーティスト名を入力"
            if let artist = self.artist {
                cell.textField.text = artist
            }
        } else if indexPath.section == 1 {
            cell.textField.placeholder = "公演情報を入力"
            if let place = self.place {
                cell.textField.text = place
            }
        }
        
        
        cell.delegate = self

        return cell
        
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        switch section {
            case 0:
                return "アーティスト名"
            case 1:
                return "公演情報"
            default:
                fatalError()
        }
        
    }
}

extension EditArtistViewController: TableViewCellDelegate {
    
    func textFieldDidEndEditing(cell: UITableViewCell) {
        print("unk")
    }
    
}





