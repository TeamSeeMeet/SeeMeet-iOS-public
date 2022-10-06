//
//  RequestCoordinator.swift
//  SeeMeet
//
//  Created by 김인환 on 2022/06/13.
//

import UIKit

class RequestCoordinator: Coordinator {
    weak var parentCoordinator: Coordinator?
    var coordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    var friendData: FriendsData?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        startRequestPlansContentsVC()
    }
    
    func startRequestPlansContentsVC() {
        let vc = RequestPlansContentsVC()
        vc.coordinator = self
        vc.delegate = self
        vc.friendDataToSet = friendData
        navigationController.setViewControllers([vc], animated: false)
    }
    
    func startRequestPlansDateVC() {
        let vc = RequestPlansDateVC()
        vc.coordinator = self
        vc.delegate = self
        navigationController.pushViewController(vc, animated: true)
    }
}

extension RequestCoordinator: RequestPlansContentsVCDelegate, RequestPlansDateVCDelegate {
    func backButtonDidTap() {
        self.navigationController.popViewController(animated: true)
    }
    
    func exitButtonDidTap() { // RequestPlansContentsVC와 RequestPlansDateVC 에서 공통으로 사용된다.
        self.navigationController.presentingViewController?.dismiss(animated: true)
        self.navigationController.viewControllers.removeAll()
        parentCoordinator?.coordinators.removeAll(where: { $0 === self })
        
        PostRequestPlansService.sharedParameterData.removeAllData()
    }
    
    func nextButtonDidTap() {
        self.startRequestPlansDateVC()
    }
    
}
