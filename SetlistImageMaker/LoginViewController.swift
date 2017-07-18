
import UIKit
import Accounts
import Social


class LoginViewController: UIViewController {

    var accountStore = ACAccountStore()
    var twAccount:     ACAccount?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        selectTwitterAccount()
    }
    
    
    private func selectTwitterAccount() {
        
        // 認証するアカウントのタイプを選択（他にはFacebookやWeiboなどがある）
        let accountType = accountStore.accountType(withAccountTypeIdentifier: ACAccountTypeIdentifierTwitter)
        
        accountStore.requestAccessToAccounts(with: accountType, options: nil) { isGranted, error in
            
            guard error == nil else {
                print("error! \(error)")
                return
            }
            
            guard isGranted else {
                print("error! Twitterアカウントの利用が許可されていません")
                self.promptGrantTweet()
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
        accounts.forEach { account in
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
        let params = ["status" : "new msg from web API..."]
        
        // リクエストを生成
        let request = SLRequest(forServiceType: SLServiceTypeTwitter,
                                requestMethod: .POST,
                                url: url,
                                parameters: params)
        
        // 取得したアカウントをセット
        request?.account = twAccount
        
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
    
    
    private func promptGrantTweet() {
        
        let alertController = UIAlertController(title: "not admitted tweet",
                                                message: "please admit tweeting in pref scene",
                                                preferredStyle: .alert)
       
        alertController.addAction(UIAlertAction(title: "Later", style: .default) { action in
            
            }
        )

        alertController.addAction(UIAlertAction(title: "Setting", style: .cancel) { action in
            
            // ここ、「A」ppって大文字にしないと遷移しない。無反応。
            if let url = URL(string:"App-prefs:root=TWITTER") {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    print("ks")
                } else {
                    UIApplication.shared.openURL(url)
                    print("nnkr")
                }
            }
        })

        present(alertController, animated: true, completion: nil)
    
    }
    
}



