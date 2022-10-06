import UIKit


class FriendsAddVC: UIViewController {
    
    // MARK: - UI Components
    
    private let topView: UIView = UIView().then {
        $0.backgroundColor = UIColor.grey06
    }
    
    private let navigationTitleLabel: UILabel = UILabel().then {
        $0.text = "친구 추가"
        $0.font = UIFont.hanSansMediumFont(ofSize: 18)
        $0.textColor = UIColor.white
    }
    
    private let closeButton: UIButton = UIButton().then {
        $0.setImage(UIImage(named: "btn_close_white"), for: .normal)
    }
    
    private let searchBar: SMSearchBar = SMSearchBar().then {
        $0.placeholder = "친구 아이디"
    }
    
    private lazy var tableView: UITableView = UITableView().then {
        $0.separatorStyle = .none
        $0.register(FriendsAddTVC.self, forCellReuseIdentifier: FriendsAddTVC.identifier)
    }
    
    private let undefinedLabel: UILabel = UILabel().then {
        $0.text = "검색 결과가 없습니다."
        $0.font = UIFont.hanSansRegularFont(ofSize: 16)
        $0.textColor = UIColor.grey03
        $0.isHidden = true
    }
    
    // MARK: - Properties
    
    static let identifier: String = "FriendsAddVC"
    
    weak var coordinator: Coordinator?
    
    private var searchResults: FriendData? {
        didSet {
            tableView.reloadData()
        }
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        setAutoLayouts()
    }
    
    // MARK: - Layout
    
    private func setAutoLayouts() {
        view.dismissKeyboardWhenTappedAround()
        view.addSubviews([topView, searchBar, tableView, undefinedLabel])
        topView.addSubviews([navigationTitleLabel, closeButton])
        
        topView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            if UIScreen.hasNotch {
                $0.height.equalTo(102 * heightRatio)
            } else {
                $0.height.equalTo((58 + CGFloat(UIScreen.getIndecatorHeight())) * heightRatio)
            }
        }
        
        navigationTitleLabel.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(-15 * heightRatio)
            $0.leading.equalToSuperview().offset(152 * widthRatio)
        }
        
        closeButton.snp.makeConstraints {
            $0.width.height.equalTo(48 * heightRatio)
            $0.trailing.equalToSuperview().offset(-5 * widthRatio)
            $0.bottom.equalToSuperview().offset(-4 * heightRatio)
        }
        
        searchBar.snp.makeConstraints {
            $0.top.equalTo(topView.snp.bottom).offset(14 * heightRatio)
            $0.leading.equalToSuperview().offset(20 * widthRatio)
            $0.trailing.equalToSuperview().offset(-20 * widthRatio)
            $0.height.equalTo(50 * heightRatio)
        }
        
        tableView.snp.makeConstraints {
            $0.leading.equalTo(20 * widthRatio)
            $0.trailing.equalTo(-14 * widthRatio)
            $0.bottom.equalToSuperview()
            $0.top.equalTo(searchBar.snp.bottom).offset(30 * heightRatio)
        }
        
        undefinedLabel.snp.makeConstraints {
            $0.top.equalTo(searchBar.snp.bottom).offset(47 * heightRatio)
            $0.centerX.equalToSuperview()
        }
    }
    
    // MARK: - Custom Methods
    
    private func configUI() {
        closeButton.addTarget(self, action: #selector(closeButtonDidTap(_:)), for: .touchUpInside)
        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    // MARK: - Network
    
    private func requestFriendsSearchResults(nickname: String) {
        FriendsSearchService.shared.searchFriends(nickname: nickname) { responseData in
            switch responseData {
            case .success(let response):
                guard let response = response as? FriendsSearchResponseModel else { return }
                self.searchResults = response.data
                self.undefinedLabel.isHidden = true
                self.tableView.isHidden = false
                
            case .requestErr(_):
                self.undefinedLabel.isHidden = false
                self.tableView.isHidden = true
            case .pathErr:
                print("Path Error")
                self.undefinedLabel.isHidden = false
                self.tableView.isHidden = true
            case .serverErr:
                self.undefinedLabel.isHidden = false
                self.tableView.isHidden = true
                print("Server Error")
            case .networkFail:
                self.undefinedLabel.isHidden = false
                self.tableView.isHidden = true
                print("Network Fail")
            }
        }
    }
    
    // MARK: - Actions
    
    @objc private func closeButtonDidTap(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
}

// MARK: - Extensions

extension FriendsAddVC: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.layer.borderColor = UIColor.pink01.cgColor
        searchBar.layer.borderWidth = 1
        undefinedLabel.isHidden = true
        tableView.isHidden = false
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.layer.borderColor = nil
        searchBar.layer.borderWidth = 0
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) { // 키보드 완료
        searchBar.endEditing(true)
        guard let searchEmail = searchBar.text else { return }
        requestFriendsSearchResults(nickname: searchEmail)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            tableView.isHidden = true
        }
    }
}

extension FriendsAddVC: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchResults != nil {
            return 1
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: FriendsAddTVC = tableView.dequeueReusableCell(withIdentifier: FriendsAddTVC.identifier) as? FriendsAddTVC else { return UITableViewCell() }
        cell.nameLabel.text = searchResults?.username
        cell.emailLabel.text = searchResults?.email
        cell.nickname = searchResults?.nickname
        cell.delegate = self
        return cell
    }
}

extension FriendsAddVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 53 * heightRatio
    }
}

extension FriendsAddVC: FriendsAddTVCDelegate {
    func friendsAddTVC(cell: FriendsAddTVC, resultMessage: String) {
        view.makeToastAnimation(message: resultMessage)
    }
}
