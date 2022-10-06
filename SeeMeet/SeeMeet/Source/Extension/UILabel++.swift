import UIKit

extension UILabel {
//    func setTextFontAttribute(defaultText: String, containText: String, changingFont: UIFont, color: UIColor) {
//        let text: String = defaultText
//        let changeText: NSMutableAttributedString = NSMutableAttributedString(string: text)
//        changeText.addAttribute(.font, value: changingFont, range: (text as NSString).range(of: containText))
//        changeText.addAttribute(.foregroundColor, value: color, range: (text as NSString).range(of: containText))
//
//        attributedText = changeText
//    }
//    
//    func setTextLineAttribute(defaultText: String, value: CGFloat) {
//        let text: String = defaultText
//        let changeText = NSMutableAttributedString(string: text)
//        changeText.addAttribute(NSAttributedString.Key.kern, value: value, range: NSRange(0 ... changeText.length-1))
//        
//        attributedText = changeText
//    }
//    
//    func setTextFontColorSpacingAttribute(defaultText: String, value: CGFloat, containText: String, changingFont: UIFont, color: UIColor) {
//        let text: String = defaultText
//        let changeText = NSMutableAttributedString(string: text)
//        changeText.addAttribute(NSAttributedString.Key.kern, value: value, range: NSRange(0 ... changeText.length-1))
//        changeText.addAttribute(.font, value: changingFont, range: (text as NSString).range(of: containText))
//        changeText.addAttribute(.foregroundColor, value: color, range: (text as NSString).range(of: containText))
//        
//        attributedText = changeText
//    }
    
    func setAttributedText(defaultText: String, containText: String? = nil,
                           font: UIFont? = nil, color: UIColor? = nil,
                           kernValue: CGFloat? = nil, lineSpacing: CGFloat? = nil) {
        let mutableAttributedText = NSMutableAttributedString(string: defaultText)
        
        if let font = font {
            mutableAttributedText.addAttribute(.font, value: font, range: (defaultText as NSString).range(of: containText ?? defaultText))
        }
        
        if let color = color {
            mutableAttributedText.addAttribute(.foregroundColor, value: color, range: (defaultText as NSString).range(of: containText ?? defaultText))
        }
        
        if let kernValue = kernValue {
            mutableAttributedText.addAttribute(.kern, value: kernValue, range: NSRange(0...defaultText.count-1))
        }
        
        if let lineSpacing = lineSpacing {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = lineSpacing
            paragraphStyle.lineBreakMode = .byTruncatingTail
            mutableAttributedText.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSRange(0...defaultText.count-1))
        }
        
        self.attributedText = mutableAttributedText
    }
}
