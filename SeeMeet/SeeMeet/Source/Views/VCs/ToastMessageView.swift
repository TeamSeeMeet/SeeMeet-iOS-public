import UIKit

class ToastMessageView: UIView{
        
    private let messageText = UILabel().then{
        $0.text = ""
        $0.font = UIFont.hanSansRegularFont(ofSize: 13)
        $0.textColor = UIColor.white
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
   
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(message: String) {
        super.init(frame: .zero)
        backgroundColor = UIColor.black.withAlphaComponent(0.8)
        clipsToBounds = true
        layer.cornerRadius = 10
        messageText.text = message
        addSubview(messageText)
        messageText.snp.makeConstraints{
            $0.top.equalToSuperview().offset(5)
            $0.leading.equalToSuperview().offset(10)
            $0.trailing.equalToSuperview().offset(-10)
            $0.bottom.equalToSuperview().offset(-5)
        }
    }
    
}
