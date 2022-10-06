import UIKit

protocol PlansSendListVCDelegate{
    func backButtonDidTap()
}
class PlansSendListVC: UIViewController {
    
    // MARK: - UI Components
    
    private let backGroundScrollView = UIScrollView().then {
        $0.isPagingEnabled = false
        $0.bounces = true
        $0.contentSize = CGSize(width: UIScreen.getDeviceWidth(), height: 1000)
        $0.backgroundColor = UIColor.grey01
        $0.showsVerticalScrollIndicator = true
        $0.contentInsetAdjustmentBehavior = .never
    }
    
    private let headerView = UIView().then {
        $0.backgroundColor = UIColor.grey01
    }
    
    private let backButton = UIButton().then {
        $0.setBackgroundImage(UIImage(named: "btn_back"), for: .normal)
    }
    
    private let headLabel = UILabel().then {
        $0.font = UIFont.hanSansRegularFont(ofSize: 24)
        $0.textColor = UIColor.grey06
        $0.setAttributedText(defaultText: "약속을 확정해 주세요", containText: "약속을 확정", font: UIFont.hanSansBoldFont(ofSize: 24), color: UIColor.grey06)
    }
    
    private let nameTagStackView: UIStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .fill
        $0.distribution = .fillProportionally
        $0.spacing = 10
        $0.layoutMargins = UIEdgeInsets.zero
        $0.isLayoutMarginsRelativeArrangement = true
    }
    
    private let confirmCountLabel = UILabel().then {
        $0.font = UIFont.dinProRegularFont(ofSize: 30)
        $0.textColor = UIColor.grey06
        $0.text = "3/3"
    }
    
    private var dateSelectStackView = UIStackView().then {
        $0.backgroundColor = UIColor.grey01
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 10
        $0.axis = .vertical
        $0.spacing = 16 * heightRatio
        $0.distribution = .fillEqually
    }
    
    //보낸 신청 내용
    private let sendPlansDetailLabel = UILabel().then {
        $0.font = UIFont.hanSansBoldFont(ofSize: 18)
        $0.text = "보낸 신청 내용"
        $0.textColor = UIColor.grey06
    }
    
    private let textView = UIView().then {
        $0.backgroundColor = UIColor.white
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 10
    }
    
    private let titleLabel = UILabel().then {
        $0.font = UIFont.hanSansBoldFont(ofSize: 14)
        $0.textColor = UIColor.grey06
    }
    
    private let titleBottomView = UIView().then {
        $0.backgroundColor = UIColor.grey02
    }
    
    private let detailTextView = UITextView().then {
        $0.font = UIFont.hanSansRegularFont(ofSize: 14)
        $0.textColor = UIColor.grey06
        $0.isEditable = false
    }
    
    private let bottomView = UIView().then {
        $0.backgroundColor = UIColor.white
    }
    
    private let cancelButton = UIButton().then {
        $0.backgroundColor = UIColor.grey04
        $0.setTitle("취소", for: .normal)
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 10
    }
    
    private let confirmButton = UIButton().then {
        $0.backgroundColor = UIColor.grey02
        $0.setTitle("확정", for: .normal)
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 10
    }
    
    // MARK: - Properties
    
    var plansId: String?
    weak var coordinator: Coordinator?
    private var checkedOptionIndex: Int?
    private var checkedOptionDateId: Int?
    private var plansData: PlansSendDetailData? {
        didSet {
            setData()
            setHeadLayout()
            setTimeOptionViewLayout()
            setButtonStack()
        }
    }
    var delegate: PlansSendListVCDelegate?

    private var responsedGuestCount: Int {
        plansData?.invitation.guests.filter { $0.isResponse == true }.count ?? 0
    }
    private var guestCount: Int {
        plansData?.invitation.guests.count ?? 0
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        setupAutoLayout()
        getPlansData()
    }
    
    // MARK: - setLayout
    
    private func setupAutoLayout() {
        setHeadLayout()
        setTextViewLayout()
        setBottomButtonView()
    }
    
    // MARK: - Custom Methods
    
    private func configUI() {
        backButton.addTarget(self, action: #selector(backButtonDidTap(_:)), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelButtonDidTap(_:)), for: .touchUpInside)
        confirmButton.addTarget(self, action: #selector(confirmButtonDidTap(_:)), for: .touchUpInside)
    }
    
    private func setHeadLayout() {
        view.addSubviews([headerView, backGroundScrollView])
        headerView.addSubview(backButton)
        backGroundScrollView.addSubviews([headLabel, nameTagStackView, confirmCountLabel, sendPlansDetailLabel, textView, bottomView, dateSelectStackView])
        
        headerView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(102)
        }
        
        backButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(2 * widthRatio)
            $0.top.equalToSuperview().offset(49 * heightRatio)
        }
        
        backGroundScrollView.snp.makeConstraints{
            $0.top.equalTo(headerView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        headLabel.snp.makeConstraints{
            $0.top.equalToSuperview().offset(30 * heightRatio)
            $0.leading.equalToSuperview().offset(20 * widthRatio)
        }
        
        nameTagStackView.snp.makeConstraints {
            $0.top.equalTo(headLabel.snp.bottom).offset(22 * heightRatio)
            $0.leading.equalToSuperview().offset(20 * widthRatio)
            $0.height.equalTo(26 * heightRatio)
        }
        
        confirmCountLabel.snp.makeConstraints {
            $0.centerY.equalTo(nameTagStackView)
            $0.trailing.equalTo(view.snp.trailing).offset(-20 * widthRatio)
        }
        
        dateSelectStackView.snp.makeConstraints {
            $0.top.equalTo(nameTagStackView.snp.bottom).offset(32 * heightRatio)
            $0.leading.equalToSuperview().offset(20 * widthRatio)
            $0.trailing.equalTo(view.snp.trailing).offset(-20 * widthRatio)
        }
    }
    
    private func setTimeOptionViewLayout() {
        guard let datesData = plansData?.invitationDates else { return }
        
        for (index, data) in datesData.enumerated() {
            let optionView = ConfirmTimeOptionView().then {
                $0.namesToShow = data.respondent.map { $0.username ?? "탈퇴" }
                $0.yearLabel.text = data.date
                do {
                    $0.timeLabel.text = try String.getAMPMTimeString(from: data.start) + " ~ " + String.getAMPMTimeString(from: data.end)
                } catch {
                    print("Error: Cannot Convert AM/PM Date From String")
                }
                $0.tag = index
                $0.invitationDateID = data.id
                $0.delegate = self
            }
            dateSelectStackView.addArrangedSubview(optionView)
        }
        
        dateSelectStackView.snp.remakeConstraints {
            $0.top.equalTo(nameTagStackView.snp.bottom).offset(32 * heightRatio)
            $0.leading.equalToSuperview().offset(20 * widthRatio)
            $0.trailing.equalTo(view.snp.trailing).offset(-20 * widthRatio)
            $0.height.equalTo(CGFloat((99 * datesData.count + (16 * datesData.count - 1))) * heightRatio)
        }
    }
    
    private func setTextViewLayout() {
        textView.addSubviews([titleLabel, titleBottomView, detailTextView])
        
        sendPlansDetailLabel.snp.makeConstraints {
            $0.top.equalTo(dateSelectStackView.snp.bottom).offset(40 * heightRatio)
            $0.leading.equalToSuperview().offset(20 * widthRatio)
        }
        
        textView.snp.makeConstraints {
            $0.top.equalTo(sendPlansDetailLabel.snp.bottom).offset(8 * heightRatio)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(255 * heightRatio)
            $0.width.equalTo(335 * widthRatio)
        }
        
        titleLabel.snp.makeConstraints{
            $0.top.equalToSuperview().offset(15 * heightRatio)
            $0.leading.equalToSuperview().offset(25 * widthRatio)
            $0.height.equalTo(32)
            $0.width.equalTo(295)
        }
        
        titleBottomView.snp.makeConstraints{
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.leading.equalToSuperview().offset(15 * widthRatio)
            $0.trailing.equalToSuperview().offset(-15 * widthRatio)
            $0.height.equalTo(1 * heightRatio)
        }
        detailTextView.snp.makeConstraints{
            $0.top.equalTo(titleBottomView.snp.bottom).offset(3 * heightRatio)
            $0.leading.equalToSuperview().offset(20 * widthRatio)
            $0.trailing.equalToSuperview().offset(-22 * widthRatio)
            $0.bottom.equalToSuperview().offset(18 * heightRatio)
        }
    }
    
    private func setBottomButtonView() {
        bottomView.addSubviews([cancelButton, confirmButton])
        bottomView.snp.makeConstraints{
            $0.top.equalTo(textView.snp.bottom).offset(60 * heightRatio)
            $0.leading.equalToSuperview()
            $0.trailing.equalTo(view.snp.trailing)
            $0.bottom.equalToSuperview()
            $0.height.equalTo(112 * heightRatio)
        }
        cancelButton.snp.makeConstraints{
            $0.top.equalToSuperview().offset(16 * heightRatio)
            $0.leading.equalToSuperview().offset(20 * widthRatio)
            $0.width.equalTo(160 * widthRatio)
            $0.height.equalTo(54 * heightRatio)
            
        }
        confirmButton.snp.makeConstraints{
            $0.top.equalToSuperview().offset(16 * heightRatio)
            $0.width.equalTo(160 * widthRatio)
            $0.trailing.equalTo(view.snp.trailing).offset(-20 * widthRatio)
            $0.height.equalTo(54 * heightRatio)
        }
    }
    
    private func setButtonStack() {
        plansData?.invitation.guests.forEach { guest in
            let nameButton: UIButton = UIButton(type: .system).then {
                $0.titleLabel?.font = UIFont.hanSansRegularFont(ofSize: 13)
                $0.setTitle(guest.username, for: .normal)
                $0.setTitleColor(guest.isResponse ? UIColor.white : UIColor.pink01, for: .normal)
                $0.backgroundColor = guest.isResponse ? UIColor.pink01 : UIColor.white
                $0.clipsToBounds = true
                $0.layer.borderWidth = 1
                $0.layer.borderColor = UIColor.pink01.cgColor
                $0.layer.cornerRadius = 26 * heightRatio / 2
            }
            
            if #available(iOS 15.0, *) {
                var buttonConfiguration = UIButton.Configuration.plain()
                buttonConfiguration.contentInsets = NSDirectionalEdgeInsets(top: 1 * heightRatio, leading: 13 * widthRatio, bottom: 0, trailing: 11 * widthRatio)
                nameButton.configuration = buttonConfiguration
                
            } else {
                nameButton.titleEdgeInsets = UIEdgeInsets(top: 1 * heightRatio, left: 13 * widthRatio, bottom: 0, right: 11 * widthRatio)
            }
            
            nameTagStackView.addArrangedSubview(nameButton)
        }
    }
    
    private func setData() {
        titleLabel.text = plansData?.invitation.invitationTitle
        detailTextView.text = plansData?.invitation.invitationDesc
        
        guard let responsedGuestCount = plansData?.invitation.guests.filter({ $0.isResponse == true }).count,
              let guestCount = plansData?.invitation.guests.count else { return }
        
        confirmCountLabel.setAttributedText(defaultText: "\(responsedGuestCount)/\(guestCount)",
                                            containText: "\(responsedGuestCount)",
                                            font: UIFont.dinProBoldFont(ofSize: 30),
                                            color: UIColor.pink01, kernValue: -0.6)
        if responsedGuestCount == guestCount {
            headLabel.setAttributedText(defaultText: "약속을 확정해 주세요", containText: "약속을 확정",
                                        font: UIFont.hanSansBoldFont(ofSize: 24),
                                        color: UIColor.grey06, kernValue: -0.6)
        }
        else {
            headLabel.setAttributedText(defaultText: "답변을 기다리고 있어요", containText: "답변",
                                        font: UIFont.hanSansBoldFont(ofSize: 24),
                                        color: UIColor.grey06, kernValue: -0.6)
        }
    }
    
    // MARK: - Network
    
    private func getPlansData() { // 처음 데이터 불러오기
        guard let plansId = plansId else { return }
        GetPlansSendDetailDataService.shared.getSendDetail(plansId: plansId) { (response) in
            switch response {
            case .success(let data) :
                if let responseData = data as? PlansSendDetailDataModel {
                    self.plansData = responseData.data
                }
            case .requestErr(_) :
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
    
    private func postAcceptRequest() { // 약속 확정
        guard let plansId = plansId,
              let checkedOptionDateId = checkedOptionDateId else { return }
        PostPlansRequestAcceptService.shared.postPlansRequestAccept(plansId: plansId, dateId: checkedOptionDateId) { (response) in
            switch response {
            case .success(let data) :
                if let response = data as? PlansRequestAcceptDataModel {
                    print(response.status, response.message)
                }
            case .requestErr(_) :
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
    
    private func postCancelRequest() { // 약속 취소
        guard let plansId = plansId else { return }
        PutInvitationCancelService.shared.putInvitationCancel(plansId: plansId) { (response) in
            switch response {
            case .success(let data):
                if let response = data as? PlansRequestAcceptDataModel{
                    print(response.status, response.message)
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
    
    // MARK: - Actions
    
    @objc private func backButtonDidTap(_ sender: UIButton) {
//        self.navigationController?.popViewController(animated: true)
        delegate?.backButtonDidTap()
    }
    
    @objc private func cancelButtonDidTap(_ sender: UIButton) {
        let alertVC = SMPopUpVC(withType: .cancelPlans)
        alertVC.modalPresentationStyle = .overFullScreen
        self.present(alertVC, animated: false, completion: nil)
        
        alertVC.pinkButtonCompletion = {
            self.postCancelRequest()
            self.dismiss(animated: true, completion: nil)
            let viewControllers : [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
            self.navigationController?.popToViewController(viewControllers[viewControllers.count - 3 ], animated: false)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "toastMessage"), object: "약속을 취소했어요")
        }
    }
    
    @objc private func confirmButtonDidTap(_ sender: UIButton) {
        var alertVC: SMRequestPopUpVC
        var yearList: [String] = []
        var dateList: [String] = []
        
        guard let checkedOptionIndex = checkedOptionIndex,
              let plansData = plansData else { return }
        let plansDate = plansData.invitationDates[checkedOptionIndex] //선택한 옵션뷰 정보
        
        yearList.append(plansDate.date)
        do {
            dateList.append(try String.getAMPMTimeString(from: plansDate.start) + " ~ " + String.getAMPMTimeString(from: plansDate.end))
        } catch let error {
            print(error.localizedDescription)
            return
        }
        
        if plansData.invitation.guests.filter({ $0.isResponse == false }).count == 0 { // 모두 응답한 경우
            if plansDate.respondent.count == plansData.invitation.guests.count { // 모든 응답자들이 선택한 옵션에 있는 경우
                alertVC = SMRequestPopUpVC(withType: .sendConfirm)
            } else { // 모든 응답자들이 선택한 옵션에 있지는 않은 경우
                alertVC = SMRequestPopUpVC(withType: .sendNotSelectConfirm)
            }
        } else { // 미응답자가 있는 경우
            alertVC = SMRequestPopUpVC(withType: .sendNotRequestConfirm)
        }
        
        alertVC.modalPresentationStyle = .overFullScreen
        alertVC.yearText = yearList
        alertVC.dateText = dateList
        self.present(alertVC, animated: false, completion: nil)
        
        alertVC.pinkButtonCompletion = {
            self.postAcceptRequest()
            self.dismiss(animated: false, completion: nil)
            let viewControllers : [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
            self.navigationController?.popToViewController(viewControllers[viewControllers.count - 3], animated: false)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "toastMessage"), object: "약속을 확정했어요")
        }
    }
}

// MARK: - Extensions

extension PlansSendListVC: TimeOptionViewDelegate {
    func timeOptionViewDidTap(view: ConfirmTimeOptionView, tag: Int) {
        if checkedOptionIndex == tag { // 선택된 옵션을 또다시 터치할경우 취소처리
            view.isSelected = false
            checkedOptionIndex = nil
            confirmButton.isEnabled = false
            confirmButton.backgroundColor = UIColor.grey02
            
            checkedOptionDateId = nil
        } else {
            view.isSelected = true
            checkedOptionIndex = tag
            dateSelectStackView.arrangedSubviews.filter { $0.tag != tag }.forEach { // 선택한 옵션 이외는 취소처리
                guard let optionView: ConfirmTimeOptionView = $0 as? ConfirmTimeOptionView else { return }
                optionView.isSelected = false
            }
            confirmButton.isEnabled = true
            confirmButton.backgroundColor = UIColor.pink01
            
            checkedOptionDateId = view.invitationDateID
        }
    }
}
