//
//  CatalogPageViewController.swift
//  STYLiSH
//
//  Created by 楊芮瑊 on 2024/7/22.
//

import UIKit
import MJRefresh

class CatalogPageViewController: UIViewController {
    
    @IBOutlet weak var catalogPageCollectionView: UICollectionView!
    
    @IBOutlet weak var womanPageButton: UIButton!
    @IBOutlet weak var manPageButton: UIButton!
    @IBOutlet weak var accessoryPageButton: UIButton!
    @IBOutlet weak var womanPageButtomView: UIView!
    @IBOutlet weak var manPageButtomView: UIView!
    @IBOutlet weak var accessoryPageButtomView: UIView!
    @IBOutlet weak var pageStackView: UIStackView!
    
    @IBOutlet weak var catalogTitleNavigationItem: UINavigationItem!
    
    var productListArray = ProductListDataModel(data: [], nextPaging: 0)
    var productListManager = ProductListManager()
    
    var pageCategory: Category = .women
    
    var isCachingData = false
    
    var underLineView = UIView()
    var underLineViewCenterXConstraint: NSLayoutConstraint?
    let selectedColor = UIColor.hexStringToUIColor(hex: "3F3A3A")
    let originColor = UIColor.hexStringToUIColor(hex: "888888")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        catalogPageCollectionView.dataSource = self
        catalogPageCollectionView.delegate = self
        catalogPageCollectionView.collectionViewLayout = configureLayout()
        
        catalogPageCollectionView.allowsSelection = true
        
        productListManager.delegate = self
        
        
        fetchData(from: pageCategory)
        
        
        headerRefresh()
        footerLoadMore()
        
        
    // MARK: - Underline for Page Change
        self.view.bringSubviewToFront(underLineView)
        
        underLineView.backgroundColor = selectedColor
        underLineView.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(underLineView)
        underLineViewCenterXConstraint = underLineView.centerXAnchor.constraint(equalTo: womanPageButton.centerXAnchor)
        
        NSLayoutConstraint.activate([
            underLineView.widthAnchor.constraint(equalTo: womanPageButton.widthAnchor),
            underLineView.heightAnchor.constraint(equalToConstant: 1),
            underLineViewCenterXConstraint!,
            underLineView.bottomAnchor.constraint(equalTo: pageStackView.bottomAnchor)
        ])
        
        // - Observe Language Change
        NotificationCenter.default.addObserver(self, selector: #selector(updateUI), name: .languageChanged, object: nil)
        updateUI()
    }
    
    // MARK: - Change Page
    @IBAction func showPage(_ sender: UIButton) {
        setUnderlineView(sender: sender)
        let buttons = [womanPageButton, manPageButton, accessoryPageButton]
        for button in buttons {
            button?.tintColor = (button == sender) ? selectedColor : originColor
        }
        if sender == womanPageButton {
            pageCategory = .women
            fetchData(from: .women, isRefresh: false, isLoadMore: false)
        } else if sender == manPageButton {
            pageCategory = .men
            fetchData(from: .men, isRefresh: false, isLoadMore: false)
        } else if sender == accessoryPageButton {
            pageCategory = .accessories
            fetchData(from: .accessories, isRefresh: false, isLoadMore: false)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .languageChanged, object: nil)
    }
}

// MARK: - Change Page Animation
extension CatalogPageViewController {
    func setUnderlineView(sender: UIButton) {
        underLineViewCenterXConstraint?.isActive = false
        
        underLineViewCenterXConstraint = underLineView.centerXAnchor.constraint(equalTo: sender.centerXAnchor)
        underLineViewCenterXConstraint?.isActive = true
        
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
                    self.view.layoutIfNeeded()
                }, completion: nil)
    }
}

// MARK: - Product List Delegate
extension CatalogPageViewController: ProductListDelegate {
    func manager(_ manager: ProductListManager, didGet productList: ProductListDataModel, isRefresh: Bool, isLoadMore: Bool) {
        if isLoadMore {
            self.productListArray.data.append(contentsOf: productList.data)
            self.productListArray.nextPaging = productList.nextPaging
        } else {
            self.productListArray = productList
        }
        
        self.catalogPageCollectionView.reloadData()
                
        self.catalogPageCollectionView.mj_header?.endRefreshing()
        self.catalogPageCollectionView.mj_footer?.endRefreshing()
    }
    
    func manager(_ manager: ProductListManager, didFailWith error: any Error) {
        print(error)
        self.catalogPageCollectionView.mj_header?.endRefreshing()
        self.catalogPageCollectionView.mj_footer?.endRefreshing()
    }
}

// MARK: - Collection View Layout
extension CatalogPageViewController {
    func configureLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 7.5, bottom: 0, trailing: 7.5)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(330))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item, item])
        
        group.contentInsets = NSDirectionalEdgeInsets(top: 12.0, leading: 7.5, bottom: 0, trailing: 7.5)
        
        let section = NSCollectionLayoutSection(group: group)
        
        section.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 0, bottom: 12, trailing: 0)
        
        return UICollectionViewCompositionalLayout(section: section)
    }
}

// MARK: - Collection View DataSource
extension CatalogPageViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        productListArray.data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CatalogCollectionViewCell", for: indexPath) as! CatalogCollectionViewCell
        cell.updateCell(with: productListArray.data[indexPath.item])
        return cell
    }
}

// MARK: - Fetch Data
extension CatalogPageViewController {
    func fetchData(from category: Category, isRefresh: Bool = false, isLoadMore: Bool = false){
        productListManager.delegate = self
        let page = isLoadMore ? productListArray.nextPaging : 0
        if page != 0 && productListArray.nextPaging == nil {
            self.catalogPageCollectionView.mj_footer?.endRefreshingWithNoMoreData()
            return
        }
        productListManager.getProductList(for: pageCategory, in: page!, isRefresh: isRefresh, isLoadMore: isLoadMore)
    }
}

// MARK: - Pull to Refresh and Load More
extension CatalogPageViewController {
    
    func headerRefresh() {
        MJRefreshConfig.default.languageCode = "en"
        let header = MJRefreshNormalHeader { [weak self] in
            self?.fetchData(from: self?.pageCategory ?? .women, isRefresh: true, isLoadMore: false)
        }
        
        catalogPageCollectionView.mj_header = header
    }
    
    func footerLoadMore() {
        let footer = MJRefreshBackNormalFooter { [weak self] in
            self?.fetchData(from: self?.pageCategory ?? .women, isRefresh: false,  isLoadMore: true)
        }
        
        catalogPageCollectionView.mj_footer = footer
    }
}

// MARK: - Collection View Delegate
extension CatalogPageViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        performSegue(withIdentifier: "showDetail", sender: indexPath)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let detailVC = segue.destination as? DetailPageTableViewController,
               let indexPath = sender as? IndexPath {
                let selectedProduct = productListArray.data[indexPath.item]
                detailVC.product = selectedProduct
                if UIDevice.current.userInterfaceIdiom == .phone {
                    detailVC.modalPresentationStyle = .fullScreen
                }
            }
        }
    }
}

// MARK: - Update UI if Language Changing
extension CatalogPageViewController {
    @objc private func updateUI() {
        
        catalogTitleNavigationItem.title = LocalizationManager.shared.strWithKey(key: "gQ0-6R-wHh.title")
        womanPageButton.setTitle(LocalizationManager.shared.strWithKey(key: "aPY-1g-c1t.configuration.title"), for: .normal)
        manPageButton.setTitle(LocalizationManager.shared.strWithKey(key: "znw-pw-ysS.configuration.title"), for: .normal)
        accessoryPageButton.setTitle(LocalizationManager.shared.strWithKey(key: "dyI-So-EPa.configuration.title"), for: .normal)
    }
}
