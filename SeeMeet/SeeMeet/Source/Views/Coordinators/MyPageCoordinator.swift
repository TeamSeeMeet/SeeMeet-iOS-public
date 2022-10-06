//
//  MyPageCoordinator.swift
//  SeeMeet
//
//  Created by 이유진 on 2022/08/02.
//

import UIKit

class MyPageCoordinator: Coordinator {
    weak var parentCoordinator: Coordinator?
    var coordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        startUserInfoVC()
    }
    
    func startUserInfoVC() {
        guard let vc = UIStoryboard(name: "UserInfo", bundle: nil).instantiateViewController(withIdentifier: "UserInfoVC") as? UserInfoVC else {return}
        vc.coordinator = self
        vc.delegate = self
        navigationController.pushViewController(vc, animated: true)
    }
    
    func startChangePasswordVC() {
        guard let vc = UIStoryboard(name: "ChangePassword", bundle: nil).instantiateViewController(withIdentifier: "ChangePasswordVC") as? ChangePasswordVC else {return}
        vc.delegate = self
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
    func startUserInfoVCRevisingStatus(){
        guard let vc = UIStoryboard(name: "UserInfo", bundle: nil).instantiateViewController(withIdentifier: "UserInfoVC") as? UserInfoVC else {return}
        vc.coordinator = self
        vc.delegate = self
        vc.isInfoEditing = true
        navigationController.pushViewController(vc, animated: true)
    }
}

extension MyPageCoordinator: UserInfoVCDelegate{
    func backButtonDidTap() {
        navigationController.popViewController(animated: true)
    }
    
    func changePasswordButtonDidTap() {
       startChangePasswordVC()
    }
    
    func withdrawalOKButtonDidTap() {
        parentCoordinator?.start()
        parentCoordinator?.coordinators.removeAll(where: { $0 === self })
    }
    
    func logoutOKButtonDidTap() {
        withdrawalOKButtonDidTap()
    }
    
}

extension MyPageCoordinator: ChangePasswordVCDelegate{
    func changePasswordCompleted() {
        navigationController.popViewController(animated: true)
    }
}

