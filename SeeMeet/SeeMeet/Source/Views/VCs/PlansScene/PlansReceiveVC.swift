import UIKit
import SnapKit
import Then

protocol PlansReceiveVCDelegate{
    func backButtonDidTap()
}

final class PlansReceiveVC: UIViewController {
    
    //MARK: UI Components
    
    private let backgroundView = UIView().then {
        $0.backgroundColor = UIColor.white
    }
    
    private let backGroundScrollView = UIScrollView().then {
        $0.backgroundColor = UIColor.white
        $0.isPagingEnabled = false
        $0.bounces = true
        $0.showsVerticalScrollIndicator = true
//        $0.contentInsetAdjustmentBehavior = .never
        $0.isScrollEnabled = true
    }
    
    private let headerBackgroundView = UIView().then {
        $0.backgroundColor = .none
    }
    
    private let backButton = UIButton().then {
        $0.setBackgroundImage(UIImage(named: "btn_back"), for: .normal)
    }
    
    private let titleLabel = UILabel().then {
        $0.setAttributedText(defaultText: "새로운 초대장", font: UIFont.hanSansBoldFont(ofSize: 14), color: UIColor.orange, kernValue: -0.6)
    }
    
    private let nameTitleLabel = UILabel().then {
        $0.textColor = UIColor.grey06
        $0.font = UIFont.hanSansRegularFont(ofSize: 24)
        $0.lineBreakMode = .byWordWrapping
        $0.numberOfLines = 2
    }
    
    private let titleImageView = UIImageView().then {
        $0.image = UIImage(named: "img_illust_11")
    }
    
    private let textBackGroundView = UIView().then {
        $0.backgroundColor = UIColor.grey01
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 10
    }
    
    private let plansTitleLabel = UILabel().then {
        $0.font = UIFont.hanSansBoldFont(ofSize: 14)
        $0.textColor = UIColor.grey06
        $0.textAlignment = .left
    }
    
    private let textBottomView = UIView().then {
        $0.backgroundColor = UIColor.grey02
    }
    
    private let plansDetailTextView = UITextView().then {
        $0.font = UIFont.hanSansRegularFont(ofSize: 14)
        $0.textColor = UIColor.grey06
        $0.backgroundColor = .none
        $0.textAlignment = .left
        $0.isEditable = false
        $0.isScrollEnabled = true
    }
    
    private let withReceiveLabel = UILabel().then {
        $0.setAttributedText(defaultText: "나와 함께 받은 사람", font: UIFont.hanSansMediumFont(ofSize: 16), color: UIColor.grey06, kernValue: -0.6)
    }
    
    private let nameButtonStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .fill
        $0.distribution = .fillProportionally
        $0.spacing = 6 * widthRatio
        $0.layoutMargins = UIEdgeInsets.zero
        $0.isLayoutMarginsRelativeArrangement = true
    }
    
    private let separatorLineView = UIView().then {
        $0.backgroundColor = UIColor.grey02
    }
    
    private let timeOptionStackView = UIStackView().then {
        $0.backgroundColor = UIColor.white
        $0.axis = .vertical
    }
    
    private let selectDateHeadLabel = UILabel().then {
        $0.numberOfLines = 2
        $0.setAttributedText(defaultText: "내 일정과 비교하며\n날짜를 선택해보세요!", containText: "날짜를 선택", font: UIFont.hanSansBoldFont(ofSize: 20), color: UIColor.pink01, kernValue: -0.6)
    }
    
    private let sideIndicator = UIView().then {
        $0.backgroundColor = UIColor.grey06
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 2
    }
    
    private var checkButton = UIButton()

    private let scheduleBackgroundView = UIView().then {
        $0.backgroundColor = UIColor.grey01
    }
    
    private let collectionViewHeadLabel = UILabel().then {
        $0.font = UIFont.dinProBoldFont(ofSize: 20)
    }
    
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout()).then {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        $0.setCollectionViewLayout(layout, animated: false)
        $0.contentInset = UIEdgeInsets.zero
        $0.backgroundColor = .none
        $0.isPagingEnabled = false
        $0.bounces = true
        $0.showsHorizontalScrollIndicator = false
        
        $0.delegate = self
        $0.dataSource = self
        $0.registerCustomXib(xibName: "PlansReceiveCVC")
    }
    //bottomButtonView
    private let bottomButtonBackgroundView = UIView().then{
        $0.backgroundColor = UIColor.white
    }
    
    private let rejectButton = UIButton().then{
        $0.backgroundColor = UIColor.grey04
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 10
        $0.setTitle("거절", for: .normal)
    }
    
    private let confirmButton = UIButton().then{
        $0.backgroundColor = UIColor.grey04
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 10
        $0.setTitle("답변", for: .normal)
    }
    
    //emptyView
    private let emptyLabel = UILabel().then{
        $0.attributedText = String.getAttributedText(text: "일정이 없어요!", letterSpacing: -0.6, lineSpacing: nil)
        $0.textColor = UIColor.grey04
    }
    
    //MARK: - Properties
    
    static let identifier: String = "PlansReceiveVC"

    var plansId: String? // 외부로부터 입력받는다.
    weak var coordinator: Coordinator?
    
    private var plansData: PlansDetailData?
    private var collectionViewData: [ResponseDateData]?
    private var isSelectedOptionViewDictionary: [Int: Bool] = [:]
    var delegate: PlansReceiveVCDelegate?
    
    private var selectedTimeOptionIDs: [Int] { // 체크박스 체크된 옵션의 invitationID들을 모은 리스트
        guard let plansData = plansData else { return [] }
        return isSelectedOptionViewDictionary
            .filter { $0.value }
            .reduce([Int]()) { list, element in
                var list = list
                list.append(plansData.invitationDates[element.key].id)
                return list
            }
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAutoLayout()
        configUI()
        getPlansData()
    }
    
    // MARK: - Layout
    
    private func setupAutoLayout() {
        setViewsHierarchy()
        setHeadLayout()
        setTextViewLayout()
    }
    
    private func setViewsHierarchy() {
        view.addSubviews([backGroundScrollView, headerBackgroundView])
        headerBackgroundView.addSubview(backButton)
        backGroundScrollView.addSubviews([titleLabel, nameTitleLabel, titleImageView, textBackGroundView, withReceiveLabel, nameButtonStackView, separatorLineView,timeOptionStackView, scheduleBackgroundView, selectDateHeadLabel, bottomButtonBackgroundView])
        textBackGroundView.addSubviews([plansTitleLabel, textBottomView, plansDetailTextView])
        scheduleBackgroundView.addSubviews([collectionViewHeadLabel, collectionView])
        bottomButtonBackgroundView.addSubviews([rejectButton, confirmButton])
    }
    
    private func setHeadLayout() {
        headerBackgroundView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(102 * heightRatio)
        }
        
        backButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(49 * heightRatio)
            $0.leading.equalToSuperview().offset(2 * widthRatio)
            $0.width.height.equalTo(48 * widthRatio)
        }
        
        backGroundScrollView.snp.makeConstraints {
            $0.top.equalTo(headerBackgroundView.snp.bottom)
            $0.leading.bottom.trailing.equalToSuperview()
        }
    }
    
    private func setTextViewLayout() {
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(29 * heightRatio)
            $0.leading.equalToSuperview().offset(20 * widthRatio)
        }
        
        nameTitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8 * heightRatio)
            $0.leading.equalToSuperview().offset(20 * widthRatio)
            $0.trailing.lessThanOrEqualTo(titleImageView.snp.leading)
        }
        
        titleImageView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.trailing.equalTo(view.snp.trailing).offset(-31 * widthRatio)
            $0.width.equalTo(107 * widthRatio)
            $0.height.equalTo(81 * heightRatio)
        }
        
        textBackGroundView.snp.makeConstraints {
            $0.top.equalTo(nameTitleLabel.snp.bottom).offset(18 * heightRatio)
            $0.leading.equalToSuperview().offset(20 * widthRatio)
            $0.trailing.equalTo(view.snp.trailing).offset(-20 * widthRatio)
            $0.height.equalTo(255 * heightRatio)
        }
        
        plansTitleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(15 * heightRatio)
            $0.leading.equalToSuperview().offset(25 * widthRatio)
        }
        
        textBottomView.snp.makeConstraints {
            $0.top.equalTo(plansTitleLabel.snp.bottom).offset(8 * heightRatio)
            $0.leading.equalToSuperview().offset(15 * widthRatio)
            $0.trailing.equalTo(view.snp.trailing).offset(-15 * widthRatio)
            $0.height.equalTo(1 * heightRatio)
        }
        
        plansDetailTextView.snp.makeConstraints {
            $0.top.equalTo(textBottomView.snp.bottom).offset(10 * heightRatio)
            $0.leading.equalToSuperview().offset(20 * widthRatio)
            $0.trailing.equalTo(view.snp.trailing).offset(-20 * widthRatio)
            $0.bottom.equalToSuperview().offset(-18 * heightRatio)
        }
        
        withReceiveLabel.snp.makeConstraints {
            $0.top.equalTo(textBackGroundView.snp.bottom).offset(22 * heightRatio)
            $0.leading.equalToSuperview().offset(20 * widthRatio)
        }
        
        nameButtonStackView.snp.makeConstraints {
            $0.top.equalTo(withReceiveLabel.snp.bottom).offset(11 * heightRatio)
            $0.leading.equalToSuperview().offset(20 * widthRatio)
            $0.height.equalTo(32 * heightRatio)
        }
        
        separatorLineView.snp.makeConstraints {
            $0.top.equalTo(nameButtonStackView.snp.bottom).offset(42 * heightRatio)
            $0.leading.equalToSuperview().offset(20 * widthRatio)
            $0.trailing.equalTo(view.snp.trailing).offset(-20 * widthRatio)
            $0.height.equalTo(1 * heightRatio)
        }
    }
    
    private func setSelectData() {
        guard let plansData = plansData else { return }
        timeOptionStackView.snp.makeConstraints {
            $0.top.equalTo(selectDateHeadLabel.snp.bottom).offset(32 * heightRatio)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.height.equalTo(82 * heightRatio * CGFloat(plansData.invitationDates.count))
        }
        
        selectDateHeadLabel.snp.makeConstraints {
            $0.top.equalTo(separatorLineView.snp.bottom).offset(37 * heightRatio)
            $0.leading.equalToSuperview().offset(20 * widthRatio)
        }
        
        if !(plansData.isResponse ?? false) {
            setCollectionViewData()
        } else {
            timeOptionStackView.snp.makeConstraints {
                $0.bottom.equalToSuperview()
            }
        }
        
        func setCollectionViewData() {
            scheduleBackgroundView.snp.makeConstraints {
                $0.top.equalTo(timeOptionStackView.snp.bottom)
                $0.leading.width.equalToSuperview()
                $0.height.equalTo(261 * heightRatio)
            }
            
            scheduleBackgroundView.addSubview(emptyLabel)
            
            emptyLabel.snp.makeConstraints {
                $0.centerX.equalToSuperview()
                $0.centerY.equalToSuperview()
            }
            
            emptyLabel.isHidden = true
            collectionViewHeadLabel.snp.makeConstraints {
                $0.top.equalToSuperview().offset(24 * heightRatio)
                $0.leading.equalToSuperview().offset(20 * widthRatio)
            }
            
            collectionView.snp.makeConstraints {
                $0.top.equalTo(collectionViewHeadLabel.snp.bottom).offset(24 * heightRatio)
                $0.leading.equalToSuperview()
                $0.trailing.equalTo(view.snp.trailing)
                $0.height.equalTo(135 * heightRatio)
            }
            
            if plansData.isResponse == false {
                setBottomButtonViewLayout()
            }
            
            func setBottomButtonViewLayout() {
                bottomButtonBackgroundView.snp.makeConstraints {
                    $0.top.equalTo(scheduleBackgroundView.snp.bottom)
                    $0.leading.bottom.equalToSuperview()
                    $0.trailing.equalTo(view.snp.trailing)
                    $0.height.equalTo(112 * heightRatio)
                }
                
                rejectButton.snp.makeConstraints {
                    $0.top.equalToSuperview().offset(15 * heightRatio)
                    $0.leading.equalTo(20 * widthRatio)
                    $0.height.equalTo(54 * heightRatio)
                    $0.width.equalTo(160 * widthRatio)
                }
                
                confirmButton.snp.makeConstraints {
                    $0.centerY.equalTo(rejectButton)
                    $0.trailing.equalTo(view.snp.trailing).offset(-20 * widthRatio)
                    $0.height.equalTo(54 * heightRatio)
                    $0.width.equalTo(160 * widthRatio)
                }
            }
        }
    }
    
    private func setTimeOptionStackViewLayout() {
        guard let plansData = plansData else { return }

        plansData.invitationDates.enumerated().forEach { index, dateData in
            let optionView = AvailTimeOptionView().then {
                $0.isResponsed = plansData.isResponse ?? false
                $0.dateLabel.text = dateData.date
                do {
                    $0.timeLabel.text = try String.getAMPMTimeString(from: dateData.start) + " ~ " + String.getAMPMTimeString(from: dateData.end)
                } catch {
                    print(error.localizedDescription)
                }
                
                $0.tag = index // tag를 이용해 몇번째 옵션인지 구별하고 몇번째 데이터 인지 식별한다.
                
                if plansData.isResponse ?? false && dateData.isSelected ?? false  { // 이미 응답한 약속이면서 골랐던 시간대이면 버튼 아이콘 바꾼다.
                    $0.checkButton.setBackgroundImage(UIImage(named: "ic_finish_check_inactive"), for: .normal)
                }
            }
            
            optionView.delegate = self
            timeOptionStackView.addArrangedSubview(optionView)
        }
        
        if plansData.isResponse == false {
            timeOptionStackView.addSubview(sideIndicator)
            sideIndicator.snp.makeConstraints {
                $0.top.equalToSuperview()
                $0.leading.equalToSuperview().offset(20 * widthRatio)
                $0.width.equalTo(4 * widthRatio)
                $0.height.equalTo(82 * heightRatio)
            }
        }
    }
    
    // MARK: - Custom Method
    
    private func configUI() {
        backButton.addTarget(self, action: #selector(backButtonDidTap(_:)), for: .touchUpInside)
        rejectButton.addTarget(self, action: #selector(rejectButtonDidTap(_:)), for: .touchUpInside)
        confirmButton.addTarget(self, action: #selector(confirmButtonDidTap(_:)), for: .touchUpInside)
    }
    
    private func setStackButton() {
        plansData?.newGuests?.forEach { guest in
            let nameButton: UIButton = UIButton(type: .system).then {
                $0.titleLabel?.font = UIFont.hanSansRegularFont(ofSize: 13)
                $0.setTitle(guest?.username, for: .normal)
                $0.setTitleColor(UIColor.pink01, for: .normal)
                $0.backgroundColor = UIColor.white
                $0.clipsToBounds = true
                $0.layer.borderWidth = 1
                $0.layer.borderColor = UIColor.pink01.cgColor
                $0.layer.cornerRadius = 32 * heightRatio / 2
                if ((guest?.username.isEmpty) != nil) {
                    $0.layer.borderWidth = 0
                }
            }
            
            if #available(iOS 15.0, *) {
                var configuration = UIButton.Configuration.plain()
                configuration.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 12 * widthRatio, bottom: 0, trailing: 12 * widthRatio)
                nameButton.configuration = configuration
            } else {
                nameButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 12 * widthRatio, bottom: 0, right: 12 * widthRatio)
            }
            nameButtonStackView.addArrangedSubview(nameButton)
        }
    }
    
    private func setTextData() {
        let hostName: String = plansData?.invitation.host.username ?? "탈퇴한 유저"
        nameTitleLabel.setAttributedText(defaultText: hostName + "님이 보냈어요",
                                         containText: hostName + "님",
                                         font: UIFont.hanSansBoldFont(ofSize: 24),
                                         color: UIColor.grey06, kernValue: -0.6)
        
        plansTitleLabel.setAttributedText(defaultText: plansData?.invitation.invitationTitle ?? "", kernValue: -0.6)
        plansDetailTextView.attributedText = String.getAttributedText(text: plansData?.invitation.invitationDesc ?? "", letterSpacing: -0.6, lineSpacing: nil)
    }
    
    // MARK: - Network
    
    private func getPlansData() {
        guard let plansId = plansId else { return }
        GetPlansDetailDataService.shared.getPlansDetail(postID: plansId) { (response) in
            switch response {
            case .success(let data):
                if let response = data as? PlansDetailDataModel {
                    print(response.data)
                    self.plansData = response.data
                    
                    DispatchQueue.main.async {
                        self.setSelectData()
                        self.setTimeOptionStackViewLayout()
                        self.setTextData()
                        self.setStackButton()
                        self.collectionView.reloadData()
                    }
                    
                    for index in 0...response.data.invitationDates.count {
                        self.isSelectedOptionViewDictionary[index] = false
                    }
                }
            case .requestErr(let message):
                print("requestERR", message)
            case .pathErr:
                print("pathERR")
            case .serverErr:
                print("serverERR")
            case .networkFail:
                print("networkFail")
            }
        }
    }
    
    private func getSelectedOptionScheduleData(dateId: String) {
        GetResponseDateDataService.shared.getResponseDate(date: dateId) { (response) in
            switch response {
            case .success(let data) :
                if let response = data as? ResponseDateDataModel {
                    self.collectionViewData = response.data
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                        self.emptyLabel.isHidden = !response.data.isEmpty
                    }
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
    
    private func postComfirmPlans() {
        guard let plansData = plansData else { return }
        PostInvitationService.shared.postInvitation(plansId: String(plansData.invitation.id), invitationDateIds: selectedTimeOptionIDs) { (response) in
            switch(response) {
            case .success(let success):
                if let success = success as? InvitationPlansDataModel {
                    print(success.message, success.status, success.data)
                }
            case .requestErr(let message) :
                print("requestERR", message)
            case .pathErr :
                print("pathERR")
            case .serverErr:
                print("serverERR")
            case .networkFail:
                print("networkFail")
            }
        }
    }
    
    private func postRejectPlans() {
        guard let plansData = plansData else { return }
        PostInvitationRejectService.shared.postRejectInvitation(plansId: String(plansData.invitation.id)) { (response) in
            switch(response) {
            case .success(let success):
                if let success = success as? InvitationRejectDataModel {
                    print(success.message, success.status, success.data)
                }
            case .requestErr(let message):
                print("requestERR", message)
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
    
    @objc private func confirmButtonDidTap(_ sender: UIButton) {
        guard let plansData = plansData else { return }

        var yearList: [String] = []
        var timeList: [String] = []
        isSelectedOptionViewDictionary.forEach { key, bool in
            if bool {
                yearList.append(plansData.invitationDates[key].date)
                do {
                    timeList.append(try String.getAMPMTimeString(from: plansData.invitationDates[key].start)
                                    + " ~ " + String.getAMPMTimeString(from: plansData.invitationDates[key].end))
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
        
        let requestAlertVC = SMRequestPopUpVC(withType: .recieveConfirm).then {
            $0.yearText = yearList
            $0.dateText = timeList
            $0.modalPresentationStyle = .overFullScreen
            $0.pinkButtonCompletion = {
                self.postComfirmPlans()
                self.dismiss(animated: false, completion: nil)
                let viewControllers : [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
                self.navigationController?.popToViewController(viewControllers[viewControllers.count - 3 ], animated: false)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "toastMessage"), object: "답변을 완료했어요.")
            }
        }
        self.present(requestAlertVC, animated: false, completion: nil)
    }
    
    @objc private func rejectButtonDidTap(_ sender: UIButton) {
        let AlertVC = SMPopUpVC(withType: .refusePlans)
        AlertVC.modalPresentationStyle = .overFullScreen
        self.present(AlertVC, animated: false, completion: nil)
        
        AlertVC.pinkButtonCompletion = {
            self.postRejectPlans()
            self.dismiss(animated: true, completion: nil)
            let viewControllers : [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
            self.navigationController?.popToViewController(viewControllers[viewControllers.count - 3 ], animated: false)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "toastMessage"), object: "답변을 완료했어요.")
        }
    }
    
    @objc private func backButtonDidTap(_ sender: UIButton){
//        self.navigationController?.popViewController(animated: true)
        delegate?.backButtonDidTap()
    }
}

// MARK: - Extensions

extension PlansReceiveVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 224 * widthRatio, height: 129 * heightRatio)
    }
}

extension PlansReceiveVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionViewData?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PlansReceiveCVC.identifier, for: indexPath) as? PlansReceiveCVC else { return UICollectionViewCell() }
        
        guard let data = collectionViewData?[indexPath.row] else { return UICollectionViewCell() }
        
        var timeText: String = ""
        do {
            timeText = try String.getAMPMTimeString(from: data.start) + " ~ " + String.getAMPMTimeString(from: data.end)
        } catch {
            print(error.localizedDescription)
        }
        
        cell.setData(title: data.invitationTitle, time: timeText,
                     namesToShow: data.users.map { $0.username })
        
        return cell
    }
}

extension PlansReceiveVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20 * widthRatio
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 20 * widthRatio, bottom: 0, right: 0)
    }
}

extension PlansReceiveVC: AvailTimeOptionViewDelegate {
    func checkBoxDidTap(view: AvailTimeOptionView) {
        isSelectedOptionViewDictionary[view.tag] = view.checkButton.isSelected
        
        if isSelectedOptionViewDictionary.values.contains(true) {
            confirmButton.backgroundColor = UIColor.pink01
            confirmButton.isEnabled = true
        } else {
            confirmButton.backgroundColor = UIColor.grey04
            confirmButton.isEnabled = false
        }
    }
    
    func availTimeOptionViewDidTap(view: AvailTimeOptionView) {
        guard let plansData = plansData else { return }
        
        if plansData.isResponse == false { // 좌측 인디케이터 움직임
            UIView.animate(withDuration: 0.5) {
                let yFrame = CGAffineTransform(translationX: 0, y: CGFloat(82 * (view.tag)) * heightRatio)
                self.sideIndicator.transform = yFrame
            }
        }
        
        collectionViewHeadLabel.setAttributedText(defaultText: plansData.invitationDates[view.tag].date, kernValue: -0.6)
        getSelectedOptionScheduleData(dateId: String(plansData.invitationDates[view.tag].id))
    }
}
