import UIKit
import Then
import SnapKit
import FSCalendar

protocol CalendarVCDelegate{
    func plansDidTap(plansID: Int?)
}
class CalendarVC: UIViewController {
    
    // MARK: - UI Components
    
    static let identifier: String = "CalendarVC"
    
    private let calendarHeaderLabel: UILabel = UILabel().then {
        $0.textColor = UIColor.pink01
        $0.font = UIFont.dinProBoldFont(ofSize: 22)
    }
    
    let calendar: FSCalendar = FSCalendar().then {
        $0.select($0.today)
        $0.scope = .month
        $0.locale = Locale(identifier: "ko_KR")
        $0.scrollDirection = .horizontal
        $0.allowsMultipleSelection = false
        $0.calendarHeaderView.isHidden = true
        $0.weekdayHeight = CGFloat(55.0 * heightRatio)
        
        $0.headerHeight = CGFloat.zero
        $0.appearance.titleFont = UIFont.dinProRegularFont(ofSize: 16)
        $0.appearance.weekdayFont = UIFont.dinProRegularFont(ofSize: 16)
        $0.appearance.subtitleFont = UIFont.dinProRegularFont(ofSize: 16)
        $0.appearance.weekdayTextColor = UIColor.grey05
        $0.appearance.titleDefaultColor = UIColor.grey06
        $0.appearance.todayColor = UIColor.pink01
        $0.appearance.eventDefaultColor = UIColor.pink01
        $0.appearance.selectionColor = UIColor.grey06
        $0.appearance.eventSelectionColor = UIColor.pink01
    }
    
    private let bottomCollectionContainerView: UIView = UIView().then {
        $0.backgroundColor = UIColor.grey01
    }
    
    private let dateAndDayLabel: UILabel = UILabel().then {
        $0.font = UIFont.hanSansBoldFont(ofSize: 18)
        $0.textColor = UIColor.grey06
        
        let nowDate = Date()
        let currentMonth = Calendar.current.component(.month, from: nowDate)
        let currentDate = Calendar.current.component(.day, from: nowDate)
        $0.text = "\(currentMonth)월 \(currentDate)일 \(Date.getCurrentKoreanWeekDay())요일"
    }
    
    private var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewLayout())
        let flowlayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout().then {
            $0.scrollDirection = .horizontal
            $0.minimumInteritemSpacing = CGFloat(16)
            $0.sectionInset = UIEdgeInsets(top: 0, left: 20.0 * widthRatio, bottom: 11 * heightRatio, right: 20 * widthRatio)
            $0.itemSize = CGSize(width: 223.0 * widthRatio, height: 134.0 * heightRatio)
        }

        collectionView.setCollectionViewLayout(flowlayout, animated: false)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.bounces = true
        collectionView.backgroundColor = .none
        collectionView.register(CalendarPlansCVC.self, forCellWithReuseIdentifier: CalendarPlansCVC.identifier)

        return collectionView
    }()
    
    // MARK: - Properties
    
    weak var coordinator: Coordinator?
    
    private var planDatas: [Plan] = []
    private var selectedDatas: [Plan]?
    var delegate: CalendarVCDelegate?
    
    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setAutoLayouts()
        configUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        requestCalendarData(year: Date.getCurrentYear(), month: Date.getCurrentMonth())
        tabBarController?.tabBar.isHidden = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    // MARK: - Layouts
    
    private func setAutoLayouts() {
        navigationController?.navigationBar.isHidden = true
        
        layoutCalendarWeekdaySeparator()

        addSubviewAndConstraints(add: calendarHeaderLabel, to: view) {
            $0.leading.equalToSuperview().offset(20 * widthRatio)
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(25 * heightRatio)
        }
        
        // 화면 작은 애들은 추후 수정 필요...?
        addSubviewAndConstraints(add: calendar, to: view) {
            $0.top.equalTo(calendarHeaderLabel.snp.bottom).offset(9 * heightRatio)
            $0.centerX.equalTo(view.snp.centerX)
            $0.width.equalTo(378 * widthRatio)
            $0.height.equalTo(418 * heightRatio)
        }
        
        addSubviewAndConstraints(add: bottomCollectionContainerView, to: view) {
            $0.top.equalTo(calendar.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            if UIScreen.hasNotch {
                $0.bottom.equalTo(view.snp.bottom).offset(88 * widthRatio)
            } else {
                $0.bottom.equalTo(view.snp.bottom).offset(77 * widthRatio)
            }
        }
        
        addSubviewAndConstraints(add: dateAndDayLabel, to: bottomCollectionContainerView) {
            $0.leading.equalToSuperview().offset(20 * widthRatio)
            $0.top.equalToSuperview().offset(16 * heightRatio)
        }
        
        addSubviewAndConstraints(add: collectionView, to: bottomCollectionContainerView) {
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(157 * heightRatio)
            $0.top.equalTo(dateAndDayLabel.snp.bottom).offset(16 * heightRatio)
        }
    }
    
    private func layoutCalendarWeekdaySeparator() {
        let separator: UIView = UIView()
        separator.backgroundColor = UIColor.grey01
        calendar.addSubview(separator)
        separator.snp.makeConstraints {
            $0.top.equalTo(calendar.calendarWeekdayView.snp.bottom)
            $0.leading.equalTo(20 * widthRatio)
            $0.trailing.equalTo(-20 * widthRatio)
            $0.height.equalTo(1 * heightRatio)
        }
    }
    
    // MARK: - Networks
    
    private func requestCalendarData(year: String, month: String) {
        CalendarService.shared.getPlanDatas(year: year, month: month) { [weak self] responseData in
            switch responseData {
            case .success(let response):
                guard let response = response as? MonthlyPlansResponseModel,
                      let data = response.data,
                      let self = self else { return }
                
                if let datasToAppend = response.data?.filter({
                    !self.planDatas.contains($0)
                }) {
                    self.planDatas.append(contentsOf: datasToAppend)
                }
                
                self.displayPlansCollectionView()
                self.calendar.reloadData()
            case .requestErr(let msg):
                print(msg)
            case .pathErr:
                print("path error")
            case .serverErr:
                print("server error")
            case .networkFail:
                print("network Fail")
            }
        }
    }
    
    // MARK: - Custom Methods
    
    private func configUI() {
        calendar.delegate = self
        calendar.dataSource = self
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        view.backgroundColor = UIColor.white
    }
    
    private func addSubviewAndConstraints(add subView: UIView, to superView: UIView, snapkitClosure closure: (ConstraintMaker) -> Void) {
        superView.addSubview(subView)
        subView.snp.makeConstraints(closure)
    }
    
    func displayPlansCollectionView(at date: Date = Date()) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let cellDay = formatter.string(from: date)
        selectedDatas = planDatas.filter {
            $0.date.components(separatedBy: "T").first == cellDay
        }
        collectionView.reloadData()
    }
}

// MARK: - Extension

extension CalendarVC: FSCalendarDataSource {
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        guard let cellDay: String = formatter.string(from: date).components(separatedBy: "T").first else { return 0}
        
        let cellPlans = planDatas.filter {
            $0.date.components(separatedBy: "T").first == cellDay
        }
        
        if cellPlans != nil && cellPlans.count != 0 {
            return 1
        } else {
            return 0
        }
    }
}

// MARK: - Extensions

extension CalendarVC: FSCalendarDelegate {
    func calendar(_ calendar: FSCalendar, willDisplay cell: FSCalendarCell, for date: Date, at monthPosition: FSCalendarMonthPosition) {
        let currentPage = calendar.currentPage
        let currentYear = Calendar.current.component(.year, from: currentPage)
        let currentMonth = Calendar.current.component(.month, from: currentPage)
        
        calendarHeaderLabel.text = "\(currentYear)년 \(currentMonth)월"
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        let selectedMonth = Calendar.current.component(.month, from: date)
        let selectedDate = Calendar.current.component(.day, from: date)

        dateAndDayLabel.text = "\(selectedMonth)월 \(selectedDate)일 \(Date.getKoreanWeekDay(from: date))요일"
        
        // 선택된 날의 약속 목록 설정
        if monthPosition == .current {
            displayPlansCollectionView(at: date)
        }
    }
    
    func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
        // 현재 달과 선택된 날이 다르면 캘린더 페이지 바뀌게 하는 로직
        if monthPosition != .current {
            calendar.setCurrentPage(date, animated: true)
            return false
        } else {
            return true
        }
    }
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) { // 페이지 바뀌면 바뀐 페이지의 일정 다시 요청
        let currentPage = calendar.currentPage
        let currentYear = String(Calendar.current.component(.year, from: currentPage))
        let currentMonth = String(Calendar.current.component(.month, from: currentPage))
        requestCalendarData(year: currentYear, month: currentMonth)
    }
}

extension CalendarVC: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedDatas?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CalendarPlansCVC", for: indexPath) as? CalendarPlansCVC else { return UICollectionViewCell() }
        
        // 약속 데이터 받아와 넣기
        let planData = selectedDatas?[indexPath.row]
        cell.headerTitle.text = planData?.invitationTitle
        
        var hourString = ""
        let startHourComponents = planData?.start.components(separatedBy: ":")
        let endHourComponents = planData?.end.components(separatedBy: ":")
        
        guard let startHourString = startHourComponents?.first,
              let startMinuteString = startHourComponents?[1],
              let endHourString = endHourComponents?.first,
              let endMinuteString = endHourComponents?[1],
              let startHour = Int(startHourString),
              let endHour = Int(endHourString)
        else { return UICollectionViewCell() }
        
        hourString = startHour < 12 ? "오전 \(startHour):\(startMinuteString)" : "오후 \(startHour):\(startMinuteString)"
        hourString += endHour < 12 ? " - 오전 \(endHour):\(endMinuteString)" : " - 오후 \(endHour):\(endMinuteString)"
        
        cell.hourLabel.text = hourString
        var namesToShow: [String] = planData?.users.map { $0.username } ?? []
        if namesToShow.count > 3 { // 일단 최대 3개만 보여줍시다.
            namesToShow.removeSubrange(3...namesToShow.count-1)
        }
        cell.namesToShow = namesToShow
        return cell
    }
}

extension CalendarVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let planData = selectedDatas?[indexPath.row]
        guard let cell = collectionView.cellForItem(at: indexPath) as? CalendarPlansCVC else { return }
        delegate?.plansDidTap(plansID: planData?.planID)
    }
}
