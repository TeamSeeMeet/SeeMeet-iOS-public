//
//  AvailTimeOptionView.swift
//  SeeMeet
//
//  Created by 김인환 on 2022/03/08.
//

import UIKit

protocol AvailTimeOptionViewDelegate {
    func checkBoxDidTap(view: AvailTimeOptionView)
    func availTimeOptionViewDidTap(view: AvailTimeOptionView)
}

class AvailTimeOptionView: UIView {
    
    // MARK: - UI Components
    
    let dateLabel: UILabel = UILabel().then {
        $0.font = UIFont.dinProBoldFont(ofSize: 16)
        $0.textColor = UIColor.grey06
    }
    
    let timeLabel: UILabel = UILabel().then {
        $0.font = UIFont.dinProRegularFont(ofSize: 14)
        $0.textColor = UIColor.grey06
    }
    
    let checkButton: UIButton = UIButton(type: .system).then {
        $0.setBackgroundImage(UIImage(named: "ic_check_grey"), for: .normal)
        $0.setBackgroundImage(UIImage(named: "ic_check_active"), for: .selected)
    }
    
    private let cellBottomView = UIView().then {
        $0.backgroundColor = UIColor.grey01
    }
    
    // MARK: - Properties
    static let identifier: String = "AvailTimeOptionView"
    
    var isResponsed: Bool = true { // 이미 응답을 보낸 약속에서 인지 여부. 버튼 상호작용 여부 결정한다.
        willSet {
            checkButton.isEnabled = !newValue
        }
    }
    
    var delegate: AvailTimeOptionViewDelegate?
    
    // MARK: - Intializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
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
        setAutoLayouts()
        configUI()
    }
    
    // MARK: - Layout
    
    private func setAutoLayouts() {
        addSubviews([dateLabel, timeLabel, checkButton, cellBottomView])
        bringSubviewToFront(checkButton)
        
        snp.makeConstraints {
            $0.width.equalTo(344 * widthRatio)
            $0.height.equalTo(82 * heightRatio)
        }
        
        dateLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(14 * heightRatio)
            $0.leading.equalToSuperview().offset(40 * widthRatio)
        }
        
        timeLabel.snp.makeConstraints {
            $0.top.equalTo(dateLabel.snp.bottom).offset(7 * heightRatio)
            $0.leading.equalToSuperview().offset(40 * widthRatio)
        }
        
        checkButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalTo(snp.trailing).offset(-11 * widthRatio)
            $0.width.height.equalTo(48 * heightRatio)
        }
        
        cellBottomView.snp.makeConstraints {
            $0.bottom.equalToSuperview()
            $0.leading.equalToSuperview().offset(20 * widthRatio)
            $0.trailing.equalTo(snp.trailing).offset(-20 * widthRatio)
            $0.height.equalTo(1)
        }
    }
    
    // MARK: - Custom Methods
    
    private func configUI() {
        checkButton.addTarget(self, action: #selector(checkButtonDidTap(_:)), for: .touchUpInside)
        setGestureRecognizer()
    }
    
    private func setGestureRecognizer() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(selfDidTap(_:)))
        tapGesture.cancelsTouchesInView = false
        addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Actions
    
    @objc private func checkButtonDidTap(_ sender: UIButton) {
        sender.isSelected.toggle()
        delegate?.checkBoxDidTap(view: self)
    }
    
    @objc private func selfDidTap(_ sender: UIGestureRecognizer) { // 이 뷰 자체를 터치했을 경우
        delegate?.availTimeOptionViewDidTap(view: self)
    }
}
