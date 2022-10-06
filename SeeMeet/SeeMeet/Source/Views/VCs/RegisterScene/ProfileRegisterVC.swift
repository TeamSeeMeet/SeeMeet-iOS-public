//
//  ProfileRegisterVC.swift
//  SeeMeet
//
//  Created by 이유진 on 2022/03/08.
//

import UIKit
import SnapKit
import Then

protocol ProfileRegisterVCDelegate {
    func registerBackButtonDidTap()
    func closeButtonDidTap()
}

class ProfileRegisterVC: UIViewController {
    
    // MARK: - UI Components
    
    private let navigationBarView = UIView().then{
        $0.backgroundColor = UIColor.white
    }
    
    private let backButton = UIButton().then {
        $0.setBackgroundImage(UIImage(named: "btn_back"), for: .normal)
    }
    
    private let navigationTitleLabel = UILabel().then {
        $0.font = UIFont.hanSansBoldFont(ofSize: 18)
        $0.textColor = UIColor.grey06
        $0.setAttributedText(defaultText: "SeeMeet 시작하기", kernValue: -0.6)
    }
    
    private let closeButton = UIButton().then {
        $0.setImage(UIImage(named: "btn_close_bold"), for: .normal)
    }
    
    private let directionInLabel = UILabel().then {
        $0.font = UIFont.hanSansRegularFont(ofSize: 16)
        $0.textColor = UIColor.grey05
        $0.setAttributedText(defaultText: "SeeMeet에서 사용할 이름과 닉네임을 입력해주세요", kernValue: -0.6)
        $0.textAlignment = .center
        $0.numberOfLines = 3
    }
    
    //name
    private let nameView = UIView().then {
        $0.backgroundColor = .none
    }
    
    private let nameViewheadLabel = UILabel().then {
        $0.font = UIFont.hanSansMediumFont(ofSize: 14)
        $0.textColor = UIColor.grey06
        $0.setAttributedText(defaultText: "이름", kernValue: -0.6)
    }
    
    private let nameTextView = GrayTextView(type: .register)
    private let nameTextField = GrayTextField(type: .email, placeHolder: "이름")
    
    private let idView = UIView().then {
        $0.backgroundColor = .none
    }
    
    private let idViewheadLabel = UILabel().then {
        $0.font = UIFont.hanSansMediumFont(ofSize: 14)
        $0.textColor = UIColor.grey06
        $0.setAttributedText(defaultText: "닉네임", kernValue: -0.6)
    }
    
    private let idTextView = GrayTextView(type: .register)
    private let idTextField = GrayTextField(type: .email, placeHolder: "닉네임")
    private let idWarningLabel = UILabel().then {
        $0.font = UIFont.hanSansRegularFont(ofSize: 12)
        $0.textColor = UIColor.red
        $0.setAttributedText(defaultText: "올바른 아이디를 입력해주세요.", kernValue: -0.6)
    }
    
    private let startButton = UIButton().then {
        $0.backgroundColor = UIColor.grey02
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 10
        $0.setTitle("시작하기", for: .normal)
    }
    
    // MARK: - Properties
    private var isKeyboardShow: Bool = false
    
    weak var coordinator: Coordinator?
    var delegate: ProfileRegisterVCDelegate?
    
    var accessTokenToSet: String?
    var refreshTokenToSet: String?
    var nameToSet: String?
    var email: String?
    var isAppleLogin: Bool = false
    
    enum IDValidCase {
        case isShortLength
        case isOnlyNumber
        case isNotAcceptableCharacters
        case isAlreadyUsed
        case isValid
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setAutoLayouts()
        NotificationCenter.default.do {
            $0.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
            $0.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        }
        configUI()
        
        if let nameToSet { // 소셜로그인 인 경우, 이름 필드 숨기기
            nameView.isHidden = true
            nameTextView.isHidden = true
            nameTextField.isHidden = true
            nameTextField.text = nameToSet
            directionInLabel.setAttributedText(defaultText: "친구들이 회원님에게 약속을 보내기 위해서는 닉네임이 필요해요.", kernValue: -0.6)
        }
    }
    
    // MARK: - setLayouts
    
    private func setAutoLayouts() {
        self.navigationController?.isNavigationBarHidden = true
        view.addSubviews( [navigationBarView,
                           directionInLabel,
                           nameView,
                           idView,
                           idWarningLabel,
                           startButton
                          ])
        
        navigationBarView.addSubviews([backButton,navigationTitleLabel,closeButton])
        
        nameView.addSubviews([nameViewheadLabel, nameTextView])
        nameTextView.addSubview(nameTextField)
        
        idView.addSubviews([idViewheadLabel, idTextView])
        
        idTextView.addSubview(idTextField)
        
        nameTextField.delegate = self
        idTextField.delegate = self
        
        idWarningLabel.isHidden = true
        
        view.dismissKeyboardWhenTappedAround()
        
        navigationBarView.snp.makeConstraints{
            $0.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(58 * heightRatio)
        }
        backButton.snp.makeConstraints{
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(2 * widthRatio)
            $0.width.height.equalTo(48 * widthRatio)
        }
        navigationTitleLabel.snp.makeConstraints{
            $0.centerY.equalTo(backButton)
            $0.centerX.equalToSuperview()
        }
        closeButton.snp.makeConstraints{
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-4 * widthRatio)
            $0.width.height.equalTo(48 * widthRatio)
        }
        directionInLabel.snp.makeConstraints{
            $0.top.equalTo(navigationBarView.snp.bottom).offset(16 * heightRatio)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(158 * widthRatio)
            
        }
        nameView.snp.makeConstraints{
            $0.top.equalTo(directionInLabel.snp.bottom).offset(32 * heightRatio)
            $0.leading.equalToSuperview().offset(20 * widthRatio)
            $0.trailing.equalTo(view.snp.trailing).offset(-20 * widthRatio)
            $0.height.equalTo(80 * heightRatio)
        }
        nameViewheadLabel.snp.makeConstraints{
            $0.top.equalToSuperview().offset(1 * heightRatio)
            $0.leading.equalToSuperview()
            
        }
        nameTextView.snp.makeConstraints{
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(50 * heightRatio)
            $0.bottom.equalToSuperview()
        }
        nameTextField.snp.makeConstraints{
            $0.leading.equalToSuperview().offset(12 * widthRatio)
            $0.top.bottom.trailing.equalToSuperview()
        }
        idView.snp.makeConstraints{
            $0.top.equalTo(nameView.snp.bottom).offset(16 * heightRatio)
            $0.leading.equalToSuperview().offset(20 * widthRatio)
            $0.trailing.equalTo(view.snp.trailing).offset(-20 * widthRatio)
            $0.height.equalTo(80 * heightRatio)
        }
        idViewheadLabel.snp.makeConstraints{
            $0.top.equalToSuperview().offset(1 * heightRatio)
            $0.leading.equalToSuperview()
            $0.width.equalTo(50 * widthRatio)
        }
        idTextView.snp.makeConstraints{
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(50 * heightRatio)
            $0.bottom.equalToSuperview()
        }
        idTextField.snp.makeConstraints{
            $0.leading.equalToSuperview().offset(12 * widthRatio)
            $0.top.bottom.trailing.equalToSuperview()
        }
        idWarningLabel.snp.makeConstraints{
            $0.leading.equalToSuperview().offset(20 * widthRatio)
            $0.top.equalTo(idView.snp.bottom).offset(10 * heightRatio)
        }
        startButton.snp.makeConstraints{
            $0.top.equalTo(idWarningLabel.snp.bottom).offset(15 * heightRatio)
            $0.leading.equalToSuperview().offset(20 * widthRatio)
            $0.trailing.equalToSuperview().offset(-20 * widthRatio)
            $0.height.equalTo(54 * heightRatio)
        }
    }
    
    // MARK: - Custom Methods
    
    private func configUI() {
        backButton.addTarget(self, action: #selector(backButtonClicked(_:)), for: .touchUpInside)
        closeButton.addTarget(self, action: #selector(closeButtonClicked(_:)), for: .touchUpInside)
        startButton.addTarget(self, action: #selector(startButtonClicked(_:)), for: .touchUpInside)
        startButton.isEnabled = false
        nameTextField.addTarget(self, action: #selector(nameTextFieldDidChange(_:)), for: .editingChanged)
        idTextField.addTarget(self, action: #selector(idTextFieldDidChange(_:)), for: .editingChanged)
    }
    
    private func checkIdValid(id: String) -> IDValidCase {
        let pattern = "^[a-zA-Z0-9_\\.]*$"
        
        guard let _ = id.range(of: pattern, options: .regularExpression) else {
            return .isNotAcceptableCharacters
        }
        
        if id.count < 7 {
            return .isShortLength
        } else if id.allSatisfy({$0.isNumber}) {
            return .isOnlyNumber
        } else {
            return .isValid
        }
    }
    
    private func presentIdWarning() {
        idTextView.layer.do {
            $0.borderColor = UIColor.pink01.cgColor
            $0.borderWidth = 1
        }
        idWarningLabel.isHidden = false
    }
    
    private func hideIdWarning() {
        idTextView.layer.do {
            $0.borderColor = nil
            $0.borderWidth = 0
        }
        idWarningLabel.isHidden = true
    }
    
    // MARK: - Actions
    
    @objc private func keyboardWillShow(_ sender: Notification) {
        if isKeyboardShow == false {
            view.frame.origin.y -= 150 * heightRatio
            isKeyboardShow = true
        }
    }
    @objc private func keyboardWillHide(_ sender: Notification) {
        if isKeyboardShow == true {
            view.frame.origin.y += 150 * heightRatio
            isKeyboardShow = false
        }
    }
    
    @objc private func backButtonClicked(_ sender: UIButton) {
        delegate?.registerBackButtonDidTap()
    }
    
    @objc private func closeButtonClicked(_ sender: UIButton){
        self.delegate?.closeButtonDidTap()
    }
    
    @objc private func startButtonClicked(_ sender: UIButton) {
        guard let accessTokenToSet = accessTokenToSet,
              let refreshTokenToSet = refreshTokenToSet,
              let name = nameTextField.text,
              let id = idTextField.text else { return }
        
        var nameToRequest: String? = nil
        if let nameToSet {
            nameToRequest = nameToSet
        }
        
        PutNameAndIdService.shared.putNameAndId(name: nameToRequest, userId: id, accessToken: accessTokenToSet) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let success):
                if let data = success as? PutNameAndIdResponseDataModel {
                    switch data.status {
                    case 404:
                        self.view.makeToastAnimation(message: "네트워크 오류! 씨밋 개발자 연락처로 연락해주세요.")
                    default:
                        TokenUtils.shared.create(account: "accessToken", value: accessTokenToSet)
                        TokenUtils.shared.create(account: "refreshToken", value: refreshTokenToSet)
                        
                        UserDefaults.standard.do {
                            $0.set(name, forKey: Constants.UserDefaultsKey.userName)
                            $0.set(id, forKey: Constants.UserDefaultsKey.userNickname)
                        }
                        UserDefaults.standard.set(self.email, forKey: Constants.UserDefaultsKey.userEmail)
                        UserDefaults.standard.set(true, forKey: Constants.UserDefaultsKey.isLogin)
                        UserDefaults.standard.set(self.isAppleLogin, forKey: Constants.UserDefaultsKey.isAppleLogin)
                        
                        self.delegate?.closeButtonDidTap()
                    }
                }
            case .requestErr(let error):
                self.idWarningLabel.text = "이미 사용 중이에요"
                self.presentIdWarning()
            case .pathErr:
                print("pathErr")
            case .networkFail:
                print("networkFail")
            case .serverErr:
                print("serverErr")
            }
        }
    }
    
    @objc func nameTextFieldDidChange(_ sender: Any?) {
        guard let nameText = nameTextField.text else {return}
        if nameText.count > 5 {
            nameTextField.deleteBackward()
        }
    }
    
    @objc func idTextFieldDidChange(_ sender: Any?) {

        guard let text = idTextField.text else { return }
        switch checkIdValid(id: text) {
        case .isShortLength:
            idWarningLabel.text = "7자 이상 써주세요"
            presentIdWarning()
            startButton.do {
                $0.isEnabled = false
                $0.backgroundColor = UIColor.grey02
            }
        case .isOnlyNumber:
            idWarningLabel.text = "숫자로만은 만들 수 없어요"
            presentIdWarning()
            startButton.do {
                $0.isEnabled = false
                $0.backgroundColor = UIColor.grey02
            }
        case .isNotAcceptableCharacters:
            idWarningLabel.text = "아이디는 알파벳, 숫자, 밑줄, 마침표만 사용 가능해요"
            presentIdWarning()
            startButton.do {
                $0.isEnabled = false
                $0.backgroundColor = UIColor.grey02
            }
        case .isAlreadyUsed:
            idWarningLabel.text = "이미 사용 중이에요"
            presentIdWarning()
            startButton.do {
                $0.isEnabled = false
                $0.backgroundColor = UIColor.grey02
            }
        case .isValid:
            hideIdWarning()
            startButton.do {
                $0.isEnabled = true
                $0.backgroundColor = UIColor.pink01
            }
        }
        
    }
}



// MARK: - Extensions

extension ProfileRegisterVC: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == idTextField {
            idTextView.layer.borderWidth = 0
            idWarningLabel.isHidden = true
        }
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == idTextField {
            guard let text = textField.text else { return }
            switch checkIdValid(id: text) {
            case .isShortLength:
                idWarningLabel.text = "7자 이상 써주세요"
                presentIdWarning()
                startButton.do {
                    $0.isEnabled = false
                    $0.backgroundColor = UIColor.grey02
                }
            case .isOnlyNumber:
                idWarningLabel.text = "숫자로만은 만들 수 없어요"
                presentIdWarning()
                startButton.do {
                    $0.isEnabled = false
                    $0.backgroundColor = UIColor.grey02
                }
            case .isNotAcceptableCharacters:
                idWarningLabel.text = "아이디는 알파벳, 숫자, 밑줄, 마침표만 사용 가능해요"
                presentIdWarning()
                startButton.do {
                    $0.isEnabled = false
                    $0.backgroundColor = UIColor.grey02
                }
            case .isAlreadyUsed:
                idWarningLabel.text = "이미 사용 중이에요"
                presentIdWarning()
                startButton.do {
                    $0.isEnabled = false
                    $0.backgroundColor = UIColor.grey02
                }
            case .isValid:
                hideIdWarning()
                startButton.do {
                    $0.isEnabled = true
                    $0.backgroundColor = UIColor.pink01
                }
            }
        }
    }
    
    // 한 글자 입력시 호출
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == nameTextField{
            let utf8Char = string.cString(using: .utf8)
                   let isBackSpace = strcmp(utf8Char, "\\b")
                   if string.hasCharacters() || isBackSpace == -92{
                       return true
                   }
                   return false
        }
        
        return true
    }
    
}



