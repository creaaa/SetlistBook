
import Foundation  // dynamicを使うために必須
import Realm
import RealmSwift

class Setlist: Object {
    
    // 管理用ID。プライマリーキー
    dynamic var id = 0
    
    dynamic var artist = ""
    dynamic var place  = ""
    dynamic var date:  Date?
    
    // 本編
    var mainSongs = List<Songs>()
    // アンコール群
    var encoreSongs: [List<Songs>] = []
    
    
    /**
     id をプライマリーキーとして設定
     */
    override static func primaryKey() -> String? {
        return "id"
    }
    
    required convenience init(mainSongs: [Songs]) {
        
        self.init()
        
        let result = List<Songs>()
        mainSongs.forEach { result.append($0) }
        
        self.mainSongs = result
        
    }
    
    required convenience init(mainSongs: [Songs], encoreSongs: [[Songs]]) {
        
        self.init()
        
        let result1 = List<Songs>()
        mainSongs.forEach { result1.append($0) }
        self.mainSongs = result1

        
        var result2: [List<Songs>] = []

        for elm in encoreSongs {
            let tmp = List<Songs>()
            elm.forEach { tmp.append($0) }
            result2.append(tmp)
        }
        
        self.encoreSongs = result2
    
    }
    
    
    /*
    required convenience init(id: Int, artist: String, place: String, date: Date,
                              songs: List<Songs>, encoreSongs: List<Songs>) {
        
        self.init()
        
        //self.init()
        
        self.id     = id
        self.artist = artist
        self.place  = place
        self.date   = date
        
        self.mainSongs   = songs
        self.encoreSongs = encoreSongs
        
    }
    */
  
    
}

// 「本編」「アンコール1」...みたいな、1セクションごとの曲の集まり
class Songs: Object {
    
    var songs = List<Song>()
    
    required convenience init(songs: [Song]) {
        
        self.init()
        
        // self.songs = songs
        
        let result = List<Song>()
        
        songs.forEach {
            result.append($0)
        }
        
        self.songs = result
        
    }
    
}


class Song: Object {
    
    dynamic var name = ""
    
    required convenience init(songName: String) {
        self.init()
        self.name = songName
    }
    
}








