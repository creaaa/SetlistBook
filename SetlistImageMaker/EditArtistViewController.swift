
import UIKit

final class EditArtistViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    // 前画面から受け渡されるモデル
    var artist: String?
    var place:  String?
    var date:   String?
    
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButtonTapped(_ sender: UIBarButtonItem) {
        
        guard let navVC = self.presentingViewController as? UINavigationController,
            let parentVC = navVC.topViewController as? SetListViewController else {
                self.dismiss(animated: true, completion: nil)
                return
        }
        
        guard let artistCell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? ArtistTableViewCell,
              let placeCell  = self.tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? ArtistTableViewCell,
              let dateCell   = self.tableView.cellForRow(at: IndexPath(row: 2, section: 0)) as? ArtistTableViewCell else {
              self.dismiss(animated: true, completion: nil)
              return
        }
        
        self.artist = artistCell.textField.text
        self.place  = placeCell.textField.text
        self.date   = dateCell.textField.text
        
        parentVC.artistInfoNames.artist = self.artist
        parentVC.artistInfoNames.place  = self.place
        parentVC.artistInfoNames.date   = self.date
        
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
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
}

extension EditArtistViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
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
        } else if indexPath.section == 2 {
            cell.textField.placeholder = "公演日時を入力"
            if let date = self.date {
                cell.textField.text = date //DateUtils.stringFromDate(date: date, format: "yyyy/MM/dd")
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
            case 2:
                return "日付"
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

