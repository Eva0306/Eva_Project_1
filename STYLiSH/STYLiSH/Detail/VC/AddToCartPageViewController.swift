//
//  AddToCartPageViewController.swift
//  STYLiSH
//
//  Created by 楊芮瑊 on 2024/7/29.
//

import UIKit
import IQKeyboardManagerSwift

protocol addToCartButtonDelegate {
    func addToCartItem(didGet item: Variant)
    func updateAddToCartButton(for status: Bool)
    func didUpdateAmount(_ amount: Int)
}

class AddToCartPageViewController: UITableViewController {
    
    var product: Product?
    var color: String?
    var size: String?
    var stock: Int?
    var currentAmount: Int?{
        didSet {
            let amountToUse = currentAmount ?? 0
            addToCartDelegate?.didUpdateAmount(amountToUse)
        }
    }
    
    
    var infoCellDelegate: CartInfoCellDelegate?
    var addToCartDelegate: addToCartButtonDelegate?
    
    private var availableStock: [String: Int] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        
        // - Observe Language Change
        NotificationCenter.default.addObserver(self, selector: #selector(updateUI), name: .languageChanged, object: nil)
        updateUI()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .languageChanged, object: nil)
    }
}

// MARK: - Chosen Variant Delegate
extension AddToCartPageViewController: CartChosenCellDelegate {
    func colorCell(_ cell: CartColorCell, didSelectColor color: String) {
        self.color = color
        addToCartDelegate?.updateAddToCartButton(for: false)
        updateSizeButtonAvaliable(forColor: color)
        updateStockLabel(forSize: "")
    }
    
    func sizeCell(_ cell: CartSizeCell, didSelectSize size: String) {
        self.size = size
        updateStockLabel(forSize: size)
        addToCartDelegate?.updateAddToCartButton(for: true)
        addToCartDelegate?.addToCartItem(didGet: findVariant(forSize: size, colorCode: color!, inProduct: product!)!)
    }
    
    private func findVariant(forSize size: String, colorCode: String, inProduct product: Product) -> Variant? {
        return product.variants.first { $0.size == size && $0.colorCode == colorCode }
    }
}

//MARK: - Update Availiable Items
extension AddToCartPageViewController {
    
    func deusableColorButtonAvailiable() {
        if let colorCell = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? CartColorCell {
            colorCell.initializedButton()
        }
    }
    
    func updateSizeButtonAvaliable(forColor color: String) {
        
        let filteredVariants = product?.variants.filter { $0.colorCode == color } ?? []
        
        for variant in filteredVariants {
            availableStock[variant.size] = variant.stock
        }
        if let sizeCell = tableView.cellForRow(at: IndexPath(row: 2, section: 0)) as? CartSizeCell {
            if !filteredVariants.isEmpty {
                for variant in filteredVariants {
                    availableStock[variant.size] = variant.stock
                }
                sizeCell.updateSizeButtons(availableStock: availableStock)
            } else {
                sizeCell.initializedButton()
            }
        }
    }
    
    func updateStockLabel(forSize size: String) {
        if let amountCell = tableView.cellForRow(at: IndexPath(row: 3, section: 0)) as? CartAmountCell {
            if let stock = availableStock[size] {
                self.stock = stock
                amountCell.stockLabel.text = String.localizedStringWithFormat(LocalizationManager.shared.strWithKey(key: "stockWithQuantity") ?? "庫存：", stock)
                if stock > 0 {
                    amountCell.usableItems()
                }
                amountCell.stock = stock
                amountCell.textField.text = "1"
                amountCell.minusButton.isEnabled = false
                amountCell.minusButton.alpha = 0.3
            } else {
                amountCell.stockLabel.text = LocalizationManager.shared.strWithKey(key: "stockWithoutQuantity")
                amountCell.setupButton()
            }
        }
    }
    
}

//MARK: - Table View DataSource
extension AddToCartPageViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        4
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CartInfoCell", for: indexPath) as!  CartInfoCell
            cell.delegate = infoCellDelegate
            if let product = product {
                cell.nameLabel.text = product.title
                cell.priceLabel.text = "NT$\(product.price)"
            }
            return cell
            
        } else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CartColorCell", for: indexPath) as! CartColorCell
            cell.delegate = self
            if let product = product {
                let colors = product.colors.map{ UIColor.hexStringToUIColor(hex: $0.code) }
                cell.addColorButtons(colors: colors)

            }
            cell.updateUI()
            return cell
            
        } else if indexPath.row == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CartSizeCell", for: indexPath) as! CartSizeCell
            cell.delegate = self
            if let product = product {
                let sizes = product.sizes.map{ $0 }
                cell.addSizeButtons(sizes: sizes)
            }
            cell.updateUI()
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CartAmountCell", for: indexPath) as! CartAmountCell
            cell.textFieldValueDidChange = { [weak self] newValue in
                self?.currentAmount = newValue
            }
            cell.updateUI()
            return cell
        }
    }
}

// MARK: - Update UI if Language Changing
extension AddToCartPageViewController {
    @objc private func updateUI() {
        tableView.reloadData()
    }
}
