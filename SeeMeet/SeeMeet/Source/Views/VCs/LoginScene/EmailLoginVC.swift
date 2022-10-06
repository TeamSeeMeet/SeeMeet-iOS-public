import UIKit
import SnapKit
import Then
import SwiftUI

protocol EmailLoginVCDelegate{
    func backButtonDidTap()
    func emailRegisterDidTap()
    func closeButtonDidTap()
    func loginCompleted()
}
class EmailLoginVC: UIViewController {
    
    // MARK: - UI Components
    
    private let navigationBarView = UIView()
    
    private let navigationTitleLabel = UILabel().then{
        $0.textColor = .black
        $0.font = UIFont.hanSansBoldFont(ofSize: 18)
        $0.text = "이메일로 로그인"
    }
    
    private let backButton = UIButton().then{
        $0.setImage(UIImage(named: "btn_back"), for: .normal)
    }
    
    private let closeButton = UIButton().then{
        $0.setImage(UIImage(named: "btn_close_bold"), for: .normal)
        
    }
    
    private let emailTextView = GrayTextView(type: .loginEmail)
    
    private let emailTextField = GrayTextField(type: .email, placeHolder: "이메일").then{
        $0.tag = 1
    }
    
    private let passwordTextView =  GrayTextView(type: .loginPassword)
    
    private let passwordTextField = GrayTextField(type: .password, placeHolder: "비밀번호").then{
        $0.tag = 2
    }
    
    private let passwordSeeButton = UIButton().then{
        $0.setBackgroundImage(UIImage(named: "ic_password_notsee"), for: .normal)
        $0.isHidden = true
    }
    
    private let loginButton = UIButton().then{
        $0.backgroundColor = UIColor.grey04
        $0.setTitle("로그인", for: .normal)
        $0.setTitleColor(UIColor.white, for: .normal)
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 10
        $0.isEnabled = false
    }
    
    private let registerLabel = UILabel().then{
        $0.text = "아직 회원이 아니신가요?"
        $0.font = UIFont.hanSansRegularFont(ofSize: 14)
        $0.textColor = UIColor.grey05
    }
    
    private let registerButton = UIButton().then{
        $0.titleLabel?.font = UIFont.hanSansRegularFont(ofSize: 14)
        $0.setTitleColor(UIColor.grey05, for: .normal)
        let attribute = [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue]
        let attributedString = NSAttributedString(string: "회원가입", attributes: attribute)
        $0.setAttributedTitle(attributedString, for: .normal)
    }
    
    // MARK: - Properties
    
    weak var coordinator: Coordinator?
    
    //원래 비밀번호 상태 true가 디폴트
    private var isNotSee: Bool = true
    private var isFull: Bool = false
    var delegate: EmailLoginVCDelegate?
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setLoginLayout()
        configUI()
    }
    
    // MARK: - Layout
    
    private func setLoginLayout(){
        self.navigationController?.isNavigationBarHidden = true
        view.backgroundColor = UIColor.white
        view.addSubviews([navigationBarView,
                          emailTextView,
                          passwordTextView,
                          loginButton,
                          registerLabel,
                          registerButton])
        navigationBarView.addSubviews([backButton,
                                       navigationTitleLabel,
                                       closeButton])
        emailTextView.addSubview(emailTextField)
        passwordTextView.addSubviews([passwordTextField,
                                      passwordSeeButton])
        
        passwordTextField.delegate = self
        emailTextField.delegate = self
        
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
        
        closeButton.snp.makeConstraints{
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-4 * widthRatio)
            $0.width.height.equalTo(48 * widthRatio)
        }
        
        navigationTitleLabel.snp.makeConstraints{
            $0.centerX.centerY.equalToSuperview()
        }
        
        emailTextView.snp.makeConstraints{
            $0.top.equalTo(navigationBarView.snp.bottom).offset(32 * heightRatio)
            $0.leading.equalToSuperview().offset(20 * widthRatio)
            $0.trailing.equalToSuperview().offset(-20 * widthRatio)
            $0.height.equalTo(48 * heightRatio)
        }
        
        emailTextField.snp.makeConstraints{
            $0.leading.equalToSuperview().offset(52 * widthRatio)
            $0.top.bottom.equalTo(0)
            $0.trailing.equalToSuperview().offset(-5 * widthRatio)
        }
        
        passwordSeeButton.snp.makeConstraints{
            $0.trailing.top.bottom.equalToSuperview()
            $0.width.equalTo(48 * widthRatio)
        }
        
        passwordTextView.snp.makeConstraints{
            $0.top.equalTo(emailTextView.snp.bottom).offset(14 * heightRatio)
            $0.leading.equalToSuperview().offset(20 * widthRatio)
            $0.trailing.equalToSuperview().offset(-20 * widthRatio)
            $0.height.equalTo(48 * heightRatio)
        }
        
        passwordTextField.snp.makeConstraints{
            $0.leading.equalToSuperview().offset(52 * widthRatio)
            $0.top.bottom.equalTo(0)
            $0.trailing.equalToSuperview().offset(-5 * widthRatio)
        }
        
        loginButton.snp.makeConstraints{
            $0.top.equalTo(passwordTextView.snp.bottom).offset(40 * heightRatio)
            $0.leading.equalToSuperview().offset(20 * widthRatio)
            $0.trailing.equalToSuperview().offset(-20 * widthRatio)
            $0.height.equalTo(54 * heightRatio)
        }
        registerLabel.snp.makeConstraints{
            $0.top.equalTo(loginButton.snp.bottom).offset(32 * heightRatio)
            $0.centerX.equalToSuperview().offset(-30 * widthRatio)
        }
        registerButton.snp.makeConstraints{
            $0.leading.equalTo(registerLabel.snp.trailing).offset(14 * widthRatio)
            $0.centerY.equalTo(registerLabel)
        }
    }
    
    // MARK: - Custom Methods
    
    private func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,50}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    private func configUI() {
        backButton.addTarget(self, action: #selector(backButtonClicked(_:)), for: .touchUpInside)
        closeButton.addTarget(self, action: #selector(closeButtonClicked(_:)), for: .touchUpInside)
        emailTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        passwordSeeButton.addTarget(self, action: #selector(notSeeButtonClicked(_:)), for: .touchUpInside)
        loginButton.addTarget(self, action: #selector(loginButtonClicked(_:)), for: .touchUpInside)
        registerButton.addTarget(self, action: #selector(registerButtonClicked(_:)), for: .touchUpInside)
    }
    
    // MARK: - Actions
    
    @objc func notSeeButtonClicked(_ sender: UIButton) {
        if isNotSee == true {
            isNotSee = false
            passwordSeeButton.setBackgroundImage(UIImage(named: "ic_password_see"), for: .normal)
            passwordTextField.isSecureTextEntry = isNotSee
        }
        else {
            isNotSee = true
            passwordSeeButton.setBackgroundImage(UIImage(named: "ic_password_notsee"), for: .normal)
            passwordTextField.isSecureTextEntry = isNotSee
        }
    }
    
    //이메일로그인 서버 완성된 후 전체적인 함수 점검하기
    @objc private func loginButtonClicked(_ sender: UIButton){
        if isFull == true {
            PostLoginService.shared.login(email: emailTextField.text ?? "", password: passwordTextField.text ?? ""){ (response) in
                switch(response) {
                case .success(let success):
                    if let success = success as? EmailLoginResponseModel {
                        if success.status == 404 {
                            self.view.makeToastAnimation(message: success.message)
                        }
                        else {
                            UserDefaults.standard.set(true, forKey: Constants.UserDefaultsKey.isLogin)
                            UserDefaults.standard.set(success.data?.user.username, forKey: Constants.UserDefaultsKey.userName)
                            UserDefaults.standard.set(success.data?.user.email, forKey: Constants.UserDefaultsKey.userEmail)
                            UserDefaults.standard.set(success.data?.user.nickname, forKey: Constants.UserDefaultsKey.userNickname)
                            NotificationCenter.default.post(name: NSNotification.Name.PushNotificationDidSet, object: success.data?.user.push)
                            guard let accessToken = success.data?.accesstoken as? String, let refreshToken = success.data?.refreshtoken as? String else { return }
                            TokenUtils.shared.create(account: "accessToken", value: accessToken)
                            TokenUtils.shared.create(account: "refreshToken", value: refreshToken)
                            UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.makeToastAnimation(message: "로그인이 완료되었습니다.")
                            self.delegate?.loginCompleted()
                        }
                    }
                case .requestErr(let message) :
                    
                    if message as? String == "이메일이 유효하지 않습니다."{
                        self.view.makeToastAnimation(message: "등록되지 않은 유저입니다.")
                    }
                    if message as? String == "로그인 실패"{
                        self.view.makeToastAnimation(message: "비밀번호가 틀렸습니다.")
                    }
                    
                case .pathErr :
                    print("pathERR")
                case .serverErr:
                    print("serverERR")
                case .networkFail:
                    print("networkFail")
                }
            }
        }
    }
    
    @objc func backButtonClicked(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func closeButtonClicked(_ sender: UIButton){
        delegate?.closeButtonDidTap()
    }
    
    @objc private func registerButtonClicked(_ sender: UIButton){
        delegate?.emailRegisterDidTap()
    }
}

// MARK: - Extensions

extension EmailLoginVC: UITextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.tag == 2{
            passwordSeeButton.isHidden = false
        }
        
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.tag == 2{
            if textField.text?.isEmpty == true{
                passwordSeeButton.isHidden = true
            }
        }
    }
    @objc func textFieldDidChange(_ sender: Any?) {
        if passwordTextField.text?.isEmpty == false && isValidEmail(testStr: emailTextField.text ?? ""){
            if passwordTextField.text?.count ?? 0 >= 8 {
                loginButton.backgroundColor = UIColor.pink01
                loginButton.isEnabled = true
                isFull = true
            }
        }
        else {
            isFull = false
            loginButton.isEnabled = false
            loginButton.backgroundColor = UIColor.grey04
        }
    }
}
