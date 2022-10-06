//
//  UICollectionView++.swift
//  SeeMeet_iOS
//
//  Created by 박익범 on 2022/01/05.
//
import UIKit

extension UICollectionView {
    public func registerCustomXib(xibName: String){
        let xib = UINib(nibName: xibName, bundle: nil)
        self.register(xib, forCellWithReuseIdentifier: xibName)
    }
}
