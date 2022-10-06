import UIKit
import RxSwift
import RxCocoa

class SelectedDateSheetTVC: UITableViewCell {
    
    // MARK: - UI Components
    
    private let ticketBodyView: UIView = UIView().then {
        $0.backgroundColor = UIColor.pink02
        $0.layer.cornerRadius = 10
    }
    
    let dateLabel: UILabel = UILabel().then {
        $0.font = UIFont.dinProBoldFont(ofSize: 18)
        $0.textColor = UIColor.grey06
    }
    
    let timeLabel: UILabel = UILabel().then {
        $0.font = UIFont.dinProRegularFont(ofSize: 14)
        $0.textColor = UIColor.grey06
        $0.text = "오전 11:00 ~ 오후 11:00" //임시
    }
    
    let removeButton: UIButton = UIButton().then {
        $0.setImage(UIImage(named: "btn_remove_black"), for: .normal)
    }
    
    // MARK: - properties
    
    static let identifier: String = "SelectedDateSheetTVC"
    
    private let disposeBag = DisposeBag()

    // MARK: - Life Cycle

    override func awakeFromNib() {
        super.awakeFromNib()
        setAutoLayouts()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setAutoLayouts()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setAutoLayouts()
    }
    
    // MARK: - Layouts
    
    private func setAutoLayouts() {
        isUserInteractionEnabled = true
        contentView.addSubviews([ticketBodyView, removeButton]) //컨텐트 뷰에 올려야 버튼 터치 가능해진다
        ticketBodyView.addSubviews([dateLabel, timeLabel])
        
        ticketBodyView.snp.makeConstraints {
            $0.height.equalTo(53 * heightRatio)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-21 * widthRatio)
            $0.bottom.equalToSuperview()
        }
        
        dateLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(46 * CGFloat(widthRatio))
            $0.centerY.equalToSuperview()
        }
        
        timeLabel.snp.makeConstraints {
            $0.trailing.equalTo(-33 * widthRatio)
            $0.centerY.equalToSuperview()
        }
        
        removeButton.snp.makeConstraints {
            $0.width.height.equalTo(40 * widthRatio)
            $0.trailing.equalToSuperview().offset(-4 * widthRatio)
            $0.bottom.equalToSuperview().offset(-33 * heightRatio)
        }
    }
}
