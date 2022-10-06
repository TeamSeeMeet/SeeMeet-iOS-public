//
//  RegisterCoordinator.swift
//  SeeMeet
//
//  Created by 김인환 on 2022/06/12.
//

import UIKit

class RegisterCoordinator: Coordinator {
    weak var parentCoordinator: Coordinator?
    var coordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        startEmailRegisterVC()
    }
    
    func startEmailRegisterVC(){
        guard let vc = UIStoryboard(name: "EmailRegister", bundle: nil).instantiateViewController(withIdentifier: "EmailRegisterVC") as? EmailRegisterVC else {return}
        vc.delegate = self
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
    
    func startProfileRegisterVC(accessToken: String, refreshToken: String ,email: String){
        guard let vc = UIStoryboard(name: "ProfileRegister", bundle: Bundle.main).instantiateViewController(withIdentifier: "ProfileRegisterVC") as? ProfileRegisterVC else { return }
        vc.do {
            $0.accessTokenToSet = accessToken
            $0.email = email
            $0.refreshTokenToSet = refreshToken
            $0.delegate = self
        }
        navigationController.pushViewController(vc, animated: true)
    }
}

extension RegisterCoordinator: EmailRegisterVCDelegate{
    func backButtonDidTap() {
        navigationController.popViewController(animated: true)
    }
    
    func closeButtonDidTap() {
        self.navigationController.presentingViewController?.dismiss(animated: true)
        self.navigationController.viewControllers.removeAll()
        parentCoordinator?.start()
        parentCoordinator?.coordinators.removeAll(where: { $0 === self })
    }
    
    func nextButtonDidTap(accessToken: String, refreshToken: String, email: String) {
        startProfileRegisterVC(accessToken: accessToken, refreshToken: refreshToken, email: email)
    }
}


extension RegisterCoordinator: ProfileRegisterVCDelegate{
    func registerBackButtonDidTap(){
        let viewControllerStack = navigationController.viewControllers
        for viewController in viewControllerStack {
            if let loginView = viewController as? MainLoginVC {
                navigationController.popToViewController(loginView, animated: true)
            }
        }
    }
}

