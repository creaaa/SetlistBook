
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
    dynamic var date : Date?
    
    // 本編
    dynamic var songs:       [String]   = []
     
    // アンコール群
    dynamic var encoreSongs: [[String]]?
    
    /**
     id をプライマリーキーとして設定
     */
    override static func primaryKey() -> String? {
        return "id"
    }
    
}







