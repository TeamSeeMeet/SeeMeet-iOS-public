import UIKit

class CompletePlansCVC: UICollectionViewCell {
    
    //MARK: - UI Components
    
    private let dateAgoLabel = UILabel().then {
        $0.font = UIFont.dinProMediumFont(ofSize: 14)
        $0.textColor = UIColor.grey04
    }
    
    private let cancelPlansButton = UIButton().then {
        $0.setTitleColor(UIColor.pink01, for: .normal)
        $0.titleLabel?.font = UIFont.hanSansMediumFont(ofSize: 14)
        $0.setAttributedTitle(String.getAttributedText(text: "약속 취소", letterSpacing: -0.6, lineSpacing: nil), for: .normal)
    }
    
    let closeButton = UIButton().then {
        $0.setBackgroundImage(UIImage(named: "btn_close"), for: .normal)
    }
    
    private let planNameLabel = UILabel().then {
        $0.font = UIFont.hanSansBoldFont(ofSize: 18)
        $0.attributedText = String.getAttributedText(text: "강화도 여행", letterSpacing: -0.6, lineSpacing: nil)
        $0.textColor = UIColor.black
    }
    
    private let plansNameButton = UIButton().then {
        $0.setBackgroundImage(UIImage(named: "btn_plansName"), for: .normal)
    }
    
    private let nameButtonStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .fill
        $0.distribution = .fillEqually
        $0.spacing = 6
        $0.isLayoutMarginsRelativeArrangement = true
    }
    
    private let bottomView = UIView().then {
        $0.backgroundColor = UIColor.grey02
    }
    
    // MARK: - Properties
    static let identifier: String = "CompletePlansCVC"
    
    var namesToShow: [String: Bool]? {
        didSet {
            setNameButtonStack()
        }
    }

    var isCanceled: Bool = false {
        willSet {
            cancelPlansButton.setAttributedTitle(String.getAttributedText(text: newValue ? "약속 취소" : "약속 확정", letterSpacing: -0.6, lineSpacing: nil), for: .normal)
        }
    }
    var dayAgoText: String? {
        willSet {
            dateAgoLabel.attributedText = String.getAttributedText(text: newValue ?? "" + "일전", letterSpacing: -0.6, lineSpacing: nil)
        }
    }
    var planTitle: String? {
        willSet {
            planNameLabel.attributedText = String.getAttributedText(text: newValue ?? "", letterSpacing: -0.6, lineSpacing: nil)
        }
    }
    
    // MARK: - Life Cycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupAutoLayouts()
    }
    
    override func prepareForReuse() {
        nameButtonStackView.removeAllSubViews()
    }
    
    // MARK: - Layout
    
    private func setupAutoLayouts() {
        addSubviews([dateAgoLabel, cancelPlansButton, planNameLabel, plansNameButton, nameButtonStackView, bottomView, closeButton])
        
        dateAgoLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(6 * heightRatio)
            $0.leading.equalToSuperview().offset(20 * widthRatio)
        }
        
        cancelPlansButton.snp.makeConstraints {
            $0.centerY.equalTo(dateAgoLabel)
            $0.leading.equalTo(dateAgoLabel.snp.trailing).offset(6 * widthRatio)
        }
        
        closeButton.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.trailing.equalToSuperview()
        }
        
        planNameLabel.snp.makeConstraints {
            $0.top.equalTo(cancelPlansButton.snp.bottom).offset(5 * heightRatio)
            $0.leading.equalToSuperview().offset(20 * widthRatio)
        }
        
        plansNameButton.snp.makeConstraints{
            $0.top.equalTo(cancelPlansButton.snp.bottom).offset(5 * heightRatio)
            $0.leading.equalTo(planNameLabel.snp.trailing)
        }
        
        nameButtonStackView.snp.makeConstraints{
            $0.top.equalTo(planNameLabel.snp.bottom).offset(11 * heightRatio)
            $0.leading.equalToSuperview().offset(20 * widthRatio)
            $0.height.equalTo(26 * heightRatio)
        }
        
        bottomView.snp.makeConstraints{
            $0.bottom.equalToSuperview().offset(-8 * heightRatio)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(1 * heightRatio)
        }
    }
    
    // MARK: - Custom Methods
    
    private func setNameButtonStack() {
        namesToShow?.forEach { (key, value) in
            
            let nameLabel = UILabel()
            nameLabel.font = UIFont.hanSansMediumFont(ofSize: 14)
            nameLabel.text = key
            nameLabel.textColor = value ? UIColor.grey06 : UIColor.grey04
            nameLabel.backgroundColor = value ? UIColor.grey02 : UIColor.white
            nameLabel.clipsToBounds = true
            nameLabel.layer.borderWidth = 1
            nameLabel.layer.borderColor = UIColor.grey02.cgColor
            nameLabel.layer.cornerRadius = 26 * heightRatio / 2
            nameLabel.lineBreakMode = .byTruncatingTail
            nameLabel.textAlignment = .center
         
            nameLabel.numberOfLines = 1
            nameLabel.snp.makeConstraints{
                $0.width.equalTo(63 * widthRatio)
            }
            nameButtonStackView.addArrangedSubview(nameLabel)
        
        }
    }
    
    func setData(namesToShow: [String: Bool], dayAgoText: String, planName: String, isCanceled: Bool) {
        self.namesToShow = namesToShow
        self.isCanceled = isCanceled
        self.dayAgoText = dayAgoText
        planTitle = planName
    }
}
