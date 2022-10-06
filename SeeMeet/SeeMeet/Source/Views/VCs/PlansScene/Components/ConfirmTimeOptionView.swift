import UIKit

protocol TimeOptionViewDelegate {
    func timeOptionViewDidTap(view: ConfirmTimeOptionView, tag: Int)
}

class ConfirmTimeOptionView: UIButton {
    
    // MARK: - UI Components
    
    let yearLabel = UILabel().then {
        $0.font = UIFont.dinProBoldFont(ofSize: 18)
        $0.textColor = UIColor.grey06
    }
    
    let timeLabel = UILabel().then {
        $0.font = UIFont.dinProMediumFont(ofSize: 16)
        $0.textColor = UIColor.grey06
        $0.textAlignment = .left
    }
    
    private let separator = UIView().then {
        $0.backgroundColor = UIColor.grey04
    }
    
    private let cellbottomView = UIView().then {
        $0.backgroundColor = UIColor.white
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 10
        $0.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
    }
    
    private let cellBackgroundView = UIView().then {
        $0.isUserInteractionEnabled = true
        $0.backgroundColor = UIColor.grey02
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 12
    }
    
    private let peopleImageView = UIImageView().then {
        $0.image = UIImage(named: "ic_friend")
    }
    
    let profileCountLabel = UILabel().then {
        $0.font = UIFont.hanSansRegularFont(ofSize: 13)
        $0.textColor = UIColor.grey03
        $0.text = "0"
    }
    
    private let nameStackView = UIStackView(frame: .zero).then {
        $0.axis = .horizontal
        $0.spacing = 8 * widthRatio
        $0.distribution = .fillProportionally
        $0.alignment = .fill
    }
    
    // MARK: - Properties
    
    static let identifier: String = "TimeOptionView"
    
    var delegate: TimeOptionViewDelegate?
    var namesToShow: [String]? {
        didSet {
            setNameLabels()
        }
    }
    var invitationDateID: Int?
    
    override var isSelected: Bool {
        willSet {
            super.isSelected = newValue
            toggleSelectedState()
        }
    }
    
    // MARK: - initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupAutoLayout()
        addTapGesture()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - setLayout
    
    private func setupAutoLayout() {
        addSubview(cellBackgroundView)
        cellBackgroundView.addSubviews([yearLabel, separator, timeLabel, cellbottomView])
        cellbottomView.addSubviews([peopleImageView, profileCountLabel, nameStackView])
        
        cellBackgroundView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.height.equalTo(99 * heightRatio)
        }
        
        yearLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(17 * heightRatio)
            $0.leading.equalToSuperview().offset(22 * widthRatio)
        }
        
        separator.snp.makeConstraints {
            $0.top.equalToSuperview().offset(18 * heightRatio)
            $0.leading.equalTo(yearLabel.snp.trailing).offset(18 * widthRatio)
            $0.width.equalTo(1)
            $0.height.equalTo(22 * heightRatio)
        }
        
        timeLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(18 * heightRatio)
            $0.trailing.equalToSuperview().offset(-22 * widthRatio)
        }
        
        cellbottomView.snp.makeConstraints {
            $0.bottom.leading.trailing.equalToSuperview()
            $0.height.equalTo(41 * heightRatio)
        }
        
        nameStackView.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-22 * widthRatio)
            $0.bottom.equalToSuperview().offset(-12 * heightRatio)
            $0.height.equalTo(16 * heightRatio)
        }
        
        profileCountLabel.snp.makeConstraints {
            if namesToShow?.count != 0 {
                $0.trailing.equalTo(nameStackView.snp.leading).offset(-17 * widthRatio)
            } else {
                $0.trailing.equalToSuperview().offset(-22 * widthRatio)
            }
            $0.bottom.equalToSuperview().offset(-12 * heightRatio)
        }
        
        peopleImageView.snp.makeConstraints {
            $0.trailing.equalTo(profileCountLabel.snp.leading).offset(-4 * widthRatio)
            $0.top.equalToSuperview().offset(13 * heightRatio)
            $0.height.width.equalTo(13 * widthRatio)
        }
    }
    
    // MARK: - Custom Method
    
    private func setNameLabels() {
        if let namesToShow = namesToShow {
            namesToShow.forEach { name in
                let nameLabel = UILabel().then {
                    $0.setAttributedText(defaultText: name,
                                         font: UIFont.hanSansRegularFont(ofSize: 13),
                                         color: UIColor.grey05,
                                         kernValue: -0.6)
                }
                nameStackView.addArrangedSubview(nameLabel)
            }
            profileCountLabel.text = "\(namesToShow.count)"
        }
    }
    
    private func addTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(timeOptionViewDidTap(_:)))
        addGestureRecognizer(tapGesture)
        isUserInteractionEnabled = true
    }
    
    private func toggleSelectedState() {
        cellBackgroundView.backgroundColor = isSelected ? UIColor.black : UIColor.grey02
        cellBackgroundView.layer.borderWidth = isSelected ? 1 : 0
        cellBackgroundView.layer.borderColor = isSelected ? UIColor.black.cgColor : UIColor.grey02.cgColor
        yearLabel.textColor = isSelected ? UIColor.white : UIColor.grey06
        timeLabel.textColor = isSelected ? UIColor.white : UIColor.grey06
    }
    
    // MARK: - Actions
    
    @objc private func timeOptionViewDidTap(_ sender: UITapGestureRecognizer) {
        delegate?.timeOptionViewDidTap(view: self, tag: tag)
    }
}
