//
//  LoginCoordinator.swift
//  SeeMeet
//
//  Created by 김인환 on 2022/06/12.
//

import UIKit

class LoginCoordinator: Coordinator {
    weak var parentCoordinator: Coordinator?
    var coordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        startMainLoginVC()
    }
    
    func startMainLoginVC() {
        guard let vc = UIStoryboard(name: "MainLogin", bundle: nil).instantiateViewController(withIdentifier: "MainLoginVC") as? MainLoginVC else {return}
        vc.coordinator = self
        vc.delegate = self
        navigationController.setViewControllers([vc], animated: true)
    }
    
    func startEmailLoginVC(){
        guard let vc = UIStoryboard(name: "EmailLogin", bundle: nil).instantiateViewController(withIdentifier: "EmailLoginVC") as? EmailLoginVC else {return}
        vc.delegate = self
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
        
    }
    func startProfileRegisterVC(accessToken: String, refreshToken: String, name: String?, isAppleLogin: Bool) {
        guard let vc = UIStoryboard(name: "ProfileRegister", bundle: Bundle.main).instantiateViewController(withIdentifier: "ProfileRegisterVC") as? ProfileRegisterVC else { return }
        vc.do {
            $0.accessTokenToSet = accessToken
            $0.refreshTokenToSet = refreshToken
            $0.nameToSet = name
            $0.isAppleLogin = isAppleLogin
        }
        vc.delegate = self
        navigationController.pushViewController(vc, animated: true)
    }
    
    func startRegisterScene(){
        let coordinator = RegisterCoordinator(navigationController: navigationController)
        coordinator.parentCoordinator = self.parentCoordinator
        parentCoordinator?.coordinators.append(coordinator)
        coordinator.start()
        parentCoordinator?.coordinators.removeAll(where: { $0 === self })
    }
    
    
}

extension LoginCoordinator: MainLoginVCDelegate, EmailLoginVCDelegate, ProfileRegisterVCDelegate {
    func needRegister(accessToken: String, refreshToken: String, name: String?, isAppleLogin: Bool) {
        startProfileRegisterVC(accessToken: accessToken, refreshToken: refreshToken, name: name, isAppleLogin: isAppleLogin)
    }
    
    func backButtonDidTap() {
        if self.navigationController.visibleViewController is MainLoginVC {
            loginCompleted()
        } else {
            navigationController.popViewController(animated: true)
        }
    }
    
    func emailRegisterDidTap() {
        startRegisterScene()
    }
    
    func emailLoginDidTap() {
        startEmailLoginVC()
    }
    
    func closeButtonDidTap() {
        loginCompleted()
    }
    
    func loginCompleted() {
        if parentCoordinator is AppCoordinator {
            self.navigationController.presentingViewController?.dismiss(animated: true)
            self.navigationController.viewControllers.removeAll()
        } else if parentCoordinator is HomeCoordinator {
            parentCoordinator?.start()
        }
        parentCoordinator?.coordinators.removeAll(where: { $0 === self })
    }
    
    func registerBackButtonDidTap() {
        backButtonDidTap()
    }
}
