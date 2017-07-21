
/*

import Foundation  // dynamicを使うために必須
import RealmSwift

class City: Object {
    
    // 管理用ID。プライマリーキー
    dynamic var id = 0
    dynamic var name = ""
    dynamic var timeZone = ""
    dynamic var isSelected = false
    
    dynamic var orderNo = -1
    
    /**
     id をプライマリーキーとして設定
     */
    override static func primaryKey() -> String? {
        return "id"
    }
    
    // Realmオブジェクトにイニシャライザを設定するには、この書き方でないとダメ
    convenience init(id: Int, name: String, timeZone: String, isSelected: Bool = false) {
        
        self.init()
        
        self.id = id
        self.name = name
        self.timeZone = timeZone
        self.isSelected = isSelected
        
    }
}

*/


import Foundation  // dynamicを使うために必須
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
    var encoreSongs: [List<Songs>] = []
    
    
    /**
     id をプライマリーキーとして設定
     */
    override static func primaryKey() -> String? {
        return "id"
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
    let songs = List<Song>()
}

class Song: Object {
    dynamic var name = ""
}








