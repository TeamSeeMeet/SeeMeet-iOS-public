//
//  UserInfoViewController.swift
//  SeeMeet
//
//  Created by 이유진 on 2022/06/05.
//

import UIKit
import AuthenticationServices

protocol UserInfoVCDelegate{
    func backButtonDidTap()
    func changePasswordButtonDidTap()
    func withdrawalOKButtonDidTap()
    func logoutOKButtonDidTap()
}
class UserInfoVC: UIViewController {
    
    private var isImageEditing = false
    var isInfoEditing = false //이름,아이디 수정 중인 상태인지 flag값
    private var userName = UserDefaults.standard.string(forKey: Constants.UserDefaultsKey.userName)
    private var userId = UserDefaults.standard.string(forKey: Constants.UserDefaultsKey.userNickname)
    private var isDuplicatedID = false
    let imagePicker = UIImagePickerController()
    weak var coordinator: Coordinator?
    var delegate: MyPageCoordinator?
    
    private let navigationBarView = UIView().then{
        $0.backgroundColor = .white
    }
    
    private let profileView = UIView().then{
        $0.backgroundColor = .white
        $0.getShadowView(color: UIColor.black.cgColor, masksToBounds: false, shadowOffset: CGSize(width: 0, height: 1), shadowRadius: 1, shadowOpacity: 0.25)
    }
    
    
    private let backButton = UIButton().then{
        $0.setImage(UIImage(named: "btn_back"), for: .normal)
    }
    
    private let profileImageView = UIImageView().then {
        guard let image = ImageManager.shared.getSavedImage(named: "profile.png") ?? UIImage(named: "img_profile")  else {return}
        $0.image = image
        $0.layer.cornerRadius = 50
        $0.clipsToBounds = true
        $0.contentMode = .scaleAspectFill
        
    }
    
    private let profileImageEditButton = UIButton().then{
        $0.setTitle("프로필사진 편집", for: .normal)
        $0.titleLabel?.font = UIFont.hanSansRegularFont(ofSize: 10)
        $0.setTitleColor(UIColor.grey06, for: .normal)
        $0.layer.cornerRadius = 6
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.grey06.cgColor
    }
    
    private let cameraButton = UIButton().then{
        $0.setImage(UIImage(named: "ic_camera"), for: .normal)
        $0.isHidden = true
    }
    
    private let nameLabel = UILabel().then{
        $0.textColor = .black
        $0.font = UIFont.hanSansBoldFont(ofSize: 16)
        $0.text = "이름"
    }
    
    private let nameTextField = UITextField().then{
        $0.font = UIFont.hanSansRegularFont(ofSize: 16)
        $0.isEnabled = false
    }
    private let nameUnderLineView = UIView().then{
        $0.backgroundColor = UIColor.grey02
        $0.isHidden = true
    }
    
    private let idLabel = UILabel().then{
        $0.textColor = .black
        $0.font = UIFont.hanSansBoldFont(ofSize: 16)
        $0.text = "아이디"
    }
    
    private let idTextField = UITextField().then{
        $0.font = UIFont.hanSansRegularFont(ofSize: 16)
        $0.isEnabled = false
    }
    
    private let idUnderLineView = UIView().then{
        $0.backgroundColor = UIColor.grey02
        $0.isHidden = true
    }
    
    private let reviseButton = UIButton().then{
        $0.setTitle("수정", for: .normal)
        $0.titleLabel?.font = UIFont.hanSansRegularFont(ofSize: 16)
        $0.setTitleColor(UIColor.grey06, for: .normal)
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 10
        $0.layer.borderColor = UIColor.grey06.cgColor
        $0.layer.borderWidth = 1
    }
    
    private let reviseCancelButton = UIButton().then{
        $0.setTitle("취소", for: .normal)
        $0.titleLabel?.font = UIFont.hanSansRegularFont(ofSize: 16)
        $0.setTitleColor(UIColor.grey03, for: .normal)
        $0.isHidden = true
    }
    
    private let changePasswordView = UIView().then{
        $0.backgroundColor = .white
        $0.getShadowView(color: UIColor.black.cgColor, masksToBounds: false, shadowOffset: CGSize(width: 0, height: 1), shadowRadius: 1, shadowOpacity: 0.25)
    }
    
    private let changePasswordLabel = UILabel().then{
        $0.textColor = .black
        $0.font = UIFont.hanSansMediumFont(ofSize: 16)
        $0.text = "비밀번호 변경"
    }
    
    private let changePasswordButton = UIButton().then{
        $0.setImage(UIImage(named: "ic_calendar_right"), for: .normal)
        $0.isUserInteractionEnabled = false
    }
    
    private let accountWithdrawalButton = UIButton().then{
        $0.setTitle("회원탈퇴", for: .normal)
        $0.titleLabel?.font = UIFont.hanSansMediumFont(ofSize: 16)
        $0.setTitleColor(UIColor.grey04, for: .normal)
    }
    
    private let logoutButton = UIButton().then{
        $0.setTitle("로그아웃", for: .normal)
        $0.titleLabel?.font = UIFont.hanSansMediumFont(ofSize: 16)
        $0.setTitleColor(UIColor.grey04, for: .normal)
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setLayout()
        setDelegate()
        setGesture()
        setTextField()
        if(isInfoEditing){
            layoutInfoRevisingOn()
        }else{
            layoutInfoRevisingOff()
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        if(isInfoEditing){
            layoutInfoRevisingOn()
        }else{
            layoutInfoRevisingOff()
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    // MARK: - Custom Method
    
    
    private func setDelegate() {
        imagePicker.delegate = self
    }
    private func setGesture(){
        profileImageEditButton.addTarget(self, action: #selector(profileImageEditButtonDidTap(_:)), for: .touchUpInside)
        cameraButton.addTarget(self, action: #selector(cameraButtonDidTap(_:)), for: .touchUpInside)
        nameTextField.addTarget(self, action: #selector(nameTextFieldDidChange(_:)), for: .editingChanged)
        idTextField.addTarget(self, action: #selector(self.idTextFieldDidChange(_:)), for: .editingChanged)
        reviseButton.addTarget(self, action: #selector(reviseButtonDidTap(_:)), for: .touchUpInside)
        reviseCancelButton.addTarget(self, action: #selector(reviseCancelButtonDidTap(_:)), for: .touchUpInside)
        accountWithdrawalButton.addTarget(self, action: #selector(accountWithdrawalButtonDidTap(_:)), for: .touchUpInside)
        logoutButton.addTarget(self, action: #selector(logoutButtonDidTap(_:)), for: .touchUpInside)
        backButton.addTarget(self, action: #selector(backButtonDidTap(_:)), for: .touchUpInside)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(changePasswordViewDidTap(_:)))
        changePasswordView.addGestureRecognizer(tapGesture)
        changePasswordView.isUserInteractionEnabled = true
    }
    
    private func putNameAndID(){
        guard let accessToken = TokenUtils.shared.read(account: "accessToken"),
              let name = nameTextField.text,
              let id = idTextField.text else { return }
        
        PutNameAndIdService.shared.putNameAndId(name: name, userId: id, accessToken: accessToken) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let success):
                if let data = success as? PutNameAndIdResponseDataModel {
                        UserDefaults.standard.do {
                            $0.set(name, forKey: Constants.UserDefaultsKey.userName)
                            $0.set(id, forKey: Constants.UserDefaultsKey.userNickname)
                    }
                    self.toggleInfoRevisingState()
//                    guard let image = self.profileImageView.image else { return }
//                    ImageManager.shared.saveImage(image: image, named: "profile.png")
                }
            case .requestErr(let error):
                print("닉네임중복") 
                self.isDuplicatedID = true
                self.view.makeToastAnimation(message: "이미 사용 중이에요")
            case .pathErr:
                print("pathErr")
            case .networkFail:
                print("networkFail")
            case .serverErr:
                print("serverErr")
            }
        }
        
    }
    
    private func postProfileImage(){
        guard let accessToken = TokenUtils.shared.read(account: "accessToken") else {return}
        PostProfileImageService.shared.postProfileImage(imageData: profileImageView.image, accessToken: accessToken){ result in
            switch result {
            case .success(let msg):
                guard let image = self.profileImageView.image else {return}
                ImageManager.shared.saveImage(image: image, named: "profile.png")
                print("success", msg)
                DispatchQueue.main.async {
                    self.cameraButton.isHidden = true
                    self.profileImageEditButton.setTitle("프로필사진 편집", for: .normal)
                }
                
                
            case .requestErr(let msg):
                print("requestERR", msg)
            case .pathErr:
                print("pathERR")
            case .serverErr:
                print("serverERR")
            case .networkFail:
                print("networkFail")
            }
        }
    }
    private func setTextField(){
        nameTextField.text = userName
        idTextField.text = userId
    }
    private func toggleImageRevisingState(){
        isImageEditing.toggle()
        switch isImageEditing{
        case true:
            cameraButton.isHidden = false
            profileImageEditButton.setTitle("프로필사진 저장", for: .normal)
            
        case false:
           
            postProfileImage()
           
            cameraButton.isHidden = true
            profileImageEditButton.setTitle("프로필사진 편집", for: .normal)
            
        }
    }
    private func toggleInfoRevisingState(){
        isInfoEditing.toggle()
        switch isInfoEditing{
        case true:
            layoutInfoRevisingOn()
        case false:
            layoutInfoRevisingOff()
        }
    }
    private func layoutInfoRevisingOn(){
        reviseCancelButton.isHidden = false
        nameTextField.isEnabled = true
        nameUnderLineView.isHidden = false
        idTextField.isEnabled = true
        idUnderLineView.isHidden = false
        reviseButton.setTitle("저장", for: .normal)
    }
    
    private func layoutInfoRevisingOff(){
        reviseCancelButton.isHidden = true
        nameTextField.isEnabled = false
        nameUnderLineView.isHidden = true
        idTextField.isEnabled = false
        idUnderLineView.isHidden = true
        reviseButton.setTitle("수정", for: .normal)
    }
    
    
    private func removeUserDefaults() {
        UserDefaults.deleteUserValue()
    }
    
    private func appleAccountWithdrawal() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let requestToApple = appleIDProvider.createRequest()
        requestToApple.requestedScopes = []
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [requestToApple])
        
        authorizationController.delegate = self
//        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    // MARK: - Layout
    
    private func setLayout() {
        self.navigationController?.isNavigationBarHidden = true
        self.view.backgroundColor = UIColor.grey01
        self.tabBarController?.tabBar.isHidden = true
        
        view.addSubviews([navigationBarView,profileView,changePasswordView,accountWithdrawalButton,logoutButton])
        navigationBarView.addSubview(backButton)
        profileView.addSubviews([profileImageView,profileImageEditButton,cameraButton,nameLabel,nameTextField,nameUnderLineView,idLabel,idTextField,idUnderLineView,reviseButton,reviseCancelButton])
        changePasswordView.addSubviews([changePasswordLabel,changePasswordButton])
        
        navigationBarView.snp.makeConstraints{
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(102)
        }
        backButton.snp.makeConstraints{
            $0.top.equalToSuperview().offset(49)
            $0.leading.equalToSuperview().offset(2)
        }
        profileView.snp.makeConstraints{
            $0.top.equalTo(navigationBarView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(309)
        }
        
        profileImageView.snp.makeConstraints{
            $0.top.equalToSuperview().offset(10)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(99)
        }
        
        profileImageEditButton.snp.makeConstraints{
            $0.top.equalTo(profileImageView.snp.bottom).offset(10)
            $0.centerX.equalTo(profileImageView.snp.centerX)
            $0.height.equalTo(20)
            $0.width.equalTo(84)
        }
        cameraButton.snp.makeConstraints{
            $0.top.equalTo(profileImageView.snp.centerY).offset(25)
            $0.leading.equalTo(profileImageView.snp.centerX).offset(25)
        }
        nameLabel.snp.makeConstraints{
            $0.top.equalToSuperview().offset(155)
            $0.leading.equalToSuperview().offset(20)
            $0.width.equalTo(60)
        }
        nameTextField.snp.makeConstraints{
            $0.leading.equalTo(nameLabel.snp.trailing).offset(58)
            $0.trailing.equalToSuperview().offset(-20)
            $0.centerY.equalTo(nameLabel)
        }
        nameUnderLineView.snp.makeConstraints{
            $0.top.equalTo(nameTextField.snp.bottom)
            $0.leading.trailing.equalTo(nameTextField)
            $0.height.equalTo(1)
        }
        idLabel.snp.makeConstraints{
            $0.top.equalTo(nameLabel.snp.bottom).offset(32)
            $0.leading.equalToSuperview().offset(20)
            $0.width.equalTo(60)
        }
        idTextField.snp.makeConstraints{
            $0.leading.equalTo(idLabel.snp.trailing).offset(58)
            $0.trailing.equalToSuperview().offset(-20)
            $0.centerY.equalTo(idLabel)
        }
        idUnderLineView.snp.makeConstraints{
            $0.top.equalTo(idTextField.snp.bottom)
            $0.leading.trailing.equalTo(idTextField)
            $0.height.equalTo(1)
        }
        reviseButton.snp.makeConstraints{
            $0.trailing.equalToSuperview().offset(-20)
            $0.bottom.equalToSuperview().offset(-32)
            $0.width.equalTo(60)
            $0.height.equalTo(40)
        }
        reviseCancelButton.snp.makeConstraints{
            $0.trailing.equalTo(reviseButton.snp.leading).offset(-20)
            $0.centerY.equalTo(reviseButton)
        }
        changePasswordView.snp.makeConstraints{
            $0.top.equalTo(profileView.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(52)
        }
        changePasswordLabel.snp.makeConstraints{
            $0.leading.equalToSuperview().offset(20)
            $0.centerY.equalToSuperview()
        }
        changePasswordButton.snp.makeConstraints{
            $0.trailing.equalToSuperview().offset(-9)
            $0.centerY.equalToSuperview()
        }
        if let useremail = UserDefaults.standard.string(forKey: Constants.UserDefaultsKey.userEmail){
            changePasswordView.isHidden = false//SNS로그인 아닌 경우
            accountWithdrawalButton.snp.makeConstraints{
                $0.top.equalTo(changePasswordView.snp.bottom).offset(56)
                $0.centerX.equalToSuperview().offset(-88)
            }
            
        }else{
                changePasswordView.isHidden = true
                accountWithdrawalButton.snp.makeConstraints{//SNS로그인인 경우
                    $0.top.equalTo(profileView.snp.bottom).offset(56)
                    $0.centerX.equalToSuperview().offset(-88)
                }
        }
       
          
        logoutButton.snp.makeConstraints{
            $0.leading.equalTo(accountWithdrawalButton.snp.trailing).offset(113)
            $0.centerY.equalTo(accountWithdrawalButton)
        }
    }
    
    // MARK: - Network
    
    private func putWithdrawal(authorizationCode: String? = nil) {
        print("authToken: \(authorizationCode)")
        PutWithdrawalService.shared.putWithdrawal(authorizationCode: authorizationCode) { response in
            switch response {
            case .success(let data):
                if let response = data as? WithdrawalDataModel {
                    print(response.status, response.message)
                    if UserDefaults.standard.string(forKey: "loginBy") == "kakao" {
                        KakaoAuthService.shared.logout() // 언링크
                    }
                    UserDefaults.standard.removeObject(forKey: "loginBy")
                    UserDefaults.deleteUserValue()
                    self.removeUserDefaults()
                    self.dismiss(animated: false)
                    self.delegate?.withdrawalOKButtonDidTap()
                }
            case .requestErr(_):
                print("requestERR")
            case .pathErr :
                print("pathERR")
            case .serverErr:
                print("serverERR")
            case .networkFail:
                print("networkFail")
            }
        }
    }
    
    
    
    //MARK: - Action
    
    @objc private func backButtonDidTap(_ sender: UIButton) {
        delegate?.backButtonDidTap()
    }
    @objc private func profileImageEditButtonDidTap(_ sender: UIButton) {
        toggleImageRevisingState()
    }
    @objc private func cameraButtonDidTap(_ sender: UIButton){
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: false, completion: nil)
        
    }
    @objc private func reviseButtonDidTap(_ sender: UIButton) {//이름,아이디 수정 버튼
        let pattern = "^[a-zA-Z0-9_\\.]*$"
        
        if (isInfoEditing){//수정중인 상태일 때 수정(저장)버튼을 눌렀을 경우
            
            if let text = nameTextField.text,text.isEmpty {
                self.view.makeToastAnimation(message: "이름을 입력해주세요")
                return}
          
            if let text = idTextField.text,text.isEmpty{
                self.view.makeToastAnimation(message: "아이디를 입력해주세요")
                return
            }
            
            if idTextField.text!.count < 7 {
                self.view.makeToastAnimation(message: "아이디는 7자 이상 입력해주세요")
                return
                
            }
            guard let id = idTextField.text else {return}
            guard let _ = id.range(of: pattern, options: .regularExpression) else {
                self.view.makeToastAnimation(message: "아이디는 알파벳, 숫자, 밑줄, 마침표만 사용 가능해요")
                return
            }
            if id.allSatisfy({$0.isNumber}){
                self.view.makeToastAnimation(message: "숫자로만은 만들 수 없어요")
                return
            }
            
            
            putNameAndID()
        }else{
            toggleInfoRevisingState()
        }
        
        
    }
    
    @objc private func reviseCancelButtonDidTap(_ sender: UIButton) {
        toggleInfoRevisingState()
        nameTextField.text = userName
        idTextField.text = userId
        
    }
    
    @objc private func changePasswordViewDidTap(_ sender: UIButton) {
        delegate?.changePasswordButtonDidTap()
    }
    
    @objc private func accountWithdrawalButtonDidTap(_ sender: UIButton) {
        let alertVC = SMPopUpVC(withType: .accountWithdrawal)
        alertVC.modalPresentationStyle = .overFullScreen
        self.present(alertVC, animated: false, completion: nil)
        
        alertVC.greyButtonCompletion = {
            if UserDefaults.standard.bool(forKey: Constants.UserDefaultsKey.isAppleLogin) {
                self.appleAccountWithdrawal()
            } else {
                self.putWithdrawal()
            }
        }
        
        alertVC.pinkButtonCompletion = {
            self.dismiss(animated: false)
        }
    }
    
    @objc private func logoutButtonDidTap(_ sender: UIButton) {
        let alertVC = SMPopUpVC(withType: .logout)
        alertVC.modalPresentationStyle = .overFullScreen
        self.present(alertVC, animated: false, completion: nil)
        
        alertVC.greyButtonCompletion = {
            self.removeUserDefaults()
            self.dismiss(animated: false)
            self.delegate?.logoutOKButtonDidTap()
        }
        
        alertVC.pinkButtonCompletion = {
            self.dismiss(animated: false)
        }
    }
    
    @objc func nameTextFieldDidChange(_ sender: Any?) {
        guard let nameText = nameTextField.text else {return}
        if nameText.count > 5 {
            nameTextField.deleteBackward()
        }
    }
    
    @objc func idTextFieldDidChange(_ sender: Any?) {
        let currentText = idTextField.text ?? ""
        idTextField.text = currentText.lowercased()

    }
    
}


extension UserInfoVC: UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            profileImageView.image = image
        }
        dismiss(animated: true, completion: nil)
    }
    
}
extension UserInfoVC: UITextFieldDelegate {
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

extension UserInfoVC: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential { // 일단 재로그인 시켜서 authorization code를 받아온 후 넘겨준다.
            let userIdentifier = appleIDCredential.user
            
            dump(authorization)
            
            if let authorizationToken = appleIDCredential.authorizationCode,
               let encodedAuthorizationToken = String(data: authorizationToken, encoding: .utf8) {
                print("authorizationToken: \(encodedAuthorizationToken)")
                self.putWithdrawal(authorizationCode: encodedAuthorizationToken)
            } else {
                self.view.makeToastAnimation(message: "탈퇴 오류! 잠시 후에 다시 시도해주세요.")
            }
            
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("error: \(error)")
    }
}

extension UserInfoVC: ASAuthorizationControllerPresentationContextProviding { // 애플계정 인증 창을 띄울 화면 설정
    @available(iOS 13.0, *)
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}
