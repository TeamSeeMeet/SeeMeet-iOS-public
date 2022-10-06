//
//  Coordinator.swift
//  SeeMeet
//
//  Created by 김인환 on 2022/05/21.
//

import Foundation
import UIKit

protocol Coordinator: AnyObject {
    var coordinators: [Coordinator] { get set } // 하위 코디네이터들을 관리하는 프로퍼티
    func start() // 해당 코디네이터의 root VC를 띄우는 메서드를 지정한다.
}
