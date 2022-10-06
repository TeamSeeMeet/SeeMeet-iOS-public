//
//  SearchInputFieldCVC.swift
//  SeeMeet
//
//  Created by 김인환 on 2022/07/08.
//

import UIKit
import SnapKit

class SearchInputFieldCVC: UICollectionViewCell {
    
    // MARK: - UI Components
    
    let inputField = UITextField().then {
        $0.backgroundColor = .clear
        $0.font = UIFont.hanSansRegularFont(ofSize: 14)
    }
    
    // MARK: - Properties
    
    static let identifier = "SearchInputFieldCVC"
        
    // MARK: - Life Cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setAutoLayouts()
        isUserInteractionEnabled = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    
    private func setAutoLayouts() {
        self.contentView.addSubview(inputField)
        inputField.snp.makeConstraints {
            $0.width.height.equalToSuperview()
        }
    }
}
