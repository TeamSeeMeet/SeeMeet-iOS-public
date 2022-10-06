import UIKit
import RxSwift
import RxCocoa
import RxRelay

class SelectedDateSheet: UIView {
    
    // MARK: - UI Components
    
    private let grabber: UIView = UIView().then {
        $0.backgroundColor = UIColor.grey02
        $0.layer.cornerRadius = 2
    }
    
    let titleLabel: UILabel = UILabel().then {
        $0.text = "선택한 날짜"
        $0.font = UIFont.hanSansMediumFont(ofSize: 16)
        $0.textColor = UIColor.grey06
    }
    private let touchAreaView: UIView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    let selectedCountLabel: UILabel = UILabel().then {
        $0.text = "0/4"
        $0.textColor = UIColor.pink01
        $0.font = UIFont.dinProMediumFont(ofSize: 14)
    }
    
    let tableView: UITableView = UITableView(frame: CGRect.zero, style: .plain).then {
        $0.register(SelectedDateSheetTVC.self, forCellReuseIdentifier: SelectedDateSheetTVC.identifier)
        $0.rowHeight = 73 * heightRatio
        $0.isScrollEnabled = false
        $0.isUserInteractionEnabled = true
    }
    
    // MARK: - properties
    
    static let identifier: String = "SelectedDateSheet"
    
    // Snap 효과를 위한 케이스
    enum SheetViewState {
        case expanded // 펼침
        case folded // 접음
    }
    
    private let disposeBag = DisposeBag()
    private var tableViewCellDisposeBag: DisposeBag? = DisposeBag()
    
    private lazy var panGesture = UIPanGestureRecognizer().then {
        $0.delaysTouchesBegan = false
        $0.delaysTouchesEnded = false
        addGestureRecognizer($0)
    }
    // 퍌친 상태 Top
    private lazy var sheetPanMinTopConstant: CGFloat = UIScreen.getDeviceHeight() - 482 * heightRatio
    // 접힌 상태 Top
    private lazy var sheetPanMaxTopConstant: CGFloat = UIScreen.getDeviceHeight() - 172 * heightRatio
    // 드래그 하기 전에 Bottom Sheet의 top Constraint value를 저장하기 위한 프로퍼티
    private lazy var sheetPanStartingTopConstant: CGFloat = frame.origin.y
    
    let rx_requestIsEnabled = PublishRelay<Bool>()
    
    // MARK: - Life Cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setAutoLayouts()
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setAutoLayouts()
    }
    
    // MARK: - func
    
    private func setAutoLayouts() {
        isUserInteractionEnabled = true
        backgroundColor = .white
        layer.cornerRadius = 20
        getShadowView(color: UIColor.black.cgColor, masksToBounds: false, shadowOffset: CGSize(width: 0, height: -3), shadowRadius: 3, shadowOpacity: 0.1)
        
        addSubviews([grabber, titleLabel, selectedCountLabel, touchAreaView, tableView])
        
        grabber.snp.makeConstraints {
            $0.height.equalTo(4 * heightRatio)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(29 * widthRatio)
            $0.top.equalToSuperview().offset(6 * heightRatio)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(30 * heightRatio)
            $0.leading.equalToSuperview().offset(20 * widthRatio)
        }
        
        touchAreaView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(60 * heightRatio)
        }
        
        selectedCountLabel.snp.makeConstraints {
            $0.leading.equalTo(titleLabel.snp.trailing).offset(7 * widthRatio)
            $0.top.equalToSuperview().offset(31 * heightRatio)
        }
        
        tableView.backgroundColor = .clear
        tableView.separatorColor = .clear
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(19 * widthRatio)
            $0.trailing.equalToSuperview().offset(-6 * widthRatio)
            $0.top.equalTo(titleLabel.snp.bottom).offset(1 * heightRatio)
            $0.height.equalTo(292 * heightRatio)
        }
    }
    
    private func setupViews() {
        panGesture.rx.event
            .asDriver()
            .drive(onNext: { [weak self] event in
                guard let self = self else { return }
                let transition = event.translation(in: self)
                
                switch event.state {
                case .began:
                    self.sheetPanStartingTopConstant = self.frame.origin.y
                case .changed:
                    if self.sheetPanStartingTopConstant + transition.y > self.sheetPanMinTopConstant {
                        self.frame = CGRect(x: 0, y: self.sheetPanStartingTopConstant + transition.y, width: self.frame.width, height: self.frame.height)
                    }
                case .ended:
                    let nearestValue = self.nearest(to: self.frame.origin.y, inValues: [self.sheetPanMinTopConstant, self.sheetPanMaxTopConstant])
                    
                    if nearestValue == self.sheetPanMinTopConstant { // 시트를 펼쳐야 한다
                        self.showSheet(atState: .expanded)
                    } else { // 시트를 접어야 한다
                        self.showSheet(atState: .folded)
                    }
                default:
                    break
                }
            })
            .disposed(by: disposeBag)
    }
    
    /// 여러 후보 값들 중 어느 것이 가장 number값에 가까운지 판별하는 메서드.
    /// - Parameters:
    ///   - number: 기준 값
    ///   - values: 후보값들
    /// - Returns: 후보값들 중 가장 기준 값에 가까운 값
    private func nearest(to number: CGFloat, inValues values: [CGFloat]) -> CGFloat {
        guard let nearestVal = values.min(by: { abs(number - $0) < abs(number - $1) }) else { return number }
        return nearestVal
    }
    
    func showSheet(atState: SheetViewState = .folded) {
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseIn, animations: {
            self.layoutIfNeeded()
            if atState == .folded {
                self.frame = CGRect(x: 0, y: self.sheetPanMaxTopConstant, width: self.frame.width, height: self.frame.height)
            } else {
                self.frame = CGRect(x: 0, y: self.sheetPanMinTopConstant, width: self.frame.width, height: self.frame.height)
            }
        }, completion: { _ in // 바뀐 시트 상태로 오토레이아웃을 업데이트 시킨다. 해주지 않으면 티켓 뷰 추가시 강제로 내려가는 버그 발생.
            let currentTop = self.frame.minY
            self.snp.remakeConstraints {
                $0.top.equalTo(currentTop)
                $0.trailing.leading.equalToSuperview()
                $0.height.equalTo(482 * heightRatio)
            }
        })
    }
    
    func addSelectedTimeData(date: String, start: String, end: String) { // 선택지의 데이터 추가 처리
        let currentDataCount = PostRequestPlansService.sharedParameterData.date.count
        if currentDataCount < 4 {
            PostRequestPlansService.sharedParameterData.date.append(date)
            PostRequestPlansService.sharedParameterData.start.append(start)
            PostRequestPlansService.sharedParameterData.end.append(end)
            
            selectedCountLabel.text = "\(PostRequestPlansService.sharedParameterData.date.count)/4"
            tableView.reloadData()
            rx_requestIsEnabled.accept(true)
        }
    }
}

// MARK: - extensions

extension SelectedDateSheet: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        PostRequestPlansService.sharedParameterData.date.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: SelectedDateSheetTVC = tableView.dequeueReusableCell(withIdentifier: SelectedDateSheetTVC.identifier, for: indexPath) as? SelectedDateSheetTVC else { return UITableViewCell() }
        
        let cellData = PostRequestPlansService.sharedParameterData
        
        cell.tag = indexPath.row
        cell.dateLabel.text = cellData.date[indexPath.row].replacingOccurrences(of: "-", with: ".")
        
        let dateFormatter: DateFormatter = DateFormatter().then {
            $0.dateFormat = "HH:mm"
            $0.locale = Locale(identifier: "ko_KR")
            $0.timeZone = TimeZone(identifier: "ko_KR")
        }
        
        guard let startDate = dateFormatter.date(from: cellData.start[indexPath.row]),
              let endDate = dateFormatter.date(from: cellData.end[indexPath.row]) else { return UITableViewCell() }
        dateFormatter.dateFormat = "a hh:mm"
        
        cell.timeLabel.text = "\(dateFormatter.string(from: startDate)) ~ \(dateFormatter.string(from: endDate))"
        
        cell.removeButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] in
                PostRequestPlansService.sharedParameterData.removeTimeData(at: cell.tag)
                self?.selectedCountLabel.text = "\(PostRequestPlansService.sharedParameterData.date.count)/4"
                if PostRequestPlansService.sharedParameterData.date.count == 0 {
                    self?.rx_requestIsEnabled.accept(false)
                }
                self?.tableViewCellDisposeBag = nil // 날려주지 않으면 셀 재사용으로 인해 중복으로 호출되게 된다.
                self?.tableViewCellDisposeBag = DisposeBag()
                tableView.reloadData()
            })
            .disposed(by: tableViewCellDisposeBag!)
        
        return cell
    }
}
