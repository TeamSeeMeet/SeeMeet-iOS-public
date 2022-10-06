//
//  PlansCoordinator.swift
//  SeeMeet
//
//  Created by 김인환 on 2022/06/01.
//

import UIKit
import Then

class PlansCoordinator: Coordinator {
    weak var parentCoordinator: Coordinator?
    var coordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) { // HomeCoordinator로부터 의존성을 주입받는다.
        self.navigationController = navigationController
    }
    
    func start() {
        startPlansListVC()
    }
    
    private func startPlansListVC() {
        let vc = PlansListVC()
        vc.coordinator = self
        vc.delegate = self
        navigationController.pushViewController(vc, animated: true)
    }
    
    func startPlansSendListVC(plansID: String) {
        
        guard let vc = UIStoryboard(name: "PlansSendList", bundle: nil).instantiateViewController(withIdentifier: "PlansSendListVC") as? PlansSendListVC else { return }
        vc.coordinator = self
        vc.delegate = self
        vc.plansId = plansID
        navigationController.pushViewController(vc, animated: true)
    }
    
    func startPlansReceiveVC(plansID: String) {
        guard let vc = UIStoryboard(name: "PlansReceiveList", bundle: nil).instantiateViewController(withIdentifier: "PlansReceiveVC") as? PlansReceiveVC else { return }
        vc.coordinator = self
        vc.delegate = self
        vc.plansId = plansID
        navigationController.pushViewController(vc, animated: true)
    }
    
    func startCalendarDetailVC(planID: Int?,isCanceled: Bool){
        let coordinator = CalendarCoordinator(navigationController: navigationController)
        coordinator.parentCoordinator = self
        coordinators.append(coordinator)
        coordinator.showCalendarDetailVC(planID: planID,isCanceled: isCanceled)
        
    }
}


extension PlansCoordinator: PlansListVCDelegate {
    func sendPlansDidTap(plansID: String) {
        startPlansSendListVC(plansID: plansID)
    }
    
    func receivePlansDidTap(plansID: String) {
        startPlansReceiveVC(plansID: plansID)
    }
    
    func completedPlansDidTap(plansID: Int?, isCanceled: Bool) {
        startCalendarDetailVC(planID: plansID,isCanceled: isCanceled)
    }
    
    func backButtonDidTap() {
        navigationController.popViewController(animated: true)
    }
}

extension PlansCoordinator: PlansReceiveVCDelegate{
    
    
}

extension PlansCoordinator: PlansSendListVCDelegate{   
    
}
