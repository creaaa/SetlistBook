
import UIKit

import Accounts
import Social
// import TwitterKit


class LoginViewController: UIViewController {

    var accountStore = ACAccountStore()
    var twAccount: ACAccount?
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        selectTwitterAccount()
        
        // onPostTwitter()
        
        /*
        let logInButton = TWTRLogInButton{ session, error in
            if let session = session {
                // self.callback(session)
                self.onPostTwitter()
            } else {
                print("error: \(error?.localizedDescription)");
            }
        }
 
        logInButton.center = self.view.center
        self.view.addSubview(logInButton)
        */
        
        
        /*
        Twitter.sharedInstance().logIn{ session, error in
            if (session != nil) {
                print("signed in as \(session?.userName)");
            } else {
                print("error: \(error?.localizedDescription)");
            }
        }
        */
        
    }
    
    
    /*
    func callback(_ session: TWTRSession) {
        
        print("おら", session.userName, session.userID)
        let client = TWTRAPIClient()
        client.loadUser(withID: "212259458") { user, error in
            print(user?.name)
        }
    }
    */
    
    /*
    // 投稿する
    func onPostTwitter() {
        Twitter.sharedInstance().logIn { session, error in
            guard let _ = session else { return }
            let composer = TWTRComposer()
            composer.setText("投稿メッセージ")
            // 投稿終了時のコールバック
            composer.show(from: self) {_ in print("投稿完了") }
        }
    }
    */
    
    
    private func selectTwitterAccount() {
        
        // 認証するアカウントのタイプを選択（他にはFacebookやWeiboなどがある）
        let accountType = accountStore.accountType(withAccountTypeIdentifier: ACAccountTypeIdentifierTwitter)
        
        accountStore.requestAccessToAccounts(with: accountType, options: nil) { granted, error in
            
            guard error == nil else {
                print("error! \(error)")
                return
            }
            
            guard granted else {
                
                print("error! Twitterアカウントの利用が許可されていません")
                
                let url = URL(string: UIApplicationOpenSettingsURLString)
                UIApplication.shared.openURL(url!)
                
                return
            }
            
            let accounts = self.accountStore.accounts(with: accountType) as! [ACAccount]
            
            guard accounts.count != 0 else {
                print("error! 設定画面からアカウントを設定してください")
                return
            }
            
            // 取得したアカウントで処理を行う...
            print(accounts[0].username)
            print(accounts[1].username)
            
            self.showAccountSelectSheet(accounts: accounts)

        }
    }
    
    
    // アカウント選択のActionSheetを表示する
    private func showAccountSelectSheet(accounts: [ACAccount]) {
        
        let alert = UIAlertController(title: "Twitter",
                                      message: "アカウントを選択してください",
                                      preferredStyle: .actionSheet)
        
        // アカウント選択のActionSheetを表示するボタン
        for account in accounts {
            alert.addAction(
                UIAlertAction(title: account.username, style: .default) { action in
                    print("your select account is \(account)")
                    self.twAccount = account
                    
                    self.postTweet()
                    
                }
            )
        }
        
        // キャンセルボタン
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        // 表示する
        self.present(alert, animated: true, completion: nil)
        
    }
    
    
    // タイムラインを取得する
    private func getTimeline() {
        
        let url = URL(string: "https://api.twitter.com/1.1/statuses/user_timeline.json")
        
        // GET/POSTやパラメータに気をつけてリクエスト情報を生成
        let request = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: .GET, url: url, parameters: nil)
        
        // 認証したアカウントをセット
        request?.account = self.twAccount
        
        // APIコールを実行
        request?.perform { responseData, urlResponse, error in
            
            guard error == nil else {
                print("error is \(error)")
                return
            }

            // 結果の表示
            let result = try? JSONSerialization.jsonObject(with: responseData!, options: .allowFragments)
                
            print("result is \(result)")
            
        }
    }
    
    
    // ツイートを投稿
    private func postTweet() {
        
        let url = URL(string: "https://api.twitter.com/1.1/statuses/update.json")
        
        // ツイートしたい文章をセット
        let params = ["status" : "Tweet from API"]
        
        // リクエストを生成
        let request = SLRequest(forServiceType: SLServiceTypeTwitter,
                                requestMethod: .POST,
                                url: url,
                                parameters: params)
        
        // 取得したアカウントをセット
        request?.account = twAccount
        
        // APIコールを実行
        request?.perform { responseData, urlResponse, error in
            
            guard error != nil else {
                print("error is \(error)")
                return
            }
            
            // 結果の表示
            let result = try? JSONSerialization.jsonObject(with: responseData!, options: .allowFragments)
            
            print("result is \(result)")
            
        }
    }
    
}


