//
//  ProfilePageViewController.swift
//  STYLiSH
//
//  Created by 楊芮瑊 on 2024/7/20.
//

import UIKit
import Kingfisher
import FacebookLogin

class ProfilePageViewController: UIViewController {
    
    @IBOutlet weak var profileNavigationItem: UINavigationItem!
    @IBOutlet weak var profilePageCollectionView: UICollectionView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileNameLabel: UILabel!
    @IBOutlet weak var profileSpendingLabel: UILabel!
    
    let keyChainService = KeychainService()
    
    var accessToken: String? {
        didSet {
            getUserProfile(accessToken: accessToken ?? "")
        }
    }
    
    var userProfile: UserData? 
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        if let token = keyChainService.getToken() {
            self.accessToken = token
        }
        
        profileImageView.image = UIImage(named: "Icons_36px_Profile_Normal")!
        profileImageView.layer.cornerRadius = profileImageView.bounds.width / 2
        profileNameLabel.text = "-----"
        profileSpendingLabel.text = "累積消費 NT$ ---"
        
        profilePageCollectionView.dataSource = self
        profilePageCollectionView.collectionViewLayout = configureLayout()
        
        profilePageCollectionView.register(HeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "Header")
        
        // - Observe Language Change
        NotificationCenter.default.addObserver(self, selector: #selector(updateUI), name: .languageChanged, object: nil)
        updateUI()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .languageChanged, object: nil)
    }
    
}

// MARK: - Collection View Layout
extension ProfilePageViewController {
    
    func configureLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            if sectionIndex == 0{
                return self.myOrderLayout()
            } else {
                return self.moreServiceLayout()
            }
        }
    }
    
    func myOrderLayout() -> NSCollectionLayoutSection {
        
        let heightDimension = NSCollectionLayoutDimension.estimated(50)
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.2), heightDimension: heightDimension)
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: heightDimension)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item, item])
        
        let section = NSCollectionLayoutSection(group: group)
        
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(70))
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        
        section.boundarySupplementaryItems = [header]
        
        return section
    }
    
    func moreServiceLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.25), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(50))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item, item])
        
        let section = NSCollectionLayoutSection(group: group)
        
        section.interGroupSpacing = 24.0
        
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(70))
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        section.boundarySupplementaryItems = [header]
        
        return section
    }
}

// MARK: - Collection View DataSource
extension ProfilePageViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0: myOrder.count
        case 1: moreService.count
        default: 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemCell", for: indexPath) as! ItemCollectionViewCell
            cell.itemImageView.image = myOrder[indexPath.item].image
            cell.itemLabel.text = myOrder[indexPath.item].name
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemCell", for: indexPath) as! ItemCollectionViewCell
            cell.itemImageView.image = moreService[indexPath.item].image
            cell.itemLabel.text = moreService[indexPath.item].name
            return cell
        }
    }
    
}

// MARK: - Collection View Header
class HeaderView: UICollectionReusableView {
    
    let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "PingFangTC-Standard", size: 16)
        label.textAlignment = .center
        return label
    }()
    
    let button: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("查看全部", for: .normal)
        button.titleLabel?.font = UIFont(name: "PingFangTC-Standard", size: 13)
        button.setTitleColor(UIColor(red: 100/255, green: 100/255, blue: 100/255, alpha: 1.0), for: .normal)
        button.titleLabel?.textAlignment = .center
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(label)
        addSubview(button)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            label.centerYAnchor.constraint(equalTo: centerYAnchor),
            button.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -26),
            button.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ProfilePageViewController {
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Header", for: indexPath) as! HeaderView
        headerView.label.text = indexPath.section == 0 ? LocalizationManager.shared.strWithKey(key: "MyOrder.title") : LocalizationManager.shared.strWithKey(key: "MoreService.title")
        headerView.button.setTitle(LocalizationManager.shared.strWithKey(key: "SeeAllButton.title"), for: .normal)
        if indexPath.section == 1 {
            headerView.button.isHidden = true
        } else {
            headerView.button.isHidden = false
        }
        return headerView
    }
}

//MARK: - Get User Profile from API
extension ProfilePageViewController {
    
    func getUserProfile(accessToken: String) {
        
        let url = URL(string:"https://api.appworks-school.tw/api/1.0/user/profile")!
        
        var request = URLRequest(url: url)
        
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let error = error {
                print(error)
            }
            
            if let data {
                let decoder = JSONDecoder()
                do {
                    let userData = try decoder.decode(UserProfileRequest.self, from: data)
                    DispatchQueue.main.async {
                        self.userProfile = userData.data
                        self.profileImageView.kf.setImage(with: URL(string: userData.data.picture))
                        self.profileNameLabel.text = userData.data.name
                    }
                    print(data)
                } catch {
                    print(error)
                }
            }
        }
        task.resume()
    }
}

// MARK: - Update UI if Language Changing
extension ProfilePageViewController {
    @objc private func updateUI() {
        
        profileNavigationItem.title = LocalizationManager.shared.strWithKey(key: "qNA-Ve-5Bx.title")
        
        profileSpendingLabel.text = LocalizationManager.shared.strWithKey(key: "vqA-L9-l1r.text")
        
        for (index, item) in myOrder.enumerated() {
            let key = "MyOrderItem\(index + 1)"
            item.name = LocalizationManager.shared.strWithKey(key: key) ?? localizationMyOrder[key]!
        }
        for (index, item) in moreService.enumerated() {
            let key = "MoreService\(index + 1)"
            item.name = LocalizationManager.shared.strWithKey(key: key) ?? localizationMoreService[key]!
        }
        profilePageCollectionView.reloadData()
    }
}

