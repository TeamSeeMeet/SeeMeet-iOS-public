//
//  TabbarVC.swift
//  SeeMeet
//
//  Created by 박익범 on 2022/01/08.
//


import SnapKit
import Then
import UIKit
import RxSwift
import RxCocoa

protocol TabbarVCDelegate {
    func presentAlert()
    func needLogin()
    func dismissAlert()
    func gotoRequestScene(friendData: FriendsData?)
}

final class TabbarVC: UITabBarController {
    
    // MARK: - UI Components
    
    private let plansRequestButton = UIButton().then {
        $0.setBackgroundImage(UIImage(named: "btn_send_message"), for: .normal)
    }
    
    // MARK: - Properties
    
    static let identifier: String = "TabbarVC"
    public var tabs: [UIViewController] = []
    
    private let disposeBag = DisposeBag()
    
    var tabBarDelegate: TabbarVCDelegate?
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configTabbar()
        setAutoLayouts()
        setupButtons()
        
        // Tabbar는 사라지지 않으니 이곳에서 노티를 받자.
//        NotificationCenter.default.rx.notification(Notification.Name.RefreshTokenExpired)
//            .asDriver(onErrorJustReturn: Notification(name: Notification.Name.init(rawValue: "error")))
//            .drive(onNext: { [weak self] noti in
//                
//            })
//            .disposed(by: disposeBag)
    }
    
    // MARK: - setLayouts
    
    private func setAutoLayouts() {
        tabBar.addSubview(plansRequestButton)
    
        plansRequestButton.snp.makeConstraints{
            $0.top.equalTo(tabBar.snp.top).offset(-9 * heightRatio)
            $0.centerX.equalTo(tabBar.snp.centerX)
            $0.width.height.equalTo(63 * heightRatio)
        }
    }
    
    // MARK: - Custom Methods
    
    private func configTabbar(){
        
        tabBar.do {
            $0.tintColor = .black
            $0.unselectedItemTintColor = .black
            $0.backgroundColor = UIColor.white
            $0.itemPositioning = .centered//하단줄의 tabBar.itemSpacing을 지정해주기 위해서 .centered를 해줘야함
            $0.itemSpacing = 140 * widthRatio //탭바 아이템간 간격 설정 - 곱해서 하자 ..
        }

    }
    
    private func setupButtons() {
        plansRequestButton.rx.tap
            .asDriver()
            .throttle(.milliseconds(100))
            .drive(onNext: { [weak self] _ in
                guard let self = self else { return }
                if UserDefaults.standard.bool(forKey: Constants.UserDefaultsKey.isLogin) == false {
                    self.tabBarDelegate?.presentAlert()
                } else {
                    self.tabBarDelegate?.gotoRequestScene(friendData: nil)
                }
            })
            .disposed(by: disposeBag)
    }
}
