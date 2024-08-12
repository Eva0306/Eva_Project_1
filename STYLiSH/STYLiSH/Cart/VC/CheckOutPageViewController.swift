import UIKit
import Kingfisher
import FacebookLogin
import CoreData

class CheckOutPageViewController: UIViewController, STOrderUserInputCellDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var checkoutNavigationItem: UINavigationItem!
    
    let header = [LocalizationManager.shared.strWithKey(key: "HeaderForCheckoutProducts"),
                  LocalizationManager.shared.strWithKey(key: "HeaderForReceiverInfo"),
                  LocalizationManager.shared.strWithKey(key: "HeaderForPaymentInfo")]
    
    let keyChainService = KeychainService()
    var managedContext: NSManagedObjectContext {
        return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }
    
    var checkProducts: [ProductInCart] = [] {
        didSet {
            productPrice = checkProducts.map({ Int($0.price) }).reduce(0, { $0 + $1 })
            productCount = checkProducts.map({ Int($0.amount) }).reduce(0, { $0 + $1 })
        }
    }
    
    var productPrice = 0
    var productCount = 0
    
    var userInfo: [String: String] = [:]
    var accessToken: String?
    
    var tpdForm: TPDForm!
    var tpdCard: TPDCard!
    var tpdStatus: TPDStatus?
    var userInfoComplete = false
    var paymentMethod: String = "Cash"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let token = keyChainService.getToken() {
            self.accessToken = token
        }
        
        tableView.dataSource = self
        
        tableView.delegate = self
        
        tableView.separatorStyle = .none
        
        tableView.lk_registerCellWithNib(identifier: String(describing: STOrderProductCell.self), bundle: nil)
        
        tableView.lk_registerCellWithNib(identifier: String(describing: STOrderUserInputCell.self), bundle: nil)
        
        tableView.lk_registerCellWithNib(identifier: String(describing: STPaymentInfoTableViewCell.self), bundle: nil)
        
        let headerXib = UINib(nibName: String(describing: STOrderHeaderView.self), bundle: nil)
        
        tableView.register(headerXib, forHeaderFooterViewReuseIdentifier: String(describing: STOrderHeaderView.self))
        
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
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .languageChanged, object: nil)
    }
    
    @IBAction func backToForePage(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
}

//MARK: - TableView DataSource
extension CheckOutPageViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 67.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: String(describing: STOrderHeaderView.self)) as? STOrderHeaderView else {
            return nil
        }
        
        headerView.titleLabel.text = header[section]
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        
        return ""
    }
    
    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        
        guard let footerView = view as? UITableViewHeaderFooterView else { return }
        
        footerView.contentView.backgroundColor = UIColor.hexStringToUIColor(hex: "cccccc")
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return header.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0{
            return checkProducts.count
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: UITableViewCell
        
        if indexPath.section == 0 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: STOrderProductCell.self), for: indexPath) as! STOrderProductCell
            cell.productImageView.kf.setImage(with: URL(string: checkProducts[indexPath.row].image!))
            cell.productTitleLabel.text = checkProducts[indexPath.row].title!
            cell.colorView.backgroundColor = UIColor.hexStringToUIColor(hex: checkProducts[indexPath.row].colorCode!)
            cell.productSizeLabel.text = checkProducts[indexPath.row].size!
            cell.priceLabel.text = "$ " + String(checkProducts[indexPath.row].price)
            cell.orderNumberLabel.text = "x " + String(checkProducts[indexPath.row].amount)
            
            return cell
            
        } else if indexPath.section == 1 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: STOrderUserInputCell.self), for: indexPath) as! STOrderUserInputCell
            
            cell.delegate = self
            cell.updateUI()
            
            return cell
        } else {
            
            cell = tableView.dequeueReusableCell(withIdentifier: String(describing: STPaymentInfoTableViewCell.self), for: indexPath)
            
            guard let paymentCell = cell as? STPaymentInfoTableViewCell else {

                return cell
            }

            paymentCell.delegate = self
            paymentCell.layoutCellWith(productPrice: productPrice,
                                       shipPrice: 60,
                                       productCount: productCount)
            paymentCell.updateUI()
        }
        
        return cell
    }
}

//MARK: - STPayment Info Delegate
extension CheckOutPageViewController: STPaymentInfoTableViewCellDelegate {
    
    func didChangePaymentMethod(_ cell: STPaymentInfoTableViewCell, for paymentMethod: String) {
        
        tableView.reloadData()
        self.paymentMethod = paymentMethod
        
        updateCheckoutButtonStatusInCell()
    }
    
    func didChangeUserData(
        _ cell: STOrderUserInputCell,
        username: String,
        email: String,
        phoneNumber: String,
        address: String,
        shipTime: String
    ) {
        userInfo = ["username": username,
                    "email": email,
                    "phoneNumber": phoneNumber,
                    "address": address,
                    "shipTime": shipTime]
        
        userInfoComplete = !username.isEmpty && !email.isEmpty && !phoneNumber.isEmpty && !address.isEmpty && !shipTime.isEmpty
        
        updateCheckoutButtonStatusInCell()
    }
    
    func didChangeUserData(
        _ cell: STPaymentInfoTableViewCell,
        payment: String,
        cardNumber: String,
        dueDate: String,
        verifyCode: String
    ) {
        print(payment, cardNumber, dueDate, verifyCode)
    }
    
    func tpdFormDidUpdate(_ tpdForm: TPDForm, status: TPDStatus) {
        self.tpdForm = tpdForm
        self.tpdStatus = status
        
        updateCheckoutButtonStatusInCell()
    }
    
    func updateCheckoutButtonStatusInCell() {
        if let paymentCell = tableView.cellForRow(at: IndexPath(row: 0, section: 2)) as? STPaymentInfoTableViewCell {
            
            if userInfoComplete && paymentMethod == "Cash" {
                paymentCell.updateCheckoutButtonState(isEnabled: true)
                
            } else if userInfoComplete && paymentMethod == "Credit Card"{
                if let tpdStatus = tpdStatus {
                    if tpdStatus.isCanGetPrime() {
                        paymentCell.updateCheckoutButtonState(isEnabled: true)
                    } else {
                        paymentCell.updateCheckoutButtonState(isEnabled: false)
                    }
                } else {
                    paymentCell.updateCheckoutButtonState(isEnabled: false)
                }
            } else {
                paymentCell.updateCheckoutButtonState(isEnabled: false)
            }
        }
    }
    
    func checkout(_ cell:STPaymentInfoTableViewCell) {
        
        if let accessToken = AccessToken.current, !accessToken.isExpired {
            
            if let tpdForm = tpdForm {
                tpdCard = TPDCard.setup(tpdForm)
                
                tpdCard.onSuccessCallback { (prime, cardInfo, cardIdentifier, additionalData)  in
                    
                    self.postCheckToAPI(accessToken: self.accessToken!,
                                        prime: prime!,
                                        subtotal: self.productPrice,
                                        freight: 60, total: self.productPrice + 60,
                                        checkProducts: self.checkProducts)
                    
                    DispatchQueue.main.async{
                        self.performSegue(withIdentifier: "showSuccessPage", sender: nil)
                    }
                    print("Prime : \(prime!), cardInfo : \(cardInfo!), cardIdentifier : \(cardIdentifier!)")
                }.onFailureCallback { (status, message) in
                    print("status : \(status), Message : \(message)")
                }.getPrime()
                return
            }
            
            self.performSegue(withIdentifier: "showSuccessPage", sender: nil)
            
        } else {
            if let tabBarVC = self.tabBarController as? tabBarController {
                tabBarVC.presentLoginViewController(isShowProfile: false)
            }
        }
    }
}

//MARK: - Post Check To API
extension CheckOutPageViewController {
    
    func transformProductList(checkProducts: [ProductInCart]) -> [[String: Any]] {
        
        var newArray: [[String: Any]] = []
        var newItem: [String: Any]
        
        for item in checkProducts {
            
            newItem = [
                "id": Int(item.id),
                "name": item.title!,
                "price": Int(item.price),
                "color": [
                    "name": item.colorName,
                    "code": item.colorCode
                ],
                "size": item.size!,
                "qty": Int(item.amount)
            ]
            newArray.append(newItem)
        }
        return newArray
    }
        
    func postCheckToAPI(accessToken: String, prime: String, subtotal: Int, freight: Int, total: Int, checkProducts: [ProductInCart]) {
        
        let checkProductList = transformProductList(checkProducts: checkProducts)
        
        guard let url = URL(string: "https://api.appworks-school.tw/api/1.0/order/checkout") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let json: [String: Any] = [
            "prime": prime,
            "order": [
                "shipping": "delivery",
                "payment": "credit_card",
                "subtotal": subtotal,
                "freight": freight,
                "total": total,
                "recipient": [
                    "name": userInfo["username"],
                    "phone": userInfo["phoneNumber"],
                    "email": userInfo["email"],
                    "address": userInfo["address"],
                    "time": userInfo["shipTime"]
                ],
                "list": checkProductList
            ]
        ]
        print(json)
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: json)
            request.httpBody = jsonData
        } catch {
            print("Error: cannot create JSON from post data")
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error)")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("Status code: \(httpResponse.statusCode)")
            }
            
            if let data = data, let responseString = String(data: data, encoding: .utf8) {
                print("Response data:\n\(responseString)")
            }
        }
        
        task.resume()
    }
}
// MARK: - Update UI if Language Changing
extension CheckOutPageViewController {
    @objc private func updateUI() {
        checkoutNavigationItem.title = LocalizationManager.shared.strWithKey(key: "Ngk-mF-l3Y.title")
        tableView.reloadData()
    }
}
