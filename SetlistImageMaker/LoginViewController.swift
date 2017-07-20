
import UIKit
import Accounts
import Social


class LoginViewController: UIViewController {

    var accountStore = ACAccountStore()
    var twAccount:     ACAccount?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
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
                self.dismiss(animated: true, completion: nil)
                return
            }
            
            // 取得したアカウントで処理を行う...
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
                    self.postSetList()
                }
            )
        }
        
        // キャンセルボタン
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            self.dismiss(animated: true, completion: nil)
        })
        
        // 表示する
        present(alert, animated: true, completion: nil)
        
    }
    

    
    private func postSetList() {
    
        let vc = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
        
        vc?.setInitialText("hello!")
        
        // vc?.add(#imageLiteral(resourceName: "fever"))
    
        vc?.completionHandler = {
            switch $0 {
                case .done:
                    print("done")
                case .cancelled:
                    print("cancel!おら")
            }
            // これ、2行書かないとだめ。すげー不可解だけど
            self.dismiss(animated: true, completion: nil)
            self.dismiss(animated: true, completion: nil)
        }
        
        
        present(vc!, animated: true, completion: nil)
        
    }
    
    
    private func promptGrantTweet() {
        
        let alertController = UIAlertController(title: "not admitted tweet",
                                                message: "please admit tweeting in pref scene",
                                                preferredStyle: .alert)
       
        alertController.addAction(UIAlertAction(title: "Later", style: .default, handler: nil))

        alertController.addAction(UIAlertAction(title: "Setting", style: .cancel) { action in
            
            // ここ、「A」ppって大文字にしないと遷移しない。無反応。気をつけてね
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





