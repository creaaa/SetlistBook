//
//import UIKit
//
//// なんとこれ、UIViewController批准してないと↓でエラーになる
//// なにが関係あるんか。。
//
//// わかった。NSObject継承でもいける。
//// どうやらNSObjectを継承したクラスを継承していないと、selectorが発信されたとき実行時エラー。
//// と同時に、@NSObjectを継承していないと @objc も使用不可。
//
//class ImageGenerator: NSObject {
//    
//    private func calcFontSize(frameSize: CGRect, text: NSString) -> UIFont {
//        
//        var checkFitFont = true
//        var font         = UIFont.systemFont(ofSize: 1)
//        
//        let textStyle = NSMutableParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
//        // このモードが決めて。ここの設定でboundingRectが返す値が大きく変わる
//        textStyle.lineBreakMode = .byClipping
//        
//        print("ターゲットRext: \(frameSize.size)")
//        
//        var tmpHeight: CGFloat = 0
//
//        while checkFitFont {
//            
//            let textSize = text.boundingRect(with: frameSize.size,
//                                             options: .usesLineFragmentOrigin,
//                                             attributes: [NSFontAttributeName: font,
//                                                          NSParagraphStyleAttributeName: textStyle],
//                                             context: nil)
//            
//            if textSize.height < tmpHeight {
//                print("おら！いい加減にしろ！")
//                break
//            }
//            
//            if textSize.width < frameSize.size.width {
//                font = UIFont.systemFont(ofSize: font.pointSize + 1)
//                print(textSize.width, textSize.height, tmpHeight)
//                tmpHeight = CGFloat(textSize.size.height)
//            } else {
//                font = UIFont.systemFont(ofSize: font.pointSize - 1)
//                checkFitFont = false
//                print("終了: \(textSize.size)")
//            }
//        }
//        
//        print("res: \(font.pointSize)")
//        
//        return font
//
//    }
//    
//    
//    func drawText(image: UIImage) -> UIImage? {
//        
//        
//        // 新しいbitmapのコンテキストのサイズ
//        // ここで指定サイズが、UIGraphicsGetImageFromCurrentImageContext()が返すimageのサイズとなる
//        UIGraphicsBeginImageContext(image.size)
//        
//        ///////////
//        // image //
//        ///////////
//        
//        let imageRect = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
//        
//        // drawによって、コンテキストに描画していく、みたいなイメージか
//        image.draw(in: imageRect)
//        
//        //////////
//        // text //
//        //////////
//        
//        let text =
//            "Some text1..\n" +
//            "Some text2..\n" +
//            "Some text3..\n" +
//            "Some text4..\n" +
//            "Some text5..\n" +
//            "Some text6..\n" +
//            "Some text7..\n" +
//            "Some text8..\n" +
//            "Some text9..\n" +
//            "Some text10..\n" +
//            "Some text11..\n" +
//            "Some text12..\n" +
//            "Some text13..\n" +
//            "Some text14..\n" +
//            "Some text15..\n" +
//            "Some text16..\n" +
//            "Some text17..\n" +
//            "Some text18..\n" +
//            "Some text19..\n" +
//            "Some text20..\n" +
//            "Some text21..\n" +
//            "Some text22..\n" +
//            "Some text23..\n" +
//            "Some text24..\n" +
//            "Some text25..\n" +
//            "Some text26..\n" +
//            "Some text27..\n" +
//            "Some text28..\n" +
//            "Some text29..\n" +
//            "Some text30.."
//
//        
//        //let font = UIFont(name: "Helvetica Neue", size: 16) // OK
//        
//        let textRect =
//            CGRect(x: image.size.width * 0.05, y: image.size.height * 0.05,
//                   width: image.size.width * 0.3, height: image.size.height * 0.85)
//        
//        let font = calcFontSize(frameSize: textRect, text: text as NSString)
//        
//        let textFontAttributes = [
//            NSFontAttributeName: font,
//            NSForegroundColorAttributeName: UIColor.cyan,
//        ]
//        
//        // drawによって、コンテキストに描画していく、みたいなイメージか
//        text.draw(in: textRect, withAttributes: textFontAttributes)
//        
//        // で、最後に、コンテキストからimageを産出するんか
//        let newImage = UIGraphicsGetImageFromCurrentImageContext()
//        
//        // スタックのトップからコンテキストを除去する
//        UIGraphicsEndImageContext()
//        
//        return newImage
//        
//    }
//
//    
//    func savePhoto(image: UIImage) {
//        UIImageWriteToSavedPhotosAlbum(image, self,
//                                    #selector(self.showResultOfSaveImage(_:didFinishSavingWithError:contextInfo:)), nil)
//    }
//    
//    
//    // 保存を試みた結果をダイアログで表示
//    @objc func showResultOfSaveImage(_ image: UIImage, didFinishSavingWithError error: NSError!, contextInfo: UnsafeMutableRawPointer) {
//        
//        var title   = "保存完了"
//        var message = "カメラロールに保存しました"
//        
//        if error != nil {
//            title = "エラー"
//            message = "保存に失敗しました"
//        }
//        
//        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
//        
//        // OKボタンを追加
//        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//        
//        // UIAlertController を表示
//        // self.present(alert, animated: true, completion: nil)
//    }
//    
//}
