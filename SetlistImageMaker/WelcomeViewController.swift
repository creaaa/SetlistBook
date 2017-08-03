
import UIKit
import RealmSwift

final class WelcomeViewController: UIViewController {

    var realm =   try! Realm()
    
    var setlists: Results<Setlist>!    
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        
        guard let navigationVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SetList") as? UINavigationController,
            let vc = navigationVC.viewControllers.first as? SetListViewController else { return }
        
        vc.setlist = makeNewSetlist()
        
        self.present(navigationVC, animated: true, completion: nil)
        
    }
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        tableView.delegate   = self
        tableView.dataSource = self
        
        self.navigationItem.leftBarButtonItem = editButtonItem

        self.tableView.rowHeight  = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 44
        
        // Realmのパス
        print(Realm.Configuration.defaultConfiguration.fileURL!)
                
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        self.setlists = realm.objects(Setlist.self).sorted(byKeyPath: "artist")  //.sorted { $0.artist < $1.artist }

        self.setlists.forEach { print($0.id) }
        
        if let selectedRow = self.tableView.indexPathForSelectedRow {
            self.tableView.deselectRow(at: selectedRow, animated: true)
        }
        
        self.tableView.reloadData()
        
    }
    
        
    override func viewDidDisappear(_ animated: Bool) {
        // 長年の謎が解けた....テーブルだけでなくVCもisEditingを持っていた、だと.....
        self.isEditing = false
    }
    
    
    // + ボタンを使って遷移するときのため、次の画面に渡されるセットリストを生成
    private func makeNewSetlist() -> Setlist {
        let main = Songs(songs: [])
        let newSetlist = Setlist(mainSongs: main)
        return newSetlist
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}


extension WelcomeViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "SetList")
            as? UINavigationController else { return }
        
        if let setlistVC = vc.viewControllers.first as? SetListViewController {
            setlistVC.setlist = self.setlists[indexPath.row]
        }
        
        present(vc, animated: true, completion: nil)
        
    }
    
}


extension WelcomeViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.setlists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.textLabel?.text = self.setlists[indexPath.row].artist
        
        var str = ""
        str.append(self.setlists[indexPath.row].place ?? "")
        if str != "" { str.append(" / ") }
        
        
        if let date = self.setlists[indexPath.row].date {
            str.append(DateUtils.stringFromDate(date: date, format: "yyyy/MM/dd"))
        }
        
        cell.detailTextLabel?.text = str != "" ? str : nil
        
        return cell
        
    }
    
    
    // 編集ボタンを押したときのコールバック
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        self.tableView.isEditing = editing
    }
    
    // 削除を許可(移動したい場合もここをONにしないとダメよ)
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
            case .delete:
                try! realm.write {
                    realm.delete(self.setlists[indexPath.row])
                }
                self.tableView.reloadData()
            
            default:
                break
        }
    }
    
}


