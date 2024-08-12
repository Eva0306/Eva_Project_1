//
//  STPaymentInfoTableViewCell.swift
//  STYLiSH
//
//  Created by WU CHIH WEI on 2019/7/26.
//  Copyright © 2019 WU CHIH WEI. All rights reserved.
//

import UIKit

private enum PaymentMethod: String, CaseIterable {
    
    case creditCard = "信用卡付款"
    case cash = "貨到付款"
    
    func localizedTitle() -> String {
        switch self {
        case .creditCard:
            return LocalizationManager.shared.strWithKey(key: "PaymentMethod.creditCard") ?? "信用卡付款"
        case .cash:
            return LocalizationManager.shared.strWithKey(key: "PaymentMethod.cash") ?? "貨到付款"
        }
    }
    
    static func fromLocalizedTitle(_ title: String) -> PaymentMethod? {
        return PaymentMethod.allCases.first { $0.localizedTitle() == title }
    }
}
// MARK: - Payment Info Delegate
protocol STPaymentInfoTableViewCellDelegate: AnyObject {
    
    func didChangePaymentMethod(_ cell: STPaymentInfoTableViewCell, for paymentMethod: String)
    
    func didChangeUserData(
        _ cell: STPaymentInfoTableViewCell,
        payment: String,
        cardNumber: String,
        dueDate: String,
        verifyCode: String
    )
    
    func tpdFormDidUpdate(_ tpdForm: TPDForm, status: TPDStatus)
    
    func checkout(_ cell:STPaymentInfoTableViewCell)
}


class STPaymentInfoTableViewCell: UITableViewCell {

    @IBOutlet weak var paymentTextField: UITextField! {
        
        didSet {
        
            let shipPicker = UIPickerView()
            
            shipPicker.dataSource = self
            
            shipPicker.delegate = self
            
            paymentTextField.inputView = shipPicker
            
            let button = UIButton(type: .custom)
            
            button.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
            
            button.setBackgroundImage(
                UIImage.asset(.Icons_24px_DropDown),
                for: .normal
            )
            
            button.isUserInteractionEnabled = false
            
            paymentTextField.rightView = button
            
            paymentTextField.rightViewMode = .always
            
            paymentTextField.delegate = self
            
            paymentTextField.text = PaymentMethod.cash.localizedTitle()
        }
    }
    
    @IBOutlet weak var productPriceTextLabel: UILabel!
    
    @IBOutlet weak var productPriceLabel: UILabel!
    
    @IBOutlet weak var totalFreightTextLabel: UILabel!
    
    @IBOutlet weak var shipPriceLabel: UILabel!
    
    @IBOutlet weak var totalPriceLabel: UILabel!
    
    @IBOutlet weak var productAmountLabel: UILabel!
    
    @IBOutlet weak var topDistanceConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var creditView: UIView! {
        
        didSet {
        
            creditView.isHidden = true
            
            let tpdFormView = UIView()
            tpdFormView.backgroundColor = .white
            tpdFormView.translatesAutoresizingMaskIntoConstraints = false
            creditView.addSubview(tpdFormView)
            NSLayoutConstraint.activate([
                tpdFormView.topAnchor.constraint(equalTo: creditView.topAnchor, constant: 40),
                tpdFormView.bottomAnchor.constraint(equalTo: creditView.bottomAnchor, constant: -10),
                tpdFormView.centerXAnchor.constraint(equalTo: creditView.centerXAnchor),
                tpdFormView.widthAnchor.constraint(equalToConstant: 330)
            ])
            
            tpdForm = TPDForm.setup(withContainer: tpdFormView)
            
//            tpdForm.setErrorColor(UIColor.red)
//            tpdForm.setOkColor(UIColor.green)
//            tpdForm.setNormalColor(UIColor.black)
            
            tpdForm.onFormUpdated { (status) in
                
                self.delegate?.tpdFormDidUpdate(self.tpdForm, status: status)
            }
        }
    }
    
    @IBOutlet weak var checkoutButton: UIButton! {
        didSet {
            checkoutButton.isEnabled = false
        }
    }
    
    private let paymentMethod: [PaymentMethod] = [.cash, .creditCard]
    
    weak var delegate: STPaymentInfoTableViewCellDelegate?
    
    var tpdForm: TPDForm!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func layoutCellWith(
        productPrice: Int,
        shipPrice: Int,
        productCount: Int
    ) {
        
        productPriceLabel.text = "NT$ \(productPrice)"
        
        shipPriceLabel.text = "NT$ \(shipPrice)"
        
        totalPriceLabel.text = "NT$ \(shipPrice + productPrice)"
        
        productAmountLabel.text = String.localizedStringWithFormat(LocalizationManager.shared.strWithKey(key: "8ov-ov-dSM.text") ?? "總計 (%d樣商品)", productCount)
    }
    
    @IBAction func checkout() {
        
        delegate?.checkout(self)
    }
    
    //MARK: checkout button condition
    func updateCheckoutButtonState(isEnabled: Bool) {
        checkoutButton.isEnabled = isEnabled
        checkoutButton.backgroundColor = isEnabled ? UIColor.hexStringToUIColor(hex: "3F3A3A") : UIColor.hexStringToUIColor(hex: "999999")
    }
}

//MARK: PickerView
extension STPaymentInfoTableViewCell: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int { return 1 }
    
    func pickerView(
        _ pickerView: UIPickerView,
        numberOfRowsInComponent component: Int
    ) -> Int
    {
        return 2
    }
    
    func pickerView(
        _ pickerView: UIPickerView,
        titleForRow row: Int,
        forComponent component: Int
    ) -> String?
    {
        
        return paymentMethod[row].localizedTitle()
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        paymentTextField.text = paymentMethod[row].localizedTitle()
    }
    
    private func manipulateHeight(_ distance: CGFloat) {
        
        topDistanceConstraint.constant = distance
        
    }
}

// MARK: - TextField DidEndEditing
extension STPaymentInfoTableViewCell: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        guard
            let text = textField.text,
            let payment = PaymentMethod.fromLocalizedTitle(text) else
        {
            return
        }
        
        switch payment {
            
        case .cash:
            
            manipulateHeight(44)
            
            delegate?.didChangePaymentMethod(self, for: "Cash")
            
            creditView.isHidden = true
            
        case .creditCard:
            
            manipulateHeight(150)
            
            delegate?.didChangePaymentMethod(self, for: "Credit Card")
            
            creditView.isHidden = false
        }
    }
}

// - Update UI
extension STPaymentInfoTableViewCell {
    func updateUI() {
        paymentTextField.placeholder = LocalizationManager.shared.strWithKey(key: "da4-NM-yrP.text")
        
        productPriceTextLabel.text = LocalizationManager.shared.strWithKey(key: "yvu-dx-COl.text")
        
        totalFreightTextLabel.text = LocalizationManager.shared.strWithKey(key: "hPR-LJ-9ws.text")
        
        checkoutButton.setTitle(LocalizationManager.shared.strWithKey(key: "Jg8-e7-47O.title"), for: .normal)
    }
}
