//
//  ChangePasswordVC.swift
//  SeeMeet
//
//  Created by 이유진 on 2022/06/05.
//

import UIKit

protocol ChangePasswordVCDelegate {
    func backButtonDidTap()
    func changePasswordCompleted()
}

class ChangePasswordVC: UIViewController {
    
    weak var coordinator: Coordinator?
    var delegate: ChangePasswordVCDelegate?
    
    private let navigationBarView = UIView().then{
        $0.backgroundColor = .white
    }
    
    private let backButton = UIButton().then{
        $0.setImage(UIImage(named: "btn_back"), for: .normal)
    }
    
    private let newPasswordLabel = UILabel().then{
        $0.textColor = .black
        $0.font = UIFont.hanSansBoldFont(ofSize: 16)
        $0.text = "새 비밀번호"
    }
    
    private let newPasswordTextField = UITextField().then{
        $0.font = UIFont.hanSansRegularFont(ofSize: 16)
        $0.isSecureTextEntry = true
        $0.addRightPadding(width: 50)
    }
    private let seePasswordButton = UIButton().then {
        $0.setBackgroundImage(UIImage(named: "ic_password_notsee"), for: .normal)
    }
    private let newPasswordUnderLineView = UIView().then{
        $0.backgroundColor = UIColor.grey02
    }
    private let passwordWarningLabel = UILabel().then {
        $0.setAttributedText(defaultText: " ", font: UIFont.hanSansRegularFont(ofSize: 12), color: UIColor.red, kernValue: -0.6)
    }
    private let passwordCheckLabel = UILabel().then{
        $0.textColor = .black
        $0.font = UIFont.hanSansBoldFont(ofSize: 16)
        $0.text = "비밀번호 확인"
    }
    
    private let passwordCheckTextField = UITextField().then{
        $0.font = UIFont.hanSansRegularFont(ofSize: 16)
        $0.isSecureTextEntry = true
        $0.addRightPadding(width: 50)

    }
    private let seePasswordCheckButton = UIButton().then {
        $0.setBackgroundImage(UIImage(named: "ic_password_notsee"), for: .normal)
    }
    
    private let passwordCheckUnderLineView = UIView().then{
        $0.backgroundColor = UIColor.grey02
    }
    
    private let passwordCheckWarningLabel = UILabel().then {
        $0.setAttributedText(defaultText: " ", font: UIFont.hanSansRegularFont(ofSize: 12), color: UIColor.red, kernValue: -0.6)
    }
    
    private let saveButton = UIButton().then{
        $0.setTitle("저장", for: .normal)
        $0.titleLabel?.font = UIFont.hanSansRegularFont(ofSize: 16)
        $0.setTitleColor(UIColor.grey06, for: .normal)
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 10
        $0.layer.borderColor = UIColor.grey06.cgColor
        $0.layer.borderWidth = 1
        $0.isEnabled = false
    }
    
    private let cancelButton = UIButton().then{
        $0.setTitle("취소", for: .normal)
        $0.titleLabel?.font = UIFont.hanSansRegularFont(ofSize: 16)
        $0.setTitleColor(UIColor.grey03, for: .normal)
        $0.isHidden = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setLayout()
        setGesture()
        setDelegate()
    }
    
    private func setDelegate() {
        newPasswordTextField.delegate = self
        passwordCheckTextField.delegate = self
    }
    private func setGesture(){
        backButton.addTarget(self, action: #selector(backButtonDidTap(_:)), for: .touchUpInside)
        seePasswordButton.addTarget(self, action: #selector(seePasswordButtonClicked(_:)), for: .touchUpInside)
        seePasswordCheckButton.addTarget(self, action: #selector(seePasswordCheckButtonClicked(_:)), for: .touchUpInside)
        newPasswordTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        passwordCheckTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        saveButton.addTarget(self, action: #selector(saveButtonDidTap(_:)), for: .touchUpInside)
    }
    
    @objc private func backButtonDidTap(_ sender: UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    @objc private func saveButtonDidTap(_ sender: UIButton){
        putPassword()
    }
    @objc func seePasswordButtonClicked(_ sender: UIButton) {
        if !newPasswordTextField.isSecureTextEntry{
            seePasswordButton.setBackgroundImage(UIImage(named: "ic_password_notsee"), for: .normal)
            newPasswordTextField.isSecureTextEntry.toggle()
        }
        else{
            seePasswordButton.setBackgroundImage(UIImage(named: "ic_password_see"), for: .normal)
            newPasswordTextField.isSecureTextEntry.toggle()
        }
    }
    @objc func seePasswordCheckButtonClicked(_ sender: UIButton) {
        if !passwordCheckTextField.isSecureTextEntry{
            seePasswordCheckButton.setBackgroundImage(UIImage(named: "ic_password_notsee"), for: .normal)
            passwordCheckTextField.isSecureTextEntry.toggle()
        }
        else{
            seePasswordCheckButton.setBackgroundImage(UIImage(named: "ic_password_see"), for: .normal)
            passwordCheckTextField.isSecureTextEntry.toggle()
        }
    }
    
    private func isValidPassword(testStr:String, regEx: [String]) -> [Bool]{
        var passwordStatus: [Bool] = []
        for reg in regEx{
            let passwordRegEx = reg
            let passwordTest = NSPredicate(format:"SELF MATCHES %@", passwordRegEx)
            passwordStatus.append(passwordTest.evaluate(with: testStr))
        }
        return passwordStatus
    }
    private func setLayout() {
        self.navigationController?.isNavigationBarHidden = true
//        self.tabBarController?.tabBar.isHidden = true
        
        view.addSubviews([navigationBarView,newPasswordLabel,newPasswordTextField,newPasswordUnderLineView,passwordWarningLabel,passwordCheckLabel,passwordCheckTextField,passwordCheckUnderLineView,passwordCheckWarningLabel,saveButton,cancelButton])
        navigationBarView.addSubview(backButton)
        newPasswordTextField.addSubview(seePasswordButton)
        passwordCheckTextField.addSubview(seePasswordCheckButton)
        
        navigationBarView.snp.makeConstraints{
            $0.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(58)
        }
        backButton.snp.makeConstraints{
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(2)
        }
        newPasswordLabel.snp.makeConstraints{
            $0.top.equalTo(navigationBarView.snp.bottom).offset(39)
            $0.leading.equalToSuperview().offset(20)
            $0.width.equalTo(92)
        }
        newPasswordTextField.snp.makeConstraints{
            $0.leading.equalTo(newPasswordLabel.snp.trailing).offset(18)
            $0.trailing.equalToSuperview().offset(-20)
            $0.centerY.equalTo(newPasswordLabel)
        }
        seePasswordButton.snp.makeConstraints{
            $0.trailing.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(48)
        }
        newPasswordUnderLineView.snp.makeConstraints{
            $0.top.equalTo(newPasswordTextField.snp.bottom)
            $0.leading.trailing.equalTo(newPasswordTextField)
            $0.height.equalTo(1)
        }
        passwordWarningLabel.snp.makeConstraints{
            $0.top.equalTo(newPasswordUnderLineView.snp.bottom).offset(3)
            $0.leading.equalTo(newPasswordUnderLineView)
        }
        passwordCheckLabel.snp.makeConstraints{
            $0.top.equalTo(newPasswordLabel.snp.bottom).offset(32)
            $0.leading.equalToSuperview().offset(20)
            $0.width.equalTo(92)
        }
        passwordCheckTextField.snp.makeConstraints{
            $0.leading.equalTo(passwordCheckLabel.snp.trailing).offset(18)
            $0.trailing.equalToSuperview().offset(-20)
            $0.centerY.equalTo(passwordCheckLabel)
        }
        seePasswordCheckButton.snp.makeConstraints{
            $0.trailing.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(48)
        }
        passwordCheckUnderLineView.snp.makeConstraints{
            $0.top.equalTo(passwordCheckTextField.snp.bottom)
            $0.leading.trailing.equalTo(passwordCheckTextField)
            $0.height.equalTo(1)
        }
        passwordCheckWarningLabel.snp.makeConstraints{
            $0.top.equalTo(passwordCheckUnderLineView.snp.bottom).offset(3)
            $0.leading.equalTo(passwordCheckUnderLineView)
        }
        saveButton.snp.makeConstraints{
            $0.trailing.equalToSuperview().offset(-20)
            $0.top.equalTo(passwordCheckUnderLineView.snp.bottom).offset(18)
            $0.width.equalTo(60)
            $0.height.equalTo(40)
        }
        cancelButton.snp.makeConstraints{
            $0.trailing.equalTo(saveButton.snp.leading).offset(-20)
            $0.centerY.equalTo(saveButton)
        }
    }

    private func putPassword(){
        guard let accessToken = TokenUtils.shared.read(account: "accessToken"),
              let password = passwordCheckTextField.text
        else{return}
        
        PutPasswordService.shared.putPassword(password: password) { [weak self] result in
       
            switch result {
            case .success(let success):
               print("비밀번호 변경 성공")
                UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.makeToastAnimation(message: "비밀번호가 변경되었습니다.")
                self?.delegate?.changePasswordCompleted()
            case .requestErr(let error):
                print("requestErr")
            case .pathErr:
                print("pathErr")
            case .networkFail:
                print("networkFail")
            case .serverErr:
                print("serverErr")
            }
        }
        
    }
    
    
}

extension ChangePasswordVC: UITextFieldDelegate{

    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField{
        case newPasswordTextField:
            let regList: [String] = ["^(?=.*[A-Za-z])(?=.*[0-9])(?=.*[!@#$%^&*()_+=-]).{8,16}", "^(?=.*[A-Za-z])(?=.*[0-9]).{8,16}", "^(?=.*[A-Za-z])(?=.*[!@#$%^&*()_+=-]).{8,16}", "^(?=.*[0-9])(?=.*[!@#$%^&*()_+=-]).{8,16}"]
            var regiBoolList: [Bool] = []
            var regiCount = 0
            regiBoolList = isValidPassword(testStr: newPasswordTextField.text ?? "", regEx: regList)
            for valid in regiBoolList{
                if valid {
                    regiCount += 1
                }
            }
             if newPasswordTextField.text?.count ?? 0 < 8 {
                    passwordWarningLabel.text = "8자 이상의 비밀번호를 입력해주세요."
                
            }else if regiCount < 1{
                passwordWarningLabel.text = "영문, 숫자, 특수문자 중 2가지 이상을 사용해주세요."
                
            } else{
                passwordWarningLabel.text = ""
                saveButton.isEnabled = true
            }
        case passwordCheckTextField:
            if newPasswordTextField.text != passwordCheckTextField.text {
                passwordCheckWarningLabel.text = "비밀번호가 일치하지 않아요."
                saveButton.isEnabled = false
            }
            else{
                passwordCheckWarningLabel.text = ""
                saveButton.isEnabled = true
            }
        default:
            print("default")
        }
     
    }
    
    @objc func textFieldDidChange(_ sender: Any?) {
        
            let regList: [String] = ["^(?=.*[A-Za-z])(?=.*[0-9])(?=.*[!@#$%^&*()_+=-]).{8,16}", "^(?=.*[A-Za-z])(?=.*[0-9]).{8,16}", "^(?=.*[A-Za-z])(?=.*[!@#$%^&*()_+=-]).{8,16}", "^(?=.*[0-9])(?=.*[!@#$%^&*()_+=-]).{8,16}"]
            var regiBoolList: [Bool] = []
            var regiCount = 0
            regiBoolList = isValidPassword(testStr: newPasswordTextField.text ?? "", regEx: regList)
            for valid in regiBoolList{
                if valid {
                    regiCount += 1
                }
            }
           
        if newPasswordTextField.text?.count ?? 0 < 8 {
                passwordWarningLabel.text = "8자 이상의 비밀번호를 입력해주세요."
        }else if regiCount < 1{
                passwordWarningLabel.text = "영문, 숫자, 특수문자 중 2가지 이상을 사용해주세요."
                
            } else{
                passwordWarningLabel.text = ""
                saveButton.isEnabled = true
            }
        
            if newPasswordTextField.text != passwordCheckTextField.text {
                passwordCheckWarningLabel.text = "비밀번호가 일치하지 않아요."
                saveButton.isEnabled = false
            }
            else{
                passwordCheckWarningLabel.text = ""
                saveButton.isEnabled = true
            }
       
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        switch textField{
        case newPasswordTextField, passwordCheckTextField:
            if let char = string.cString(using: String.Encoding.utf8) {
                let isBackSpace = strcmp(char, "\\b")
                if isBackSpace == -92 {
                    return true
                }
            }
            guard textField.text!.count < 16 else { return false }
        default:
            return true
            
        }
        return true
    }
}


