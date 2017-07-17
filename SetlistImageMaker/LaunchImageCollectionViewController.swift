
import UIKit

final class LaunchImageCollectionViewController: UIViewController {

    let filterNames = [
        "CIPhotoEffectChrome",
        "CIPhotoEffectFade",
        "CIPhotoEffectInstant",
        "CIPhotoEffectNoir",
        "CIPhotoEffectProcess",
        "CIPhotoEffectTonal",
        "CIPhotoEffectTransfer",
        "CISepiaTone"
    ]
    
    @IBOutlet weak var imageView:  UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    let ciContext  = CIContext(options: nil)
    
    //= yieldFilters() // lazyだからといってインスタンスメソッドが使えるわけじゃない.
    // selfが使えるようになるだけ
    var filter: [CIFilter]!
    
    
    @IBAction func launch(_ sender: UIButton) {
        
        // ライブラリかカメラ、どっちを使うか尋ねる
        let alert = UIAlertController(title: nil, message: "Choose resource you use...",
                                      preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Camera",  style: .default, handler: launchVC))
        alert.addAction(UIAlertAction(title: "Library", style: .default, handler: launchVC))
        alert.addAction(UIAlertAction(title: "Cancel",  style: .cancel,  handler: nil))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    
    private func launchVC(_ action: UIAlertAction) {
        switch action.title! {
            case "Camera":
                igniteVC(.camera)
            case "Library":
                igniteVC(.photoLibrary)
            default:
                fatalError()
        }
    }
    
    private func igniteVC(_ type: UIImagePickerControllerSourceType) {
        
        guard UIImagePickerController.isSourceTypeAvailable(type) else { return }
        
        let pickerController = UIImagePickerController()
        pickerController.delegate   = self
        pickerController.sourceType = type
        present(pickerController, animated: true, completion: nil)

    }
    
    
    // setlistボタンを押すと呼ばれる
    @IBAction func addSetlist(_ sender: UIBarButtonItem) {
        guard let image = self.imageView.image else { return }
        self.imageView.image = drawText(image: image)
    }
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.filter = yieldFilters()
        
        scrollViewSetup { result in
            result.forEach { self.scrollView.addSubview($0); print("とおった") }
        }
        
    }
    
    
    // 各フィルターボタンがタップされた
    func filterButtonTapped(_ sender: UIButton) {
        // まず、フィルタされた画像をセットして...
        self.imageView.image = sender.backgroundImage(for: UIControlState())
        // その上にセットリストをadd!
        // self.imageView.image = drawText(image: self.imageView.image!)
    }
    

    /*
    private func filter() {
        
        // image が 元画像のUIImage
        guard let image = self.imageView.image else { return }
        
        // step 1: UIImage → CIImage へ変換
        // ここでCIImageを生成しない(UIImageのままやっちゃう)と後続でエラーになる
        let ciImage = CIImage(image: image)
        
        
        // https://developer.apple.com/library/content/documentation/GraphicsImaging/Reference/CoreImageFilterReference/index.html#//apple_ref/doc/filter/ci/CILanczosScaleTransform
        
        // step 2: CIFilterを作成（今回はモノクロ風フィルタをかけます）
        let ciFilter = CIFilter(name: "CIPhotoEffectNoir")!
        
        // フィルタによっては、強度や露光量などのパラメータを設定できるものもあります。
        // その場合は、このように、CIFilterオブジェクトにセットしていけばOK
        
        // どんなフィルターを使っても、このパラメータは絶対必要なはず
        ciFilter.setValue(ciImage, forKey: kCIInputImageKey)
        
        // あとは、フィルターの種類によっては、パラメータ取れる
        /*
        ciFilter.setValue(0.8,     forKey: "inputIntensity")
        */
        
        // step 3: フィルタ後の画像を取得
        let ciContext = CIContext(options: nil)
        let cgimg =
            ciContext.createCGImage(ciFilter.outputImage!, from:ciFilter.outputImage!.extent)!
        
        // step 4: CIImage → UIImage へ変換
        let image2 = UIImage(cgImage: cgimg, scale: 1.0, orientation: .up)
        
        self.imageView.image = image2
        
    }
    */
    
    
    private func drawText(image: UIImage) -> UIImage {
        
        let text =
            "Some text1..\n" +
            "Some text2..\n" +
            "Some text3..\n" +
            "Some text4..\n" +
            "Some text5..\n" +
            "Some text6..\n" +
            "Some text7..\n" +
            "Some text8..\n" +
            "Some text9..\n" +
            "Some text10.."
        
        
        let font      = UIFont(name: "Verdana", size: 28)
        
        let imageRect = CGRect(x: 0, y: 0,
                               width:  image.size.width,
                               height: image.size.height)
        
        // UIGraphicsBeginImageContext(image.size)
        // 画像が非retinaの場合、こっち使わんと画像が荒くなる場合あり??
        UIGraphicsBeginImageContextWithOptions(image.size, false, 0)
        
        image.draw(in: imageRect)
        
        let textRect  = CGRect(x: 5, y: 55, width: image.size.width - 5, height: image.size.height - 5)
        
        let textStyle = NSMutableParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        
        let textFontAttributes = [
            NSFontAttributeName: font,
            NSForegroundColorAttributeName: UIColor.cyan,
            NSParagraphStyleAttributeName: textStyle
        ]
        text.draw(in: textRect, withAttributes: textFontAttributes)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return newImage!
        
    }
    
    
    
    // 並列処理でフィルター生成を展開
    func yieldFilters() -> [CIFilter] {
        
        var result: [CIFilter] = []
        
        // ここ、asyncにすると、filterNameをselfつけろっていわれる。syncだとそんなことない。
        // つまりsyncだとエスケープしない、ってこと。asyncだとエスケープしてる。
        // 検証の結果、ここ並列処理しなくても結果はそんなに変わらなかった。。。。とりまやっとく
        DispatchQueue.global(qos: .default).sync {
            (0..<8).forEach { no in
                result.append(CIFilter(name: self.filterNames[no])!)
                print("append!")
            }
        }
        
        print(result)
        
        return result
        
    }
    
    
    // ここがむちゃくちゃ重いｗｗｗ
    
    fileprivate func scrollViewSetup(completion: ([UIButton]) -> Void) {
        
        // Variables for setting the Font Buttons
        var xCoord:            CGFloat = 5
        let yCoord:            CGFloat = 5
        let buttonWidth:       CGFloat = 70
        let buttonHeight:      CGFloat = 70
        let gapBetweenButtons: CGFloat = 5

        
        DispatchQueue.global(qos: .default).sync {
            
            var result: [UIButton] = []
            
            (0..<8).forEach {
                
                // Button properties
                let filterButton = UIButton(type: .custom)
                filterButton.frame = CGRect(x: xCoord, y: yCoord, width: buttonWidth, height: buttonHeight)
                filterButton.tag = $0
                filterButton.showsTouchWhenHighlighted = true
                filterButton.addTarget(self, action: #selector(filterButtonTapped(_:)), for: .touchUpInside)
                filterButton.layer.cornerRadius = 6
                filterButton.clipsToBounds = true
                
                
                // Create filters for each button
                // ciContext = CIContext(options: nil)
                let coreImage = CIImage(image: self.imageView.image!)
                
                // filter = CIFilter(name: filterNames[i])
                
                self.filter[$0].setDefaults()
                self.filter[$0].setValue(coreImage, forKey: kCIInputImageKey)
                let filteredImageData = self.filter[$0].value(forKey: kCIOutputImageKey) as! CIImage
                
                // ここが激重???????
                let filteredImageRef = self.ciContext.createCGImage(filteredImageData, from: filteredImageData.extent)
                
                // result.append(filteredImageRef!)
                
                let imageForButton = UIImage(cgImage: filteredImageRef!)
                
                filterButton.setBackgroundImage(imageForButton, for: UIControlState())
                filterButton.contentMode = .scaleAspectFit
                
                xCoord += buttonWidth + gapBetweenButtons
                
                // self.scrollView.addSubview(filterButton)

                result.append(filterButton)
                
                print("\($0) done!")
                
            }
            
            completion(result)
        
        }
        
        
        // Resize Scroll View
        self.scrollView.contentSize =
            // この7は、本来、itemCountが来てた。注意。
            CGSize(width: buttonWidth * CGFloat(Double(7) + 1.7), height: yCoord)
        
    }
    
    deinit { print("消滅した") }
    
    
} // end of class


extension LaunchImageCollectionViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    

    // 写真を撮影/ライブラリから写真を選択した瞬間に呼ばれるメソッド
    
    // 今の実装バグあり！
    // 現在と他の写真を選ぶとデッドロック？？固まる！！！と思いきや生きてる！
    // 1枚目の写真が、なぜかやたら時間クソかかる！
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String:Any]) {
        // 撮影/選択された画像を取得する
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else { return }
        
        self.imageView.image = image
        
        // 新たなimageを元にボタンを作る前に、古いやつをremoveしとく
        self.scrollView.subviews.forEach {
            $0.removeFromSuperview()
        }
        
        scrollViewSetup { result in
            result.forEach { self.scrollView.addSubview($0) }
        }
        
        picker.dismiss(animated: true, completion: nil)
        
    }
    
    // ここまで通ってるにもかかわらず、この直後落ちるｗどうしろとww
    // なおカメラのみ発生する模様、ライブラリからだと落ちない
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // 閉じる
        picker.dismiss(animated: true, completion: nil)
    }
    
}



