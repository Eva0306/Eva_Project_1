//
//  ViewController.swift
//  STYLiSH
//
//  Created by 楊芮瑊 on 2024/7/17.
//

import UIKit
import Kingfisher
import MJRefresh


class HomePageViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var homePageTableView: UITableView!
    
    @IBOutlet weak var changeLanguageBarButtonItem: UIBarButtonItem!
    
    var totalProducts = 0
    
    var marketManger = MarketManager()
    
    var marketingHotsArray: [MarketingHots] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        homePageTableView.dataSource = self
        homePageTableView.delegate = self
        
        homePageTableView.separatorStyle = .none
        
        marketManger.delegate = self
        
        fetchData()
        
        headerRefresh()
        
        updateCartBadge()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateUI), name: .languageChanged, object: nil)
        
        updateUI()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBAction func changeLanguage(_ sender: Any) {
        let currentLanguage = LocalizationManager.shared.language
        let newLanguage: Language = (currentLanguage == .english) ? .chineseT : .english
        
        LocalizationManager.shared.language = newLanguage
        
        NotificationCenter.default.post(name: .languageChanged, object: nil)
    }
}

// MARK: - Market Manager Delegate
extension HomePageViewController: MarketManagerDelegate {
    
    func manager(_ manager: MarketManager, didGet marketingHots: MarketingHotsData) {
        self.marketingHotsArray = marketingHots.data
        self.homePageTableView.reloadData()
        self.homePageTableView.mj_header?.endRefreshing()
    }
    
    func manager(_ manager: MarketManager, didFailWith error: any Error) {
        print(error)
        self.homePageTableView.mj_header?.endRefreshing()
    }
}


// MARK: - Table View DataSource
extension HomePageViewController {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        marketingHotsArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        marketingHotsArray[section].products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row % 2 == 0 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "SingleImageCell", for: indexPath) as! SingleImageTableViewCell
            let product = marketingHotsArray[indexPath.section].products[indexPath.row]
            cell.updateCell(for: product)
            
            return cell
            
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "FourImageCell", for: indexPath) as! FourImageTableViewCell
            let product = marketingHotsArray[indexPath.section].products[indexPath.row]
            cell.updateCell(for: product)
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        let myLabel = UILabel()
        myLabel.backgroundColor = UIColor.white
        myLabel.frame = CGRect(x: 16, y: 0, width: tableView.frame.width, height: 60)
        myLabel.font = UIFont(name: "PingFangTC-Bold", size: 18)
        myLabel.text = marketingHotsArray[section].title
        myLabel.textColor = UIColor.hexStringToUIColor(hex: "3F3A3A")

        let headerView = UIView()
        headerView.addSubview(myLabel)

        return headerView
    }
}

// MARK: - Table View Delegate
extension HomePageViewController {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "showProductDetail", sender: indexPath)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showProductDetail" {
            if let detailVC = segue.destination as? DetailPageTableViewController,
               let indexPath = sender as? IndexPath {
                let selectedProduct = marketingHotsArray[indexPath.section].products[indexPath.row]
                detailVC.product = selectedProduct
                if UIDevice.current.userInterfaceIdiom == .phone {
                    detailVC.modalPresentationStyle = .fullScreen
                }
            }
        }
    }
    
}

// MARK: - Fetch Data
extension HomePageViewController {
    
    func fetchData() {
        marketManger.delegate = self
        marketManger.getMarketingHots()
    }
}

// MARK: - Pull to Refresh
extension HomePageViewController {
    
    func headerRefresh() {
        MJRefreshConfig.default.languageCode = "en"
        let header = MJRefreshNormalHeader { [weak self] in
            self?.fetchData()
        }
        
        homePageTableView.mj_header = header
    }
}

//MARK: - Update Tab Bar Badge
extension HomePageViewController {
    func updateCartBadge() {
        let badgeValue = UserDefaults.standard.integer(forKey: "cartBadgeValue")
        if let tabBarController = self.tabBarController {
            tabBarController.setBadgeValue(for: 2, count: badgeValue)
        }
    }
}

//MARK: - Change Language
extension HomePageViewController {
    
    @objc private func updateUI() {
        changeLanguageBarButtonItem.title = LocalizationManager.shared.strWithKey(key: "ChangeLanguangeItem.title")
    }
}

