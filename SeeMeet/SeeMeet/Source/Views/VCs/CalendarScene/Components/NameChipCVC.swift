//
//  nameChipCVC.swift
//  SeeMeet
//
//  Created by 이유진 on 2022/08/11.
//

import UIKit

class NameChipCVC: UICollectionViewCell {
    
    private let nameLabel = UILabel().then {
        $0.font = UIFont.hanSansMediumFont(ofSize: 14)
        $0.textColor = UIColor.white
    }

    // MARK: - Properties
    
    static let identifier: String = "nameChipCVC"

    // MARK: - initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setLayout()
        setAutoLayouts()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setLayout()

        setAutoLayouts()
    }
    
    private func setLayout(){
        clipsToBounds = true
        layer.cornerRadius = 30 * heightRatio / 2
        backgroundColor = UIColor.pink01
    }
    private func setAutoLayouts() {
        
        addSubview(nameLabel)
        
        nameLabel.snp.makeConstraints{
            $0.centerX.centerY.equalToSuperview()
        }
    }
    func setData(name: String){
        nameLabel.text = name
    }
    
    func setPossibleLayout(){
        backgroundColor = UIColor.pink01
    }
    
    func setImpossibleLayout(){
        backgroundColor = UIColor.grey04
    }
    
    func setCanceledLayout(){
        backgroundColor = UIColor.grey04
        
    }
}
