import UIKit
import RxSwift
import RxCocoa

protocol NameButtonTappedDelegate{
    func nameButtonTapped()
}

class MyPageView: UIView {
    
    // MARK: - UI Components
    
    let profileImageView = UIImageView().then{
        guard let image = ImageManager.shared.getSavedImage(named: "profile.png") ?? UIImage(named: "img_profile")  else {return}
        $0.image = image
        $0.layer.cornerRadius = 46/2
        $0.clipsToBounds = true
        $0.contentMode = .scaleAspectFill
    }
    private let closeButton = UIButton().then{
        $0.setBackgroundImage(UIImage(named: "btn_close_white"), for: .normal)
    }
    let nameButton = UIButton().then{
        $0.setTitle("로그인", for: .normal)
        $0.titleLabel?.font = UIFont.hanSansBoldFont(ofSize: 20)
        $0.setImage(UIImage(named: "ic_mypage_login"), for: .normal)
        $0.setTitleColor(UIColor.white, for: .normal)
        $0.semanticContentAttribute = .forceRightToLeft

    }
    let nicknameLabel = UILabel().then{
        $0.text = "SeeMeet에서 친구와 약속을 잡아보세요!"
        $0.font = UIFont.hanSansMediumFont(ofSize: 14)
        $0.textColor = UIColor.white
    }
    private let menuView = UIView().then{
        $0.backgroundColor = .white
    }
    let noticeButton = UIButton().then{
        $0.setTitle("공지사항", for: .normal)
        $0.titleLabel?.font = UIFont.hanSansMediumFont(ofSize: 16)
        $0.setTitleColor(UIColor.black, for: .normal)
    }
    private let separateLineView = UIView().then{
        $0.backgroundColor = .grey02
    }
    private let pushNotificationLabel = UILabel().then{
        $0.text = "푸시알림"
        $0.font = UIFont.hanSansMediumFont(ofSize: 16)
    }
    
    let pushAlarmSwitch = UISwitch().then {
        $0.isOn = UserDefaults.standard.bool(forKey: Constants.UserDefaultsKey.isPushNotificationOn)
    }
    
    private let separateLineView2 = UIView().then{
        $0.backgroundColor = .grey02
    }
    let termOfServiceButton = UIButton().then{
        $0.setTitle("이용약관", for: .normal)
        $0.titleLabel?.font = UIFont.hanSansMediumFont(ofSize: 14)
        $0.setTitleColor(UIColor.black, for: .normal)
    }
    let privacyPolicyButton = UIButton().then{
        $0.setTitle("개인정보 정책", for: .normal)
        $0.titleLabel?.font = UIFont.hanSansMediumFont(ofSize: 14)
        $0.setTitleColor(UIColor.black, for: .normal)
    }
    let openSourceButton = UIButton().then{
        $0.setTitle("오픈소스", for: .normal)
        $0.titleLabel?.font = UIFont.hanSansMediumFont(ofSize: 14)
        $0.setTitleColor(UIColor.black, for: .normal)
    }
    
    // MARK: - Properties
    
    var nameButtonTappedDelegate: NameButtonTappedDelegate?
    
    let disposeBag = DisposeBag()
    
    
    // MARK: - Life Cycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupAutoLayouts()
        
        NotificationCenter.default.rx.notification(Notification.Name.RefreshTokenExpired)
            .asDriver(onErrorJustReturn: Notification(name: Notification.Name("Error"), object: nil, userInfo: nil))
            .drive(onNext: { [weak self] noti in
                guard let isPushOn = noti.object as? Bool else { return }
                self?.pushAlarmSwitch.isOn = isPushOn
            })
            .disposed(by: disposeBag)
        
        NotificationCenter.default.rx.notification(Notification.Name.DidLogout)
            .asDriver(onErrorJustReturn: Notification(name: Notification.Name("Error"), object: nil, userInfo: nil))
            .drive(onNext: { [weak self] noti in
                guard let image = UIImage(named: "img_profile") else { return }
                ImageManager.shared.saveImage(image: image, named: "profile_png")
                self?.profileImageView.image = image
                self?.nameButton.setTitle("로그인", for: .normal)
                self?.nicknameLabel.text = "SeeMeet에서 친구와 약속을 잡아보세요!"
            })
            .disposed(by: disposeBag)
        
        NotificationCenter.default.rx.notification(Notification.Name.PushNotificationDidSet)
            .asDriver(onErrorJustReturn: Notification(name: Notification.Name("Error"), object: nil, userInfo: nil))
            .drive(onNext: { [weak self] noti in
                guard let isPushOn = noti.object as? Bool else { return }
                self?.pushAlarmSwitch.isOn = isPushOn
            })
            .disposed(by: disposeBag)
    }
   
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - setLayouts
    
    private func setupAutoLayouts(){
        addSubviews([profileImageView, closeButton, nameButton, nicknameLabel,menuView])
        menuView.addSubviews([noticeButton,separateLineView,pushNotificationLabel,pushAlarmSwitch,separateLineView2,termOfServiceButton,privacyPolicyButton,openSourceButton])
        self.backgroundColor = UIColor.black
        profileImageView.snp.makeConstraints{
            $0.top.equalToSuperview().offset(94 * heightRatio)
            $0.leading.equalToSuperview().offset(20 * widthRatio)
            $0.width.height.equalTo(46 * heightRatio)
        }
        closeButton.snp.makeConstraints{
            $0.top.equalToSuperview().offset(48 * heightRatio)
            $0.trailing.equalToSuperview().offset(-4 * widthRatio)
            $0.width.height.equalTo(48 * widthRatio)
        }
        nameButton.snp.makeConstraints{
            $0.top.equalTo(profileImageView.snp.bottom).offset(13 * heightRatio)
            $0.leading.equalToSuperview().offset(20 * widthRatio)
            $0.height.equalTo(48 * heightRatio)
            
        }
        nicknameLabel.snp.makeConstraints{
            $0.top.equalTo(nameButton.snp.bottom).offset(11 * heightRatio)
            $0.leading.equalToSuperview().offset(20 * widthRatio)
            $0.width.equalTo(300 * widthRatio)
            $0.height.equalTo(20 * heightRatio)
        }
        menuView.snp.makeConstraints{
            $0.top.equalTo(nicknameLabel.snp.bottom).offset(33 * heightRatio)
            $0.leading.bottom.trailing.equalToSuperview()
        }
        noticeButton.snp.makeConstraints{
            $0.top.equalToSuperview().offset(47 * heightRatio)
            $0.leading.equalToSuperview().offset(20 * widthRatio)

        }
        separateLineView.snp.makeConstraints{
            $0.top.equalTo(noticeButton.titleLabel!.snp.bottom).offset(12 * heightRatio)
            $0.leading.trailing.equalToSuperview().inset(20 * widthRatio)
            $0.height.equalTo(1)
        }
        pushNotificationLabel.snp.makeConstraints{
            $0.top.equalTo(separateLineView.snp.bottom).offset(24 * heightRatio)
            $0.leading.equalToSuperview().offset(20 * widthRatio)
        }
        pushAlarmSwitch.snp.makeConstraints{
            $0.trailing.equalToSuperview().offset(-20 * widthRatio)
            $0.centerY.equalTo(pushNotificationLabel)
        }
        separateLineView2.snp.makeConstraints{
            $0.top.equalTo(pushNotificationLabel.snp.bottom).offset(12 * heightRatio)
            $0.leading.trailing.equalToSuperview().inset(20 * widthRatio)
            $0.height.equalTo(1)
        }
        termOfServiceButton.snp.makeConstraints{
            $0.top.equalTo(separateLineView2.snp.bottom).offset(36 * heightRatio)
            $0.leading.equalToSuperview().offset(20 * widthRatio)
        }
        privacyPolicyButton.snp.makeConstraints{
            $0.top.equalTo(termOfServiceButton.snp.bottom).offset(12 * heightRatio)
            $0.leading.equalToSuperview().offset(20 * widthRatio)
        }
        openSourceButton.snp.makeConstraints{
            $0.top.equalTo(privacyPolicyButton.snp.bottom).offset(12 * heightRatio)
            $0.leading.equalToSuperview().offset(20 * widthRatio)
        }
    }
    
    private func setupViews() {
        closeButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] in
                UIView.animate(withDuration: 0.5) {
                    let yFrame = CGAffineTransform(translationX: -UIScreen.getDeviceWidth() * 0.84, y: 0)
                    self?.transform = yFrame
                }
            })
            .disposed(by: disposeBag)
        
        nameButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] in
                self?.nameButtonTappedDelegate?.nameButtonTapped()
            })
            .disposed(by: disposeBag)
        
        pushAlarmSwitch.rx.isOn
            .asDriver()
            .drive(onNext: { [weak self] isOn in
                self?.postPushNotificationSet(isNotificationOn: isOn)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Network
    
    private func postPushNotificationSet(isNotificationOn: Bool) {
        PostPushNotificationSetService.shared.pushSet(isNotificationOn: isNotificationOn) { response in
            switch response {
            case .success(let data):
                if let response = data as? NotificationSetResponseModel {
                    print("푸시 알림 설정 완료")
                }
                UserDefaults.standard.set(isNotificationOn, forKey: Constants.UserDefaultsKey.isPushNotificationOn)
            case .pathErr:
                print("pathError")
            case .networkFail:
                print("networkFail")
            case .requestErr(let err):
                print("requestErr")
            case .serverErr:
                print("serverErr")
            }
        }
    }
}
