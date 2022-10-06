import UIKit

enum textViewType{
    case loginEmail
    case loginPassword
    case register

}
class GrayTextView: UIView{
    var isNotSee: Bool = false
    var notSeeButtonCompletion: ((Bool) -> Bool)?

    let emailTextIamgeView = UIImageView().then{
        $0.image = UIImage(named: "ic_e-mail")
    }
    let pwdTextImageView = UIImageView().then{
        $0.image = UIImage(named: "ic_password")
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
   
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(type: textViewType) {
        super.init(frame: .zero)
        self.backgroundColor = UIColor.grey01
        self.clipsToBounds = true
        self.layer.cornerRadius = 10

        switch type {
        case .loginEmail:
            addSubview(emailTextIamgeView)
            emailTextIamgeView.snp.makeConstraints{
                $0.top.leading.bottom.equalToSuperview().offset(0)
                $0.width.equalTo(48)
            }
        case .loginPassword:
            addSubviews([pwdTextImageView])
            pwdTextImageView.snp.makeConstraints{
                $0.top.leading.bottom.equalToSuperview().offset(0)
                $0.width.equalTo(48)
            }
        default:
            print("defultView")
        }
    }


}
