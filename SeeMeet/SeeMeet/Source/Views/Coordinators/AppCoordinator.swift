//
//  AppCoordinator.swift
//  SeeMeet
//
//  Created by 김인환 on 2022/05/21.
//

import UIKit
import RxSwift

class AppCoordinator: Coordinator {
    
    var coordinators: [Coordinator] = []
    
    let window: UIWindow?
    
    var navigationController = UINavigationController().then {
        $0.modalTransitionStyle = .crossDissolve
        $0.modalPresentationStyle = .overFullScreen
    }
    
    private let disposeBag = DisposeBag()
    
    init(_ window: UIWindow?) { // SceneDelegate에서 UIWindow의 의존성 주입받는다.
        self.window = window
        window?.makeKeyAndVisible()
    }
    
    func start() {
        startTabbarViewController()
    }
    
    private func startTabbarViewController() {
        let tabBarController = TabbarVC()
        tabBarController.tabBarDelegate = self
        
        let homeCoordinator = HomeCoordinator()
        homeCoordinator.parentCoordinator = self
        coordinators.append(homeCoordinator)
        let homeVC = homeCoordinator.startHomeVC()
        homeVC.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "home_ic"), selectedImage: UIImage(named: "home_ic_clicked"))
        
        let calendarCoordinator = CalendarCoordinator()
        calendarCoordinator.parentCoordinator = self
        coordinators.append(calendarCoordinator)
        let calendarVC = calendarCoordinator.startCalendarVC()
        calendarVC.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "calendar_ic"), selectedImage: UIImage(named: "calendar_ic_clicked"))
        
        tabBarController.setViewControllers([homeVC, calendarVC], animated: false)
        tabBarController.selectedViewController = homeVC
        
        [homeVC, calendarVC].forEach {
            $0.tabBarItem.imageInsets = UIEdgeInsets(top: UIScreen.hasNotch ? -5 * heightRatio : -25 * heightRatio, left: 0, bottom: 0, right: 0)
        }
        
        self.window?.rootViewController = tabBarController
    }
    
    func startRequestSceneFromFriendsList(friendData: FriendsData) {
        gotoRequestScene(friendData: friendData)
    }
}

extension AppCoordinator: TabbarVCDelegate {
    func needLogin() {
        if self.navigationController.isBeingPresented {
            return
        }
        let loginCoordinator = LoginCoordinator(navigationController: self.navigationController) // AppCoordinator의 경우엔 로그인 완료시 그냥 dismiss
        loginCoordinator.parentCoordinator = self
        coordinators.append(loginCoordinator)
        loginCoordinator.start()
        self.window?.rootViewController?.present(navigationController, animated: true) {
            self.window?.rootViewController?.view.makeToastAnimation(message: "로그인이 필요합니다.")
        }
    }
    
    func dismissAlert() {
        self.window?.rootViewController?.presentedViewController?.dismiss(animated: false)
    }
    
    func gotoRequestScene(friendData: FriendsData?) {
        let requestCoordinator = RequestCoordinator(navigationController: self.navigationController)
        requestCoordinator.parentCoordinator = self
        requestCoordinator.friendData = friendData
        self.coordinators.append(requestCoordinator)
        requestCoordinator.start()
        self.window?.rootViewController?.present(self.navigationController, animated: false)
    }
    
    func presentAlert() {
        let alertVC = SMPopUpVC(withType: .needLogin).then {
            $0.modalPresentationStyle = .overFullScreen
            $0.pinkButtonCompletion = { [weak self] in
                guard let self = self else { return }
                self.window?.rootViewController?.presentedViewController?.dismiss(animated: false)
                self.needLogin()
            }
        }
        self.window?.rootViewController?.present(alertVC, animated: false)
    }
}
