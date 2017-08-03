
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    
        let fontName = "HigashiOme-Gothic"  //"Quicksand"
        
        // ナビゲーションバーのタイトル
        UINavigationBar.appearance().titleTextAttributes =
            [NSForegroundColorAttributeName: UIColor(red:0.96, green:0.96, blue:0.96, alpha:1.0),
            NSFontAttributeName: UIFont(name: fontName, size: 18) as Any
            ]
        
        // ナビゲーションバーの背景色
        UINavigationBar.appearance().barTintColor = UIColor(red:0.22, green:0.62, blue:0.67, alpha:1.0)
        
        // ナビゲーションバー・ボタンの設定
        
        UIBarButtonItem.appearance().setTitleTextAttributes(
        [ NSFontAttributeName: UIFont(name: fontName, size: 16) as Any,
        NSForegroundColorAttributeName: UIColor(red:0.96, green:0.96, blue:0.96, alpha:1.0)
        ],
        for: .normal)
        
        return true
        
    }
    
}
