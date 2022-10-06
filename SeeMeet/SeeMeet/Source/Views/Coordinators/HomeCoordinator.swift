//
//  TabbarCoordinator.swift
//  SeeMeet
//
//  Created by 김인환 on 2022/05/21.
//

import Foundation
import UIKit

class HomeCoordinator: Coordinator {
    weak var parentCoordinator: Coordinator?
    var coordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    init() {
        self.navigationController = UINavigationController()
    }
    
    func start() {
        _ = startHomeVC()
    }
    
    func startHomeVC() -> UINavigationController {
        let vc = HomeVC()
        vc.coordinator = self
        vc.delegate = self
        navigationController.setViewControllers([vc], animated: true)
        return navigationController
    }
    
    func startPlansScenes() {
        let coordinator = PlansCoordinator(navigationController: navigationController)
        coordinator.parentCoordinator = self
        coordinators.append(coordinator)
        coordinator.start()
    }
    
    func startFriendScenes(friendNames: [String]) {
        let coordinator = FriendsCoordinator(navigationController: navigationController, friendNames: friendNames)
        coordinator.parentCoordinator = self
        coordinators.append(coordinator)
        coordinator.start()
    }
    
    func startLoginScene(){
        let coordinator = LoginCoordinator(navigationController: navigationController) // home의 경우에는 로그인 완료 시 start하면 될듯
        coordinator.parentCoordinator = self
        coordinators.append(coordinator)
        coordinator.start()
    }
    
    func startMyPageScene(){
        let coordinator = MyPageCoordinator(navigationController: navigationController)
        coordinator.parentCoordinator = self
        coordinators.append(coordinator)
        coordinator.start()
    }
    
    func startProfileRevise(){
        let coordinator = MyPageCoordinator(navigationController: navigationController)
        coordinator.parentCoordinator = self
        coordinators.append(coordinator)
        coordinator.startUserInfoVCRevisingStatus()
    }
}

extension HomeCoordinator: HomeVCDelegate {
    func notificationButtonDidTap() {
        startPlansScenes()
    }
    
    func friendsButtonDidTap(friendNames: [String]) {
        startFriendScenes(friendNames: friendNames)
    }
    
    func nameButtonDidTap() {
        startMyPageScene()
    }
    
    func loginButtonDidTap(){
        startLoginScene()
    }
    
    func upcomingPalnDidTap() {
    }
    
    func goToProfileRevise() {
        startProfileRevise()
    }
}
