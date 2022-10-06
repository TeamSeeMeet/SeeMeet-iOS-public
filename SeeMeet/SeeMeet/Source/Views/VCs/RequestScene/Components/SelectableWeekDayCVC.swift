import UIKit

/// 셀의 상태를 관리하기 위한 열거타입
enum SelectableDayCVCState {
    case invalid
    case unselected
    case selected
}

class SelectableWeekDayCVC: UICollectionViewCell {
    
    // MARK: - UI Components
    
    private let cellView = UIView().then {
        $0.tintColor = UIColor.white
        $0.layer.cornerRadius = 10
        $0.backgroundColor = UIColor.white
    }
    
    private let weekDayLabel = UILabel().then {
        $0.font = UIFont.hanSansMediumFont(ofSize: 13)
        $0.textColor = UIColor.grey04
    }
    
    private let dayLabel = UILabel().then {
        $0.font = UIFont.hanSansBoldFont(ofSize: 13)
        $0.textColor = UIColor.grey06
    }
    
    private let pinkDotView = UIView().then {
        $0.backgroundColor = UIColor.pink01
    }
    
    private let touchAreaView: UIView = UIView().then {
        $0.backgroundColor = UIColor.clear
    }

    // MARK: - Properties
    
    static let identifier: String = "SelectableWeekDayCVC"

    
    /// 표시할 날짜
    var dateToShow: Date? {
        didSet {
            if let dateToShow = dateToShow {
                weekDayLabel.text = Date.getKoreanWeekDay(from: dateToShow)
                dayLabel.text = "\(dateToShow.day)"
            }
        }
    }
    /// 해당 날짜에 약속이 있는지 여부
    var isScheduled = Bool() {
        didSet {
            pinkDotView.isHidden = !isScheduled
        }
    }
    /// 셀의 상태를 관리할 프로퍼티
    var status: SelectableDayCVCState = .unselected {
        didSet {
            guard let date = dateToShow else { return }

            switch status {
            case .invalid:
                isUserInteractionEnabled = false
                cellView.layer.borderWidth = 0
                cellView.backgroundColor = .grey02
                weekDayLabel.textColor = .grey03
                dayLabel.textColor = .grey03
                
            case .unselected:
                isUserInteractionEnabled = true
                if Calendar.current.isDateInToday(date) {
                    cellView.layer.borderWidth = 0
                    cellView.backgroundColor = UIColor.pink01
                    weekDayLabel.textColor = .white
                    dayLabel.textColor = .white
                } else {
                    cellView.layer.borderWidth = 0
                    cellView.backgroundColor = UIColor.white
                    weekDayLabel.textColor = .grey04
                    dayLabel.textColor = .grey06
                }
            case .selected:
                isUserInteractionEnabled = true
                if Calendar.current.isDateInToday(date) { // 이 셀이 만약 '오늘'을 나타낸다면
                    cellView.layer.borderColor = UIColor.black.cgColor
                    cellView.layer.borderWidth = 1
                    cellView.backgroundColor = UIColor.pink01
                    weekDayLabel.textColor = .white
                    dayLabel.textColor = .white
                } else {
                    cellView.backgroundColor = UIColor.black
                    weekDayLabel.textColor = .white
                    dayLabel.textColor = .white
                }
            }
        }
    }
    // MARK: - initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setAutoLayouts()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setAutoLayouts()
    }
    
    private func setAutoLayouts() {
        addSubviews([cellView,pinkDotView])
        cellView.addSubviews([weekDayLabel,dayLabel])
        
        
//        self.snp.makeConstraints({
//            $0.width.equalTo(42 * widthRatio)
//            $0.height.equalTo(79 * heightRatio)
//        })
        
        cellView.snp.makeConstraints{
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(70 * heightRatio)
        }
        
        weekDayLabel.snp.makeConstraints{
            $0.top.equalToSuperview().offset(13 * heightRatio)
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(-11 * heightRatio)
        }
        
        dayLabel.snp.makeConstraints{
            $0.top.equalTo(weekDayLabel.snp.bottom).offset(8 * heightRatio)
            $0.centerX.equalToSuperview()
        }
        pinkDotView.snp.makeConstraints{
            $0.top.equalTo(cellView.snp.bottom).offset(4 * heightRatio)
            $0.centerX.equalTo(cellView.snp.centerX)
            $0.width.height.equalTo(5 * widthRatio)
        }
        
        pinkDotView.layer.cornerRadius = 5/2
        pinkDotView.isHidden = true
    }
}
