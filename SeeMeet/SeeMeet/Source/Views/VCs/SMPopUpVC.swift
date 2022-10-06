import UIKit
import SnapKit

enum SMPopUpType {
    case needLogin // 메인뷰
    case deletePlans // 캘린더 상세 뷰
    case dismissRequest // 약속 신청 뷰
    case cancelPlans // 약속 내역 보낸 요청
    case refusePlans // 약속 내역 받은 요청
    case accountWithdrawal// 계정 탈퇴
    case logout// 로그아웃
    case profile
}

class SMPopUpVC: UIViewController {
    
    // MARK: - properties
    static let identifier: String = "SMPopUpVC"
    
    private var messageLabels: [UILabel] = []
    
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
    
    var type: SMPopUpType = .needLogin {
        didSet {
            setContents()
        }
    }
    
    private let popUpView: UIView = UIView().then {
        $0.backgroundColor = UIColor.white
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 10
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
    
    var greyButtonCompletion: (() -> Void)?
    
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
    
    init(withType: SMPopUpType) {
        super.init(nibName: nil, bundle: nil)
        type = withType
        setContents()
    }
    
    private func setContents() {
        var messageText: [String] = []
        
        switch type {
        case .needLogin:
            messageText = ["로그인이 필요한 서비스에요", "로그인 하러 갈까요?"]
            greyButton.setTitle("취소", for: .normal)
            pinkButton.setTitle("로그인", for: .normal)
        case .deletePlans:
            messageText = ["정말 이 약속을 삭제할까요?"]
            greyButton.setTitle("취소", for: .normal)
            pinkButton.setTitle("삭제", for: .normal)
        case .dismissRequest:
            messageText = ["작성중인 내용이 있어요", "여기서 나갈까요?"]
            greyButton.setTitle("취소", for: .normal)
            pinkButton.setTitle("나가기", for: .normal)
        case .cancelPlans:
            messageText = ["약속을 취소하시겠어요?"]
            greyButton.setTitle("아니오", for: .normal)
            pinkButton.setTitle("예", for: .normal)
        case .refusePlans:
            messageText = ["약속을 거절하시겠어요?"]
            greyButton.setTitle("취소", for: .normal)
            pinkButton.setTitle("거절", for: .normal)
        case .accountWithdrawal:
            messageText = ["회원탈퇴 시 \n 저장된 모든 정보가 삭제되며 \n 복구가 불가능합니다.\n(애플 로그인의 경우\n탈퇴 진행을 위해 재로그인이\n 필요합니다.)"]
            greyButton.setTitle("네", for: .normal)
            pinkButton.setTitle("다음에 할게요", for: .normal)
        case .logout:
            messageText = ["정말 로그아웃 하시겠어요?"]
            greyButton.setTitle("네", for: .normal)
            pinkButton.setTitle("다음에 할게요", for: .normal)
        case .profile:
            messageText = ["아직 회원가입을 완료하지 않았어요 \n 씨밋에서 사용할 이름과 아아디를 \n 입력해주세요"]
            greyButton.setTitle("네", for: .normal)
            pinkButton.setTitle("확인", for: .normal)
        }
        
        messageText.forEach {
            let label: UILabel = UILabel()
            label.font = UIFont.hanSansMediumFont(ofSize: 16)
            label.text = $0
            label.textColor = UIColor.black
            label.textAlignment = .center
            label.numberOfLines = 0
            messageLabels.append(label)
            
        }
    }
    
    private func setLayouts() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        
        view.addSubview(popUpView)
        popUpView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(53 * widthRatio)
            $0.top.equalToSuperview().offset(317 * heightRatio)
            $0.width.equalTo(270 * widthRatio)
            $0.height.equalTo(167 * heightRatio)
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
    
    private func setMessageLayout() {
        popUpView.addSubviews(messageLabels)
        
        switch type {
        case .deletePlans, .cancelPlans, .refusePlans, .accountWithdrawal, .logout:
            if let messageLabel = messageLabels.first {
                messageLabel.snp.makeConstraints {
                    $0.centerY.equalToSuperview().offset(-25*heightRatio)
                    $0.centerX.equalToSuperview()
                }
            }
        case .needLogin, .dismissRequest:
            if let messageLabelFirst = messageLabels.first,
               let messageLabelLast = messageLabels.last {
                messageLabelFirst.snp.makeConstraints {
                    $0.top.equalToSuperview().offset(33 * heightRatio)
                    $0.leading.equalToSuperview().offset(12 * widthRatio)
                    $0.trailing.equalToSuperview().offset(-12 * widthRatio)
                }
                
                messageLabelLast.snp.makeConstraints {
                    $0.top.equalTo(messageLabelFirst.snp.bottom).offset(10 * heightRatio)
                    $0.leading.equalToSuperview().offset(12 * widthRatio)
                    $0.trailing.equalToSuperview().offset(-12 * widthRatio)
                }
            }
        case .profile:
            greyButton.isHidden = true
            pinkButton.snp.remakeConstraints{
                
                $0.leading.bottom.trailing.equalToSuperview()
                $0.height.equalTo(greyButton.snp.height)
                
            }
            if let messageLabel = messageLabels.first {
                messageLabel.snp.makeConstraints {
                    $0.centerY.equalToSuperview().offset(-25*heightRatio)
                    $0.centerX.equalToSuperview()
                }
            }
        }
        
    }
    
    private func configUI() {
        greyButton.addTarget(self, action: #selector(touchUpGreyButton(_:)), for: .touchUpInside)
        pinkButton.addTarget(self, action: #selector(touchUpPinkButton(_:)), for: .touchUpInside)
    }
    
    // MARK: - objc
    
    @objc func touchUpGreyButton(_ sender: UIButton) {
        switch type {
        case .accountWithdrawal, .logout :
            guard let completion = greyButtonCompletion else {return}
            completion()
        default:
            dismiss(animated: false, completion: nil)
        }
    }
    
    @objc func touchUpPinkButton(_ sender: UIButton) {
        guard let completion = pinkButtonCompletion else { return }
        completion()
    }
}
