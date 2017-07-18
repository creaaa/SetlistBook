
import UIKit
import TwitterKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        Twitter.sharedInstance().start(
            withConsumerKey:   "Y1TwOLvjn3s4Sm6MaQjD7HHrY", consumerSecret:"ieAyAYIGEnYqWYFC1h0Bn5IoAmKH9CWIG6VbpzNyJkN1HmiAJb")

        return true
    }
    
    
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        return Twitter.sharedInstance().application(app, open: url, options: options)
    }

}
