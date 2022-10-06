import UIKit

class ProgressSendCVC: UICollectionViewCell {
    
    // MARK: - UI Component
    
    private let cellHeadLabel = UILabel().then {
        $0.font = UIFont.hanSansBoldFont(ofSize: 18)
        $0.textColor = UIColor.pink01
        $0.textAlignment = .center
        $0.text = "보낸 요청"
    }
    
    private let dateAgoLabel = UILabel().then {
        $0.font = UIFont.hanSansRegularFont(ofSize: 13)
        $0.textColor = UIColor.grey04
        $0.text = "1일 전"
    }
    
    private let sendLabel = UILabel().then {
        $0.font = UIFont.hanSansRegularFont(ofSize: 16)
        $0.textColor = UIColor.black
    }
    
    private let nameTagButtonStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .fill
        $0.distribution = .fillProportionally
        $0.spacing = 8
    }
    
    // MARK: - Properties
    
    static let identifier: String = "ProgressSendCVC"
    
    var dateAgoText: String?
    var namesToShow: [String: Bool]?
    
    // MARK: - Life Cycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupAutoLayout()
    }
    
    override func prepareForReuse() {
        nameTagButtonStackView.removeAllSubViews()
    }
    
    //MARK: - Layout
    
    private func setupAutoLayout() {
        addSubviews([cellHeadLabel, dateAgoLabel, nameTagButtonStackView, sendLabel])
        
        getShadowView(color: UIColor.grey04.cgColor, masksToBounds: false, shadowOffset: CGSize.zero, shadowRadius: 3, shadowOpacity: 0.4)
        contentView.clipsToBounds = true
        contentView.layer.cornerRadius = 10
        contentView.backgroundColor = UIColor.white
        
        cellHeadLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(18 * heightRatio)
            $0.leading.equalToSuperview().offset(24 * widthRatio)
        }
        
        dateAgoLabel.snp.makeConstraints {
            $0.centerY.equalTo(cellHeadLabel)
            $0.trailing.equalToSuperview().offset(-24 * widthRatio)
        }
        
        sendLabel.snp.makeConstraints {
            $0.top.equalTo(cellHeadLabel.snp.bottom).offset(8 * heightRatio)
            $0.leading.equalToSuperview().offset(24 * widthRatio)
        }
        
        nameTagButtonStackView.snp.makeConstraints {
            $0.top.equalTo(sendLabel.snp.bottom).offset(6 * heightRatio)
            $0.leading.equalToSuperview().offset(24 * widthRatio)
            $0.height.equalTo(26 * heightRatio)
        }
    }
    
    // MARK: - Custom Method
    
    func setData(dateAgo: String, namesToShow: [String: Bool]) { // 외부로부터 데이터를 입력받는 메서드
        dateAgo == "0" ? dateAgoLabel.setAttributedText(defaultText: "방금 전", kernValue: -0.6) : dateAgoLabel.setAttributedText(defaultText: dateAgo + "일전", kernValue: -0.6)
        
        let waitCount = namesToShow.values.filter { $0 == false }.count
        sendLabel.setAttributedText(defaultText: waitCount != 0
                                    ? "친구 \(waitCount)명의 답변을 기다리고 있어요!"
                                    : "친구가 답변을 모두 완료하였어요!",
                                    containText: "\(waitCount)",
                                    font: UIFont.hanSansBoldFont(ofSize: 16),
                                    color: UIColor.pink01)
        
        self.namesToShow = namesToShow
        setNameButtonStack()
    }
    
    private func setNameButtonStack() {
        namesToShow?.forEach { (key, value) in
            let nameLabel = UILabel()
            nameLabel.font = UIFont.hanSansMediumFont(ofSize: 14)
            nameLabel.text = key
            nameLabel.textColor = value ? UIColor.white : UIColor.pink01
            nameLabel.backgroundColor = value ? UIColor.pink01 : UIColor.white
            nameLabel.clipsToBounds = true
            nameLabel.layer.borderWidth = 1
            nameLabel.layer.borderColor = UIColor.pink01.cgColor
            nameLabel.layer.cornerRadius = 26 * heightRatio / 2
            nameLabel.lineBreakMode = .byTruncatingTail
            nameLabel.textAlignment = .center
         
            nameLabel.numberOfLines = 1
            nameLabel.snp.makeConstraints{
                $0.width.equalTo(63 * widthRatio)
            }
            if key == "" {
                nameLabel.layer.borderWidth = 0
            }
            nameTagButtonStackView.addArrangedSubview(nameLabel)
        }
    }
}
