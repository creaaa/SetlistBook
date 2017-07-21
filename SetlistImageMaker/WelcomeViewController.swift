
import UIKit
import RealmSwift

final class WelcomeViewController: UIViewController {

    var realm =   try! Realm()
    var setlists: Results<Setlist>!

    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        
        guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SetList")
            as? UINavigationController else { return }
        
        self.present(vc, animated: true, completion: nil)
        
    }
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        tableView.delegate   = self
        tableView.dataSource = self
        
        self.tableView.rowHeight  = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 44
        
        // Realmのパス
        print(Realm.Configuration.defaultConfiguration.fileURL!)
        
        self.setlists = realm.objects(Setlist.self)
        
        print(self.setlists.count)
        
    }
    
    
    func testInjection() {
        
        /*
        let songs1: Songs = Songs(value: List<Song>())
        
        let list1 = List<Songs>()
        list1.append(songs1)
        
        
        let mySetlist1 = Setlist(id: 1, artist: "Alice", place: "横浜アリーナ", date: Date(), songs: songs1, encoreSongs: list1)
        
        let mySetlist2 = Setlist(id: 2, artist: "Bob", place: "日本武道館", date: Date(),
                                 songs: songs1, encoreSongs: list1)
        
        let mySetlist3 = Setlist(id: 3, artist: "Calin", place: "新宿JAM", date: Date(),
                                 songs: songs1, encoreSongs: list1)
        
        try! realm.write {
            realm.add(mySetlist1)
            realm.add(mySetlist2)
            realm.add(mySetlist3)
        }
        */
        
    }
    
}


extension WelcomeViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
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
        
        let date = self.setlists[indexPath.row].date
        str.append(DateUtils.stringFromDate(date: date!, format: "yyyy/MM/dd") ?? "")
        
        cell.detailTextLabel?.text = str != "" ? str : nil
        
        return cell
        
    }
    
}







