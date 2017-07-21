
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
    var mainSongs   = List<Songs>()
    // アンコール群
    var encoreSongs = List<EncoreSongs>()
    
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
    
    required convenience init(mainSongs: [Songs], encoreSongs: [EncoreSongs]) {
        
        self.init()
        
        let result1 = List<Songs>()
        mainSongs.forEach { result1.append($0) }
        self.mainSongs = result1

        
        let result2 = List<EncoreSongs>()

        // 「アンコール1」に対し...
        encoreSongs.forEach {
            result2.append($0)
        }
        
        self.encoreSongs = result2
    
    }
    
}


// 「アンコール1」「アンコール2」...みたいな、1セクションごとの曲の集まり
class EncoreSongs: Object {
    
    var encoreSongs = List<Songs>()
    
    required convenience init(encoreSongs: [[Songs]]) {
        
        self.init()
        
        let result = List<Songs>()
        
        // 「アンコール1」(1つぶん)が持つ曲群に対し,,,
        for eachEncoreSongs: [Songs] in encoreSongs {
            eachEncoreSongs.forEach {
                // $0: Songs
                result.append($0)
            }
        }
        
        self.encoreSongs = result
        
    }
    
}


// 「本編」
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








