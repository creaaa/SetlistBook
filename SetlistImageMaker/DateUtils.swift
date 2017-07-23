
import UIKit

struct DateUtils {
    
    static func dateFromString(string: String, format: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        
        
        return formatter.date(from: string)!
    }
    
    static func stringFromDate(date: Date, format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
    
}

extension UIViewController {
    
    func createSimpleAlert(title: String, message: String? = nil, style: UIAlertControllerStyle = .alert) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
}
