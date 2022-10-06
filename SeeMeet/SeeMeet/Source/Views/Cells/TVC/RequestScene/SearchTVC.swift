//
//  searchTVC.swift
//  SeeMeet
//
//  Created by 이유진 on 2022/01/14.
//

import UIKit
import Then
import SnapKit

class SearchTVC: UITableViewCell {
    
    // MARK: - UI Components
    
    private let profileImageView: UIImageView = UIImageView().then{
        $0.image = UIImage(named: "img_profile")
    }
    private let nameLabel: UILabel = UILabel().then{
        $0.font = UIFont.hanSansMediumFont(ofSize: 14)
    }
    
    // MARK: - Properties
    
    static let identifier: String = "SearchTVC"
    
    private var name: String = ""
    var data: FriendsData?
    
    // MARK: - Life Cycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addContentView()
        setAutolayouts()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addContentView()
        setAutolayouts()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    // MARK: - Layouts
    
    private func addContentView() {
        addSubviews([profileImageView,nameLabel])
    }
    
    private func setAutolayouts() {
        profileImageView.snp.makeConstraints{
            $0.leading.centerY.equalToSuperview()
            $0.width.height.equalTo(40 * widthRatio)
            
        }
        nameLabel.snp.makeConstraints {
            $0.leading.equalTo(profileImageView.snp.trailing).offset(18 * widthRatio)
            $0.centerY.equalToSuperview()
        }

    }
    
    // MARK: - Interface
    
    func setData(data: FriendsData) {
        self.data = data
        nameLabel.text = data.username
    }

}
