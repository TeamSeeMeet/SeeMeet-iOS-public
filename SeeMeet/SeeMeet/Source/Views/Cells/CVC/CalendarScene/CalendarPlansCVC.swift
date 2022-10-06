import UIKit

class CalendarPlansCVC: UICollectionViewCell {
    
    // MARK: - properties
    
    static let identifier: String = "CalendarPlansCVC"
    
    var isSchedule: Bool = false {
        didSet {
            if isSchedule {
                nameLabelStackView = nil
                headerView.backgroundColor = UIColor.grey04
            }
        }
    }
    
    private let headerView: UIView = UIView().then {
        $0.layer.cornerRadius = CGFloat(10.0)
        $0.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        $0.backgroundColor = UIColor.grey06
    }
    
    let headerTitle: UILabel = UILabel().then {
        $0.textColor = .white
        $0.font = UIFont.hanSansBoldFont(ofSize: 14)
        $0.lineBreakMode = .byTruncatingTail
    }
    
    let hourLabel: UILabel = UILabel().then {
        $0.textColor = .grey06
        $0.font = UIFont.dinProRegularFont(ofSize: 14)
        $0.text = "오전 11:00"
    }
    
    private lazy var nameLabelStackView: UIStackView? = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .fill
        $0.distribution = .fillEqually
        $0.spacing = 6 * widthRatio
        $0.layoutMargins = UIEdgeInsets(top: 10 * heightRatio, left: 0, bottom: 10 * heightRatio, right: 0)
        $0.isLayoutMarginsRelativeArrangement = true
    }
    
    var namesToShow: [String]? {
        didSet {
            setNameStackViewLayout()
        }
    }
    
    // MARK: - Life Cycle

    override func awakeFromNib() {
        super.awakeFromNib()
        getShadowView(color: UIColor.black.cgColor, masksToBounds: false, shadowOffset: CGSize(width: 0, height: 4), shadowRadius: 3, shadowOpacity: 0.25)
        setBaseViewLayouts()
        setContentViewLayouts()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        getShadowView(color: UIColor.black.cgColor, masksToBounds: false, shadowOffset: CGSize(width: 0, height: 4), shadowRadius: 3, shadowOpacity: 0.25)
        setBaseViewLayouts()
        setContentViewLayouts()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        getShadowView(color: UIColor.black.cgColor, masksToBounds: false, shadowOffset: CGSize(width: 0, height: 4), shadowRadius: 3, shadowOpacity: 0.25)
        setBaseViewLayouts()
        setContentViewLayouts()
    }
    
    override func prepareForReuse() {
        namesToShow?.removeAll()
    }
    
    // MARK: - layout
    
    private func setBaseViewLayouts() {
        //shadow 추가 필요
        layer.cornerRadius = CGFloat(10.0)
        backgroundColor = UIColor.white
        
        addSubview(headerView)
        headerView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(52 * heightRatio)
        }
        
        headerView.addSubview(headerTitle)
        headerTitle.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(22 * widthRatio)
            $0.top.equalToSuperview().offset(17 * heightRatio)
            $0.trailing.equalToSuperview().offset(-12 * widthRatio)
        }
    }
    
    private func setContentViewLayouts() {
        
        addSubview(hourLabel)
        hourLabel.snp.makeConstraints {
            if isSchedule {
                $0.leading.equalToSuperview().offset(37 * widthRatio)
                $0.top.equalTo(headerView.snp.bottom).offset(31 * heightRatio)
            } else {
                $0.leading.equalToSuperview().offset(22 * widthRatio)
                $0.top.equalTo(headerView.snp.bottom).offset(17 * heightRatio)
            }
        }
        
        if isSchedule {
            hourLabel.font = UIFont.dinProRegularFont(ofSize: 16)
        }
        else {

            guard let nameLabelStackView = nameLabelStackView else { return }

            addSubview(nameLabelStackView)
            nameLabelStackView.snp.makeConstraints {
                $0.leading.equalToSuperview().offset(22 * widthRatio)
                $0.top.equalTo(hourLabel.snp.bottom).offset(4 * heightRatio)
                $0.width.equalTo(62 * widthRatio)
                $0.height.equalTo(45 * heightRatio)
            }
        }
    }
    
    func setNameStackViewLayout() {
    
        guard let nameLabelStackView = nameLabelStackView else { return }
    
        nameLabelStackView.snp.updateConstraints {
            $0.width.equalTo(56 * widthRatio * CGFloat(namesToShow?.count ?? 0) + 6 * CGFloat((namesToShow?.count ?? 1) - 1))
        }
        
        nameLabelStackView.arrangedSubviews.forEach { // 표시 데이터 초기화 안하면 쌓임쌓임
            $0.removeFromSuperview()
        }
        
        namesToShow?.forEach {
            let nameLabel: UILabel = UILabel()
            nameLabel.font = UIFont.hanSansMediumFont(ofSize: 12)
            nameLabel.textColor = UIColor.pink01
            nameLabel.text = $0
            nameLabel.sizeToFit()
            nameLabel.clipsToBounds = true
            nameLabel.layer.cornerRadius = 13 * heightRatio
            nameLabel.layer.borderWidth = 1
            nameLabel.layer.borderColor = UIColor.pink01.cgColor
            nameLabel.textAlignment = .center
            nameLabelStackView.addArrangedSubview(nameLabel)
        }
        setNeedsLayout()
        layoutIfNeeded()
    }
}
