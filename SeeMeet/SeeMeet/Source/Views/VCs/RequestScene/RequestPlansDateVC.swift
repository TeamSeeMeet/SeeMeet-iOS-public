//
//  RequestPlansDate.swift
//  SeeMeet_iOS
//
//  Created by 김인환 on 2022/06/23.
//

import UIKit
import RxSwift
import RxCocoa
import RxRelay
import Then
import SnapKit

protocol RequestPlansDateVCDelegate {
    func backButtonDidTap()
    func exitButtonDidTap()
}


class RequestPlansDateVC: UIViewController {
    
    // MARK: - UI Components
    
    private let navigationAreaView = UIView()
    
    private let backButton = UIButton().then {
        $0.setBackgroundImage(UIImage(named: "btn_back"), for: .normal)
    }
    
    private let exitButton = UIButton().then {
        $0.setBackgroundImage(UIImage(named: "btn_close_bold"), for: .normal)
    }
    
    private let titleLabel = UILabel().then {
        $0.text = "약속 신청"
        $0.font = UIFont.hanSansBoldFont(ofSize: 18)
    }
    
    private let addDateView = UIView().then {
        $0.backgroundColor = UIColor.white
    }
    
    private let currentSelectedDateView = UIView().then {
        $0.backgroundColor = UIColor.grey01
        $0.layer.cornerRadius = 10
        $0.layer.borderColor = UIColor.pink01.cgColor
        $0.layer.borderWidth = 1
    }
    
    private var selectedDateLabel = UILabel().then {
        $0.font = UIFont.dinProBoldFont(ofSize:18)
        $0.textColor = UIColor.grey06
    }
    
    private let selectedTimeLabel = UILabel().then {
        $0.text = "오전 11:00 ~ 오전 12:00"
        $0.font = UIFont.dinProRegularFont(ofSize: 14)
        $0.textColor = UIColor.grey06
    }
    
    private let addDateButton = UIButton().then {
        $0.setBackgroundImage(UIImage(named: "btn_embody_on"), for: .normal)
    }
    
    private let selectDateLabel = UILabel().then {
        $0.text = "약속 신청할 날짜를 선택하세요"
        $0.font = UIFont.hanSansRegularFont(ofSize: 18)
        $0.textColor = UIColor.grey06
        let attributedString = NSMutableAttributedString(string: "약속 신청할 날짜를 선택하세요")
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.pink01, range: ($0.text! as NSString).range(of:"날짜"))
        attributedString.addAttribute(.font, value: UIFont.hanSansBoldFont(ofSize: 18), range: ($0.text! as NSString).range(of: "날짜"))
        $0.attributedText = attributedString
    }
    
    private let separateLineView = UIView().then {
        $0.backgroundColor = UIColor.grey02
    }
    
    private let scrollView = UIScrollView().then {
        $0.isPagingEnabled = false
        $0.bounces = true
        $0.showsHorizontalScrollIndicator = true
        $0.isUserInteractionEnabled = true
        $0.isScrollEnabled = true
    }
    
    private let scheduleAreaBackgroundView = UIView().then {
        $0.backgroundColor = UIColor.grey01
    }
    
    private let prevWeekButton = UIButton().then {
        $0.setBackgroundImage(UIImage(named: "leftchevron"), for: .normal)
        $0.tag = 1
    }
    
    private let yearAndWeekLabelButton = UIButton().then {
        $0.setTitle("\(Date.getCurrentYear())년 \(Date.getCurrentMonth())월", for: .normal)
        $0.setTitleColor(.pink01, for: .normal)
        $0.titleLabel?.font = UIFont.dinProMediumFont(ofSize: 18)
    }
    
    private let nextWeekButton = UIButton().then {
        $0.setBackgroundImage(UIImage(named: "rightchevron"), for: .normal)
        $0.tag = 2
    }
    
    private lazy var weekDayCollectionView = UICollectionView(frame: .zero, collectionViewLayout: .init()).then {
        $0.register(SelectableWeekDayCVC.self, forCellWithReuseIdentifier: SelectableWeekDayCVC.identifier)
        $0.isPagingEnabled = false // paging 시 어그러짐을 잡기 위해 이렇게 설정한다.
        $0.decelerationRate = .fast
        $0.showsHorizontalScrollIndicator = false
        $0.backgroundColor = .clear
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 7 * widthRatio
        layout.itemSize = CGSize(width: 42 * widthRatio, height: 80 * heightRatio)
        layout.sectionInset = UIEdgeInsets(top: 10 * heightRatio, left: 0.0, bottom: 0.0, right: 0.0)
        $0.collectionViewLayout = layout
    }
    
    private let weekdaySeparateLineView =  UIView().then {
        $0.backgroundColor = UIColor.grey02
    }
    
    private let selectedDayLabel = UILabel().then {
        $0.text = "1월 6일 금요일"
        $0.text = "\(Date.getCurrentMonth())월 \(Date.getCurrentDate())일 \(Date.getCurrentKoreanWeekDay())요일"
        $0.font = UIFont.hanSansBoldFont(ofSize: 16)
        $0.textColor = UIColor.grey06
    }
    
//    private let scheduleStackView = UIStackView().then {
//        $0.axis = .vertical
//        $0.distribution = .fill
//        $0.spacing = 10 * heightRatio
//        $0.alignment = .fill
//    }
    
    private lazy var scheduleTableView = UITableView(frame: CGRect.zero, style: .plain).then {
        $0.register(ScheduleTVC.self, forCellReuseIdentifier: ScheduleTVC.identifier)
        $0.bounces = false
        $0.backgroundColor = .clear
    }
    
    private let emptyScheduleLabel = UILabel().then {
        $0.text = "일정이 없어요"
        $0.font = UIFont.hanSansRegularFont(ofSize: 16)
        $0.textColor = UIColor.grey04
    }
    
    private let allDayView = UIView().then {
        $0.backgroundColor = UIColor.white
    }
    
    private let allDayLabel = UILabel().then {
        $0.text = "하루 종일"
        $0.font = UIFont.hanSansMediumFont(ofSize: 14)
        $0.textColor = UIColor.grey04
    }
    
    private let separateLineView2 = UIView().then{
        $0.backgroundColor = UIColor.grey02
    }
    
    private let allDaySwitch = UISwitch().then{
        $0.onTintColor = UIColor.pink01
    }
    
    private let startTimeLabel = UILabel().then {
        $0.text = "시작 시간"
        $0.font = UIFont.hanSansMediumFont(ofSize: 14)
        $0.textColor = UIColor.grey04
    }
    
    private let startTimePicker = UIDatePicker().then {
        $0.datePickerMode = .time
        $0.locale = Locale(identifier: "ko-KR")
        $0.timeZone = .current
        $0.preferredDatePickerStyle = .inline
        $0.minuteInterval = 5
        $0.tag = 1
    }
    
    private let timeSeparateView = UIView().then {
        $0.backgroundColor = UIColor.grey01
    }
    
    private let endTimeLabel = UILabel().then{
        $0.text = "종료 시간"
        $0.font = UIFont.hanSansMediumFont(ofSize: 14)
        $0.textColor = UIColor.grey04
    }
    
    private let endTimePicker = UIDatePicker().then{
        $0.datePickerMode = .time
        $0.locale = Locale(identifier: "ko-KR")
        $0.timeZone = .current
        $0.preferredDatePickerStyle = .inline
        $0.minuteInterval = 5
        $0.tag = 2
    }
    
    private let bottomSheetView = SelectedDateSheet()
    
    private let bottomSeparateLineView = UIView().then {
        $0.backgroundColor = UIColor.grey02
    }
    private let bottomAreaBackgroundView = UIView().then {
        $0.backgroundColor = UIColor.white
    }
    
    private let requestButton = UIButton().then {
        $0.backgroundColor = UIColor.grey02
        $0.setTitle("약속 신청", for: .normal)
        $0.titleLabel?.font = UIFont.hanSansMediumFont(ofSize: 16)
        $0.layer.cornerRadius = 10
        $0.isEnabled = false
    }
    
    // MARK: - Properties
    
    weak var coordinator: Coordinator?
    var delegate: RequestPlansDateVCDelegate?
    
    private let disposeBag = DisposeBag()
    
    private let startSundayToDisplay: Date = {
        if Date.getCurrentKoreanWeekDay() == "일" { // 오늘이 일요일이면 바로 리턴
            return Date()
        } else { // 일요일이 아니라면 전주의 일요일을 반환
            let previousWeekDayByInt = Calendar.current.component(.weekday, from: Date().previousDate(value: 7))
            return Date().previousDate(value: 7).nextDate(value: 8 - previousWeekDayByInt)
        }
    }()
    private var scheduleDataList: [ScheduleData]?
    
    /// 주간 달력에 표시할 값을 관리, 초기값은 이번주 포함 3주를 표시
    private lazy var weekDayRelay = BehaviorRelay(value: Array(repeating: startSundayToDisplay, count: 21).enumerated().map { $0.1.nextDate(value: $0.0)} )
    
    private let selectedDaySchedule = PublishRelay<[ScheduleData]>()
    /// 선택된 셀 인덱스 관리
    private var selectedCellIndex: Int?
    
    private var pickedDate = PickedDate()

    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        view.backgroundColor = .white
        self.navigationController?.isNavigationBarHidden = false
        setAutoLayouts()
        setupViews()
        setupWeekDayCollectionView()
        setupScheduleTableView()
        
        for index in 0...2 { // 이번 달 부터 3달치 스케쥴을 미리 로드한다.
            let monthDateToRequest = Calendar.current.date(byAdding: DateComponents(month: index), to: Date())
            guard let year = monthDateToRequest?.year, let month = monthDateToRequest?.month else { return }
            requestCalendarData(yearString: "\(year)", monthString: "\(month)")
        }
        
        // 상단 선택된 시간 라벨의 초기값은 오늘 날짜이고 시간은 아래 기준으로 결정
        let min = Calendar.current.component(.minute, from: Date())
        
        //시간이 30분 이하일 때 다음 정각으로 설정
        if Int(min) < 30 {
            guard let minuteRevisedDate = Calendar.current.date(bySetting: .minute, value: 0, of: pickedDate.startTime) else { return }
            pickedDate.startTime = minuteRevisedDate//올림해줘버림..
            guard let hourRevisedDate = Calendar.current.date(byAdding: .hour, value: 1, to: pickedDate.endTime) else { return }
            pickedDate.endTime = hourRevisedDate
            guard let minuteRevisedDate = Calendar.current.date(bySetting: .minute, value: 0, of: pickedDate.endTime) else { return }
            pickedDate.endTime = minuteRevisedDate
            
        } else { //30분 이상일 때 다음 삼십분으로 설정
            guard let minuteRevisedDate = Calendar.current.date(bySetting: .minute, value: 30, of: pickedDate.startTime) else { return }
            pickedDate.startTime = minuteRevisedDate
            guard let hourRevisedDate = Calendar.current.date(byAdding: .hour, value: 1, to: pickedDate.endTime) else { return }
            pickedDate.endTime = hourRevisedDate
            guard let minuteRevisedDate = Calendar.current.date(bySetting: .minute, value: 30, of: pickedDate.endTime) else { return }
            pickedDate.endTime = minuteRevisedDate
        }
        
        updateSelectedDateLabel()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // 시간 데이터 모두 지우기
        PostRequestPlansService.sharedParameterData.date.removeAll()
        PostRequestPlansService.sharedParameterData.start.removeAll()
        PostRequestPlansService.sharedParameterData.end.removeAll()
    }
    
    // MARK: - Layout
    
    private func setAutoLayouts() {
        view.addSubviews([navigationAreaView, currentSelectedDateView
                          ,addDateButton, selectDateLabel, scrollView,
                          bottomSheetView,
                          bottomAreaBackgroundView])
        
        navigationAreaView.addSubviews([backButton, exitButton, titleLabel])
        
        navigationAreaView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(58 * widthRatio)
        }
        
        backButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(2 * widthRatio)
        }
        
        exitButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-4 * widthRatio)
            $0.centerY.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        currentSelectedDateView.snp.makeConstraints {
            $0.width.equalTo(274 * widthRatio)
            $0.height.equalTo(53 * heightRatio)
            $0.leading.equalToSuperview().offset(20 * heightRatio)
            $0.top.equalTo(backButton.snp.bottom).offset(30 * heightRatio)
        }
        
        currentSelectedDateView.addSubviews([selectedDateLabel, selectedTimeLabel])
        
        selectedDateLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16 * widthRatio)
            $0.top.equalToSuperview().offset(14 * heightRatio)
        }
        
        selectedTimeLabel.snp.makeConstraints {
            $0.leading.equalTo(selectedDateLabel.snp.trailing).offset(16 * widthRatio)
            $0.top.equalToSuperview().offset(16 * heightRatio)
        }
        
        addDateButton.snp.makeConstraints {
            $0.width.height.equalTo(53 * widthRatio)
            $0.leading.equalTo(currentSelectedDateView.snp.trailing).offset(8 * widthRatio)
            $0.top.equalTo(currentSelectedDateView.snp.top)
        }
        
        selectDateLabel.snp.makeConstraints {
            $0.leading.equalTo(20 * heightRatio)
            $0.top.equalTo(currentSelectedDateView.snp.bottom).offset(36 * heightRatio)
        }
        
        scrollView.snp.makeConstraints {
            $0.width.centerX.equalToSuperview()
            $0.top.equalTo(selectDateLabel.snp.bottom).offset(13 * heightRatio)
            $0.bottom.equalToSuperview().offset(-112 * heightRatio)
        }
        
        scrollView.addSubviews([separateLineView, scheduleAreaBackgroundView])
        
        separateLineView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(1 * heightRatio)
        }
        
        scheduleAreaBackgroundView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.leading.equalTo(view.snp.leading)
            $0.trailing.equalTo(view.snp.trailing)
            $0.height.equalTo(330 * heightRatio)
        }
        
        scheduleAreaBackgroundView.addSubviews([prevWeekButton, yearAndWeekLabelButton, nextWeekButton, weekDayCollectionView,
                                                weekdaySeparateLineView, selectedDayLabel, scheduleTableView])
        
        prevWeekButton.snp.makeConstraints {
            $0.width.height.equalTo(42 * heightRatio)
            $0.leading.equalTo(1 * widthRatio)
            $0.top.equalTo(6 * heightRatio)
        }
        
        yearAndWeekLabelButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(15 * heightRatio)
        }
        
        nextWeekButton.snp.makeConstraints {
            $0.width.height.equalTo(42 * heightRatio)
            $0.trailing.equalTo(-2 * widthRatio)
            $0.top.equalTo(6 * heightRatio)
        }
        
        weekDayCollectionView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(9 * widthRatio)
            $0.trailing.equalToSuperview().offset(-9 * widthRatio)
            $0.height.equalTo(90 * heightRatio)
            $0.top.equalTo(yearAndWeekLabelButton.snp.bottom).offset(5 * heightRatio)
        }
        
        weekdaySeparateLineView.snp.makeConstraints {
            $0.top.equalTo(weekDayCollectionView.snp.bottom).offset(8 * heightRatio)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(1 * heightRatio)
        }
        
        selectedDayLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20 * widthRatio)
            $0.top.equalTo(weekdaySeparateLineView.snp.bottom).offset(15 * heightRatio)
        }
        
        scheduleTableView.snp.makeConstraints {
            $0.top.equalTo(selectedDayLabel.snp.bottom).offset(11 * heightRatio)
            $0.width.equalTo(335 * widthRatio)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(30 * heightRatio)
        }
        
        scrollView.addSubviews([allDayLabel, allDaySwitch, separateLineView2,
                               startTimeLabel, startTimePicker, timeSeparateView, endTimeLabel, endTimePicker])
        
        allDayLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(21 * widthRatio)
            $0.top.equalTo(scheduleAreaBackgroundView.snp.bottom).offset(24 * heightRatio)
        }
        
        allDaySwitch.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-20 * widthRatio)
            $0.top.equalTo(scheduleAreaBackgroundView.snp.bottom).offset(18 * heightRatio)
        }
        
        separateLineView2.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(1 * heightRatio)
            $0.top.equalTo(allDaySwitch.snp.bottom).offset(17 * heightRatio)
        }
        
        startTimeLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(21 * widthRatio)
            $0.top.equalTo(separateLineView2.snp.bottom).offset(26 * heightRatio)
        }
        
        startTimePicker.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-20 * widthRatio)
            $0.top.equalTo(separateLineView2).offset(15 * heightRatio)
        }
        
        timeSeparateView.snp.makeConstraints {
            $0.width.equalTo(335 * widthRatio)
            $0.centerX.equalToSuperview()
            $0.top.equalTo(startTimeLabel.snp.bottom).offset(19 * heightRatio)
            $0.height.equalTo(1)
        }
        
        endTimeLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(21 * widthRatio)
            $0.top.equalTo(timeSeparateView.snp.bottom).offset(24 * heightRatio)
        }
        
        endTimePicker.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-20 * widthRatio)
            $0.top.equalTo(timeSeparateView.snp.bottom).offset(15 * heightRatio)
            $0.bottom.equalToSuperview().offset(-77 * heightRatio)
        }
        
        bottomAreaBackgroundView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(112 * heightRatio)
        }
        
        bottomAreaBackgroundView.addSubviews([bottomSeparateLineView, requestButton])
        
        bottomSeparateLineView.snp.makeConstraints {
            $0.height.equalTo(1 * heightRatio)
            $0.leading.trailing.top.equalToSuperview()
        }
        
        requestButton.snp.makeConstraints {
            $0.width.equalTo(335 * widthRatio)
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(16 * heightRatio)
            $0.height.equalTo(54 * heightRatio)
        }
        
        bottomSheetView.snp.makeConstraints {
            $0.bottom.equalTo(bottomAreaBackgroundView.snp.bottom).offset(310 * heightRatio)
            $0.trailing.leading.equalToSuperview()
            $0.height.equalTo(482 * heightRatio)
        }
    }
    
    private func setupViews() {
        backButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] in
                self?.delegate?.backButtonDidTap()
            })
            .disposed(by: disposeBag)
        
        exitButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] in
                self?.dismiss(animated: false)
            })
            .disposed(by: disposeBag)
        
        yearAndWeekLabelButton.rx.tap // 라벨을 탭하면 가장 처음 페이지로 돌아간다
            .asDriver()
            .drive(onNext: { [weak self] in
                self?.weekDayCollectionView.setContentOffset(.zero, animated: true)
            })
            .disposed(by: disposeBag)
        
        prevWeekButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] in
                guard let vself = self else { return }
                let pageWidth = vself.weekDayCollectionView.frame.width + 7 * widthRatio
                let index: CGFloat = round(vself.weekDayCollectionView.contentOffset.x / pageWidth) - 1
                guard index >= 0 else { return }
                self?.weekDayCollectionView.setContentOffset(CGPoint(x: index * pageWidth, y: vself.weekDayCollectionView.contentOffset.y), animated: true)
            })
            .disposed(by: disposeBag)
        
        nextWeekButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] in
                guard let vself = self else { return }
                let pageWidth = vself.weekDayCollectionView.frame.width + 7 * widthRatio
                let index: CGFloat = floor(vself.weekDayCollectionView.contentOffset.x / pageWidth) + 1
                self?.weekDayCollectionView.setContentOffset(CGPoint(x: index * pageWidth, y: vself.weekDayCollectionView.contentOffset.y), animated: true)
            })
            .disposed(by: disposeBag)
        
        addDateButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] in
                // 데이터 변경은 바텀 시트쪽에서 처리하도록 몰아넣도록 하자
                guard let vself = self else { return }
                
                if vself.startTimePicker.date > vself.endTimePicker.date { // 만약 시작 시간이 종료시간 보다 빠르다면
                    vself.view.makeToastAnimation(message: "종료시간을 확인해주세요")
                } else {
                    vself.bottomSheetView.addSelectedTimeData(date: vself.pickedDate.getDateStringForRequest(),
                                                        start: vself.pickedDate.getStartTimeStringForRequest(),
                                                        end: vself.pickedDate.getEndTimeStringForRequest())
                }
            })
            .disposed(by: disposeBag)
        
        allDaySwitch.rx.isOn
            .asDriver()
            .drive(onNext: { [weak self] isOn in
                guard let vself = self else { return }
                
                let dateFormatter = DateFormatter().then {
                    $0.dateFormat = "a hh:mm"
                    $0.timeZone = NSTimeZone(name: "ko_KR") as TimeZone?
                    $0.locale = Locale(identifier: "ko_KR")
                }
                
                guard let startDate = dateFormatter.date(from: isOn ? "오전 12:00" : "오전 09:00"),
                      let endDate = dateFormatter.date(from: isOn ? "오후 11:55" : "오후 02:00") else { return }
                
                vself.startTimePicker.setDate(startDate,animated: true)
                vself.endTimePicker.setDate(endDate,animated: true)
                
                vself.startTimePicker.isUserInteractionEnabled = !isOn
                vself.endTimePicker.isUserInteractionEnabled = !isOn
                
                let startDateComponents = DateComponents(year: vself.pickedDate.startTime.year, month: vself.pickedDate.startTime.month, day: vself.pickedDate.startTime.day, hour: isOn ? 0 : 9, minute: 0)
                let endDateComponents = DateComponents(year: vself.pickedDate.startTime.year, month: vself.pickedDate.startTime.month, day: vself.pickedDate.startTime.day, hour: isOn ? 23 : 14, minute: isOn ? 55 : 0)
                guard let revisedStartDate = Calendar.current.date(from: startDateComponents),
                      let revisedEndDate = Calendar.current.date(from: endDateComponents) else { return }
                
                vself.pickedDate.startTime = revisedStartDate
                vself.pickedDate.endTime = revisedEndDate
                
                vself.updateSelectedDateLabel()
            })
            .disposed(by: disposeBag)
        
        startTimePicker.rx.date
            .asDriver()
            .drive(onNext: { [weak self] date in
                guard let vself = self else { return }
                let startDateComponents = DateComponents(year: vself.pickedDate.startTime.year, month: vself.pickedDate.startTime.month, day: vself.pickedDate.startTime.day, hour: date.hour, minute: date.minute)
                if let revisedDate = Calendar.current.date(from: startDateComponents) {
                    vself.pickedDate.startTime = revisedDate
                }
                vself.updateSelectedDateLabel()
            })
            .disposed(by: disposeBag)
        
        endTimePicker.rx.date
            .asDriver()
            .drive(onNext: { [weak self] date in
                guard let vself = self else { return }
                let endDateComponents = DateComponents(year: vself.pickedDate.startTime.year, month: vself.pickedDate.startTime.month, day: vself.pickedDate.startTime.day, hour: date.hour, minute: date.minute)
                if let revisedDate = Calendar.current.date(from: endDateComponents) {
                    vself.pickedDate.endTime = revisedDate
                }
                vself.updateSelectedDateLabel()
            })
            .disposed(by: disposeBag)
        
        scrollView.rx.willBeginDragging
            .asDriver()
            .drive(onNext: { [weak self] in
                self?.bottomSheetView.showSheet(atState: .folded)
            })
            .disposed(by: disposeBag)
        
        bottomSheetView.rx_requestIsEnabled
            .asObservable()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] isEnabled in
                self?.requestButton.isEnabled = isEnabled
                self?.requestButton.backgroundColor = isEnabled ? UIColor.pink01 : UIColor.grey02
            })
            .disposed(by: disposeBag)
        
        requestButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] in
                PostRequestPlansService.shared.requestPlans { response in
                    switch response {
                    case .success(_):
                        self?.view.makeToastAnimation(message: "약속 요청 보내기 완료!")
                        self?.delegate?.exitButtonDidTap()
                    case .networkFail:
                        self?.view.makeToastAnimation(message: "네트워크 에러입니다.")
                    case .pathErr:
                        self?.view.makeToastAnimation(message: "내부 오류")
                    case .requestErr(_):
                        self?.view.makeToastAnimation(message: "요청 오류, 다시 시도하십시오")
                    case .serverErr:
                        self?.view.makeToastAnimation(message: "서버 에러")
                    }
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func setupWeekDayCollectionView() {
        /// 셀 표시 구현
        weekDayRelay
            .bind(to: weekDayCollectionView.rx.items) { [weak self] (collectionView, item, element) in
                guard let vself = self,
                      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SelectableWeekDayCVC.identifier, for: IndexPath(item: item, section: 0)) as? SelectableWeekDayCVC else { return UICollectionViewCell() }
                
                cell.dateToShow = element
                if element.year < Date().year ||
                    (element.year == Date().year && element.month < Date().month) ||
                    (element.year == Date().year && element.month == Date().month && element.day < Date().day) {
                    cell.status = .invalid
                } else if vself.selectedCellIndex == item {
                    cell.status = .selected
                } else {
                    cell.status = .unselected
                }
                
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                formatter.locale = Locale(identifier: "ko_KR")
                formatter.timeZone = NSTimeZone(name: "ko_KR") as TimeZone?
                let dateString: String = formatter.string(from: element)
                
                cell.isScheduled = !(vself.scheduleDataList?.filter { $0.date == dateString }.isEmpty ?? false) // 찾아서 있으면 표시
                
                return cell
            }
            .disposed(by: disposeBag)
        
        /// 무한스크롤링
        weekDayCollectionView.rx.contentOffset.changed
            .asDriver()
            .drive(onNext: { [weak self] contentOffset in
                guard let vself = self else { return }
                if contentOffset.x > vself.weekDayCollectionView.contentSize.width - vself.weekDayCollectionView.frame.width { // 마지막 페이지에 도달 시 추가한다
                    
                    guard let lastDisplayedDate = vself.weekDayRelay.value.last else { return }
                    let datesForAppend: [Date] = Array(repeating: lastDisplayedDate.nextDate(value: 1), count: 14).enumerated().map { $0.1.nextDate(value: $0.0) } // 2주씩 추가
                    
                    vself.weekDayRelay.accept(vself.weekDayRelay.value + datesForAppend)
                    if let appendLastDate = datesForAppend.last, appendLastDate.month > lastDisplayedDate.month { // 만약 추가될 마지막 날짜가 원래 표시되던 마지막 날의 달 보다 크면 스케쥴 데이터 요청시킨다.
                        vself.requestCalendarData(yearString: "\(datesForAppend.last?.year ?? 2022)", monthString: "\(datesForAppend.last?.month ?? 1)")
                    }
                }
            })
            .disposed(by: disposeBag)
        
        /// paging시 컨텐트 오프셋을 조정, 출처 : https://eunjin3786.tistory.com/203
        weekDayCollectionView.rx.willEndDragging
            .asDriver()
            .drive(onNext: { [weak self] draggingValue in
                guard let vself = self else { return }
                // 한 페이지 사이즈
                let pageWidth = vself.weekDayCollectionView.frame.width + 7 * widthRatio
                
                // 도착할 오프셋
                var offsetWillMove = draggingValue.targetContentOffset.pointee
                // 페이지 인덱스 (몇번째 페이지?)
                let index = (offsetWillMove.x + vself.weekDayCollectionView.contentInset.left) / pageWidth
                var roundedIndex = round(index)
        
                roundedIndex = vself.weekDayCollectionView.contentOffset.x > draggingValue.targetContentOffset.pointee.x ? floor(index) : ceil(index)
                
                
                offsetWillMove = CGPoint(x: roundedIndex * pageWidth, y: draggingValue.targetContentOffset.pointee.y)
                draggingValue.targetContentOffset.pointee = offsetWillMove
            })
            .disposed(by: disposeBag)
        
        // 셀 선택시 동작을 정의
        weekDayCollectionView.rx.itemSelected
            .asDriver()
            .drive(onNext: { [weak self] indexPath in
                guard let vself = self else { return }
                guard let cell = vself.weekDayCollectionView.cellForItem(at: indexPath) as? SelectableWeekDayCVC else { return }
                guard let dateToShow = cell.dateToShow else { return }

                // 어차피 invalid는 선택할 수 없으므로 아래와 같이 설정
                if let selectedCellIndex = vself.selectedCellIndex {
                    let previousSelectedCell = vself.weekDayCollectionView.cellForItem(at: IndexPath(item: selectedCellIndex, section: 0)) as? SelectableWeekDayCVC
                    previousSelectedCell?.status = .unselected
                }
                vself.selectedCellIndex = indexPath.row
                cell.status = .selected

                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "YYYY-MM-dd" // 2020-08-13 16:30
                vself.selectedDateLabel.text = dateFormatter.string(from: dateToShow)
                
                let selectedDay = DateComponents(year: dateToShow.year, month: dateToShow.month, day: dateToShow.day, hour: vself.pickedDate.startTime.hour, minute: vself.pickedDate.startTime.minute)
                vself.pickedDate.startTime = Calendar.current.date(from: selectedDay) ?? dateToShow
                vself.selectedDayLabel.text = "\(dateToShow.month)월 \(dateToShow.day)일 \(Date.getKoreanWeekDay(from: dateToShow))요일"
                vself.yearAndWeekLabelButton.setTitle("\(dateToShow.year)년 \(dateToShow.month)월", for: .normal)
                
                // 해당 날짜에 해당하는 스케쥴이 있다면 스케쥴 표시를 위한 이벤트 발행
                guard let scheduleDataList = vself.scheduleDataList else { return }
                let selectedDaySchedule = scheduleDataList.filter({ $0.date == dateFormatter.string(from: dateToShow) })
                vself.selectedDaySchedule.accept(selectedDaySchedule)
            })
            .disposed(by: disposeBag)
    }
    
    private func setupScheduleTableView() {
        selectedDaySchedule
            .bind(to: scheduleTableView.rx.items) { (tableView, row, element) in
                guard let cell = tableView.dequeueReusableCell(withIdentifier: ScheduleTVC.identifier, for: IndexPath(row: row, section: 0)) as? ScheduleTVC else { return UITableViewCell() }
                
                cell.setData(time: "\(element.start)-\(element.end)", plansTitle: element.invitationTitle)
                return cell
            }
            .disposed(by: disposeBag)
    }
    
    private func updateSelectedDateLabel() {
        selectedDateLabel.text = pickedDate.getDateString()
        selectedTimeLabel.text = pickedDate.getStartToEndString()
    }
    
    // MARK: - Networks
    
    /// 1달 단위의 스케쥴이 있는지 조회하는 메서드
    /// - Parameters:
    ///   - yearString: 연도
    ///   - monthString: 월
    private func requestCalendarData(yearString: String, monthString: String) {
        GetScheduleService.shared.getScheduleData(year: yearString, month: monthString)  { [weak self] responseData in
            switch responseData {
            case .success(let response):
                guard let response = response as? InvitationPlanData else { return }
                if (self?.scheduleDataList) != nil {
                    self?.scheduleDataList?.append(contentsOf: response.data ?? [])
                } else {
                    self?.scheduleDataList = response.data ?? []
                }
                DispatchQueue.main.async {
                    self?.weekDayCollectionView.reloadData()
                }
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
}
