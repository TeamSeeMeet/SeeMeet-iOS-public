import UIKit


protocol FriendsListTVCDelegate {
    func messageButtonDidTap(friendData: FriendsData)
}

class FriendsListTVC: UITableViewCell {
    
    // MARK: - UI Components
    
    private let profileIcon: UIImageView = UIImageView().then {
        $0.image = UIImage(named: "img_profile")
    }
    
    let nameLabel: UILabel = UILabel().then {
        $0.textColor = UIColor.black
        $0.font = UIFont.hanSansMediumFont(ofSize: 16)
        $0.text = "김준희"
    }
    
    private let messageButton: UIButton = UIButton().then {
        $0.setImage(UIImage(named: "btn_add-message"), for: .normal)
    }
    
    // MARK: - Properties
    
    static let identifier: String = "FriendsListTVC"
    var friendData: FriendsData?
    
    var delegate: FriendsListTVCDelegate?
    
    // MARK: - initializer
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setAutoLayouts()
        configUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setAutoLayouts()
        configUI()
    }
    
    // MARK: - Life Cycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setAutoLayouts()
        configUI()
    }
    
    // MARK: - Layout
    
    private func setAutoLayouts() {
        selectionStyle = .none
        addSubviews([profileIcon, nameLabel])
        contentView.addSubview(messageButton)
        
        profileIcon.snp.makeConstraints {
            $0.width.height.equalTo(42 * heightRatio)
            $0.leading.centerY.equalToSuperview()
        }
        
        nameLabel.snp.makeConstraints {
            $0.leading.equalTo(profileIcon.snp.trailing).offset(18 * widthRatio)
            $0.centerY.equalToSuperview()
        }
        
        messageButton.snp.makeConstraints {
            $0.trailing.equalToSuperview()
            $0.width.height.equalTo(48 * widthRatio)
            $0.centerY.equalToSuperview()
        }
    }
    
    // MARK: - Custom Methods
    
    private func configUI() {
        messageButton.addTarget(self, action: #selector(messageButtonDidTap(_:)), for: .touchUpInside)
    }
    
    // MARK: - Actions
    
    @objc private func messageButtonDidTap(_ sender: UIButton) {
        guard let friendData = friendData else {
            return
        }
        delegate?.messageButtonDidTap(friendData: friendData)
    }
}
