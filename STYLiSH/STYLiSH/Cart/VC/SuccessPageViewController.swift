//
//  SuccessPageViewController.swift
//  STYLiSH
//
//  Created by 楊芮瑊 on 2024/8/6.
//

import UIKit
import CoreData

class SuccessPageViewController: UIViewController {
    
    @IBOutlet weak var checkoutResultNavigationItem: UINavigationItem!
    
    @IBOutlet weak var checkoutAccessLabel: UILabel!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var continueButton: UIButton!
    
    var managedContext: NSManagedObjectContext {
        return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // - Observe Language Change
        NotificationCenter.default.addObserver(self, selector: #selector(updateUI), name: .languageChanged, object: nil)
        updateUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
        cleanCartProducts()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .languageChanged, object: nil)
    }
    
    @IBAction func keepShopping(_ sender: Any) {
        
        if let viewControllers = navigationController?.viewControllers {
            for vc in viewControllers {
                if vc is CartPageViewController {
                    navigationController?.popToViewController(vc, animated: true)
                    break
                }
            }
        }
    }
    
}

//MARK: - Delete All Products from Core Data
extension SuccessPageViewController {
    func cleanCartProducts() {
        
        let fetchRequest: NSFetchRequest<ProductInCart> = ProductInCart.fetchRequest()
        
        do {
            let results = try managedContext.fetch(fetchRequest)
            
            for result in results {
                managedContext.delete(result)
            }
            try managedContext.save()
            
        } catch let error as NSError {
            print("Error deleting data from Core Data: \(error)")
        }
    }
}

//MARK: - Update UI
extension SuccessPageViewController {
    @objc private func updateUI() {
        checkoutResultNavigationItem.title = LocalizationManager.shared.strWithKey(key: "wus-X5-8ZB.title")
        checkoutAccessLabel.text = LocalizationManager.shared.strWithKey(key: "dkv-RB-QfG.text")
        descriptionLabel.text = LocalizationManager.shared.strWithKey(key: "0rE-uI-kXg.text")
        continueButton.setTitle(LocalizationManager.shared.strWithKey(key: "g3D-AL-iaF.configuration.title"), for: .normal)
    }
}
