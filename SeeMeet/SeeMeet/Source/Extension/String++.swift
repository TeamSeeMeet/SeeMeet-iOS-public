import UIKit

enum ConvertError: Error {
    case NotAcceptableFormatError
}

extension String {
    static func getAttributedText(text: String, letterSpacing: CGFloat?, lineSpacing: CGFloat?) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: text)
        
        if let letterSpacing = letterSpacing {
            attributedString.addAttribute(.kern, value: letterSpacing, range: NSRange(location: 0, length: text.count))
        }
        
        if let lineSpacing = lineSpacing {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = lineSpacing
            paragraphStyle.lineBreakMode = .byTruncatingTail
            attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: text.count))
        }
        
        return NSAttributedString(attributedString: attributedString)
    }
    
    static func getTimeIntervalString(from dateString: String, by dateFormat: String? = nil) -> String { // ISO 형식에 맞아야 한다.
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat ?? "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        let startDate = dateFormatter.date(from: Date.getCurrentYear() + "-" + Date.getCurrentMonth() + "-" + Date.getCurrentDate()) ?? Date()
        let endDate = dateFormatter.date(from: dateString) ?? Date()
        
        let interval = endDate.timeIntervalSince(startDate)
        let days = Int(interval / 86400)
        
        return String(abs(days))
    }
    
    static func getTimeInterval(from dateString: String, by dateFormat: String? = nil) -> Int { // ISO 형식에 맞아야 한다.
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat ?? "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        let startDate = dateFormatter.date(from: Date.getCurrentYear() + "-" + Date.getCurrentMonth() + "-" + Date.getCurrentDate()) ?? Date()
        let endDate = dateFormatter.date(from: dateString) ?? Date()
        
        let interval = endDate.timeIntervalSince(startDate)
        let days = Int(interval / 86400)
        
        return days
    }
    
    static func getAMPMTimeString(from timeString: String) throws -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        
        if let date = dateFormatter.date(from: timeString) {
            dateFormatter.locale = Locale(identifier: "ko_KR")
            dateFormatter.dateFormat = "a hh:mm"
            dateFormatter.amSymbol = "오전"
            dateFormatter.pmSymbol = "오후"
            
            return dateFormatter.string(from: date)
        } else {
            throw ConvertError.NotAcceptableFormatError
        }
    }
    
    func hasCharacters() -> Bool{
            do{
                let regex = try NSRegularExpression(pattern: "^[가-힣ㄱ-ㅎㅏ-ㅣ\\s]$", options: .caseInsensitive)
                if let _ = regex.firstMatch(in: self, options: NSRegularExpression.MatchingOptions.reportCompletion, range: NSMakeRange(0, self.count)){
                    return true
                }
            }catch{
                print(error.localizedDescription)
                return false
            }
            return false
        }
}
