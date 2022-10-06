//
//  ChipView.swift
//  SeeMeet
//
//  Created by 이유진 on 2022/01/15.
//

import UIKit
import Then
import SnapKit
import RxSwift
import RxCocoa

protocol SearchFieldTokenCVCDelegate{
    func removeButtonTap(cell: SearchFieldTokenCVC)
}

class SearchFieldTokenCVC: UICollectionViewCell {
    
    // MARK: - UI Components
    
    private let nameLabel = UILabel().then {
        $0.font = UIFont.hanSansMediumFont(ofSize: 14)
        $0.textColor = UIColor.white
        $0.numberOfLines = 1
        $0.lineBreakMode = .byTruncatingTail
    }
    
    let removeButton = UIButton().then {
        $0.setImage(UIImage(named: "property1White"), for: .normal)
    }
    
    // MARK: - Properties
    
    static let identifier = "SearchFieldTokenCVC"
    
    let disposeBag = DisposeBag()
    
    var friendsData = FriendsData()
    var delegate: SearchFieldTokenCVCDelegate?
    
    // MARK: - Life Cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configUI()
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    
    private func configUI() {
        backgroundColor = UIColor.pink01
        layer.cornerRadius = 13 * heightRatio
        nameLabel.text = friendsData.username
        
        removeButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] in
                guard let self = self else { return }
                self.delegate?.removeButtonTap(cell: self)
            })
            .disposed(by: disposeBag)
    }
    
    private func setLayout() {
        addSubviews([nameLabel,removeButton])
        
        self.snp.makeConstraints({
            $0.width.equalTo(82 * widthRatio)
            $0.height.equalTo(26 * heightRatio)
        })
        
        removeButton.snp.makeConstraints{
            $0.trailing.equalToSuperview().offset(15 * widthRatio)
            $0.centerY.equalToSuperview()
        }
        
        nameLabel.snp.makeConstraints{
            $0.leading.equalToSuperview().offset(13 * widthRatio)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(39 * widthRatio)
        }
    }
    
    // MARK: - Custom Methods
    
    func setFriendsData(friendsData: FriendsData) {
        self.friendsData = friendsData
        self.nameLabel.text = friendsData.username
        
        if friendsData.username.count > 3 {
            nameLabel.snp.updateConstraints {
                $0.width.equalTo(53 * widthRatio)
            }
        }
    }
}
