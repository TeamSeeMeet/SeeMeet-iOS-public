//
//  RequestPlansContentsVC.swift
//  SeeMeet
//
//  Created by 이유진 on 2022/01/10.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa
import RxRelay
import Alamofire

protocol RequestPlansContentsVCDelegate {
    func exitButtonDidTap()
    func nextButtonDidTap()
}

class RequestPlansContentsVC: UIViewController,UIGestureRecognizerDelegate {
    
    // MARK: - UI Components
    
    private let titleView = UIView()
    
    private let titleLabel = UILabel().then {
        $0.text = "약속 신청"
        $0.font = UIFont.hanSansBoldFont(ofSize: 18)
    }
    
    private let exitButton = UIButton().then {
        $0.setBackgroundImage(UIImage(named: "btn_close_bold"), for: .normal)
    }
    
    private let friendSelectionLabel = UILabel().then {
        $0.text = "약속 신청할 친구를 선택하세요"
        $0.font = UIFont.hanSansRegularFont(ofSize: 18)
        $0.textColor = UIColor.grey06
        let attributedString = NSMutableAttributedString(string: "약속 신청할 친구를 선택하세요")
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.pink01, range: ($0.text! as NSString).range(of:"친구"))
        attributedString.addAttribute(.font, value: UIFont.hanSansBoldFont(ofSize: 18), range: ($0.text! as NSString).range(of: "친구"))
        $0.attributedText = attributedString
    }
    
    private let searchFieldView = UIView().then {
        $0.backgroundColor = .grey01
        $0.layer.cornerRadius = 10
    }
    
    private let searchFieldPlaceholderLabel = UILabel().then {
        $0.attributedText = NSAttributedString(string: "받는 사람:", attributes: [.foregroundColor: UIColor.grey04])
        $0.font = .hanSansRegularFont(ofSize: 14)
    }
    
    private let searchResultTableView: UITableView = {
        let searchTableView = UITableView()
        searchTableView.register(SearchTVC.self, forCellReuseIdentifier: SearchTVC.identifier)
        return searchTableView
    }()
    
    private lazy var selectedCollectionView = UICollectionView(frame: .zero, collectionViewLayout: .init()).then {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        $0.collectionViewLayout = layout
        $0.backgroundColor = .clear
        $0.register(SearchFieldTokenCVC.self, forCellWithReuseIdentifier: SearchFieldTokenCVC.identifier)
        $0.register(SearchInputFieldCVC.self, forCellWithReuseIdentifier: SearchInputFieldCVC.identifier)
        $0.showsHorizontalScrollIndicator = false
        layout.sectionInset = UIEdgeInsets(top: 11 * heightRatio, left: 0, bottom: 11 * heightRatio, right: 0)
    }
    
    private let tableBackgroundView = UIView().then {
        $0.backgroundColor = UIColor.white
    }
    
    private let searchImageView = UIImageView().then {
        $0.image = UIImage(named: "ic_search")
    }
    
    private let contentsWritingLabel = UILabel().then {
        $0.text = "약속의 내용을 작성하세요"
        $0.font = UIFont.hanSansRegularFont(ofSize: 18)
        $0.textColor = UIColor.grey06
        let attributedString = NSMutableAttributedString(string: "약속의 내용을 작성하세요")
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.pink01, range: ($0.text! as NSString).range(of:"내용"))
        attributedString.addAttribute(.font, value: UIFont.hanSansBoldFont(ofSize: 18), range: ($0.text! as NSString).range(of: "내용"))
        $0.attributedText = attributedString
    }
    
    private let plansContentsView = UIView().then {
        $0.backgroundColor = UIColor.grey01
        $0.layer.cornerRadius = 10
    }
    
    private lazy var plansTitleTextField = UITextField().then {
        $0.font = UIFont.hanSansBoldFont(ofSize: 14)
        $0.textColor = UIColor.grey06
        $0.attributedPlaceholder = NSAttributedString(string: "제목", attributes: [.foregroundColor: UIColor.grey04, .font: UIFont.hanSansRegularFont(ofSize: 14)])
        $0.returnKeyType = .done
        $0.delegate = self
    }
    
    private let seperateLineView = UIView().then {
        $0.backgroundColor = UIColor.grey02
    }
    
    private lazy var plansContentsTextView = UITextView().then {
        $0.font = UIFont.hanSansRegularFont(ofSize: 14)
        $0.backgroundColor = UIColor.grey01
        $0.textColor = UIColor.grey06
        $0.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        $0.textContainer.lineFragmentPadding = 0
        $0.scrollIndicatorInsets = $0.textContainerInset
        $0.returnKeyType = .done
        $0.delegate = self
    }
    
    private let navigationLineView = UIView().then {
        $0.backgroundColor = UIColor.grey02
    }
    
    private let nextButton = UIButton().then {
        $0.backgroundColor = UIColor.grey02
        $0.isEnabled = false
        $0.setTitle("다음", for: .normal)
        $0.titleLabel?.font = UIFont.hanSansMediumFont(ofSize: 16)
        $0.layer.cornerRadius = 10
    }
    
    // MARK: - Properties
    
    weak var coordinator: Coordinator?
    var delegate: RequestPlansContentsVCDelegate?
    var friendDataToSet: FriendsData?
    
    private let disposeBag = DisposeBag()
    
    private var friendDataList: [FriendsData] = []
    private var filteredFriendList: [FriendsData] = []
    private var selectedFriendList: [FriendsData] = []
    
    enum SearchTokenType {
        case selectedFriendToken(data: FriendsData) // 선택하여 추가한 친구 이름 토큰
        case inputFieldToken // 항상 마지막에 위치하는, 입력창이 있는 토큰
    }
    
    private lazy var selectedFriendsListRelay: BehaviorRelay<[SearchTokenType]> = { [weak self] in
        if let friendDataToSet = self?.friendDataToSet {
            return BehaviorRelay<[SearchTokenType]>(value: [.selectedFriendToken(data: friendDataToSet), .inputFieldToken]) // 항상 마지막은 입력 필드 셀
        } else {
            return BehaviorRelay<[SearchTokenType]>(value: [.inputFieldToken]) // 항상 마지막은 입력 필드 셀
        }
    }()
    
    private lazy var filteredFriendsRelay = BehaviorRelay<[FriendsData]>(value: friendDataList)
    
    private lazy var isPlansTitleValid = plansTitleTextField.rx.text.asDriver().map { !($0?.isEmpty ?? true) }
    private lazy var isPlansContentsTextValid = plansContentsTextView.rx.text.asDriver().map { [weak self] in
        $0 != self?.textViewPlaceHolder && $0 == "" ? false : true }
    private lazy var isNextButtonValid = Driver.combineLatest(isPlansTitleValid,
                                                              isPlansContentsTextValid, selectedFriendsListRelay.asDriver()).map { $0.0 && $0.1 && $0.2.count > 1 }
    
    
    private lazy var plansTextBeginEditing = Driver.merge(plansTitleTextField.rx.controlEvent(.editingDidBegin).asDriver(),
                                                          plansContentsTextView.rx.didBeginEditing.asDriver())
    private lazy var plansTextEndEditing = Driver.merge(plansTitleTextField.rx.controlEvent(.editingDidEnd).asDriver(),
                                                        plansContentsTextView.rx.didEndEditing.asDriver())
    
    
    private let textViewPlaceHolder = "약속 상세 내용"
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let friendDataToSet = friendDataToSet {
            selectedFriendList.append(friendDataToSet)
        }
        view.backgroundColor = .white
        setAutoLayouts()
        setupViews()
        setupSearchTableView()
        dismissKeyboard()
        getFriendsList() // 네트워킹
        setContentsTextViewPlaceholder()
        //        setDelegate()
        setupSelectedCollectionView()
    }
    
    // MARK: - Layouts
    
    private func setAutoLayouts() {
        navigationController?.navigationBar.isHidden = true // 숨겨라
        
        view.addSubviews([titleView, nextButton,
                          friendSelectionLabel, searchFieldView, contentsWritingLabel, plansContentsView,navigationLineView,tableBackgroundView,searchResultTableView])
        titleView.addSubviews([titleLabel,exitButton])
        searchFieldView.addSubviews([searchFieldPlaceholderLabel,searchImageView, selectedCollectionView])
        plansContentsView.addSubviews([plansTitleTextField,seperateLineView,plansContentsTextView])
        
        titleView.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(58 * heightRatio)
        }
        
        titleLabel.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
        }
        
        exitButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-4 * widthRatio)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(48 * heightRatio)
        }
        
        friendSelectionLabel.snp.makeConstraints {
            $0.top.equalTo(titleView.snp.bottom).offset(24 * heightRatio)
            $0.leading.equalToSuperview().offset(20 * widthRatio)
            $0.height.equalTo(32 * heightRatio)
        }
        
        searchFieldView.snp.makeConstraints {
            $0.top.equalTo(friendSelectionLabel.snp.bottom).offset(7 * heightRatio)
            $0.leading.equalTo(friendSelectionLabel)
            $0.trailing.equalToSuperview().offset(-20 * widthRatio)
            $0.height.equalTo(50 * heightRatio)
        }
        
        tableBackgroundView.snp.makeConstraints {
            $0.top.equalTo(searchFieldView.snp.bottom)
            $0.leading.bottom.trailing.equalToSuperview()
        }
        
        searchResultTableView.snp.makeConstraints {
            $0.top.equalTo(searchFieldView.snp.bottom)
            $0.leading.equalTo(searchFieldView.snp.leading).offset(23 * widthRatio)
            $0.trailing.equalTo(searchFieldView.snp.trailing).offset(-22 * widthRatio)
            $0.height.equalTo(270 * heightRatio)
        }
        
        searchImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(8 * widthRatio)
            $0.width.height.equalTo(34 * widthRatio)
        }
        
        selectedCollectionView.snp.makeConstraints {
            $0.centerY.height.equalToSuperview()
            $0.leading.equalTo(searchImageView.snp.trailing).offset(2 * widthRatio)
            $0.trailing.equalToSuperview()
        }
        
        contentsWritingLabel.snp.makeConstraints {
            $0.top.equalTo(searchFieldView.snp.bottom).offset(38 * heightRatio)
            $0.leading.equalToSuperview().offset(20 * widthRatio)
            $0.height.equalTo(32 * heightRatio)
        }
        
        plansContentsView.snp.makeConstraints {
            $0.top.equalTo(contentsWritingLabel.snp.bottom).offset(12 * heightRatio)
            $0.leading.equalToSuperview().offset(20 * widthRatio)
            $0.trailing.equalToSuperview().offset(-20 * widthRatio)
            $0.height.equalTo(255 * heightRatio)
        }
        
        plansTitleTextField.snp.makeConstraints {
            $0.top.equalToSuperview().offset(15 * heightRatio)
            $0.leading.equalToSuperview().offset(19 * widthRatio)
            $0.trailing.equalToSuperview().offset(-15 * widthRatio)
            $0.height.equalTo(32 * widthRatio)
        }
        
        seperateLineView.snp.makeConstraints {
            $0.top.equalTo(plansTitleTextField.snp.bottom).offset(9 * heightRatio)
            $0.leading.equalToSuperview().offset(15 * widthRatio)
            $0.trailing.equalToSuperview().offset(-15 * widthRatio)
            $0.height.equalTo(1 * heightRatio)
        }
        
        plansContentsTextView.snp.makeConstraints {
            $0.top.equalTo(seperateLineView.snp.bottom).offset(3 * heightRatio)
            $0.leading.equalToSuperview().offset(9 * widthRatio)
            $0.bottom.equalToSuperview().offset(-8 * heightRatio)
            $0.trailing.equalToSuperview().offset(-5 * widthRatio)
        }
        
        navigationLineView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(nextButton.snp.top).offset(-16 * widthRatio)
            $0.height.equalTo(1 * heightRatio)
        }
        
        nextButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20 * widthRatio)
            $0.trailing.equalToSuperview().offset(-20 * widthRatio)
            $0.bottom.equalToSuperview().offset(-42 * heightRatio)
            $0.height.equalTo(54 * heightRatio)
        }
        
        tableBackgroundView.isHidden = true
        searchResultTableView.isHidden = true
        searchResultTableView.separatorStyle = .none
    }
    
    func setContentsTextViewPlaceholder() {
        plansContentsTextView.text = textViewPlaceHolder
        plansContentsTextView.textColor = UIColor.grey04
    }
    
    //입력하다가 다른 곳 터치시 키패드 내려가게 하기
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    private func dismissKeyboard() {
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer()
        view.addGestureRecognizer(tapGesture)
        
        tapGesture.rx.event.bind(onNext: { [weak self] _ in
            guard let self = self else { return }
            [self.plansTitleTextField, self.plansContentsTextView].forEach {
                $0.endEditing(true)
            }
        })
        .disposed(by: disposeBag)
        tapGesture.cancelsTouchesInView = false
    }
    
    // MARK: - Actions
    
    private func setupViews() {
        
        exitButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] in
                self?.delegate?.exitButtonDidTap()
            })
            .disposed(by: disposeBag)
        
        nextButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] in
                guard let self = self else { return }
                
                var parameterData = PostRequestPlansService.sharedParameterData
                parameterData.title = self.plansTitleTextField.text ?? ""
                parameterData.contents = self.plansContentsTextView.text ?? ""
                parameterData.guests = self.selectedFriendList.map { ["id": $0.id, "username": $0.username] }
                
                self.delegate?.nextButtonDidTap()
            })
            .disposed(by: disposeBag)
        
        selectedCollectionView.rx.itemSelected // 마지막 아이템(텍스트 입력 셀) 터치했을 때 처리
            .filter { [weak self] in $0 == IndexPath(item: self?.selectedFriendList.count ?? 0, section: 0) }
            .asObservable()
            .subscribe(onNext: { [weak self] _ in
                self?.tableBackgroundView.isHidden = false
                self?.searchResultTableView.isHidden = false
                self?.filteredFriendList = self?.friendDataList ?? []
                self?.searchResultTableView.reloadData()
            })
            .disposed(by: disposeBag)
        
        isNextButtonValid
            .asDriver()
            .drive(onNext: { [weak self] isEnabled in
                self?.nextButton.backgroundColor = isEnabled ? .pink01 : .grey02
                self?.nextButton.isEnabled = isEnabled
            })
            .disposed(by: disposeBag)
        
        plansTextBeginEditing
            .drive(onNext: { [weak self] in
                self?.plansContentsView.layer.borderColor = UIColor.pink01.cgColor // 테두리 하이라이팅 시키고 플레이스홀더 지움
                self?.plansContentsView.layer.borderWidth = 1.0
                
                if self?.plansContentsTextView.text == self?.textViewPlaceHolder {
                    self?.plansContentsTextView.text = nil
                    self?.plansContentsTextView.textColor = UIColor.black
                }
            })
            .disposed(by: disposeBag)
        
        plansTextEndEditing
            .drive(onNext: { [weak self] in
                self?.plansContentsView.layer.borderColor = UIColor.grey04.cgColor
                self?.plansContentsView.layer.borderWidth = 0
                if self?.plansContentsTextView.text == self?.textViewPlaceHolder || self?.plansContentsTextView.text == "" {
                    self?.setContentsTextViewPlaceholder()
                }
            })
            .disposed(by: disposeBag)
        
        plansContentsTextView.rx.didChange
            .asDriver()
            .drive(onNext: { [weak self] element in
                guard let self = self else { return }
                let attrString = NSMutableAttributedString(string: self.plansContentsTextView.text, attributes: [.font: UIFont.hanSansRegularFont(ofSize: 14),.kern: -0.6])
                let style = NSMutableParagraphStyle()
                style.lineSpacing = 10
                attrString.addAttribute(NSAttributedString.Key.paragraphStyle, value: style, range: NSMakeRange(0, attrString.length))
                self.plansContentsTextView.attributedText = attrString
            })
            .disposed(by: disposeBag)
    }
    
    private func setupSearchTableView() {
        filteredFriendsRelay // 검색된 데이터 뿌리기
            .bind(to: searchResultTableView.rx.items) { (tableView, row, element) in
                guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchTVC.identifier) as? SearchTVC else { return UITableViewCell() }
                cell.setData(data: element)
                return cell
            }
            .disposed(by: disposeBag)
        
        searchResultTableView.rx.modelSelected(FriendsData.self)
            .asDriver()
            .drive(onNext: { [weak self] data in
                self?.selectedFriendList.append(data)
                var tokens = self?.selectedFriendList.map { SearchTokenType.selectedFriendToken(data: $0) } ?? []
                tokens.append(.inputFieldToken)
                self?.selectedFriendsListRelay.accept(tokens)
            })
            .disposed(by: disposeBag)
    }
    
    private func setupSelectedCollectionView() {
        selectedFriendsListRelay
            .bind(to: selectedCollectionView.rx.items) { (collectionView, item, element) in
                switch element {
                case .selectedFriendToken(let friendsData):
                    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchFieldTokenCVC.identifier, for: IndexPath(row: item, section: 0)) as? SearchFieldTokenCVC else { return UICollectionViewCell() }
                    cell.setFriendsData(friendsData: friendsData)
                    
                    cell.removeButton.rx.tap // 토큰 삭제버튼 눌렀을 때 처리
                        .asDriver()
                        .drive(onNext: { [weak self] in
                            guard let self = self else { return }
                            self.selectedFriendList = self.selectedFriendList.filter { $0.username != cell.friendsData.username }
                            var tokens = self.selectedFriendList.map { SearchTokenType.selectedFriendToken(data: $0) }
                            tokens.append(.inputFieldToken)
                            self.selectedFriendsListRelay.accept(tokens)
                        })
                        .disposed(by: self.disposeBag)
                    
                    return cell
                    
                case .inputFieldToken: // 항상 맨 마지막에 위치한다.
                    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchInputFieldCVC.identifier, for: IndexPath(row: item, section: 0)) as? SearchInputFieldCVC else { return UICollectionViewCell() }
                    cell.inputField.rx.text // 검색 처리
                        .distinctUntilChanged()
                        .bind(onNext: { [weak self] text in
                            self?.filteredFriendsRelay.accept(
                                self?.friendDataList.filter { $0.username.lowercased().prefix(text?.count ?? 0) == text?.lowercased().prefix(text?.count ?? 0) ?? ""
                                    && !(self?.selectedFriendList.contains($0) ?? false) } ?? []
                            )// 검색 필드 처리
                        })
                        .disposed(by: self.disposeBag)
                    
                    cell.inputField.rx.controlEvent(.editingDidBegin)
                        .asDriver()
                        .drive(onNext: { [weak self] _ in
                            self?.tableBackgroundView.isHidden = false
                            self?.searchResultTableView.isHidden = false
                            self?.searchFieldView.layer.borderColor = UIColor.pink01.cgColor
                            self?.searchFieldView.layer.borderWidth = 1.0
                        })
                        .disposed(by: self.disposeBag)
                    
                    cell.inputField.rx.controlEvent(.editingDidEnd)
                        .asDriver()
                        .drive(onNext: { [weak self] _ in
                            self?.tableBackgroundView.isHidden = true
                            self?.searchResultTableView.isHidden = true
                            self?.searchFieldView.layer.borderColor = UIColor.grey01.cgColor
                            self?.searchFieldView.layer.borderWidth = 1.0
                        })
                        .disposed(by: self.disposeBag)

                    return cell
                }
            }
            .disposed(by: disposeBag)
        
        selectedCollectionView.rx.setDelegate(self).disposed(by: disposeBag) // cell 크기 조정을 위해 delegate 사용
    }
    
    // MARK: - Network
    
    private func getFriendsList() {
        GetFriendsListService.shared.getFriendsList() { [weak self] response in
            switch response {
            case .success(let data) :
                if let response = data as? FriendsDataModel {
                    self?.friendDataList = response.data ?? []
                    if let friendDataToSet = self?.friendDataToSet {
                        self?.filteredFriendsRelay.accept(self?.friendDataList.filter { $0 != friendDataToSet } ?? [])
                    } else {
                        self?.filteredFriendsRelay.accept(self?.friendDataList ?? [])
                    }
                }
            case .requestErr(_):
                print("requestERR")
            case .pathErr :
                print("pathERR")
            case .serverErr:
                print("serverERR")
            case .networkFail:
                print("networkFail")
            }
        }
    }
}

// MARK: - Extension

extension RequestPlansContentsVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch indexPath.item {
        case self.selectedFriendsListRelay.value.count-1: // 컬렉션 뷰 셀 마지막 -> 입력 필드 셀
            if self.selectedFriendsListRelay.value.count > 1 {
                return CGSize(width: collectionView.bounds.width * 0.3, height: 26 * heightRatio)
            } else { // 아직 친구를 선택하지 않았을 때는 컬렉션 뷰 전체 너비를 차지하자
                return CGSize(width: collectionView.bounds.width, height: 26 * heightRatio)
            }
        default:
            return CGSize.init(width: 260 / 3 * widthRatio, height: 26 * heightRatio)
        }
    }
}

extension RequestPlansContentsVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // TextField 비활성화
        return true
    }
}

extension RequestPlansContentsVC: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}
