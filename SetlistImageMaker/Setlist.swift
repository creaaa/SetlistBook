
import Foundation  // dynamicを使うために必須
import Realm
import RealmSwift

class Setlist: Object {
    
    // 管理用ID。プライマリーキー
    dynamic var id = 0
    
    dynamic var artist = ""
    dynamic var place  = ""
    dynamic var date:  Date?
    
    // ここ、無理やりListにしないと落ちる
    
    // 本編
    var mainSongs = List<Songs>()
    // アンコール群
    var encores   = List<Encores>()
    
    /**
     id をプライマリーキーとして設定
     */
    override static func primaryKey() -> String? {
        return "id"
    }
    
    required convenience init(mainSongs: Songs) {
        
        self.init()
        
        let result = List<Songs>()
        result.append(mainSongs)
        
        self.mainSongs = result
        
    }
    
    /*
    required convenience init(mainSongs: [Songs], encoreSongs: [[Songs]]) {
        
        
        self.init()
        
        let result1 = List<Songs>()
        mainSongs.forEach { result1.append($0) }
        self.mainSongs = result1

        
        let result2 = Encores()

        // 「アンコール1」に対し...
        encoreSongs.forEach {
            // 「アンコール1が持つ曲の1曲」に対し...
            var encore: Encores = Encores(encores: $0)
        }
        
        self.encores = result2
        
    }
     */
    
}


// アンコール群
class Encores: Object {
    
    var encores = List<Songs>()
    
    required convenience init(encores: [Songs]) {
        
        self.init()
        
        let result = List<Songs>()
        encores.forEach { result.append($0) }
        
        self.encores = result
        
    }
    
}


// 「本編」「アンコール1」「アンコール2」など、それぞれがのセクションが持つ曲リスト
class Songs: Object {
    
    var songs = List<Song>()
    
    required convenience init(songs: [Song]) {
        
        self.init()
        
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








