import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa
import SafariServices

protocol HomeVCDelegate {
    func notificationButtonDidTap()
    func friendsButtonDidTap(friendNames: [String])
    func nameButtonDidTap()
    func loginButtonDidTap()
    func upcomingPalnDidTap()
    func goToProfileRevise()
}

final class HomeVC: UIViewController {
    
    // MARK: - UI Components
    
    private let homeBackgroundView = UIView().then {
        $0.backgroundColor = UIColor.grey01
    }
    
    private let topView = UIView().then{
        $0.backgroundColor = UIColor.pink01
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 10
        $0.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        $0.getShadowView(color: UIColor.black.cgColor, masksToBounds: false, shadowOffset: CGSize(width: 0, height: 4), shadowRadius: 3, shadowOpacity: 0.25)
    }
    
    private let menuButton = UIButton().then{
        $0.setBackgroundImage(UIImage(named: "btn_menu"), for: .normal)
    }
    
    private let friendsButton = UIButton().then{
        $0.setBackgroundImage(UIImage(named: "btn_friends"), for: .normal)
    }
    
    private let notificationButton = UIButton().then{
        $0.setBackgroundImage(UIImage(named: "ic_noti"), for: .normal)
    }
    
    private let dDayLabel = UILabel().then{
        $0.font = UIFont.hanSansRegularFont(ofSize: 22)
        $0.textColor = UIColor.black
        $0.numberOfLines = 2
        $0.setAttributedText(defaultText: "씨밋과 함께 약속을 잡아볼까요?", containText: "약속", font: UIFont.hanSansBoldFont(ofSize: 26), color: UIColor.white, kernValue: -0.6)
        //가운데 일수는 26/bold/white
    }
    
    private let characterImageView = UIImageView().then{
        $0.image = UIImage(named: "img_illust_5")
    }
    
    private let collectionViewHeadLabel = UILabel().then{
        $0.text = "다가오는 약속"
        $0.font = UIFont.hanSansBoldFont(ofSize: 20)
        $0.textColor = UIColor.black
    }
    
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: .init()).then {
        let flowLayout = UICollectionViewFlowLayout().then { layout in
            layout.minimumLineSpacing = 0
            layout.minimumInteritemSpacing = 0
            layout.scrollDirection = .horizontal
        }
        $0.setCollectionViewLayout(flowLayout, animated: false)
        $0.backgroundColor = .none
        $0.bounces = true
        $0.showsHorizontalScrollIndicator = false
    }
    
    private let noEventImageView = UIImageView().then{
        $0.image = UIImage(named: "img_illust_10")
    }
    
    private let noEventLabel = UILabel().then{
        $0.text = "일정이 없어요!"
        $0.font = UIFont.hanSansRegularFont(ofSize: 16)
        $0.textColor = UIColor.grey04
        $0.textAlignment = .center
    }
    
    private let myPageView = MyPageView()
    
    // MARK: - Properties
    weak var coordinator: HomeCoordinator?
    var delegate: HomeVCDelegate?
    
    private var lastEventDate: String = ""
    private var userWidth: CGFloat = UIScreen.getDeviceWidth()
    private var userHeight: CGFloat = UIScreen.getDeviceHeight() - 88 * heightRatio
    
    private var homeData: [HomeData]? {
        didSet {
            homeData = homeData?.filter { !isPrevious(date: $0.date) }
        }
    }
    private var friendsListData: [FriendsData]?
    
    let disposeBag = DisposeBag()
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setAutoLayouts()
        configUI()
        setDelegate()
        setCollectionViewLayout()
        isNoEventLayout()
        setMainillust()
        setupMyPageViewButtons()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tabBarController?.tabBar.isHidden = false
        getHomeData()
        getLastPlansCount()
        NotificationCenter.default.addObserver(self, selector: #selector(makeToast(_:)), name: NSNotification.Name(rawValue: "toastMessage"), object: nil)
        setMyPageData()
        
        if let accessToken = TokenUtils.shared.read(account: "accessToken") {
            print(accessToken)
        }
        var userName = UserDefaults.standard.string(forKey: Constants.UserDefaultsKey.userName)
        var userId = UserDefaults.standard.string(forKey: Constants.UserDefaultsKey.userNickname)
        var isLogin = UserDefaults.standard.bool(forKey: Constants.UserDefaultsKey.isLogin)
        if (userName == nil)&&(userId == nil)&&(isLogin==true){
            let alertVC = SMPopUpVC(withType: .profile)
            alertVC.modalPresentationStyle = .overFullScreen
            self.present(alertVC, animated: false, completion: nil)
            
            alertVC.pinkButtonCompletion = {
                self.dismiss(animated: false)
                self.delegate?.goToProfileRevise()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    // MARK: - setLayouts
    
    private func setAutoLayouts() {
        self.navigationController?.isNavigationBarHidden = true
        
        view.addSubview(homeBackgroundView)
        homeBackgroundView.addSubviews([topView, collectionViewHeadLabel])
        topView.addSubviews([menuButton, friendsButton, notificationButton, dDayLabel, characterImageView])
        
        homeBackgroundView.snp.makeConstraints{
            $0.top.bottom.leading.trailing.equalToSuperview()
        }
        topView.snp.makeConstraints{
            let topViewRatio: CGFloat = 0.6
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(userHeight * topViewRatio)
        }
        menuButton.snp.makeConstraints{
            $0.top.equalToSuperview().offset(48 * heightRatio)
            $0.leading.equalToSuperview().offset(7 * widthRatio)
            $0.height.width.equalTo(48 * heightRatio)
        }
        notificationButton.snp.makeConstraints{
            $0.centerY.equalTo(menuButton)
            $0.trailing.equalToSuperview().offset(-20 * widthRatio)
            $0.width.height.equalTo(48 * widthRatio)
        }
        friendsButton.snp.makeConstraints{
            $0.centerY.equalTo(menuButton)
            $0.trailing.equalTo(notificationButton.snp.leading)
            $0.width.height.equalTo(48 * widthRatio)
        }
        dDayLabel.snp.makeConstraints{
            $0.top.equalTo(menuButton.snp.bottom).offset(35 * heightRatio)
            $0.leading.equalToSuperview().offset(20 * widthRatio)
//            $0.width.equalTo(250 * widthRatio)
//            $0.height.equalTo(63 * heightRatio)
        }
        characterImageView.snp.makeConstraints{
            $0.bottom.equalTo(topView.snp.bottom).offset(-11 * heightRatio)
            $0.trailing.equalToSuperview().offset(-24 * heightRatio)
            $0.width.equalTo(317 * heightRatio)
            $0.height.equalTo(210 * heightRatio)
        }
        collectionViewHeadLabel.snp.makeConstraints{
            $0.top.equalTo(topView.snp.bottom).offset(14 * heightRatio)
            $0.leading.equalToSuperview().offset(20 * widthRatio)
            $0.width.equalTo(116 * widthRatio)
            $0.height.equalTo(32 * heightRatio)
        }
        
        view.addSubview(myPageView)
        
        myPageView.frame = CGRect(x: -userWidth * 0.84, y: 0, width: userWidth * 0.84, height: userHeight + 88)
        myPageView.isHidden = true
    }
    
    // MARK: - Custom Methods
    
    private func configUI() {
        menuButton.addTarget(self, action: #selector(menuButtonClicked(_:)), for: .touchUpInside)
        friendsButton.addTarget(self, action: #selector(friendsButtonDidTap(_:)), for: .touchUpInside)
        notificationButton.addTarget(self, action: #selector(notiButtonClicked(_:)), for: .touchUpInside)
    }
    
    private func setupMyPageViewButtons() {
        guard let noticeURL = URL(string: "https://be-simon.notion.site/Seemeet-4b19c31ed34b4429ae8348d8c2950437"),
              let termOfServiceURL = URL(string: "https://be-simon.notion.site/Seemeet-107c957d37b745858a4da44498dd4b7a"),
              let privacyPolicyURL = URL(string: "https://be-simon.notion.site/Seemeet-6fbe99c20f0f47f8a2a23cb4c601bd12"),
              let openSourceURL = URL(string: "https://be-simon.notion.site/Seemeet-30d0b45f3a2d40f9b6d2ca65094cf955") else { return }
        myPageView.noticeButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] in
                let webView = SFSafariViewController(url: noticeURL)
                self?.present(webView, animated: true)
            })
            .disposed(by: disposeBag)
        
        myPageView.termOfServiceButton.rx.tap // 이용약관
            .asDriver()
            .drive(onNext: { [weak self] in
                let webView = SFSafariViewController(url: termOfServiceURL)
                webView.modalPresentationStyle = .pageSheet
                webView.dismissButtonStyle = .close
                self?.present(webView, animated: true)
            })
            .disposed(by: disposeBag)
        
        myPageView.privacyPolicyButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] in
                let webView = SFSafariViewController(url: privacyPolicyURL)
                webView.modalPresentationStyle = .pageSheet
                webView.dismissButtonStyle = .close
                self?.present(webView, animated: true)
            })
            .disposed(by: disposeBag)
        
        myPageView.openSourceButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] in
                let webView = SFSafariViewController(url: openSourceURL)
                webView.modalPresentationStyle = .pageSheet
                webView.dismissButtonStyle = .close
                self?.present(webView, animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    private func setDelegate(){
        myPageView.nameButtonTappedDelegate = self
    }
    
    private func setCollectionViewLayout() {
        homeBackgroundView.addSubview(collectionView)
        collectionView.do {
            $0.delegate = self
            $0.dataSource = self
            $0.registerCustomXib(xibName: "HomeEventCVC")
        }
        
        collectionView.snp.makeConstraints {
            let collectionViewRatio: CGFloat = 0.32
            $0.top.equalTo(collectionViewHeadLabel.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(userHeight * collectionViewRatio)
        }
    }
    
    private func isNoEventLayout() {
        if homeData == nil {
            homeBackgroundView.addSubviews([noEventImageView, noEventLabel])
            noEventImageView.snp.makeConstraints{
                $0.top.equalTo(collectionViewHeadLabel.snp.bottom).offset(10 * heightRatio)
                $0.centerX.equalToSuperview()
                $0.width.equalTo(249 * widthRatio)
                $0.height.equalTo(128 * heightRatio)
            }
            noEventLabel.snp.makeConstraints{
                $0.top.equalTo(noEventImageView.snp.bottom).offset(12 * heightRatio)
                $0.centerX.equalToSuperview()
                $0.width.equalTo(110 * widthRatio)
            }
        }
    }
    
    private func setMyPageData() {
        if UserDefaults.standard.bool(forKey: Constants.UserDefaultsKey.isLogin) {
            myPageView.do {
                $0.nameButton.setTitle(UserDefaults.standard.string(forKey: Constants.UserDefaultsKey.userName) ?? "로그인", for: .normal)
                $0.nicknameLabel.text = UserDefaults.standard.string(forKey: Constants.UserDefaultsKey.userNickname) ?? "SeeMeet에서 친구와 약속을 잡아보세요!"
                guard let image = ImageManager.shared.getSavedImage(named: "profile.png") ?? UIImage(named: "img_profile")  else {return}
                $0.profileImageView.image = image
            }
        }
    }
    
    func isPrevious(date: String) -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let startDate = dateFormatter.date(from: Date.getCurrentYear() + "-" + Date.getCurrentMonth() + "-" + Date.getCurrentDate()) ?? Date()
        let endDate = dateFormatter.date(from: date) ?? Date()
        
        let interval = endDate.timeIntervalSince(startDate)
        let days = Int(interval / 86400)
        
        if days <= 0 {
            return true
        }
        else {
            return false
        }
        
    }
    
    private func setMainillust() {
        let elapsedDays = String.getTimeInterval(from: lastEventDate, by: "yyyy-MM-dd")
        
        enum MainText: String {
            case firstComeIn = "씨밋과 함께 약속을 잡아볼까요?"
            case firstFriendAdded = "친구가 당신의 약속 신청을 기다리고 있어요!"
            case todayMeet = "아싸 오늘은 친구 만나는 날이다!"
            case twoWeek = "약속잡기에 딱 좋은\n 시기에요!"
            case threeWeek = "친구와 만난지 벌써 \n%@일이 지났어요"
            case overThreeWeek = "친구를 언제 만났는지 기억도 안나요.."
        }
        
        let randomMessageList: [MainText] = [.firstFriendAdded, .twoWeek, .overThreeWeek]
        var mainText: MainText = .firstComeIn
        var mainCharacterImage: UIImage?
        var containText: String {
            switch mainText {
            case .firstComeIn:
                return "약속"
            case .firstFriendAdded:
                return "약속 신청"
            case .todayMeet:
                return "친구"
            case .twoWeek:
                return "딱 좋은"
            case .threeWeek:
                return "\(abs(elapsedDays))일"
            case .overThreeWeek:
                return "기억도"
            default:
                return ""
            }
        }
        
        if friendsListData?.count ?? 0 == 0  && homeData?.count ?? 0 == 0 { // 사용자 초기 화면: 친구목록도 아직 없고, 약속 데이터도 없음
            mainCharacterImage = UIImage(named: "img_illust_5")
            mainText = .firstComeIn
            
        } else if friendsListData?.count ?? 0 > 0 && homeData?.count ?? 0 == 0 { // 친구는 있으나, 약속 데이터 없음
            switch randomMessageList.randomElement() {
            case .firstFriendAdded:
                mainCharacterImage = UIImage(named: "img_illust_4")
                mainText = .firstFriendAdded
            case .twoWeek:
                mainCharacterImage = UIImage(named: "img_illust_8")
                mainText = .twoWeek
            case .overThreeWeek:
                mainCharacterImage = UIImage(named: "img_illust_7")
                mainText = .overThreeWeek
            default:
                print("error")
            }
            
        } else if elapsedDays <= 0 {
            if elapsedDays > -14 {
                mainCharacterImage = UIImage(named: "img_illust_8")
                mainText = .twoWeek
            } else if elapsedDays < -14 && elapsedDays > -21 {
                mainCharacterImage = UIImage(named: "img_illust_6")
                mainText = .threeWeek
            } else if elapsedDays <= -21 {
                mainCharacterImage = UIImage(named: "img_illust_6")
                mainText = .overThreeWeek
            }
            
        } else if homeData?.contains(where: {
            $0.date == Date.getCurrentYear() + "-" + Date.getCurrentMonth() + "-" + Date.getCurrentDate()
        }) ?? false {
            mainText = .todayMeet
            mainCharacterImage = UIImage(named: "img_illust_1")
        }
        
        let defaultText = mainText != .threeWeek ? mainText.rawValue : String(format: mainText.rawValue, containText)
        
        dDayLabel.setAttributedText(defaultText: defaultText, containText: containText,
                                    font: UIFont.hanSansBoldFont(ofSize: 26), color: UIColor.white,
                                    kernValue: -0.6 * widthRatio)
        characterImageView.image = mainCharacterImage
    }
    
    // MARK: - Actions
    
    @objc private func notiButtonClicked(_ sender: UIButton) {
        delegate?.notificationButtonDidTap()
    }
    
    @objc private func friendsButtonDidTap(_ sender: UIButton) {
        if UserDefaults.standard.bool(forKey: Constants.UserDefaultsKey.isLogin) {
            delegate?.friendsButtonDidTap(friendNames: friendsListData?.map { $0.username } ?? [])
            
        } else {
            let alertVC = SMPopUpVC(withType: .needLogin).then {
                $0.modalPresentationStyle = .overFullScreen
                $0.pinkButtonCompletion = { [weak self] in
                    self?.dismiss(animated: false, completion: nil)
                    self?.delegate?.loginButtonDidTap()
                }
            }
            present(alertVC, animated: false, completion: nil)
        }
    }
    
    @objc private func menuButtonClicked(_ sender: UIButton) {
        myPageView.isHidden = false
        myPageView.pushAlarmSwitch.isOn = UserDefaults.standard.bool(forKey: Constants.UserDefaultsKey.isPushNotificationOn)
        UIView.animate(withDuration: 0.3) {
            let yFrame = CGAffineTransform(translationX: self.userWidth * 0.84, y: 0)
            self.myPageView.transform = yFrame
        }
    }
    
    @objc private func makeToast(_ notification: NSNotification){
        view.makeToastAnimation(message: notification.object as? String ?? "")
    }
    
    // MARK: - Networks
    
    private func getHomeData() {
        GetHomeDataService.shared.getHomeData(year: Date.getCurrentYear(), month: Date.getCurrentMonth()){ [weak self] (response) in
            switch response {
            case .success(let data) :
                if let response = data as? HomeDataModel {
                    self?.homeData = response.data
                    self?.setMainillust()
                    if response.data.isEmpty {
                        self?.isNoEventLayout()
                        self?.noEventLabel.isHidden = false
                        self?.noEventImageView.isHidden = false
                    } else {
                        self?.noEventLabel.isHidden = true
                        self?.noEventImageView.isHidden = true
                    }
                    self?.collectionView.reloadData()
                }
            case .requestErr(let message) :
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
    
    private func getLastPlansCount() {
        GetLastDateService.shared.getLastPlans(year: Date.getCurrentYear(), month: Date.getCurrentMonth(), day: Date.getCurrentDate()) { [weak self](response) in
            switch response {
            case .success(let data) :
                if let response = data as? LastDateDataModel {
                    self?.lastEventDate = response.data.date
                    self?.setMainillust()
                }
            case .requestErr(let message) :
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
    
    //    private func requestFriendsList() {
    //        GetFriendsListService.shared.getFriendsList() { response in
    //            switch response {
    //            case .success(let data) :
    //                if let response = data as? FriendsDataModel {
    //                    self.friendsListData = response.data
    //                    self.setMainillust()
    //                }
    //            case .requestErr(let message) :
    //                print("requestERR")
    //            case .pathErr :
    //                print("pathERR")
    //            case .serverErr:
    //                print("serverERR")
    //            case .networkFail:
    //                print("networkFail")
    //            }
    //        }
    //    }
}

// MARK: - Extensions

extension HomeVC: NameButtonTappedDelegate{
    func nameButtonTapped() {
        if !UserDefaults.standard.bool(forKey: Constants.UserDefaultsKey.isLogin) {
           let popUp = SMPopUpVC(withType: .needLogin).then {
                        $0.modalPresentationStyle = .overFullScreen
                        $0.pinkButtonCompletion = { [weak self] in
                            self?.dismiss(animated: false, completion: nil)
                            self?.tabBarController?.tabBar.isHidden = true
                            self?.delegate?.loginButtonDidTap()
                        }
                    }
                present(popUp, animated: false, completion: nil)
        }else{
            delegate?.nameButtonDidTap()
        }
    }
}

extension HomeVC: UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellHeight = userHeight * 0.3
        let cellWidth = userWidth * 0.4
        return CGSize(width: cellWidth, height: cellHeight)
    }
}

extension HomeVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let homeData = homeData {
            if homeData.isEmpty {
                return 0
            } else {
                if !isPrevious(date: homeData[section].date) {
                    return homeData.count
                } else {
                    isNoEventLayout()
                    return 0
                }
            }
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell =  collectionView.dequeueReusableCell(withReuseIdentifier: HomeEventCVC.identifier, for: indexPath) as? HomeEventCVC,
              let homeData = homeData else { return UICollectionViewCell() }
        
        let dDayDate = String.getTimeIntervalString(from: homeData[indexPath.row].date, by: "yyyy-MM-dd")
        let eventDate = homeData[indexPath.row].date.components(separatedBy: "-")
        let event = eventDate[1] + "-" + eventDate[2]
        var imageName = ""
        
        if Int(homeData[indexPath.row].count) ?? 0 - 1 > 2 {
            imageName = "img_illust_3"
        } else {
            imageName = "img_illust_2"
        }
        cell.setData(dDay: "D-" + dDayDate, image: imageName, eventName: homeData[indexPath.row].invitationTitle, eventData: event)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
       
    }
}

extension HomeVC: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        10 * widthRatio
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 0, left: 20 * widthRatio, bottom: 0, right: 0)
    }
}
