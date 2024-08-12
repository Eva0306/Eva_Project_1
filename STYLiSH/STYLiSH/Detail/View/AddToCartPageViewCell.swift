//
//  AddToCartPageViewCell.swift
//  STYLiSH
//
//  Created by 楊芮瑊 on 2024/7/29.
//

import UIKit

//MARK: - Info Cell
protocol CartInfoCellDelegate {
    func didTapCloseButton(in cell: CartInfoCell)
}
class CartInfoCell: UITableViewCell {
    var delegate: CartInfoCellDelegate?
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    @IBAction func closeCartView(_ sender: UIButton) {
        delegate?.didTapCloseButton(in: self)
    }
}

//MARK: - Chosen Cell Delegate
protocol CartChosenCellDelegate {
    func colorCell(_ cell: CartColorCell, didSelectColor color: String)
    func sizeCell(_ cell: CartSizeCell, didSelectSize size: String)
}

//MARK: - Color Cell
class CartColorCell: UITableViewCell {
    
    @IBOutlet weak var colorLabel: UILabel!
    @IBOutlet weak var colorButton: UIButton!
    
    private var colorButtons: [UIButton] = []
    private var selectedButton: UIButton?
    private var containerView: UIView?
    
    private var widthConstraints: [UIButton: NSLayoutConstraint] = [:]
    private var heightConstraints: [UIButton: NSLayoutConstraint] = [:]
    
    var delegate: CartChosenCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupButton()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupButton()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupButton()
    }
    
    private func setupButton() {
        if let colorButton = colorButton {
            colorButton.translatesAutoresizingMaskIntoConstraints = false
            colorButton.backgroundColor = .gray
        }
    }
    
    private func clearColorButtons() {
        if let colorButton = colorButton {
            colorButton.removeFromSuperview()
        }
        colorButtons.forEach { $0.removeFromSuperview() }
        colorButtons.removeAll()
    }
    
    func addColorButtons(colors: [UIColor]) {
        
        clearColorButtons()
        var previousButton: UIButton? = nil
        
        for color in colors {
            let newButton = UIButton()
            newButton.translatesAutoresizingMaskIntoConstraints = false
            newButton.backgroundColor = color
            newButton.layer.borderColor = UIColor.hexStringToUIColor(hex: "D9D9D9").cgColor
            newButton.layer.borderWidth = 1.0
            newButton.addTarget(self, action: #selector(colorButtonTapped(_:)), for: .touchUpInside)
            contentView.addSubview(newButton)
            
            let centerXAnchorConstant: CGFloat = previousButton == nil ? 40 : 64
            let widthConstraint = newButton.widthAnchor.constraint(equalToConstant: 48)
            let heightConstraint = newButton.heightAnchor.constraint(equalToConstant: 48)
            
            NSLayoutConstraint.activate([
                newButton.centerYAnchor.constraint(equalTo: colorLabel.bottomAnchor, constant: 32),
                newButton.centerXAnchor.constraint(equalTo: previousButton?.centerXAnchor ?? contentView.leadingAnchor, constant: centerXAnchorConstant),
                newButton.centerYAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40),
                widthConstraint,
                heightConstraint
            ])
            previousButton = newButton
            colorButtons.append(newButton)
            widthConstraints[newButton] = widthConstraint
            heightConstraints[newButton] = heightConstraint
        }
    }
    
    @objc private func colorButtonTapped(_ sender: UIButton) {
        
        containerView?.removeFromSuperview()
        
        if let selectedButton = selectedButton {
            
            widthConstraints[selectedButton]?.constant = 48
            heightConstraints[selectedButton]?.constant = 48
            
            NSLayoutConstraint.activate([
                widthConstraints[selectedButton]!,
                widthConstraints[selectedButton]!
            ])
            
            selectedButton.superview?.layoutIfNeeded()
        }
        
        let newContainerView: UIView = {
            let view = UIView()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.backgroundColor = .white
            view.layer.borderWidth = 1
            view.layer.borderColor = UIColor.black.cgColor
            return view
        }()
        
        sender.superview?.insertSubview(newContainerView, belowSubview: sender)
        
        NSLayoutConstraint.activate([
            newContainerView.widthAnchor.constraint(equalToConstant: 48),
            newContainerView.heightAnchor.constraint(equalToConstant: 48),
            newContainerView.centerXAnchor.constraint(equalTo: sender.centerXAnchor),
            newContainerView.centerYAnchor.constraint(equalTo: sender.centerYAnchor)
        ])
        
        widthConstraints[sender]?.constant = 42
        heightConstraints[sender]?.constant = 42
        
        NSLayoutConstraint.activate([
            widthConstraints[sender]!,
            heightConstraints[sender]!
        ])
        
        sender.superview?.layoutIfNeeded()
        
        self.selectedButton = sender
        self.containerView = newContainerView
        if let color = sender.backgroundColor?.toHexString() {
            delegate?.colorCell(self, didSelectColor: color)
        }
    }
    
    func initializedButton() {
        for button in colorButtons {
            containerView?.removeFromSuperview()
            widthConstraints[button]?.constant = 48
            heightConstraints[button]?.constant = 48
            
            NSLayoutConstraint.activate([
                widthConstraints[button]!,
                widthConstraints[button]!
            ])
            button.superview?.layoutIfNeeded()
        }
    }
    
    // - Update UI
    func updateUI() {
        colorLabel.text = LocalizationManager.shared.strWithKey(key: "Wpl-lE-dbe.text")
    }
}

//MARK: - Size Cell
class CartSizeCell: UITableViewCell {

    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var sizeButton: UIButton!
    
    var sizeButtons: [UIButton] = []
    
    private var selectedButton: UIButton?
    private var containerView: UIView?
    
    private var widthConstraints: [UIButton: NSLayoutConstraint] = [:]
    private var heightConstraints: [UIButton: NSLayoutConstraint] = [:]
    
    var delegate: CartChosenCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupButton()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupButton()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupButton()
    }
    
    private func setupButton() {
        if let sizeButton = sizeButton {
            sizeButton.translatesAutoresizingMaskIntoConstraints = false
            sizeButton.backgroundColor = UIColor.hexStringToUIColor(hex: "F0F0F0")
        }
    }
    
    private func clearSizeButtons() {
        if let sizeButton = sizeButton {
            sizeButton.removeFromSuperview()
        }
        sizeButtons.forEach { $0.removeFromSuperview() }
        sizeButtons.removeAll()
    }
    
    func addSizeButtons(sizes: [String]) {
        
        clearSizeButtons()
        var previousButton: UIButton? = nil
        
        for size in sizes {
            let newButton = UIButton()
            newButton.translatesAutoresizingMaskIntoConstraints = false
            newButton.backgroundColor = UIColor.hexStringToUIColor(hex: "F0F0F0")
            newButton.setTitle(size, for: .normal)
            newButton.setTitleColor(UIColor.hexStringToUIColor(hex: "B4B4B8"), for: .normal)
            newButton.isEnabled = false
            
            contentView.addSubview(newButton)
            newButton.addTarget(self, action: #selector(sizeButtonTapped(_:)), for: .touchUpInside)
            
            let centerXAnchorConstant: CGFloat = previousButton == nil ? 40 : 64
            let widthConstraint = newButton.widthAnchor.constraint(equalToConstant: 48)
            let heightConstraint = newButton.heightAnchor.constraint(equalToConstant: 48)
            
            NSLayoutConstraint.activate([
                newButton.centerYAnchor.constraint(equalTo: sizeLabel.bottomAnchor, constant: 32),
                newButton.centerXAnchor.constraint(equalTo: previousButton?.centerXAnchor ?? contentView.leadingAnchor, constant: centerXAnchorConstant),
                newButton.centerYAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40),
                widthConstraint,
                heightConstraint
            ])
            previousButton = newButton
            sizeButtons.append(newButton)
            widthConstraints[newButton] = widthConstraint
            heightConstraints[newButton] = heightConstraint
        }
    }
    
    // MARK: - Size Button Available
    func updateSizeButtons(availableStock: [String: Int]) {
        
        initializedButton()
        
        //顯示可用size button
        for button in sizeButtons {
            if let size = button.title(for: .normal) {
                if availableStock[size] != 0 {
                    button.isEnabled = true
                    button.setTitleColor(.black, for: .normal)
                }
            }
        }
    }
    
    // MARK: - Size Button Tapped
    @objc private func sizeButtonTapped(_ sender: UIButton) {
        
        containerView?.removeFromSuperview()
        
        if let selectedButton = selectedButton {
            
            widthConstraints[selectedButton]?.constant = 48
            heightConstraints[selectedButton]?.constant = 48
            
            NSLayoutConstraint.activate([
                widthConstraints[selectedButton]!,
                widthConstraints[selectedButton]!
            ])
            selectedButton.superview?.layoutIfNeeded()
        }
        
        let newContainerView: UIView = {
            let view = UIView()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.backgroundColor = .white
            view.layer.borderWidth = 1
            view.layer.borderColor = UIColor.black.cgColor
            return view
        }()
        
        sender.superview?.insertSubview(newContainerView, belowSubview: sender)
        
        NSLayoutConstraint.activate([
            newContainerView.widthAnchor.constraint(equalToConstant: 48),
            newContainerView.heightAnchor.constraint(equalToConstant: 48),
            newContainerView.centerXAnchor.constraint(equalTo: sender.centerXAnchor),
            newContainerView.centerYAnchor.constraint(equalTo: sender.centerYAnchor)
        ])
        
        widthConstraints[sender]?.constant = 42
        heightConstraints[sender]?.constant = 42
        
        NSLayoutConstraint.activate([
            widthConstraints[sender]!,
            heightConstraints[sender]!
        ])
        
        sender.superview?.layoutIfNeeded()
        self.selectedButton = sender
        self.containerView = newContainerView
        
        if let size = sender.title(for: .normal) {
            delegate?.sizeCell(self, didSelectSize: size)
        }
    }
    
    func initializedButton() {
        for button in sizeButtons {
            button.isEnabled = false
            button.setTitleColor(UIColor.hexStringToUIColor(hex: "B4B4B8"), for: .normal)
            containerView?.removeFromSuperview()
            widthConstraints[button]?.constant = 48
            heightConstraints[button]?.constant = 48
            
            NSLayoutConstraint.activate([
                widthConstraints[button]!,
                widthConstraints[button]!
            ])
            button.superview?.layoutIfNeeded()
        }
    }
    
    // - Update UI
    func updateUI() {
        sizeLabel.text = LocalizationManager.shared.strWithKey(key: "u1a-93-4KZ.text")
    }
}

//MARK: - Amount Cell
class CartAmountCell: UITableViewCell, UITextFieldDelegate {
    
    var textFieldValueDidChange: ((Int) -> Void)?
    
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var stockLabel: UILabel!
    @IBOutlet weak var minusButton: UIButton!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var plusButton: UIButton!
    
    var stock: Int = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textField.delegate = self
        textField.addTarget(self, action: #selector(textDidChange(_:)), for: .editingChanged)
        
        setupButton()
    }
    
    @IBAction func changeAmount(_ sender: UIButton) {
        
        guard let text = textField.text, !text.isEmpty, let currentValue = Int(text) else {
            if sender == plusButton {
                textField.text = "1"
            }
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
    
    @objc func textDidChange(_ textField: UITextField){
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
        textFieldValueDidChange?(min(currentValue, stock))
    }
    
    func setupButton() {
        minusButton.isEnabled = false
        plusButton.isEnabled = false
        textField.isEnabled = false
        minusButton.alpha = 0.3
        plusButton.alpha = 0.3
        textField.alpha = 0.3
        minusButton.layer.borderWidth = 1.0
        plusButton.layer.borderWidth = 1.0
        minusButton.layer.borderColor = UIColor.black.cgColor
        plusButton.layer.borderColor = UIColor.black.cgColor
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let allowedCharacterSet = CharacterSet.decimalDigits
        let characterSet = CharacterSet(charactersIn: string)
        return allowedCharacterSet.isSuperset(of: characterSet)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let text = textField.text, let currentValue = Int(text) {
            textFieldValueDidChange?(currentValue)
        } else {
            textFieldValueDidChange?(0)
        }
    }
    
    func usableItems() {
        minusButton.isEnabled = true
        plusButton.isEnabled = true
        textField.isEnabled = true
        minusButton.alpha = 1
        plusButton.alpha = 1
        textField.alpha = 1
    }
    
    // - Update UI
    func updateUI() {
        amountLabel.text = LocalizationManager.shared.strWithKey(key: "PnU-aa-Pw7.text")
        stockLabel.text = LocalizationManager.shared.strWithKey(key: "stockWithoutQuantity")
    }
}
