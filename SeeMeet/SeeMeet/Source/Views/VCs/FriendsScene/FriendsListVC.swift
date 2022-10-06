import UIKit

protocol FriendsListVCDelegate {
    func backButtonDidTap()
    func messageButtonDidTap(friendData: FriendsData)
    func addFriendsButtonDidTap()
}

class FriendsListVC: UIViewController {
    
    // MARK: - UI Components
    
    private let topView: UIView = UIView().then {
        $0.backgroundColor = UIColor.clear
    }
    
    private let navigationTitleLabel: UILabel = UILabel().then {
        $0.text = "친구"
        $0.textColor = UIColor.grey06
        $0.font = UIFont.hanSansMediumFont(ofSize: 18)
    }
    
    private let backButton: UIButton = UIButton().then {
        $0.setImage(UIImage(named: "btn_back"), for: .normal)
    }
    
    private let addFriendsButton: UIButton = UIButton().then {
        $0.setImage(UIImage(named: "btn_add-friends"), for: .normal)
    }
    
    private let searchBar: SMSearchBar = SMSearchBar().then {
        $0.placeholder = "친구 검색"
    }
    
    private let separator: UIView = UIView().then {
        $0.backgroundColor = UIColor.clear
    }
    
    private let tableView: UITableView = UITableView().then {
        $0.register(FriendsListTVC.self, forCellReuseIdentifier: FriendsListTVC.identifier)
    }
    
    private lazy var emptyImage: UIImageView = UIImageView().then {
        $0.image = UIImage(named: "img_illust_9")
    }
    
    private lazy var emptyMessageLabel1: UILabel = UILabel().then {
        $0.font = UIFont.hanSansRegularFont(ofSize: 16)
        $0.textColor = UIColor.grey05
        $0.text = "등록된 친구가 없어요!"
    }
    
    private lazy var emptyMessageLabel2: UILabel = UILabel().then {
        $0.font = UIFont.hanSansRegularFont(ofSize: 16)
        $0.textColor = UIColor.grey05
        $0.text = "친구를 추가해 주세요"
    }
    
    // MARK: - Properties
    
    static let identifier: String = "FriendsListVC"
    
    weak var coordinator: Coordinator?
    private var filteredFriendsData: [FriendsData] = []
    var delegate: FriendsListVCDelegate?
    
    private var friendsData: [FriendsData]?
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setAutoLayouts()
        configUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getFriendsList()
    }
    
    // MARK: - setLayouts
    
    private func setAutoLayouts() {
        view.dismissKeyboardWhenTappedAround()
        view.addSubviews([topView, searchBar, separator,tableView])
        topView.addSubviews([navigationTitleLabel, backButton, addFriendsButton])
        
        topView.snp.makeConstraints {
            $0.leading.trailing.top.equalToSuperview()
            $0.height.equalTo(102 * heightRatio)
        }
        
        backButton.snp.makeConstraints {
            $0.width.height.equalTo(48 * heightRatio)
            $0.leading.equalTo(2 * widthRatio)
            $0.bottom.equalTo(5 * heightRatio)
        }
        
        navigationTitleLabel.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(-11 * heightRatio)
            $0.leading.equalTo(backButton.snp.trailing).offset(120 * widthRatio)
        }
        
        addFriendsButton.snp.makeConstraints {
            $0.width.height.equalTo(48 * heightRatio)
            $0.centerY.equalTo(backButton.snp.centerY)
            $0.trailing.equalToSuperview().offset(-11 * widthRatio)
        }
        
        searchBar.delegate = self
        searchBar.snp.makeConstraints {
            $0.width.equalTo(335 * widthRatio)
            $0.height.equalTo(50 * heightRatio)
            $0.top.equalTo(topView.snp.bottom).offset(14 * heightRatio)
            $0.centerX.equalToSuperview()
        }
        
        separator.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(searchBar.snp.bottom).offset(14 * heightRatio)
            $0.height.equalTo(1)
        }
    }
    
    private func setAutoLayoutsIfEmptyTable() {
        view.addSubviews([emptyImage, emptyMessageLabel1, emptyMessageLabel2])
        emptyImage.snp.makeConstraints {
            $0.width.height.equalTo(164 * heightRatio)
            $0.top.equalTo(searchBar.snp.bottom).offset(135 * heightRatio)
            $0.centerX.equalToSuperview()
        }
        
        emptyMessageLabel1.snp.makeConstraints {
            $0.top.equalTo(emptyImage.snp.bottom).offset(17 * heightRatio)
            $0.centerX.equalToSuperview()
        }
        
        emptyMessageLabel2.snp.makeConstraints {
            $0.top.equalTo(emptyMessageLabel1.snp.bottom).offset(4 * heightRatio)
            $0.centerX.equalToSuperview()
        }
    }
    
    // MARK: - Custom Methods
    
    private func configUI() {
        backButton.addTarget(self, action: #selector(backButtonDidTap(_:)), for: .touchUpInside)
        addFriendsButton.addTarget(self, action: #selector(addFriendsButtonDidTap(_:)), for: .touchUpInside)
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
    }
    
    // MARK: - Network
    
    func getFriendsList() {
        GetFriendsListService.shared.getFriendsList(){ [weak self] (response) in
            guard let self = self else { return }
            switch response {
            case .success(let data):
                if let response = data as? FriendsDataModel {
                    self.friendsData = response.data
                    if let friendsData = self.friendsData, friendsData.count > 0 {
                        self.tableView.snp.makeConstraints {
                            $0.leading.equalToSuperview().offset(20 * widthRatio)
                            $0.trailing.equalToSuperview().offset(-11 * widthRatio)
                            $0.bottom.equalToSuperview()
                            $0.top.equalTo(self.separator.snp.bottom)
                        }
                        self.tableView.reloadData()
                    } else {
                        self.setAutoLayoutsIfEmptyTable()
                    }
                }
            case .requestErr(let message) :
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
    
    // MARK: - Actions
    
    @objc private func backButtonDidTap(_ sender: UIButton) {
        delegate?.backButtonDidTap()
    }
    
    @objc private func addFriendsButtonDidTap(_ sender: UIButton) {
        delegate?.addFriendsButtonDidTap()
    }
    
    // MARK: - tableview Delegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !scrollView.contentOffset.y.isZero {
            separator.backgroundColor = UIColor.grey02
        } else {
            separator.backgroundColor = UIColor.clear
        }
    }
}

// MARK: - Extensions

extension FriendsListVC: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.layer.borderColor = UIColor.pink01.cgColor
        searchBar.layer.borderWidth = 1
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.layer.borderColor = nil
        searchBar.layer.borderWidth = 0
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if !searchText.isEmpty {
            filteredFriendsData = friendsData?.filter { $0.username.lowercased().prefix(searchText.count) == searchText.lowercased() } ?? []
        } else {
            filteredFriendsData.removeAll()
        }
        tableView.reloadData() // 일단은 음절단위로 갑시다!
    }
}

extension FriendsListVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if filteredFriendsData.isEmpty {
            return friendsData?.count ?? 0
        } else {
            return filteredFriendsData.count
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FriendsListTVC.identifier, for: indexPath) as? FriendsListTVC else { return UITableViewCell() }
        if filteredFriendsData.isEmpty {
            cell.nameLabel.text = friendsData?.map({$0.username})[indexPath.row] ?? ""
            cell.friendData = friendsData?[indexPath.row]
        } else {
            cell.nameLabel.text = filteredFriendsData.map({$0.username})[indexPath.row]
            cell.friendData = filteredFriendsData[indexPath.row]
        }
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 68 * heightRatio
    }
}

extension FriendsListVC: FriendsListTVCDelegate {
    func messageButtonDidTap(friendData: FriendsData) {
        delegate?.messageButtonDidTap(friendData: friendData)
    }
}
