import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa
import SwiftUI

protocol PlansListVCDelegate {
    func backButtonDidTap()
    func sendPlansDidTap(plansID: String)
    func receivePlansDidTap(plansID: String)
    func completedPlansDidTap(plansID: Int?,isCanceled: Bool)
}

class PlansListVC: UIViewController {
    
    // MARK: UI Components
    
    //headerView
    private let plansListBackgroundView = UIView().then {
        $0.backgroundColor = UIColor.white
    }
    
    private let headerView = UIView().then {
        $0.backgroundColor = UIColor.grey01
    }
    
    private let backButton = UIButton().then {
        $0.setBackgroundImage(UIImage(named: "btn_back"), for: .normal)
    }
    
    private let headerLabel = UILabel().then {
        $0.text = "약속 내역"
        $0.font = UIFont.hanSansBoldFont(ofSize: 18)
        $0.textColor = UIColor.grey06
        $0.textAlignment = .center
    }
    
    //customTabbar
    private let progressView = UIView().then {
        $0.backgroundColor = .none
        $0.isUserInteractionEnabled = true
    }
    
    private let completeView = UIView().then {
        $0.backgroundColor = .none
        $0.isUserInteractionEnabled = true
    }
    
    private let progressHeadView = UIView().then {
        $0.backgroundColor = .none
    }
    
    private let completeHeadView = UIView().then {
        $0.backgroundColor = .none
    }
    
    private let progressLabel = UILabel().then {
        $0.text = "진행중"
        $0.font = UIFont.hanSansBoldFont(ofSize: 16)
        $0.textColor = UIColor.grey06
        $0.textAlignment = .center
    }
    
    private let completeLabel = UILabel().then {
        $0.text = "완료"
        $0.font = UIFont.hanSansMediumFont(ofSize: 16)
        $0.textColor = UIColor.grey06
        $0.textAlignment = .center
    }
    
    private let bottomView = UIView().then {
        $0.backgroundColor = UIColor.grey06
    }
    
    //collectionViewHeader
    private let progressHeadLabel = UILabel().then {
        $0.font = UIFont.hanSansMediumFont(ofSize: 24)
        $0.setAttributedText(defaultText: "진행 중이에요", containText: "진행 중", font: UIFont.hanSansBoldFont(ofSize: 24), color: UIColor.grey06)
    }
    
    private let completeHeadLabel = UILabel().then {
        $0.font = UIFont.hanSansMediumFont(ofSize: 24)
        $0.setAttributedText(defaultText: "완료되었어요", containText: "완료", font: UIFont.hanSansBoldFont(ofSize: 24), color: UIColor.grey06)
        $0.textColor = UIColor.grey06
    }
    
    private let progressHeadCountLabel = UILabel().then {
        $0.font = UIFont.dinProRegularFont(ofSize: 24)
        $0.textColor = UIColor.grey06
    }
    
    private let completeHeadCountLabel = UILabel().then {
        $0.font = UIFont.dinProRegularFont(ofSize: 24)
        $0.textColor = UIColor.grey06
    }
    
    private let pagerScrollView = UIScrollView().then {
        $0.isPagingEnabled = true
        $0.bounces = false
        $0.backgroundColor = .none
        $0.showsHorizontalScrollIndicator = false
        $0.showsVerticalScrollIndicator = false
    }
    
    //progressCollectionView
    private let progressCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout()).then {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        $0.tag = 1
        $0.setCollectionViewLayout(layout, animated: false)
        $0.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        $0.backgroundColor = .none
        $0.bounces = true
        $0.showsVerticalScrollIndicator = false
    }
    
    //completeCollectionView
    private let completeCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout()).then {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        $0.tag = 2
        $0.setCollectionViewLayout(layout, animated: false)
        $0.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        $0.backgroundColor = .none
        $0.bounces = true
        $0.showsVerticalScrollIndicator = false
    }
    
    private let networkFailImage1 = UIImageView(image: UIImage(named: "img_network_fail")).then {
        $0.contentMode = .scaleAspectFit
    }
    private let networkFailImage2 = UIImageView(image: UIImage(named: "img_network_fail")).then {
        $0.contentMode = .scaleAspectFit
    }
    
    private let networkFailLabel1 = UILabel().then {
        $0.text = "인터넷 연결을 확인해주세요"
        $0.font = UIFont.hanSansMediumFont(ofSize: 16)
    }
    
    private let networkFailLabel2 = UILabel().then {
        $0.text = "인터넷 연결을 확인해주세요"
        $0.font = UIFont.hanSansMediumFont(ofSize: 16)
    }
    
    // MARK: - Properties
    
    static let identifier: String = "PlansListVC"
    
    weak var coordinator: PlansCoordinator?
    var delegate: PlansListVCDelegate?
    
    private var disposeBag: DisposeBag? = DisposeBag()
    
    private var userWidth: CGFloat = UIScreen.getDeviceWidth()
    private var userHeight: CGFloat = UIScreen.getDeviceHeight()
    
    private var invitationData: [Invitation] = [] // 진행 중 약속들
    private var confirmData: [ConfirmedAndCanceld?] = [] // 완료 된 약속들
    
    private var progressPlansCount: Int {
        invitationData.count
    }
    
    private var completePlansCount: Int {
        confirmData.count
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        setupAutoLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if NetworkReachabilityService.isConnectedToNetwork() {
            showNetworkFailViews(show: false)
            getPlansData()
        } else {
            showNetworkFailViews(show: true)
        }
    }
    
    // MARK: - Layout
    
    private func configUI() {
        backButton.addTarget(self, action: #selector(backButtonDidTap(_:)), for: .touchUpInside)
        
        let tapGestureProgressView = UITapGestureRecognizer(target: self, action: #selector(tabbarDidTap(_:)))
        let tapGestureCompleteView = UITapGestureRecognizer(target: self, action: #selector(tabbarDidTap(_:)))
        progressView.addGestureRecognizer(tapGestureProgressView)
        completeView.addGestureRecognizer(tapGestureCompleteView)
        
        [progressCollectionView, completeCollectionView].forEach {
            $0.dataSource = self
            $0.delegate = self
        }
        pagerScrollView.delegate = self
        
        progressCollectionView.registerCustomXib(xibName: "ProgressSendCVC")
        progressCollectionView.registerCustomXib(xibName: "ProgressReceiveCVC")
        completeCollectionView.registerCustomXib(xibName: "CompletePlansCVC")
    }
    
    private func setupAutoLayout() {
        setHeaderLayout()
        setScrollViewLayout()
    }
    
    private func setHeaderLayout() {
        view.addSubview(plansListBackgroundView)
        plansListBackgroundView.addSubview(headerView)
        headerView.addSubviews([backButton, headerLabel, progressView, completeView, bottomView])
        progressView.addSubview(progressLabel)
        completeView.addSubview(completeLabel)
        
        plansListBackgroundView.snp.makeConstraints{
            $0.top.bottom.leading.trailing.equalToSuperview()
        }
        
        headerView.snp.makeConstraints{
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(152 * heightRatio)
        }
        
        backButton.snp.makeConstraints{
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(5 * heightRatio)
            $0.leading.equalToSuperview().offset(2 * widthRatio)
            $0.width.height.equalTo(48 * widthRatio)
        }
        
        headerLabel.snp.makeConstraints{
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(15 * heightRatio)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(80 * widthRatio)
        }
        
        progressView.snp.makeConstraints{
            $0.bottom.equalToSuperview()
            $0.leading.equalToSuperview()
            $0.width.equalTo(userWidth * 0.5)
            $0.height.equalTo(50 * heightRatio)
        }
        
        progressLabel.snp.makeConstraints{
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
        
        completeView.snp.makeConstraints{
            $0.bottom.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.width.equalTo(userWidth * 0.5)
            $0.height.equalTo(50 * heightRatio)
        }
        
        completeLabel.snp.makeConstraints{
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
        
        bottomView.snp.makeConstraints{
            $0.leading.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.width.equalTo(userWidth * 0.5)
            $0.height.equalTo(3 * heightRatio)
        }
    }
    
    private func setScrollViewLayout() {
        plansListBackgroundView.addSubview(pagerScrollView)
        pagerScrollView.addSubviews([progressHeadView, completeHeadView, progressCollectionView, completeCollectionView])
        progressHeadView.addSubviews([progressHeadLabel, progressHeadCountLabel])
        completeHeadView.addSubviews([completeHeadLabel, completeHeadCountLabel])
        progressCollectionView.addSubview(networkFailImage1)
        progressCollectionView.addSubview(networkFailLabel1)
        completeCollectionView.addSubview(networkFailImage2)
        completeCollectionView.addSubview(networkFailLabel2)
        
        pagerScrollView.contentSize = CGSize(width: userWidth * 2, height: userHeight - 152)
        
        pagerScrollView.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        progressHeadView.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom)
            $0.leading.equalToSuperview()
            $0.trailing.equalTo(completeHeadView.snp.leading)
            $0.bottom.equalTo(progressCollectionView.snp.top)
            $0.height.equalTo(74 * heightRatio)
            $0.width.equalTo(userWidth)
        }
        
        progressHeadLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(20 * widthRatio)
            $0.width.equalTo(145 * widthRatio)
        }
        
        progressHeadCountLabel.snp.makeConstraints {
            $0.centerY.equalTo(progressHeadLabel)
            $0.trailing.equalToSuperview().offset(-20 * widthRatio)
            $0.width.equalTo(50 * widthRatio)
        }
        
        completeHeadView.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom)
            $0.leading.equalTo(progressHeadView.snp.trailing)
            $0.trailing.equalToSuperview()
            $0.bottom.equalTo(completeCollectionView.snp.top)
            $0.height.equalTo(74 * heightRatio)
            $0.width.equalTo(userWidth)
        }
        
        completeHeadLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(20 * widthRatio)
            $0.width.equalTo(145 * widthRatio)
        }
        
        completeHeadCountLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-20 * widthRatio)
            $0.width.equalTo(50 * widthRatio)
        }
        
        progressCollectionView.snp.makeConstraints {
            $0.top.equalTo(progressHeadView.snp.bottom)
            $0.bottom.leading.equalToSuperview()
            $0.trailing.equalTo(completeCollectionView.snp.leading)
            $0.width.equalTo(userWidth)
            $0.height.equalTo(userHeight-242 * heightRatio)
        }
        
        completeCollectionView.snp.makeConstraints {
            $0.top.equalTo(completeHeadView.snp.bottom)
            $0.bottom.trailing.equalToSuperview()
            $0.leading.equalTo(progressCollectionView.snp.trailing)
            $0.width.equalTo(userWidth)
            $0.height.equalTo(userHeight-242)
        }
        
        networkFailImage1.snp.makeConstraints {
            $0.width.equalTo(275 * widthRatio)
            $0.height.equalTo(205.32 * heightRatio)
            $0.centerX.equalToSuperview()
            $0.top.equalTo(headerView.snp.bottom).offset(164 * heightRatio)
        }
        
        networkFailImage2.snp.makeConstraints {
            $0.width.equalTo(275 * widthRatio)
            $0.height.equalTo(205.32 * heightRatio)
            $0.centerX.equalToSuperview()
            $0.top.equalTo(headerView.snp.bottom).offset(164 * heightRatio)
        }
        
        networkFailLabel1.snp.makeConstraints {
            $0.top.equalTo(networkFailImage1.snp.bottom)
            $0.centerX.equalToSuperview()
        }
        
        networkFailLabel2.snp.makeConstraints {
            $0.top.equalTo(networkFailImage2.snp.bottom)
            $0.centerX.equalToSuperview()
        }
        
        setCountLabel()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        moveBottomView(offsetX: pagerScrollView.contentOffset.x / 2)
        setTabbarTitle(offsetX: pagerScrollView.contentOffset.x)
        
        func moveBottomView(offsetX: CGFloat) {
            bottomView.snp.remakeConstraints {
                $0.leading.equalToSuperview().offset(offsetX)
                $0.height.equalTo(3 * heightRatio)
                $0.width.equalTo(userWidth/2)
                $0.bottom.equalToSuperview()
            }
        }
        
        func setTabbarTitle(offsetX: CGFloat) {
            if offsetX > userWidth / 2 {
                progressLabel.font = UIFont.hanSansMediumFont(ofSize: 16)
                completeLabel.font = UIFont.hanSansBoldFont(ofSize: 16)
            } else{
                progressLabel.font = UIFont.hanSansBoldFont(ofSize: 16)
                completeLabel.font = UIFont.hanSansMediumFont(ofSize: 16)
            }
        }
    }
    
    // MARK: - Custom Method
    
    private func setCountLabel() {
        progressHeadCountLabel.setAttributedText(defaultText: "\(progressPlansCount)건", containText: "\(progressPlansCount)", font: UIFont.dinProBoldFont(ofSize: 24), color: UIColor.pink01)
        completeHeadCountLabel.setAttributedText(defaultText: "\(completePlansCount)건", containText: "\(completePlansCount)", font: UIFont.dinProBoldFont(ofSize: 24), color: UIColor.pink01)
    }
    
    private func setCompleteEmptyView() {
        let emptyImage = UIImageView().then {
            $0.image = UIImage(named: "img_illust_9")
        }
        let emptyLabel = UILabel().then{
            $0.text = "완료된 약속이 없어요!"
            $0.font = UIFont.hanSansRegularFont(ofSize: 16)
            $0.textColor = UIColor.grey05
            $0.textAlignment = .center
        }
        if completePlansCount == 0 {
            completeCollectionView.addSubviews([emptyImage, emptyLabel])
            emptyImage.snp.makeConstraints {
                $0.centerX.equalToSuperview()
                $0.top.equalToSuperview().offset(110)
                $0.width.height.equalTo(164)
            }
            emptyLabel.snp.makeConstraints {
                $0.top.equalTo(emptyImage.snp.bottom).offset(15)
                $0.centerX.equalToSuperview()
                $0.height.equalTo(30)
            }
        }
        else {
            completeCollectionView.removeAllSubViews()
        }
    }
    
    private func setProgressEmptyView() {
        let emptyImage = UIImageView().then {
            $0.image = UIImage(named: "img_illust_9")
        }
        
        let emptyLabel = UILabel().then{
            $0.text = "진행 중인 약속이 없어요!"
            $0.font = UIFont.hanSansRegularFont(ofSize: 16)
            $0.textColor = UIColor.grey05
            $0.textAlignment = .center
        }
        
        if progressPlansCount == 0 {
            progressCollectionView.addSubviews([emptyImage, emptyLabel])
            emptyImage.snp.makeConstraints{
                $0.centerX.equalToSuperview()
                $0.top.equalToSuperview().offset(110 * heightRatio)
                $0.width.height.equalTo(164 * widthRatio)
            }
            emptyLabel.snp.makeConstraints{
                $0.top.equalTo(emptyImage.snp.bottom).offset(15 * heightRatio)
                $0.centerX.equalToSuperview()
                $0.height.equalTo(30 * heightRatio)
            }
        } else {
            progressCollectionView.removeAllSubViews()
        }
        
    }
    
    private func showNetworkFailViews(show: Bool) {
        [networkFailImage1,networkFailImage2,networkFailLabel1,networkFailLabel2]
            .forEach { $0.isHidden = !show }
    }
    
    //MARK: - Network
    
    private func getPlansData() {
        setCompleteEmptyView()
        setProgressEmptyView()
        GetPlansListDataService.shared.getPlansList { (response) in
            switch response {
            case .success(let data) :
                if let response = data as? PlansListDataModel {
                    self.invitationData = response.data?.invitations.sorted(by: {
                        
                        guard let timeInterval1 = TimeInterval(String.getTimeIntervalString(from: $0.createdAt)),
                              let timeInterval2 = TimeInterval(String.getTimeIntervalString(from: $1.createdAt)) else { return $0.id < $1.id}
                        return timeInterval1 < timeInterval2
                    }) ?? []
                    
                    self.confirmData = response.data?.confirmedAndCanceld.sorted(by: { $0.id > $1.id }) ?? []
                    
                    DispatchQueue.main.async {
                        self.setCountLabel()
                        self.setCompleteEmptyView()
                        self.setProgressEmptyView()
                        self.progressCollectionView.reloadData()
                        self.completeCollectionView.reloadData()
                    }
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
    
    private func putInvitationListDelete(id: String) {
        PutInvitationListService.shared.putInvitationListCancel(invitationId: id) { [weak self] response in
            switch response {
            case .success(_):
                self?.getPlansData()
            case .networkFail:
                self?.view.makeToastAnimation(message: "통신오류! 다시 시도하십시오.")
            default:
                self?.view.makeToastAnimation(message: "요청 실패")
            }
        }
    }
    
    // MARK: - Actions
    
    @objc private func tabbarDidTap(_ sender: UIView) {
        var contentOffsetX = pagerScrollView.contentOffset.x
        if contentOffsetX >= userWidth {
            pagerScrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        } else{
            pagerScrollView.setContentOffset(CGPoint(x: userWidth, y: 0), animated: true)
        }
    }
    
    @objc private func backButtonDidTap(_ sender: UIButton) {
        delegate?.backButtonDidTap()
    }
}

//MARK: - Extension

extension PlansListVC: UICollectionViewDelegate {
      func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
          if collectionView.tag == 1 {
              return CGSize(width: userWidth-40, height: 144.0 * heightRatio)
          }
          else{
              return CGSize(width: userWidth, height: 146.0 * heightRatio)
          }
      }
}

extension PlansListVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView.tag {
        case 1: // progressCollectionView
            return progressPlansCount
        case 2: // completeCollectionView
            return completePlansCount
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let day: Int = 1
        
        switch collectionView.tag {
        case 1: // progressCollectionView
            let data = invitationData[indexPath.row]
            
            if data.isReceived { // 받은요청
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProgressReceiveCVC.identifier, for: indexPath) as? ProgressReceiveCVC else { return UICollectionViewCell() }
                
                cell.setData(dayAgo: String.getTimeIntervalString(from: data.createdAt),
                             hostName: data.host?.username ?? "탈퇴")
                
                return cell
                
            } else { // 보낸요청
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProgressSendCVC.identifier, for: indexPath) as? ProgressSendCVC else { return UICollectionViewCell() }
                
                cell.setData(dateAgo: String.getTimeIntervalString(from: data.createdAt),
                             namesToShow: data.guests?.reduce([String: Bool]()) { dict, guest in
                    var dict = dict
                    dict[guest.username] = guest.isResponse
                    return dict
                } ?? [:])
                
                return cell
            }
            
        case 2: // completeCollectionView
            let data = confirmData[indexPath.row]
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CompletePlansCVC.identifier, for: indexPath) as? CompletePlansCVC else { return UICollectionViewCell() }
            
            cell.setData(namesToShow: data?.guests.reduce([String: Bool]()) { dict, guest in
                var dict = dict
                dict[guest.username] = guest.isResponse
                return dict
            } ?? ["":false], dayAgoText: "\(day + indexPath.row)일전", planName: data?.invitationTitle ?? "", isCanceled: data?.isCanceled ?? false)
            
            guard let id = data?.id else { return UICollectionViewCell() }
            
            cell.closeButton.rx.tap
                .asDriver()
                .drive(onNext: { [weak self] in
                    self?.disposeBag = nil
                    self?.disposeBag = DisposeBag()
                    self?.putInvitationListDelete(id: "\(id)")
                })
                .disposed(by: disposeBag!)
            
            return cell
            
        default:
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch collectionView.tag {
        case 1: // progressCollectionView
            if invitationData[indexPath.row].isReceived {
                let plansID = String(invitationData[indexPath.row].id)
                delegate?.receivePlansDidTap(plansID: plansID)
                                             
            } else {
                let plansID = String(invitationData[indexPath.row].id)
                delegate?.sendPlansDidTap(plansID: plansID)
            }
        case 2:
            if confirmData[indexPath.row]?.isConfirmed == true && confirmData[indexPath.row]?.isCanceled == false {
                let plansID = confirmData[indexPath.row]?.planID
                delegate?.completedPlansDidTap(plansID: plansID,isCanceled: false)
            }else {
                let ID = confirmData[indexPath.row]?.id
                delegate?.completedPlansDidTap(plansID: ID, isCanceled: true)
            }
        default:
            break
        }
    }
}

extension PlansListVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        switch collectionView.tag {
        case 1:
            return 20 * heightRatio
        case 2:
            return 0
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        switch collectionView.tag {
        case 1:
            return UIEdgeInsets(top: 20 * heightRatio, left: 0, bottom: 0, right: 0)
        case 2:
            return UIEdgeInsets.zero
        default:
            return UIEdgeInsets.zero
        }
    }
}
