//
//  CartPageViewController.swift
//  STYLiSH
//
//  Created by 楊芮瑊 on 2024/7/31.
//

import UIKit
import CoreData
import StatusAlert
import FacebookLogin

class CartPageViewController: UIViewController {
    
    @IBOutlet weak var cartPageTableView: UITableView!
    @IBOutlet weak var checkoutButton: UIButton!
    @IBOutlet weak var logoutBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var cartNavigationItem: UINavigationItem!
    
    var fetchedResultsController: NSFetchedResultsController<ProductInCart>!
    
    var managedContext: NSManagedObjectContext {
            return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }
    
    var totalProductDidChange: ((Int) -> Void)?
    
    var totalProductsAmount = 0 {
        didSet{
            updateBadge()
            totalProductDidChange?(totalProductsAmount)
            updateCheckoutButton()
        }
    }
    
    var checkProducts: [ProductInCart] = []
    
    @IBAction func goToCheckButton(_ sender: Any) {
        addProductsToCheck()
        performSegue(withIdentifier: "showCheckPage", sender: sender)
    }
    
    @IBAction func logout(_ sender: Any) {
        let loginManager = LoginManager()
        loginManager.logOut()
        if AccessToken.current == nil {
            showStatusAlert("登出成功")
            logoutBarButtonItem.isHidden = true
        } else {
            showStatusAlert("登出失敗")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.cartPageViewController = self
        }
        
        cartPageTableView.delegate = self
        cartPageTableView.dataSource = self
        cartPageTableView.separatorStyle = .none
        
        initializeFetchedResultsController()
        
        // - Observe Language Change
        NotificationCenter.default.addObserver(self, selector: #selector(updateUI), name: .languageChanged, object: nil)
        updateUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        initializeFetchedResultsController()
        updateTotalProducts()
        if let accessToken = AccessToken.current, !accessToken.isExpired {
            logoutBarButtonItem.isHidden = false
        } else {
            logoutBarButtonItem.isHidden = true
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .languageChanged, object: nil)
    }
}

//MARK: - Update Table View From Core Data
extension CartPageViewController: NSFetchedResultsControllerDelegate {
    func initializeFetchedResultsController() {
        let fetchRequest: NSFetchRequest<ProductInCart> = ProductInCart.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("Fetch request failed: \(error)")
        }
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        cartPageTableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let newIndexPath = newIndexPath {
                cartPageTableView.insertRows(at: [newIndexPath], with: .automatic)
            }
        case .delete:
            if let indexPath = indexPath {
                cartPageTableView.deleteRows(at: [indexPath], with: .automatic)
            }
        case .update:
            if let indexPath = indexPath {
                cartPageTableView.reloadRows(at: [indexPath], with: .automatic)
            }
        case .move:
            if let oldIndexPath = indexPath, let newIndexPath = newIndexPath {
                cartPageTableView.moveRow(at: oldIndexPath, to: newIndexPath)
            }
        @unknown default:
            fatalError("Unknown case in NSFetchedResultsChangeType")
        }
    }
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        updateTotalProducts()
        cartPageTableView.endUpdates()
    }
}



//MARK: - TableView DataSource
extension CartPageViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections?[section]
        return sectionInfo?.numberOfObjects ?? 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CartProductCell", for: indexPath) as! CartProductCell
        cell.delegate = self
        let entity = fetchedResultsController.object(at: indexPath)
        cell.updateCartCell(withEntity: entity)
        cell.updateUI()
        return cell
    }
}

//MARK: - Remove Product
extension CartPageViewController: CartProductCellDelegate {
    
    func didTapRemoveButton(in cell: CartProductCell) {
        if let indexPath = cartPageTableView.indexPath(for: cell) {
            deleteItem(at: indexPath)
        }
    }
    
    func deleteItem(at indexPath: IndexPath) {
        let itemToDelete = fetchedResultsController.object(at: indexPath)
        managedContext.delete(itemToDelete)

        do {
            try managedContext.save()
        } catch {
            print("Failed to delete item: \(error)")
        }
    }
    
    func didChangeAmount(amount: Int, in cell: CartProductCell) {
        guard let indexPath = cartPageTableView.indexPath(for: cell) else { return }
        updateItem(at: indexPath, with: "\(amount)")
    }
    
    func updateItem(at indexPath: IndexPath, with newValue: String) {
        let itemToUpdate = fetchedResultsController.object(at: indexPath)
        itemToUpdate.amount = Int32(newValue)! 
        
        do {
            try managedContext.save()
        } catch {
            print("Failed to update item: \(error)")
        }
    }
}

// MARK: - Setup Tab Bar
extension UITabBarController {
    func setBadgeValue(for index: Int, count: Int) {
        let badgeValue = count > 0 ? "\(count)" : nil
        if let items = self.tabBar.items, index < items.count {
            items[index].badgeColor = UIColor.hexStringToUIColor(hex: "845932")
            items[index].badgeValue = badgeValue
        }
    }
    
}
//MARK: - Update Total Products for Badge
extension CartPageViewController {
    func updateTotalProducts() {
        let fetchRequest: NSFetchRequest<ProductInCart> = ProductInCart.fetchRequest()
        do {
            let results = try managedContext.fetch(fetchRequest)
            totalProductsAmount = results.reduce(0) { $0 + Int($1.amount) }
        } catch {
            print("Failed to fetch values: \(error)")
        }
    }
    
    func updateBadge() {
        UserDefaults.standard.set(totalProductsAmount, forKey: "cartBadgeValue")
        if let tabBarController = self.tabBarController {
            tabBarController.setBadgeValue(for: 2, count: totalProductsAmount)
        }
    }
}
//MARK: - Update Checkout Button
extension CartPageViewController {
    func updateCheckoutButton() {
        if totalProductsAmount > 0 {
            checkoutButton.isUserInteractionEnabled = true
            checkoutButton.backgroundColor = UIColor.hexStringToUIColor(hex: "3F3A3A")
        } else {
            checkoutButton.isUserInteractionEnabled = false
            checkoutButton.backgroundColor = UIColor.hexStringToUIColor(hex: "999999")
        }
    }
}

// MARK: - Show Checkout Page
extension CartPageViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showCheckPage" {
            if let checkVC = segue.destination as? CheckOutPageViewController{
                checkVC.checkProducts = checkProducts
                if UIDevice.current.userInterfaceIdiom == .phone {
                    checkVC.modalPresentationStyle = .fullScreen
                }
            }
        }
    }
    
    func addProductsToCheck() {
        if let products = fetchedResultsController.fetchedObjects {
            checkProducts = products
        } else {
            print("No products fetched.")
        }
    }
}

//MARK: - Show Status Alert
extension CartPageViewController {
    func showStatusAlert(_ status: String) {
        let statusAlert = StatusAlert()
        statusAlert.image = UIImage(named: "Icons_44px_Success01")!
        statusAlert.title = status
        statusAlert.sizesAndDistances.alertWidth = 200
        statusAlert.sizesAndDistances.minimumAlertHeight = 200
        statusAlert.showInKeyWindow()
    }
}

// MARK: - Update UI if Language Changing
extension CartPageViewController {
    @objc func updateUI() {
        cartPageTableView.reloadData()
        cartNavigationItem.title = LocalizationManager.shared.strWithKey(key: "4O1-lk-EMA.title")
        checkoutButton.setTitle(LocalizationManager.shared.strWithKey(key: "GnC-FW-hqq.configuration.title"), for: .normal)
        logoutBarButtonItem.title = LocalizationManager.shared.strWithKey(key: "mmG-CK-S8e.title")
    }
}
