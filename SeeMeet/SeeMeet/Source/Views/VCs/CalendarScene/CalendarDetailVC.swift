import UIKit

protocol CalendarDetailVCDelegate{
    func backButtonDidTap()
}
class CalendarDetailVC: UIViewController {
    
    // MARK: - UI Components
    
    static let identifier: String = "CalendarDetailVC"
    
    private let topView: UIView = UIView().then {
        $0.backgroundColor = UIColor.grey06
    }
    
    private let backButton: UIButton = UIButton().then {
        $0.setImage(UIImage(named: "btn_back_white"), for: .normal)
    }
    
    private let navigationTitleLabel: UILabel = UILabel().then {
        $0.font = UIFont(name: "SpoqaHanSansNeo-Medium", size: 18.0)
        $0.textAlignment = .center
        $0.textColor = UIColor.white
    }
    
    private let eventTitleLabel: UILabel = UILabel().then {
        $0.font = UIFont(name: "SpoqaHanSansNeo-Bold", size: 22.0)
        $0.textColor = UIColor.grey06
        $0.textAlignment = .left
        $0.numberOfLines = 0
        $0.lineBreakMode = .byCharWrapping
    }
    
    let timeLabel: UILabel = UILabel().then {
        $0.font = UIFont(name: "DINPro-Regular", size: 18.0)
        $0.textColor = UIColor.grey06
    }
    
    //    private let nameTagStackView: UIStackView = UIStackView().then {
    //        $0.axis = .horizontal
    //        $0.alignment = .fill
    //        $0.distribution = .fillEqually
    //        $0.spacing = 10
    //        $0.layoutMargins = UIEdgeInsets(top: 10 * heightRatio, left: 10 * widthRatio, bottom: 10 * heightRatio, right: 10 * widthRatio)
    //        $0.isLayoutMarginsRelativeArrangement = true
    //    }
    
    private var nameTagCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewLayout())
        let flowlayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout().then {
            $0.scrollDirection = .vertical
            $0.minimumInteritemSpacing = CGFloat(0)
            $0.itemSize = CGSize(width: 100 * widthRatio, height: 23 * heightRatio)
            
        }
        
        collectionView.bounces = false
        collectionView.setCollectionViewLayout(flowlayout, animated: false)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .white
        collectionView.register(NameChipCVC.self, forCellWithReuseIdentifier: NameChipCVC.identifier)
        
        return collectionView
    }()
    
    private let separator: UIView = UIView().then {
        $0.backgroundColor = UIColor.grey02
    }
    
    private let letterView: UIView = UIView().then {
        $0.backgroundColor = UIColor.grey01
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 10
    }
    
    private let letterTitleLabel: UILabel = UILabel().then {
        $0.font = UIFont(name: "SpoqaHanSansNeo-Bold", size: 14)
        $0.textColor = UIColor.grey06
        $0.lineBreakMode = .byTruncatingTail
    }
    
    private let letterSeparator: UIView = UIView().then {
        $0.backgroundColor = UIColor.grey02
    }
    
    private let letterContentView: UITextView = UITextView().then {
        $0.isEditable = false
        $0.backgroundColor = UIColor.clear
        $0.textColor = UIColor.grey06
        $0.font = UIFont(name: "SpoqaHanSansNeo-Regular", size: 14)
        
        $0.textContainerInset = UIEdgeInsets(top: 10 * heightRatio, left: 10 * widthRatio, bottom: 10 * heightRatio, right: 10 * widthRatio)
    }
    
    private let organizerLabel: UILabel = UILabel().then {
        $0.text = "약속 주최자"
        $0.font = UIFont(name: "SpoqaHanSansNeo-Bold", size: 14)
        $0.textColor = UIColor.grey04
    }
    
    private let divider: UIView = UIView().then {
        $0.backgroundColor = UIColor.grey04
    }
    
    private let organizerNameLabel: UILabel = UILabel().then {
        $0.font = UIFont(name: "SpoqaHanSansNeo-Bold", size: 15)
    }
    
    private let bottomSeparator: UIView = UIView().then {
        $0.backgroundColor = UIColor.grey02
    }
    
    private let deleteButton: UIButton = UIButton().then {
        $0.backgroundColor = UIColor.grey04
        $0.setTitle("약속 삭제", for: .normal)
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 10
    }
    
    // MARK: - Properties
    
    var planID: Int? // 외부에서 반드시 입력받아야 함
    var isCanceled = false
    weak var coordinator: Coordinator?
    
    private var possibleNameList = [PossibleUser]() {
        didSet {
            //            setNameTag(nameList: possibleNameList?.map { $0.username ?? "탈퇴 유저" } )
        }
    }
    private var impossibleNameList = [PossibleUser]() {
        didSet {
            //            setNameTag(nameList: impossibleNameList?.map { $0.username ?? "탈퇴 유저" } )
        }
    }
//    private var nameList = ["안뇽","랄라라"]
    private var nameList = [CanceledPlansGuest]()
    var delegate: CalendarDetailVCDelegate?

    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setAutoLayouts()
        configUI()
        switch isCanceled{
        case true:
            getCanceledPlansData()
            deleteButton.isHidden = true
            bottomSeparator.isHidden = true
        case false:
            requestPlanDetail()
            deleteButton.isHidden = false
            bottomSeparator.isHidden = false
        }
        setDelegate()
    }
    
    // MARK: - setLayouts
    
    private func setAutoLayouts() {
        view.addSubview(topView)
        topView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            if UIScreen.hasNotch {
                $0.height.equalTo(102 * heightRatio)
            } else {
                $0.height.equalTo(CGFloat(58 + UIScreen.getIndecatorHeight()) * heightRatio)
            }
        }
        
        topView.addSubview(backButton)
        backButton.snp.makeConstraints {
            $0.height.width.equalTo(48 * heightRatio)
            $0.leading.equalToSuperview().offset(2 * heightRatio)
            $0.bottom.equalToSuperview().offset(-5 * heightRatio)
        }
        
        topView.addSubview(navigationTitleLabel)
        navigationTitleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.height.equalTo(32 * heightRatio)
            $0.bottom.equalToSuperview().offset(-11 * heightRatio)
        }
        
        view.addSubview(eventTitleLabel)
        eventTitleLabel.snp.makeConstraints {
            $0.top.equalTo(topView.snp.bottom).offset(33 * heightRatio)
            $0.leading.equalToSuperview().offset(21 * widthRatio)
            $0.trailing.equalToSuperview().offset(-37 * widthRatio)
        }
        
        view.addSubview(timeLabel)
        timeLabel.snp.makeConstraints {
            $0.leading.equalTo(eventTitleLabel.snp.leading)
            $0.top.equalTo(eventTitleLabel.snp.bottom).offset(6 * heightRatio)
        }
        
        view.addSubview(nameTagCollectionView)
        //        nameTagStackView.snp.makeConstraints {
        //            $0.leading.equalToSuperview().offset(10 * widthRatio)
        //            $0.top.equalTo(timeLabel.snp.bottom).offset(20 * heightRatio)
        //            $0.height.equalTo(46 * heightRatio)
        //        }
        nameTagCollectionView.snp.makeConstraints {
            $0.top.equalTo(timeLabel.snp.bottom).offset(20 * heightRatio)
            $0.leading.trailing.equalToSuperview().inset(10 * widthRatio)
            $0.height.equalTo(100 * heightRatio)
        }
        
        view.addSubview(separator)
        separator.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(1)
            $0.top.equalTo(nameTagCollectionView.snp.bottom).offset(18.5 * heightRatio)
        }
        
        view.addSubview(letterView)
        letterView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20 * widthRatio)
            $0.trailing.equalToSuperview().offset(-20 * widthRatio)
            $0.top.equalTo(separator.snp.bottom).offset(25 * heightRatio)
            $0.height.equalTo(225 * heightRatio)
        }
        
        letterView.addSubview(letterTitleLabel)
        letterTitleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(15 * heightRatio)
            $0.leading.equalToSuperview().offset(19 * widthRatio)
            $0.trailing.equalToSuperview().offset(-15 * widthRatio)
            $0.height.equalTo(32 * heightRatio)
        }
        
        letterView.addSubview(letterSeparator)
        letterSeparator.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(15 * widthRatio)
            $0.trailing.equalToSuperview().offset(-15 * widthRatio)
            $0.height.equalTo(1)
            $0.top.equalTo(letterTitleLabel.snp.bottom).offset(9 * heightRatio)
        }
        
        letterView.addSubview(letterContentView)
        letterContentView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(9 * widthRatio)
            $0.top.equalTo(letterSeparator.snp.bottom).offset(3 * heightRatio)
            $0.trailing.equalToSuperview().offset(-5 * widthRatio)
            $0.bottom.equalToSuperview().offset(-8 * heightRatio)
        }
        
        view.addSubview(organizerLabel)
        organizerLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(25 * widthRatio)
            $0.top.equalTo(letterView.snp.bottom).offset(10 * heightRatio)
        }
        
        view.addSubview(divider)
        divider.snp.makeConstraints {
            $0.leading.equalTo(organizerLabel.snp.trailing).offset(10 * widthRatio)
            $0.top.equalTo(letterView.snp.bottom).offset(10 * heightRatio)
            $0.width.equalTo(1)
            $0.height.equalTo(16 * heightRatio)
        }
        
        view.addSubview(organizerNameLabel)
        organizerNameLabel.snp.makeConstraints {
            $0.top.equalTo(letterView.snp.bottom).offset(8 * heightRatio)
            $0.leading.equalTo(divider.snp.trailing).offset(15.5 * widthRatio)
        }
        
        view.addSubview(bottomSeparator)
        bottomSeparator.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(1)
            $0.bottom.equalTo(-112 * heightRatio)
        }
        
        view.addSubview(deleteButton)
        deleteButton.snp.makeConstraints {
            $0.top.equalTo(bottomSeparator.snp.bottom).offset(16 * heightRatio)
            $0.leading.equalTo(20 * widthRatio)
            $0.trailing.equalTo(-20 * widthRatio)
            $0.height.equalTo(54 * heightRatio)
        }
    }
    
    // MARK: - Custom Methods
    
    private func configUI() {
        backButton.addTarget(self, action: #selector(backButtonDidTap(_:)), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(deleteButtonDidTap(_:)), for: .touchUpInside)
    }
    
    private func setDelegate(){
        nameTagCollectionView.delegate = self
        nameTagCollectionView.dataSource = self
    }
    
    private func displayDateLabel(at date: String) {

        let formatter = DateFormatter().then {
            $0.dateFormat = "yyyy-MM-dd"
            $0.timeZone =  NSTimeZone(name: "UTC") as TimeZone?
            $0.locale = Locale(identifier: "ko_KR")
        }
        
        if let date: Date = formatter.date(from: date) {
            formatter.dateFormat = "yyyy월 M월 d일 E요일"
            self.navigationTitleLabel.text = formatter.string(from: date)
        }
    }
    
    // MARK: - Networks
    
    private func getCanceledPlansData() {
        guard let plansId = planID else { return }
        GetCanceldPlansDetailService.shared.getCanceledPlans(plansId: String(plansId)) { (response) in
            switch response {
            case .success(let data):
                if let response = data as? CanceledPlanDetailModel {

                    self.eventTitleLabel.text = response.data.invitationTitle
                    self.letterTitleLabel.text = response.data.invitationTitle
                    self.letterContentView.text = response.data.invitationDesc
                    self.nameList = response.data.guest
                    self.organizerNameLabel .text = response.data.hostName
                    

                    DispatchQueue.main.async {
                        self.nameTagCollectionView.reloadData()
                        self.timeLabel.text = "취소된 약속"
                        self.timeLabel.textColor = UIColor.pink01
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
    
    private func requestPlanDetail() { // UI 코드를 분리 시켜야 할듯... 일단 나중에ㅠㅠ
        guard let planID = planID else {
            view.makeToastAnimation(message: "약속 조회 오류! 다시 시도해주세요.")
            return
        }
        
        CalendarService.shared.getDetailPlanData(planID: planID) { [weak self] responseData in
            switch responseData {
            case .success(let response):
                guard let response = response as? PlanDetailResponseModel else { return }
                self?.eventTitleLabel.text = response.data?.invitationTitle
                self?.letterTitleLabel.text = response.data?.invitationTitle
                self?.letterContentView.text = response.data?.invitationDesc
                self?.organizerNameLabel.text = response.data?.hostName
                self?.possibleNameList = response.data?.possible ?? []
                self?.impossibleNameList = response.data?.impossible ?? []
                self?.displayDateLabel(at: response.data?.date ?? "2022-01-01")
                
                self?.nameTagCollectionView.reloadData()
                
                var hourString = ""
                let startHourComponents = response.data?.start.components(separatedBy: ":")
                let endHourComponents = response.data?.end.components(separatedBy: ":")
                
                if let startHourString = startHourComponents?.first,
                   let startMinuteString = startHourComponents?[1],
                   let endHourString = endHourComponents?.first,
                   let endMinuteString = endHourComponents?[1],
                   let startHour = Int(startHourString),
                   let endHour = Int(endHourString)
                {
                    
                    hourString = startHour < 12 ? "오전 \(startHour):\(startMinuteString)" : "오후 \(startHour):\(startMinuteString)"
                    hourString += endHour < 12 ? " - 오전 \(endHour):\(endMinuteString)" : " - 오후 \(endHour):\(endMinuteString)"
                    
                    self?.timeLabel.text = hourString
                }
                
            case .requestErr(let response):
                guard let response = response as? PlanDetailResponseModel,
                      let message = response.message else { return }
                self?.view.makeToastAnimation(message: message)
                
            case .pathErr:
                print("Path Err")
                self?.view.makeToastAnimation(message: "요청 오류! 다시 시도하십시오.")
                
            case .serverErr:
                print("Server Err")
                self?.view.makeToastAnimation(message: "서버 에러! 다시 시도하십시오.")
                
            case .networkFail:
                print("Network Err")
                self?.view.makeToastAnimation(message: "통신 오류! 다시 시도하십시오.")
            }
        }
    }
    
    private func requestPlanDelete() {
        guard let planID = planID else {
            return
        }
        
        PutPlanDeleteService.shared.putPlanDelete(planId: "\(planID)") { responseData in
            switch responseData {
            case .success(let response):
                //                guard response is PlansDeleteResponseModel else { return }
                self.navigationController?.popViewController(animated: true)
                self.view.makeToastAnimation(message: "약속 삭제 되었습니다.")
            default:
                self.view.makeToastAnimation(message: "약속 삭제 실패. 다시 시도하십시오.")
            }
        }
        
    }
    
    // MARK: - Actions
    
    @objc private func backButtonDidTap(_ sender: UIButton) {
        delegate?.backButtonDidTap()
    }
    
    @objc private func deleteButtonDidTap(_ sender: UIButton) {
        let nextVC = SMPopUpVC(withType: .deletePlans)
        nextVC.modalPresentationStyle = .overCurrentContext
        nextVC.pinkButtonCompletion = { [weak self] in
            self?.requestPlanDelete()
            self?.dismiss(animated: false)
        }
        present(nextVC, animated: false)
    }
}

extension CalendarDetailVC: UICollectionViewDelegate{
    
}


extension CalendarDetailVC: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch isCanceled{
        case true:
            return nameList.count
        case false:
            let possibleCount = possibleNameList.count
            let impossibleCount = impossibleNameList.count
            
            return possibleCount + impossibleCount
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch isCanceled{
        case true:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NameChipCVC.identifier, for: indexPath) as? NameChipCVC else {return UICollectionViewCell()}
            
            
            cell.setData(name: nameList[indexPath.row].username)
                cell.setCanceledLayout()
           
            
            return cell
        case false:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NameChipCVC.identifier, for: indexPath) as? NameChipCVC else {return UICollectionViewCell()}
            
            let possibleCount = possibleNameList.count
            if (indexPath.row<possibleCount){
                cell.setData(name: possibleNameList[indexPath.row].username!)
                cell.setPossibleLayout()
            }else{
                cell.setData(name: impossibleNameList[indexPath.row - possibleCount].username ??
                "탈퇴")
                cell.setImpossibleLayout()
            }
            
            return cell
        }
        
    }
}

extension CalendarDetailVC: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch isCanceled{
        case false:
            let possibleCount = possibleNameList.count
            if (indexPath.row<possibleCount){
                return CGSize(
                    width: (possibleNameList[indexPath.item].username?.size(withAttributes: [NSAttributedString.Key.font : UIFont.hanSansMediumFont(ofSize: 14)]).width ?? 0) + 25,
                    height: 32)
            }else {
                let idx = indexPath.row - possibleCount
                return CGSize(
                    width: (impossibleNameList[idx].username?.size(withAttributes: [NSAttributedString.Key.font : UIFont.hanSansMediumFont(ofSize: 14)]).width ?? 0) + 25,
                    height: 32)
            }
        case true:
            return CGSize(
                width: (nameList[indexPath.item].username.size(withAttributes: [NSAttributedString.Key.font : UIFont.hanSansMediumFont(ofSize: 14)]).width) + 25,
                height: 32)
        }
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    
    
}
