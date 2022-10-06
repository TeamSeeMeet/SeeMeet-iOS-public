//
//  SMRequestPopUpVC.swift
//  SeeMeet
//
//  Created by 박익범 on 2022/01/15.
//

import UIKit
import Then
import SnapKit

enum SMRequestPopUpType{
case recieveConfirm // 받은약속 확정 후 보내는 뷰
case sendConfirm //보낸약속 확정하기
case sendNotSelectConfirm //해당 날짜를 선택하지 않은 친구가 있을때
case sendNotRequestConfirm // 답변을 보내지 않은 친구가 있을때
}

class SMRequestPopUpVC: UIViewController {
    
    // MARK: - properties
    static let identifier: String = "SMPopUpVC"
    
    private var messageLabels: [UILabel] = []
    private var dateLabels: [UILabel] = []
    var yearText: [String] = []
    var dateText: [String] = []
    
    var greyButtonText: String? {
        didSet {
            greyButton.setTitle(oldValue, for: .normal)
        }
    }
    
    var pinkButtonText: String? {
        didSet {
            pinkButton.setTitle(oldValue, for: .normal)
        }
    }
    
    var type: SMRequestPopUpType = .recieveConfirm {
        didSet {
            setContents()
        }
    }
    
    private let popUpView: UIView = UIView().then {
        $0.backgroundColor = UIColor.white
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 10
    }
    private let textView = UIView ().then{
        $0.backgroundColor = UIColor.grey01
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 10
    }
    private let yearStackView = UIStackView().then{
        $0.axis = .vertical
        $0.backgroundColor = .none
        $0.alignment = .fill
        $0.distribution = .fillEqually
        $0.spacing = 0
        $0.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        $0.isLayoutMarginsRelativeArrangement = true
    }
    private let dateStackView = UIStackView().then{
        $0.axis = .vertical
        $0.backgroundColor = .none
        $0.alignment = .fill
        $0.distribution = .fillEqually
        $0.spacing = 0
        $0.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        $0.isLayoutMarginsRelativeArrangement = true
    }
    private let greyButton: UIButton = UIButton().then {
        $0.setTitleColor(UIColor.grey05, for: .normal)
        $0.backgroundColor = UIColor.grey02
        $0.titleLabel?.font = UIFont.hanSansMediumFont(ofSize: 16)
    }
    
    private let pinkButton: UIButton = UIButton().then {
        $0.setTitleColor(UIColor.white, for: .normal)
        $0.backgroundColor = UIColor.pink01
        $0.titleLabel?.font = UIFont.hanSansMediumFont(ofSize: 16)
    }
    
    var pinkButtonCompletion: (() -> Void)?
    
    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setLayouts()
        setMessageLayout()
        configUI()
    }
    
    convenience init() {
        self.init()
        setContents()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setContents()
    }
    
    init(withType: SMRequestPopUpType) {
        super.init(nibName: nil, bundle: nil)
        type = withType
        setContents()
    }
    
    private func configUI() {
        greyButton.addTarget(self, action: #selector(touchUpGreyButton(_:)), for: .touchUpInside)
        pinkButton.addTarget(self, action: #selector(touchUpPinkButton(_:)), for: .touchUpInside)
    }
    
    private func setContents() {
        var messageText: [String] = []
        
        switch type {
        case .recieveConfirm:
            messageText = ["이렇게 보낼까요?"]
            greyButton.setTitle("취소", for: .normal)
            pinkButton.setTitle("보내기", for: .normal)
        case .sendConfirm:
            messageText = ["약속을 확정하시겠어요?"]
            greyButton.setTitle("취소", for: .normal)
            pinkButton.setTitle("확정", for: .normal)
        case .sendNotSelectConfirm:
            messageText = ["만날 수 없는 친구가 있어요", "확정할까요?"]
            greyButton.setTitle("취소", for: .normal)
            pinkButton.setTitle("확정", for: .normal)
        case .sendNotRequestConfirm:
            messageText = ["답변하지 않은 친구가 있어요", "확정할까요?"]
            greyButton.setTitle("아니오", for: .normal)
            pinkButton.setTitle("예", for: .normal)
        }
        
        messageText.forEach {
            let label: UILabel = UILabel()
            label.font = UIFont.hanSansMediumFont(ofSize: 16)
            label.text = $0
            label.textColor = UIColor.black
            label.textAlignment = .center
            messageLabels.append(label)
        }
    }
    
    private func setLayouts() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        
        view.addSubview(popUpView)
        popUpView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(30 * widthRatio)
            $0.top.equalToSuperview().offset(229 * heightRatio)
            $0.width.equalTo(315 * widthRatio)
            $0.height.equalTo(333 * heightRatio)
        }
        
        popUpView.addSubview(textView)
        switch type{
        case .recieveConfirm:
            textView.snp.makeConstraints{
                $0.top.equalToSuperview().offset(18 * heightRatio)
                $0.leading.equalToSuperview().offset(16 * widthRatio)
                $0.trailing.equalToSuperview().offset(-16 * heightRatio)
                $0.height.equalTo(189 * heightRatio)
            }
            textView.addSubviews([yearStackView, dateStackView])
            yearStackView.snp.makeConstraints{
                $0.top.equalToSuperview().offset(18 * heightRatio)
                $0.leading.equalToSuperview().offset(21 * widthRatio)
                $0.height.equalTo(152 * heightRatio)
//                $0.width.equalTo(88 * widthRatio)
            }
            dateStackView.snp.makeConstraints{
                $0.top.equalToSuperview().offset(18 * heightRatio)
                $0.leading.equalTo(yearStackView.snp.trailing).offset(18 * widthRatio)
                $0.trailing.equalToSuperview().offset(21 * widthRatio)
                $0.height.equalTo(152 * heightRatio)
            }
            setDateLayout()
        default:
            textView.snp.makeConstraints{
                $0.top.equalToSuperview().offset(18 * heightRatio)
                $0.leading.equalToSuperview().offset(16 * widthRatio)
                $0.trailing.equalToSuperview().offset(-16 * widthRatio)
                $0.height.equalTo(150 * heightRatio)
            }
        }
        popUpView.addSubviews([greyButton, pinkButton])
        
        greyButton.snp.makeConstraints {
            $0.leading.bottom.equalToSuperview()
            $0.width.equalTo(popUpView.snp.width).dividedBy(2)
            $0.height.equalTo(50 * heightRatio)
        }
        
        pinkButton.snp.makeConstraints {
            $0.bottom.trailing.equalToSuperview()
            $0.width.equalTo(greyButton.snp.width)
            $0.height.equalTo(greyButton.snp.height)
        }
    }
    private func setDateLayout(){
        yearText.forEach {
                let label: UILabel = UILabel()
                label.font = UIFont.dinProBoldFont(ofSize: 18)
                label.text = $0
                label.textColor = UIColor.black
                label.textAlignment = .left
                yearStackView.addArrangedSubview(label)
        }
        dateText.forEach {
                let label: UILabel = UILabel()
                label.font = UIFont.dinProRegularFont(ofSize: 14)
                label.text = $0
                label.textColor = UIColor.black
                label.textAlignment = .left
                dateStackView.addArrangedSubview(label)
        }
    }
    func setTextMessageLayout(){
        yearText.forEach {
                let label: UILabel = UILabel()
                label.font = UIFont.dinProBoldFont(ofSize: 18)
                label.text = $0
                label.textColor = UIColor.black
                label.textAlignment = .left
                dateLabels.append(label)
        }
        dateText.forEach {
                let label: UILabel = UILabel()
                label.font = UIFont.dinProRegularFont(ofSize: 14)
                label.text = $0
                label.textColor = UIColor.black
                label.textAlignment = .left
                dateLabels.append(label)
        }
        
        textView.addSubviews(dateLabels)
        if type != .recieveConfirm {
            if let dateLabelFirst = dateLabels.first,
               let dateLabelSectond = dateLabels.last {
                dateLabelFirst.snp.makeConstraints {
                    $0.top.equalToSuperview().offset(46)
                    $0.centerX.equalToSuperview()
                    $0.height.equalTo(23)
                }
                dateLabelSectond.snp.makeConstraints{
                    $0.top.equalTo(dateLabelFirst.snp.bottom).offset(10)
                    $0.centerX.equalToSuperview()
                    $0.height.equalTo(18)
                }
            }
        }
    }
    
    
    private func setMessageLayout() {
        popUpView.addSubviews(messageLabels)
        
        switch type {
        case .recieveConfirm:
            if let messageLabel = messageLabels.first {
                messageLabel.snp.makeConstraints {
                    $0.top.equalTo(textView.snp.bottom).offset(26 * heightRatio)
                    $0.centerX.equalToSuperview()
                }
            }
        case .sendConfirm:
            if let messageLabel = messageLabels.first {
                messageLabel.snp.makeConstraints {
                    $0.top.equalTo(textView.snp.bottom).offset(46 * heightRatio)
                    $0.centerX.equalToSuperview()
                }
            }
        case .sendNotSelectConfirm, .sendNotRequestConfirm:
            if let messageLabelFirst = messageLabels.first,
                let messageLabelLast = messageLabels.last {
                messageLabelFirst.snp.makeConstraints {
                    $0.top.equalTo(textView.snp.bottom).offset(33 * heightRatio)
                    $0.leading.equalToSuperview().offset(12 * widthRatio)
                    $0.trailing.equalToSuperview().offset(-12 * widthRatio)
                }
                messageLabelLast.snp.makeConstraints {
                    $0.top.equalTo(messageLabelFirst.snp.bottom).offset(10 * heightRatio)
                    $0.leading.equalToSuperview().offset(12 * widthRatio)
                    $0.trailing.equalToSuperview().offset(-12 * widthRatio)
                }
            }
        }
        setTextMessageLayout()
    }
    
    // MARK: - objc
    
    @objc func touchUpGreyButton(_ sender: UIButton) {
        dismiss(animated: false, completion: nil)
    }
    
    @objc func touchUpPinkButton(_ sender: UIButton) {
        guard let completion = pinkButtonCompletion else { return }
        completion()
    }

}
