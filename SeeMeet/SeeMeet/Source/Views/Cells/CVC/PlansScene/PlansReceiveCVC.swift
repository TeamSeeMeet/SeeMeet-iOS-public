import UIKit
import SnapKit
import Then


protocol PlansReceiveCVCDelegate {
    func plansReceiveCVCDidTap(cell: PlansReceiveCVC)
}

class PlansReceiveCVC: UICollectionViewCell {
    
    // MARK: - UI Components
    
    private let titleLabel = UILabel().then {
        $0.font = UIFont.hanSansBoldFont(ofSize: 16)
        $0.textColor = UIColor.grey06
    }
    
    private let bottomView = UIView().then {
        $0.backgroundColor = UIColor.grey02
    }
    
    private let sideView = UIView().then {
        $0.backgroundColor = UIColor.grey06
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 12
        $0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
    }
    
    private let timeLabel = UILabel().then {
        $0.font = UIFont.dinProRegularFont(ofSize: 13)
        $0.textColor = UIColor.grey06
        $0.text = "오전 11:00 - 오후 2:00"
    }
    
    private let nameTagButtonStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .fill
        $0.distribution = .fillEqually
        $0.spacing = 6 * widthRatio
        $0.layoutMargins = UIEdgeInsets(top: 4*heightRatio , left: 0 , bottom: 4*heightRatio, right: 10*widthRatio)
        $0.isLayoutMarginsRelativeArrangement = true
    }
    
    // MARK: - Properties
    
    static let identifier: String = "PlansReceiveCVC"
    
    var delegate: PlansReceiveCVCDelegate?
    
    var namesToShow: [String]?
    
    // MARK: - Life Cycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupAutoLayouts()
        setGestureRecognizer()
    }
    
    override func prepareForReuse() {
        nameTagButtonStackView.removeAllSubViews()
    }
    
    // MARK: - Layout

    private func setupAutoLayouts() {
        addSubviews([titleLabel, bottomView, sideView, timeLabel, nameTagButtonStackView])
        
        contentView.clipsToBounds = false
        contentView.layer.cornerRadius = 10
        contentView.backgroundColor = UIColor.white
        getShadowView(color: UIColor.black.cgColor, masksToBounds: false, shadowOffset: CGSize(width: 0, height: 0), shadowRadius: 1, shadowOpacity: 0.1)
        
        sideView.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview()
            $0.width.equalTo(12 * widthRatio)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(15 * heightRatio)
            $0.leading.equalTo(sideView.snp.trailing).offset(15 * widthRatio)
            $0.height.equalTo(20 * heightRatio)
        }
        
        bottomView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(13 * heightRatio)
            $0.leading.equalTo(sideView.snp.trailing).offset(14 * widthRatio)
            $0.trailing.equalToSuperview().offset(-16 * widthRatio)
            $0.height.equalTo(1 * heightRatio)
        }
        
        timeLabel.snp.makeConstraints {
            $0.top.equalTo(bottomView.snp.bottom).offset(11 * heightRatio)
            $0.leading.equalTo(sideView.snp.trailing).offset(15 * widthRatio)
            $0.height.equalTo(17 * heightRatio)
        }
        nameTagButtonStackView.snp.makeConstraints {
            $0.top.equalTo(timeLabel.snp.bottom).offset(12 * heightRatio)
            $0.leading.equalTo(sideView.snp.trailing).offset(15 * widthRatio)
            $0.width.equalTo(180 * widthRatio)
            $0.height.equalTo(32 * heightRatio)
        }
        
    }
    
   private func setStackButton() {
       guard let namesToShow = namesToShow else { return }
       
       nameTagButtonStackView.snp.updateConstraints {
           $0.width.equalTo(60 * widthRatio * CGFloat(namesToShow.count ?? 0) + 6 * CGFloat((namesToShow.count ?? 1) - 1))
       }
       
       nameTagButtonStackView.arrangedSubviews.forEach {
           $0.removeFromSuperview()
       }
       
       namesToShow.forEach { name in
           let nameButton: UIButton = UIButton().then {
               $0.titleLabel?.font = UIFont.hanSansRegularFont(ofSize: 13)
               $0.setTitle(name, for: .normal)
               $0.setTitleColor(UIColor.pink01, for: .normal)
               $0.backgroundColor = UIColor.white
               $0.clipsToBounds = true
               $0.layer.borderWidth = 1
               $0.layer.borderColor = UIColor.pink01.cgColor
               $0.layer.cornerRadius = 12
           }
           nameTagButtonStackView.addArrangedSubview(nameButton)
       }
       setNeedsLayout()
    }
    
    // MARK: - Custom Methods
    
    private func setGestureRecognizer() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTap(_:)))
        addGestureRecognizer(gesture)
    }
    
    func setData(title: String, time: String, namesToShow: [String]) {
        titleLabel.attributedText = String.getAttributedText(text: title, letterSpacing: -0.6, lineSpacing: nil)
        timeLabel.attributedText = String.getAttributedText(text: time, letterSpacing: -0.6, lineSpacing: nil)
        
        self.namesToShow = namesToShow
        setStackButton()
    }
    
    // MARK: - Actions
    
    @objc private func didTap(_ sender: UITapGestureRecognizer) {
        delegate?.plansReceiveCVCDidTap(cell: self)
    }
}
