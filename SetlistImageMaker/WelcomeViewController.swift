
import UIKit
import RealmSwift

final class WelcomeViewController: UIViewController {

    var realm =   try! Realm()
    
    // var setlists: Results<Setlist>!
    var setlists: [Setlist]!
    
    
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
        
        self.tableView.rowHeight  = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 44
        
        // Realmのパス
        print(Realm.Configuration.defaultConfiguration.fileURL!)
        
        // testInjection()
        
        // self.setlists = realm.objects(Setlist.self).sorted { $0.id < $1.id }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        self.setlists = realm.objects(Setlist.self).sorted { $0.artist < $1.artist }

        self.setlists.forEach {
            print($0.id)
        }
        
        if let selectedRow = self.tableView.indexPathForSelectedRow {
            self.tableView.deselectRow(at: selectedRow, animated: true)
        }
        
        self.tableView.reloadData()
        
    }
    
    // + ボタンを使って遷移するときのため、次の画面に渡されるセットリストを生成
    private func makeNewSetlist() -> Setlist {
        
        let main = Songs(songs: [])

        let newSetlist = Setlist(mainSongs: main)
        
        // newSetlist.id = 1
        // newSetlist.id = UUID().uuidString
        
        /*
        newSetlist.artist = "Indigo la End"
        newSetlist.place  = "Zepp Tokyo"
        newSetlist.date   = Date()
        */
        
        try! realm.write {
            realm.add(newSetlist)
            print("addしました")
        }
        
        return newSetlist
        
    }
    
    private func testInjection() {
        
        do {
            try self.realm.write {
                
                let song1 = Song(songName: "キスする前に")
                let song2 = Song(songName: "深海冷蔵庫")
                let song3 = Song(songName: "17の月")
                
                let song4 = Song(songName: "ジェット")
                let song5 = Song(songName: "トンネル")
                /*
                let song6 = Song(songName: "えりあし")
                */
                
                let main    = Songs(songs: [song1, song2, song3])
                /*
                let encore1 = Songs(songs: [song4, song5])
                let encore2 = Songs(songs: [song6])
                */
                
                // こっちはOK
                // let newSetlist = Setlist(mainSongs: main)
                
                // こっちは?
                let newSetlist = Setlist(mainSongs: main, encoreSongs: [])
                
                ////////////
                
                // newSetlist.id     = UUID().uuidString
                newSetlist.artist = "aiko"
                newSetlist.place  = "Zepp Tokyo"
                newSetlist.date   = Date()
                
                realm.add(newSetlist)
                
                print("はい、セーブできてるはず")
                
            }
        } catch {
        }
        
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
            str.append(DateUtils.stringFromDate(date: date, format: "yyyy/MM/dd") ?? "")
        }
        
        cell.detailTextLabel?.text = str != "" ? str : nil
        
        return cell
        
    }
    
}


