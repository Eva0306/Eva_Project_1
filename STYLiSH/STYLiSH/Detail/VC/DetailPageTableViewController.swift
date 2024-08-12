//
//  DetailPageTableViewController.swift
//  STYLiSH
//
//  Created by 楊芮瑊 on 2024/7/26.
//

import UIKit
import CoreData
import Kingfisher
import StatusAlert

class DetailPageTableViewController: UIViewController {
    
    @IBOutlet weak var DetailPageTableView: UITableView!
    @IBOutlet weak var backBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var addingToCartButton: UIButton!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var containerViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var overlayView: UIView!
    
    var managedContext: NSManagedObjectContext {
        return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }
    var badgeValue = UserDefaults.standard.integer(forKey: "cartBadgeValue")
    
    var product: Product?
    var cartVC: AddToCartPageViewController?
    var amount = 1
    
    var selectedVariant: Variant?
    var selectedColor: Color?
    
    @IBAction func backToForePage(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func addToCart(_ sender: UIButton) {
        if containerView.isHidden {
            showCartView()
        } else {
            initializedCartVC()
            overlayView.isHidden = true
            showSuccessAlert()
            
            containerViewBottomConstraint.constant = -containerView.frame.height
            UIView.animate( withDuration: 0.3, animations: {
                self.view.layoutIfNeeded()
            }, completion: { _ in
                self.containerView.isHidden = true
                self.containerView.alpha = 0
            })
            
            addProduct()
            updateCartBadge(for: amount)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DetailPageTableView.dataSource = self
        DetailPageTableView.delegate = self
        DetailPageTableView.separatorStyle = .none
        
        adjustSafeAreaInsets()
        
        backBarButtonItem.image = UIImage(named: "Icons_44px_Back01")?.withRenderingMode(.alwaysOriginal)
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.backgroundColor = .clear
        
        // - Observe Language Change
        NotificationCenter.default.addObserver(self, selector: #selector(updateUI), name: .languageChanged, object: nil)
        updateUI()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        adjustSafeAreaInsets()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
        containerView.isHidden = true
        containerView.alpha = 0
        containerViewBottomConstraint.constant = -containerView.frame.height
        overlayView.isHidden = true
        totalProductsChange()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .languageChanged, object: nil)
    }
}

//MARK: - Adjust Safe Area Insets
extension DetailPageTableViewController {
    private func adjustSafeAreaInsets() {
        if let windowScene = view.window?.windowScene {
            let topPadding = windowScene.windows.first?.safeAreaInsets.top ?? 0
            self.additionalSafeAreaInsets.top = -topPadding
            
            DetailPageTableView.contentInset = UIEdgeInsets(top: -topPadding, left: 0, bottom: 0, right: 0)
        }
    }
}

//MARK: - Table View DetaSource
extension DetailPageTableViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ImageScrollViewCell", for: indexPath) as! ImageScrollViewCell
            cell.pageControl.numberOfPages = 4
            if let product = product {
                cell.image1View.kf.setImage(with: URL(string: product.images[0]))
                cell.image2View.kf.setImage(with: URL(string: product.images[1]))
                cell.image3View.kf.setImage(with: URL(string: product.images[2]))
                cell.image4View.kf.setImage(with: URL(string: product.images[3]))
            }
            return cell
            
        } else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "InfoCell", for: indexPath) as! InfoTableViewCell
            if let product = product {
                cell.nameLabel.text = product.title
                cell.idLabel.text = "\(product.id)"
                cell.priceLabel.text = "NT$\(product.price)"
            }
            return cell
            
        } else if indexPath.row == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "StoryCell", for: indexPath) as! StoryTableViewCell
            if let product = product {
                cell.storyLabel.text = product.story
            }
            return cell
            
        } else if indexPath.row == 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ColorCell", for: indexPath) as! ColorTableViewCell
            if let product = product {
                let colors = product.colors.map{UIColor.hexStringToUIColor(hex: $0.code)}
                cell.addColorViews(colors: colors)
            }
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "VariantsCell", for: indexPath) as! VariantsTableViewCell
            if let product = product {
                cell.updatCell(with: product, for: indexPath.row - 4)
            }
            return cell
        }
        
        
    }
}

//MARK: - Hide Cart View
extension DetailPageTableViewController: CartInfoCellDelegate {
    
    func showCartView() {
        containerView.isHidden = false
        containerViewBottomConstraint.constant = 0
        containerView.alpha = 1
        self.addingToCartButton.backgroundColor = UIColor.hexStringToUIColor(hex: "999999")
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
        })
        overlayView.isHidden = false
        self.addingToCartButton.isUserInteractionEnabled = false
    }
    
    func didTapCloseButton(in cell: CartInfoCell) {
        containerViewBottomConstraint.constant = -containerView.frame.height
        UIView.animate( withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
        }, completion: { _ in
            self.containerView.isHidden = true
            self.containerView.alpha = 0
            self.addingToCartButton.backgroundColor = UIColor.hexStringToUIColor(hex: "3F3A3A")
        })
        overlayView.isHidden = true
        self.addingToCartButton.isUserInteractionEnabled = true
        initializedCartVC()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showCartSegue" {
            if let cartVC = segue.destination as? AddToCartPageViewController {
                cartVC.infoCellDelegate = self
                cartVC.addToCartDelegate = self
                cartVC.product = self.product
                self.cartVC = cartVC
            }
        }
    }
    
    func initializedCartVC() {
        cartVC?.deusableColorButtonAvailiable()
        cartVC?.updateSizeButtonAvaliable(forColor: "")
        cartVC?.updateStockLabel(forSize: "")
    }
}

// MARK: - Add To Cart Page Delegate
extension DetailPageTableViewController: addToCartButtonDelegate {    
    func addToCartItem(didGet item: Variant) {
        self.selectedVariant = item
        self.selectedColor = product!.colors.filter({ $0.code == item.colorCode }).first
    }
    
    func updateAddToCartButton(for status: Bool) {
        if status == true {
            addingToCartButton.isUserInteractionEnabled = true
            addingToCartButton.backgroundColor = UIColor.hexStringToUIColor(hex: "3F3A3A")
        } else {
            addingToCartButton.isUserInteractionEnabled = false
            addingToCartButton.backgroundColor = UIColor.hexStringToUIColor(hex: "999999")
        }
    }
    
    func didUpdateAmount(_ amount: Int) {
        self.amount = amount
        addingToCartButton.isEnabled = (amount > 0)
        self.addingToCartButton.backgroundColor = (amount > 0) ? UIColor.hexStringToUIColor(hex: "3F3A3A") : UIColor.hexStringToUIColor(hex: "999999")
    }
}

// MARK: - Show Status Alert
extension DetailPageTableViewController {
    func showSuccessAlert() {
        let statusAlert = StatusAlert()
        statusAlert.image = UIImage(named: "Icons_44px_Success01")!
        statusAlert.title = "Success"
        statusAlert.sizesAndDistances.alertWidth = 200
        statusAlert.sizesAndDistances.minimumAlertHeight = 200
        statusAlert.showInKeyWindow()
    }
}

//MARK: - Add New Product to Cart
extension DetailPageTableViewController {
    func addProduct() {
        let newProduct = ProductInCart(context: managedContext)
        if let product = product,
           let size = selectedVariant?.size,
           let colorCode = selectedVariant?.colorCode,
           let colorName = selectedColor?.name,
           let stock = selectedVariant?.stock{
            newProduct.id = Int64(product.id)
            newProduct.title = product.title
            newProduct.price = Int32(product.price)
            newProduct.size = size
            newProduct.colorCode = colorCode
            newProduct.colorName = colorName
            newProduct.image = product.mainImage
            newProduct.stock = Int32(stock)
            newProduct.amount = Int32(amount)
        }
        do {
            try managedContext.save()
        } catch {
            print("Failed to save new item: \(error)")
        }
    }
}

//MARK: - Update Tab Bar Badge
extension DetailPageTableViewController {
    func updateCartBadge(for amount: Int) {
        UserDefaults.standard.set(badgeValue, forKey: "cartBadgeValue")
        if let tabBarController = self.tabBarController {
            tabBarController.setBadgeValue(for: 2, count: badgeValue)
        }
    }
    
    func totalProductsChange () {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            if let cartVC = appDelegate.cartPageViewController {
                cartVC.totalProductDidChange = { [weak self] totalProducts in
                    self?.badgeValue = totalProducts
                }
            } else {
                badgeValue += amount
            }
        } else {
            print("Failed to cast UIApplication.shared.delegate to AppDelegate")
        }
    }
}

// MARK: - Update UI if Language Changing
extension DetailPageTableViewController {
    @objc private func updateUI() {
        
        addingToCartButton.setTitle(LocalizationManager.shared.strWithKey(key: "8py-Ee-eBs.configuration.title"), for: .normal)
    }
}
