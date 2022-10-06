import UIKit
import SnapKit
import Then


class ProgressReceiveCVC: UICollectionViewCell {
    
    // MARK: - UI Components
    
    private let cellHeadLabel = UILabel().then {
        $0.font = UIFont.hanSansBoldFont(ofSize: 18)
        $0.textColor = UIColor.black
        $0.textAlignment = .center
        $0.text = "받은 요청"
    }
    
    private let dateAgoLabel = UILabel().then {
        $0.font = UIFont.hanSansRegularFont(ofSize: 13)
        $0.textColor = UIColor.grey04
    }
    
    private let nameLabel = UILabel().then {
        $0.backgroundColor = UIColor.black
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 26 * heightRatio / 2
        $0.font = UIFont.hanSansMediumFont(ofSize: 14)
        $0.textColor = UIColor.white
        $0.lineBreakMode = .byTruncatingTail
        $0.textAlignment = .center
        $0.numberOfLines = 1
       
    }
    
    private let receiveLabel = UILabel().then {
        $0.text = "친구의 요청에 답해보세요!"
        $0.font = UIFont.hanSansRegularFont(ofSize: 16)
    }
    
    // MARK: - Properties
    
    static let identifier: String = "ProgressReceiveCVC"
    
    var hostNameText: String = ""
    var dayAgoText: String = ""
    
    // MARK: - Life Cycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupAutoLayout()
        setButtonTitle()
    }
    
    // MARK: - Layout
    
    func setupAutoLayout() {
        addSubviews([cellHeadLabel, dateAgoLabel, nameLabel, receiveLabel])
        
        getShadowView(color: UIColor.grey04.cgColor, masksToBounds: false, shadowOffset: CGSize(width: 0, height: 0), shadowRadius: 3, shadowOpacity: 0.4)
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
        
        nameLabel.snp.makeConstraints {
            $0.top.equalTo(cellHeadLabel.snp.bottom).offset(12 * heightRatio)
            $0.leading.equalToSuperview().offset(24 * widthRatio)
            $0.width.equalTo(63 * widthRatio)
            $0.height.equalTo(26 * heightRatio)
        }
        
        receiveLabel.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom).offset(8 * heightRatio)
            $0.leading.equalToSuperview().offset(24 * widthRatio)
        }
        
    }
    
    // MARK: - Custom Methods
    
    private func setButtonTitle() {
        nameLabel.text = hostNameText
        if dayAgoText == "0" {
            dateAgoLabel.setAttributedText(defaultText: "방금 전",
                                           font: UIFont.hanSansRegularFont(ofSize: 13),
                                           color: UIColor.grey04,
                                           kernValue: -0.6)
        } else {
            dateAgoLabel.setAttributedText(defaultText: dayAgoText + "일전",
                                           font: UIFont.hanSansRegularFont(ofSize: 13),
                                           color: UIColor.grey04,
                                           kernValue: -0.6)
        }
    }
    
    func setData(dayAgo: String, hostName: String) {
        hostNameText = hostName
        dayAgoText = dayAgo
        setButtonTitle()
    }
}
