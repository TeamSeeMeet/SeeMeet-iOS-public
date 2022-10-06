import UIKit

protocol FriendsAddTVCDelegate {
    func friendsAddTVC(cell: FriendsAddTVC, resultMessage: String)
}

class FriendsAddTVC: UITableViewCell {
    
    // MARK: - UI Components
    
    let profileImage: UIImageView = UIImageView().then {
        $0.image = UIImage(named: "img_illust_2")
    }
    
    let nameLabel: UILabel = UILabel().then {
        $0.font = UIFont.hanSansMediumFont(ofSize: 16)
        $0.textColor = UIColor.black
    }
    
    let emailLabel: UILabel = UILabel().then {
        $0.font = UIFont.hanSansMediumFont(ofSize: 13)
        $0.textColor = UIColor.grey04
    }
    
    private let addButton: UIButton = UIButton().then {
        $0.setImage(UIImage(named: "btn_add-friends_circle"), for: .normal)
    }
    
    // MARK: - Properties
    
    static let identifier: String = "FriendsAddTVC"
    
    var delegate: FriendsAddTVCDelegate?
    
    var nickname: String?
    
    // MARK: - Initializer
    
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
    
    override func prepareForReuse() {
        addButton.setImage(UIImage(named: "btn_add-friends_circle"), for: .normal)
    }
    
    // MARK: - Layout
    
    private func setAutoLayouts() {
        selectionStyle = .none
        
        addSubviews([profileImage, nameLabel, emailLabel])
        contentView.addSubview(addButton)
        profileImage.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.width.height.equalTo(42 * heightRatio)
            $0.top.equalToSuperview().offset(5 * heightRatio)
        }
        
        nameLabel.snp.makeConstraints {
            $0.leading.equalTo(profileImage.snp.trailing).offset(24 * widthRatio)
            $0.top.equalToSuperview().offset(6 * heightRatio)
        }
        
        emailLabel.snp.makeConstraints {
            $0.leading.equalTo(nameLabel.snp.leading)
            $0.top.equalTo(nameLabel.snp.bottom).offset(3 * heightRatio)
        }
        
        addButton.snp.makeConstraints {
            $0.trailing.equalToSuperview()
            $0.width.height.equalTo(48 * widthRatio)
            $0.top.equalToSuperview().offset(2 * heightRatio)
        }
    }
    
    // MARK: - Custom Methods
    
    private func configUI() {
        addButton.addTarget(self, action: #selector(addButtonDidTap(_:)), for: .touchUpInside)
    }
    
    // MARK: - Network
    
    private func requestAddFriend() {
        FriendsAddService.shared.addFriends(nickname: nickname ?? "") { responseData in
            switch responseData {
            case .success(let response):
                self.addButton.setImage(UIImage(named: "btn_add-friends_fin"), for: .normal)
            case .requestErr(let response):
                guard let response = response as? FriendsAddResponseModel else { return }
                if response.message != "" {
                    self.delegate?.friendsAddTVC(cell: self, resultMessage: response.message ?? "잘못된 요청입니다.")
                }
            case .pathErr:
                self.delegate?.friendsAddTVC(cell: self, resultMessage: "잘못된 요청입니다.")
                print("Path Error")
            case .serverErr:
                print("Server Error")
            case .networkFail:
                print("Network Fail")
            }
        }
    }
    
    // MARK: - Actions
    
    @objc private func addButtonDidTap(_ sender: UIButton) {
        requestAddFriend()
    }
}
