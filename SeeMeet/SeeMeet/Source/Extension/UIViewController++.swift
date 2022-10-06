//
//  UIViewController++.swift
//  SeeMeet_iOS
//
//  Created by 박익범 on 2022/01/05.
//

import UIKit

extension UIViewController {
    
    func makeRequestAlert(title : String,
                          message : String,
                          okAction : ((UIAlertAction) -> Void)?,
                          cancelAction : ((UIAlertAction) -> Void)? = nil,
                          completion : (() -> Void)? = nil){
        
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        let alertViewController = UIAlertController(title: title, message: message,
                                                    preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "예", style: .default, handler: okAction)
        alertViewController.addAction(okAction)
        
        
        let cancelAction = UIAlertAction(title: "아니오", style: .default, handler: cancelAction)
        alertViewController.addAction(cancelAction)
        
        
        self.present(alertViewController, animated: true, completion: completion)
    }
    
    
    func makeAlert(title : String,
                   message : String,
                   okAction : ((UIAlertAction) -> Void)? = nil,
                   completion : (() -> Void)? = nil){
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        let alertViewController = UIAlertController(title: title, message: message,
                                                    preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "확인", style: .default, handler: okAction)
        alertViewController.addAction(okAction)
        
        
        self.present(alertViewController, animated: true, completion: completion)
    }
    
    func makeAlert(title : String?,
                   message : String?,
                   okAction : ((UIAlertAction) -> Void)? = nil,
                   completion : (() -> Void)? = nil){
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        let alertViewController = UIAlertController(title: "", message: message,
                                                    preferredStyle: .alert)
        
        
        
        let okAction = UIAlertAction(title: "확인", style: .default, handler: okAction)
        alertViewController.addAction(okAction)
        
        
        self.present(alertViewController, animated: true, completion: completion)
    }
    
    func addBackButton() {
        let backButton = UIBarButtonItem(image: UIImage(named: "btn_back"), style: .plain, target: self, action: #selector(popVC))
        backButton.tintColor = .grey06
        self.navigationItem.leftBarButtonItem = backButton
    }
    
    @objc func popVC() {
        self.navigationController?.popViewController(animated: true)
    }
}
