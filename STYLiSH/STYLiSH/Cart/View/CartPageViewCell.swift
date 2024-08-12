//
//  CartPageViewCell.swift
//  STYLiSH
//
//  Created by 楊芮瑊 on 2024/7/31.
//

import UIKit
import Kingfisher

protocol CartProductCellDelegate {
    func didTapRemoveButton(in: CartProductCell)
    func didChangeAmount(amount: Int, in cell: CartProductCell)
}

class CartProductCell: UITableViewCell, UITextFieldDelegate {
    
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var removeButton: UIButton!
    @IBOutlet weak var minusButton: UIButton!
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var textField: UITextField!
    
    var stock = 1 {
        didSet {
            setupButton()
        }
    }
    var productimageView = UIImageView()
    var delegate: CartProductCellDelegate?
    //var indexPath: IndexPath?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textField.delegate = self
        textField.addTarget(self, action: #selector(textDidChange(_:)), for: .editingChanged)
        textField.isEnabled = false
        setupView()
    }
    
    @IBAction func removeProduct(_ sender: UIButton) {
        delegate?.didTapRemoveButton(in: self)
    }
    
    //MARK: - Change Amount
    @IBAction func changeAmount(_ sender: UIButton) {
        
        guard let text = textField.text, !text.isEmpty, let currentValue = Int(text) else {
            return
        }
        
        var newValue = max(1, currentValue)
        
        if sender == minusButton {
            newValue = max(1, currentValue - 1)
        } else {
            newValue = currentValue + 1
        }
        textField.text = "\(newValue)"
        textDidChange(textField)
    }
    
    //MARK: - TextField Text Change
    @objc func textDidChange(_ textField: UITextField){
        print("value did change")
        checkButtonCondition()
        guard let text = textField.text, !text.isEmpty,
              let currentValue = Int(text) else {
            return
        }
        
        delegate?.didChangeAmount(amount: currentValue, in: self)
        
    }
    
    //MARK: - Button Condition
    func checkButtonCondition() {
        guard let text = textField.text, !text.isEmpty,
              let currentValue = Int(text) else {
            self.minusButton.isEnabled = false
            self.minusButton.alpha = 0.3
            return
        }
        
        if currentValue < 2 {
            self.minusButton.isEnabled = false
            self.minusButton.alpha = 0.3
        } else {
            self.minusButton.isEnabled = true
            self.minusButton.alpha = 1
        }
        
        if currentValue >= stock {
            self.textField.text = "\(stock)"
            self.plusButton.isEnabled = false
            self.plusButton.alpha = 0.3
        } else {
            self.plusButton.isEnabled = true
            self.plusButton.alpha = 1
        }
    }
    
    //MARK: - Update Cart Product
    func updateCartCell(withEntity entity: ProductInCart) {
        productimageView.kf.setImage(with: URL(string: entity.image!))
        nameLabel.text = entity.title
        priceLabel.text = "NT$\(entity.price)"
        sizeLabel.text = entity.size
        colorView.backgroundColor = UIColor.hexStringToUIColor(hex: entity.colorCode ?? "FFFFFF")
        stock = Int(entity.stock)
        textField.text = "\(entity.amount)"
        checkButtonCondition()
    }
    
    //MARK: - TextField Condition
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let allowedCharacterSet = CharacterSet.decimalDigits
        let characterSet = CharacterSet(charactersIn: string)
        return allowedCharacterSet.isSuperset(of: characterSet)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let text = textField.text, text.isEmpty {
                textField.text = ""
            }
//        if let text = textField.text, let currentValue = Int(text) {
//            //textFieldValueDidChange?(currentValue)
//        } else {
//            //textFieldValueDidChange?(0)
//        }
    }
    
    //MARK: - Setup ImageView
    func setupView() {
        textField.borderStyle = .none
        textField.layer.borderWidth = 1.0
        textField.layer.borderColor = UIColor.hexStringToUIColor(hex: "3F3A3A").cgColor
        productimageView.contentMode = .scaleAspectFit
        productimageView.translatesAutoresizingMaskIntoConstraints = false
        colorView.layer.borderColor = UIColor.hexStringToUIColor(hex: "D9D9D9").cgColor
        colorView.layer.borderWidth = 1.0
        
        addSubview(productimageView)
        
        NSLayoutConstraint.activate([
            productimageView.widthAnchor.constraint(equalToConstant: 83),
            productimageView.heightAnchor.constraint(equalToConstant: 110),
            productimageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            productimageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12)
        ])
    }
    
    //MARK: - Setup Button
    func setupButton() {
        checkButtonCondition()
        minusButton.layer.borderWidth = 1.0
        minusButton.layer.borderColor = UIColor.hexStringToUIColor(hex: "3F3A3A").cgColor
        plusButton.layer.borderWidth = 1.0
        plusButton.layer.borderColor = UIColor.hexStringToUIColor(hex: "3F3A3A").cgColor
    }
    
    //MARK: - Update UI
    func updateUI() {
        removeButton.setTitle(LocalizationManager.shared.strWithKey(key: "U98-6G-Ssp.normalTitle"), for: .normal)
    }
    
}
