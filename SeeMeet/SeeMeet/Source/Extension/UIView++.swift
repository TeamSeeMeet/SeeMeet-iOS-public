//
//  UIView++.swift
//  SeeMeet_iOS
//
//  Created by 박익범 on 2022/01/05.
//

import UIKit

extension UIView {
    func addSubviews(_ views: [UIView]) {
        views.forEach { self.addSubview($0) }
    }
    
    func removeAllSubViews() {
        self.subviews.forEach { $0.removeFromSuperview() }
    }

    func getDeviceHeight() -> Int {
        return Int(UIScreen.main.bounds.height)
        }
    func getDeviceWidth() -> Int{
        return Int(UIScreen.main.bounds.width)
    }
    
    func dismissKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer =
            UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        tap.cancelsTouchesInView = false
        self.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        self.endEditing(true)
    }
    
    func getShadowView(color : CGColor, masksToBounds : Bool, shadowOffset : CGSize, shadowRadius : Int, shadowOpacity : Float) {
        layer.shadowColor = color
        layer.masksToBounds = masksToBounds
        layer.shadowOffset = shadowOffset
        layer.shadowRadius = CGFloat(shadowRadius)
        layer.shadowOpacity = shadowOpacity
    }
    func removeShadowView() {
        layer.shadowOpacity = 0
    }
    
    func makeToastAnimation(message: String){
        let toastMessage = ToastMessageView(message: message)
        UIApplication.shared.windows.filter { $0.isKeyWindow }.first?.addSubview(toastMessage)
        toastMessage.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
        UIView.animate(withDuration: 1.0, animations: {
            toastMessage.alpha = 0
        }, completion: {_ in toastMessage.removeFromSuperview() })
    }
}
