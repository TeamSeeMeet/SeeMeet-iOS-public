//
//  MainLoginVC.swift
//  SeeMeet
//
//  Created by 이유진 on 2022/03/06.
//

import UIKit
import SnapKit
import AuthenticationServices
import Kingfisher

protocol MainLoginVCDelegate {
    func loginCompleted()
    func needRegister(accessToken: String, refreshToken: String, name: String?, isAppleLogin: Bool)
    func backButtonDidTap()
    func emailRegisterDidTap()
    func emailLoginDidTap()
}

class MainLoginVC: UIViewController {
    
    // MARK: - UI Components
    
    private let navigationBarView = UIView()
    
    private let backButton = UIButton().then{
        $0.setImage(UIImage(named: "btn_back"), for: .normal)
    }
    
    private let logoImageView = UIImageView().then {
        $0.image = UIImage(named: "img_seemeet_logo")
    }
    
    private let kakaoLoginButton = UIButton().then{
        $0.setImage(UIImage(named: "img_logo_kakao"), for: .normal)
        $0.backgroundColor = UIColor.kakaoyellow
        $0.setTitle("카카오로 계속하기", for: .normal)
        $0.setTitleColor(UIColor.snslogoblack, for: .normal)
        $0.titleLabel?.font = UIFont.hanSansBoldFont(ofSize: 16)
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 10
        $0.imageEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: 10 * widthRatio)
        $0.titleEdgeInsets = .init(top: 0, left: 30 * widthRatio, bottom: 0, right: 20 * widthRatio)
    }
    
    private let appleLoginButton = UIButton().then{
        $0.setImage(UIImage(named: "img_logo_apple"), for: .normal)
        $0.backgroundColor = UIColor.white
        $0.setTitle("Apple로 계속하기", for: .normal)
        $0.setTitleColor(UIColor.snslogoblack, for: .normal)
        $0.titleLabel?.font = UIFont.hanSansBoldFont(ofSize: 16)
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 10
        $0.layer.borderWidth = 1.0
        $0.layer.borderColor = UIColor.black.cgColor
        $0.imageEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: 5)
        $0.adjustsImageWhenHighlighted = false // 버튼 클릭하면 이미지의 하얀부분 회색되는거 없애기
    }
    
    private let emailLoginButton = UIButton().then{
        $0.setTitleColor(UIColor.grey05, for: .normal)
        $0.titleLabel?.font = UIFont.hanSansRegularFont(ofSize: 14)
        let underlineAttribute = [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue]
        let underlineAttributedString = NSAttributedString(string: "이메일로 로그인", attributes: underlineAttribute)
        $0.setAttributedTitle(underlineAttributedString, for: .normal)
    }
    
    private let emailJoinButton = UIButton().then{
        $0.setTitleColor(UIColor.grey05, for: .normal)
        $0.titleLabel?.font = UIFont.hanSansRegularFont(ofSize: 14)
        let underlineAttribute = [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue]
        let underlineAttributedString = NSAttributedString(string: "이메일로 가입", attributes: underlineAttribute)
        $0.setAttributedTitle(underlineAttributedString, for: .normal)
    }
    
    // MARK: Properties
    
    weak var coordinator: Coordinator?
    var delegate: MainLoginVCDelegate?
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setAutoLayouts()
        configUI()
    }
    
    // MARK: - Layout
    
    private func setAutoLayouts() {
        self.navigationController?.isNavigationBarHidden = true
        view.backgroundColor = UIColor.white
        view.addSubviews([navigationBarView,
                          logoImageView,
                          kakaoLoginButton,
                          appleLoginButton,
                          emailLoginButton,
                          emailJoinButton])
        navigationBarView.addSubview(backButton)
        
        navigationBarView.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(58)
        }
        
        backButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(5 * heightRatio)
            $0.leading.equalToSuperview().offset(2 * widthRatio)
            $0.width.height.equalTo(48 * widthRatio)
        }
        
        logoImageView.snp.makeConstraints {
            $0.top.equalTo(navigationBarView.snp.bottom).offset(48 * heightRatio)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(158 * widthRatio)
        }
        
        kakaoLoginButton.snp.makeConstraints {
            $0.top.equalTo(logoImageView.snp.bottom).offset(48 * heightRatio)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(335 * widthRatio)
            $0.height.equalTo(54 * heightRatio)
        }
        
        appleLoginButton.snp.makeConstraints {
            $0.top.equalTo(kakaoLoginButton.snp.bottom).offset(12 * heightRatio)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(335 * widthRatio)
            $0.height.equalTo(54 * heightRatio)
        }
        
        emailJoinButton.snp.makeConstraints{
            $0.top.equalTo(appleLoginButton.snp.bottom).offset(24 * heightRatio)
            $0.centerX.equalToSuperview().offset(-60 * widthRatio)
        }
        
        emailLoginButton.snp.makeConstraints{
            $0.leading.equalTo(emailJoinButton.snp.trailing).offset(32 * widthRatio)
            $0.centerY.equalTo(emailJoinButton)
        }
    }
    
    private func configUI() {
        backButton.addTarget(self, action: #selector(backButtonClicked(_:)), for: .touchUpInside)
        appleLoginButton.addTarget(self, action: #selector(appleLoginButtonClicked(_:)), for: .touchUpInside)
        emailLoginButton.addTarget(self, action: #selector(emailLoginButtonClicked(_:)), for: .touchUpInside)
        emailJoinButton.addTarget(self, action: #selector(emailJoinButtonClicked(_:)), for: .touchUpInside)
        kakaoLoginButton.addTarget(self, action: #selector(kakaoButtonDidTap(_:)), for: .touchUpInside)
    }
    
    // MARK: - Custom Method
    
    private func getAuthFromApple(){
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let requestToApple = appleIDProvider.createRequest()
        requestToApple.requestedScopes = [.fullName, .email]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [requestToApple])
        
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    // MARK: - Actions
    
    @objc private func backButtonClicked(_ sender: UIButton) {
        delegate?.backButtonDidTap()
    }
    
    @available(iOS 13.0, *)
    @objc private func appleLoginButtonClicked(_ sender: UIButton){
        getAuthFromApple()
    }
    
    @objc private func emailLoginButtonClicked(_ sender: UIButton){
        delegate?.emailLoginDidTap()
    }
    
    @objc private func emailJoinButtonClicked(_ sender: UIButton) {
        delegate?.emailRegisterDidTap()
    }
    
    // MARK: - Network
    
    @objc private func kakaoButtonDidTap(_ sender: UIButton) {
        KakaoAuthService.shared.login { responseData in
            switch responseData {
            case .success(let success):
                if let success = success as? SocialLoginDataModel {
                    if 400...499 ~= success.status {
                        self.view.makeToastAnimation(message: success.message)
                    } else {
                        guard let userData = success.data?.user,
                              let accessToken = success.data?.accesstoken,
                              let refreshToken = success.data?.refreshtoken else { return }
                        
                        if let nickName = userData.nickname { // nickname값이 있으면 기존에 가입된 아이디 -> 바로 로그인 처리
                            UserDefaults.standard.do {
                                $0.set(userData.email, forKey: Constants.UserDefaultsKey.userEmail)
                                $0.set(userData.username, forKey: Constants.UserDefaultsKey.userName)
                                $0.set(userData.nickname, forKey: Constants.UserDefaultsKey.userNickname)
                                $0.set(true, forKey: Constants.UserDefaultsKey.isLogin)
                            }
                            
                            NotificationCenter.default.post(name: NSNotification.Name.PushNotificationDidSet, object: userData.push)
                            
                            TokenUtils.shared.create(account: "accessToken", value: accessToken)
                            TokenUtils.shared.create(account: "refreshToken", value: refreshToken)
                            
                            
                            if let url = userData.imgLink{
                                if let url = URL(string: url){
                                    let resource = ImageResource(downloadURL: url)
                                    KingfisherManager.shared.retrieveImage(with: resource){ result in
                                        switch result{
                                        case .success(let value):
                                            ImageManager.shared.saveImage(image: value.image, named: "profile.png")
                                        case .failure(let error):
                                            print(error)
                                        }
                                    }
                                }
                            }
                            print("accessToken: ", accessToken)
                            self.delegate?.loginCompleted()
                        } else { // nickname값이 없으면 최초 가입시켜야 한다
                            self.delegate?.needRegister(accessToken: accessToken, refreshToken: refreshToken, name: userData.username, isAppleLogin: false)
//                            self.putNameAndId(userData: userData, accessToken: accessToken, refreshToken: refreshToken)
                        }
                    }
                }
            case .pathErr:
                print("pathErr")
            case .requestErr(let message):
                print("requestERR", message)
            case .serverErr:
                print("serverErr")
            case .networkFail:
                print("networkFail")
            }
        }
    }
}

// MARK: - Extension

extension MainLoginVC: ASAuthorizationControllerDelegate {
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            let userIdentifier = appleIDCredential.user
            dump(appleIDCredential)
            let fullName = appleIDCredential.fullName
            var token = String()
            var name = String()
            if let identityToken = appleIDCredential.identityToken,
               let authorizationToken = appleIDCredential.authorizationCode,
               let tokenString = String(data: identityToken, encoding: .utf8) {
                token = tokenString
                print("authorizationToken: \(String(data: authorizationToken, encoding: .utf8))")
                print("tokenString: \(tokenString)") }
            
            if let lastName = fullName?.familyName,
               let firstName = fullName?.givenName {
                name = "\(lastName)\(firstName)"
            }
            AppleAuthService.shared.login(name: name, token: token) { responseData in
                switch responseData {
                case .success(let success):
                    if let success = success as? SocialLoginDataModel {
                        if success.status == 404 {
                            self.view.makeToastAnimation(message: success.message)
                        } else {
                            guard let userData = success.data?.user,
                                  let accessToken = success.data?.accesstoken,
                                  let refreshToken = success.data?.refreshtoken else { return }
                            
                            if let nickName = userData.nickname { // nickname값이 있으면 기존에 가입된 아이디 -> 바로 로그인 처리
                                UserDefaults.standard.do {
                                    $0.set(userData.email, forKey: Constants.UserDefaultsKey.userEmail)
                                    $0.set(userData.username, forKey: Constants.UserDefaultsKey.userName)
                                    $0.set(userData.nickname, forKey: Constants.UserDefaultsKey.userNickname)
                                    $0.set(true, forKey: Constants.UserDefaultsKey.isLogin)
                                    $0.set(true,forKey: Constants.UserDefaultsKey.isAppleLogin)
                                    $0.set(userIdentifier,forKey: Constants.UserDefaultsKey.userAppleID)
                                }
                                NotificationCenter.default.post(name: NSNotification.Name.PushNotificationDidSet, object: userData.push)
                                
                                TokenUtils.shared.create(account: "accessToken", value: accessToken)
                                TokenUtils.shared.create(account: "refreshToken", value: refreshToken)
                                if let url = userData.imgLink{
                                    if let url = URL(string: url){
                                        let resource = ImageResource(downloadURL: url)
                                        KingfisherManager.shared.retrieveImage(with: resource){ result in
                                            switch result{
                                            case .success(let value):
                                                ImageManager.shared.saveImage(image: value.image, named: "profile.png")
                                            case .failure(let error):
                                                print(error)
                                            }
                                        }
                                    }
                                }
                                self.delegate?.loginCompleted()
                                
                            } else { // nickname값이 없으면 최초 가입시켜야 한다
                                self.delegate?.needRegister(accessToken: accessToken, refreshToken: refreshToken, name: userData.username, isAppleLogin: true)
                            }
                        }
                    }
                case .pathErr:
                    print("pathErr")
                case .requestErr(let message):
                    print("requestERR", message)
                case .serverErr:
                    print("serverErr")
                case .networkFail:
                    print("networkFail")
                }
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("error \(error)")
    }
}

extension MainLoginVC: ASAuthorizationControllerPresentationContextProviding { // 애플계정 인증 창을 띄울 화면 설정
    @available(iOS 13.0, *)
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}
