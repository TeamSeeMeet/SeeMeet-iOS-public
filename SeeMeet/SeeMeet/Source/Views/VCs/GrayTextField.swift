import UIKit

enum textFieldType {
    case email
    case password
}

class GrayTextField: UITextField{
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
   
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(type: textFieldType, placeHolder: String) {
        super.init(frame: .zero)
        self.placeholder = ""
        self.font = UIFont.hanSansRegularFont(ofSize: 14)
        self.tintColor = UIColor.pink01
        self.contentVerticalAlignment = .center
        if #available(iOS 12.0, *) {
            self.textContentType = .oneTimeCode
        }

        switch type{
        case .email:
            self.placeholder = placeHolder
        case .password:
            self.isSecureTextEntry = true
            self.placeholder = placeHolder
        }
    }
}
