//
//  SMSearchBar.swift
//  SeeMeet
//
//  Created by 김인환 on 2022/01/13.
//

import UIKit
import SnapKit

class SMSearchBar: UISearchBar {
    
    // MARK: - initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configUI()
        setAutoLayouts()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configUI()
        setAutoLayouts()
    }
    
    // MARK: - Layout
    
    private func setAutoLayouts() {
        searchTextField.snp.makeConstraints {
            $0.leading.trailing.top.bottom.equalToSuperview()
        }
    }
    
    // MARK: - Custom Methods
    
    private func configUI() {
        setImage(UIImage(named: "ic_search"), for: .search, state: .normal)
        setImage(UIImage(named: "btn_remove"), for: .clear, state: .normal)
        backgroundColor = UIColor.grey01
        backgroundImage = UIImage()
        searchBarStyle = .minimal
        isTranslucent = false
        layer.cornerRadius = 10
        
        if let textfield = value(forKey: "searchField") as? UITextField {
            textfield.attributedPlaceholder = NSAttributedString(string: textfield.placeholder ?? "", attributes: [NSAttributedString.Key.foregroundColor: UIColor.grey04, NSAttributedString.Key.font: UIFont.hanSansRegularFont(ofSize: 14)])
            textfield.textColor = UIColor.grey06
            textfield.font = UIFont.hanSansRegularFont(ofSize: 14)
        }
    
    }
}
