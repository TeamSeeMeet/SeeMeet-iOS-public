//
//  CalendarCoordinator.swift
//  SeeMeet
//
//  Created by 김인환 on 2022/05/24.
//

import UIKit

class CalendarCoordinator: Coordinator {
    weak var parentCoordinator: Coordinator?
    var coordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    init() {
        navigationController = UINavigationController()
    }
    
    init(navigationController: UINavigationController) { // HomeCoordinator로부터 의존성을 주입받는다.
        self.navigationController = navigationController
    }
    
    func start() {
        startCalendarVC()
    }
    
    func startCalendarVC() -> UINavigationController {
        let vc = CalendarVC()
        vc.coordinator = self
        vc.delegate = self
        navigationController.setViewControllers([vc], animated: false)
        return navigationController
    }
    
    func showCalendarDetailVC(planID: Int?,isCanceled: Bool) {
        guard let detailVC = UIStoryboard(name: "CalendarDetail", bundle: nil).instantiateViewController(withIdentifier: CalendarDetailVC.identifier) as? CalendarDetailVC else { return }
        detailVC.delegate = self
        detailVC.planID = planID
        detailVC.isCanceled = isCanceled
        navigationController.pushViewController(detailVC, animated: true)

    }
}

extension CalendarCoordinator: CalendarVCDelegate{
    func plansDidTap(plansID: Int?) {
        showCalendarDetailVC(planID: plansID, isCanceled: false)
    }
}

extension CalendarCoordinator: CalendarDetailVCDelegate{
    func backButtonDidTap() {
        navigationController.popViewController(animated: true)
    }
}
