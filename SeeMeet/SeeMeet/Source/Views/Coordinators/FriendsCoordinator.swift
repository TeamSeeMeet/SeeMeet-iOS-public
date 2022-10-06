//
//  FriendsCoordinator.swift
//  SeeMeet
//
//  Created by 김인환 on 2022/06/12.
//

import Foundation
import UIKit

class FriendsCoordinator: Coordinator {
    weak var parentCoordinator: Coordinator?
    var coordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    private var friendNames: [String]
    
    init(navigationController: UINavigationController, friendNames: [String]) { // HomeCoordinator로부터 주입받는다.
        self.navigationController = navigationController
        self.friendNames = friendNames
    }
    
    func start() {
        startFriendsListVC()
    }
    
    func startFriendsListVC() {
        guard let vc = UIStoryboard(name: "FriendsList", bundle: nil).instantiateViewController(withIdentifier: "FriendsListVC") as? FriendsListVC else { return }
        vc.coordinator = self
        vc.delegate = self
        navigationController.pushViewController(vc, animated: true)
    }
    
    func startFriendsAddVC() {
        guard let vc = UIStoryboard(name: "FriendsAdd", bundle: nil).instantiateViewController(withIdentifier: FriendsAddVC.identifier) as? FriendsAddVC else { return }
        vc.modalPresentationStyle = .fullScreen
        vc.coordinator = self
        navigationController.present(vc, animated: true)
    }
    
    
}

extension FriendsCoordinator: FriendsListVCDelegate{
    
    func backButtonDidTap() {
        navigationController.popViewController(animated: true)
    }
    
    func addFriendsButtonDidTap() {
        startFriendsAddVC()
    }
    
    func messageButtonDidTap(friendData: FriendsData) {
        coordinators.removeAll()
        navigationController.popToRootViewController(animated: true)
        
        guard let homeCoordinator = parentCoordinator as? HomeCoordinator, let appCoordinator = homeCoordinator.parentCoordinator as? AppCoordinator else { return } // 이럴 바에 notificationCenter 쓰는게 나을듯...
        appCoordinator.startRequestSceneFromFriendsList(friendData: friendData)
        parentCoordinator = nil
    }
}





