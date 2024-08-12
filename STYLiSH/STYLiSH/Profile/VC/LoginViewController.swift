//
//  LoginViewController.swift
//  STYLiSH
//
//  Created by 楊芮瑊 on 2024/8/5.
//

import UIKit
import FacebookLogin

class LoginViewController: UIViewController {
    
    @IBOutlet weak var loginFirstLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var fbLoginButton: UIButton!
    
    let keyChainService = KeychainService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // - Observe Language Change
        NotificationCenter.default.addObserver(self, selector: #selector(updateUI), name: .languageChanged, object: nil)
        updateUI()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .languageChanged, object: nil)
    }
    
    @IBAction func loginFB(_ sender: Any) {
        let loginManager = LoginManager()
        loginManager.logIn(permissions: ["public_profile", "email"], from: self) { result, error in
            if let error = error {
                print("Encountered Erorr: \(error)")
            } else if let result = result, result.isCancelled {
                print("Cancelled")
            } else {
                print("Logged In")
                self.dismiss(animated: true, completion: nil)
                if let accessToken = AccessToken.current?.tokenString {
                    self.postFBTokenToAPI(accessToken: accessToken)
                }
            }
        }
    }
    
    @IBAction func closeLoginView(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func postFBTokenToAPI(accessToken: String) {
        guard let url = URL(string: "https://api.appworks-school.tw/api/1.0/user/signin") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let json: [String: Any] = [
            "provider":"facebook",
            "access_token": accessToken
        ]
        
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
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                print("Error: server error")
                return
            }
            
            if let data = data {
                do {
                    let signInResponse = try JSONDecoder().decode(SignInResponse.self, from: data)
                    let accessToken = signInResponse.data.accessToken
                    self.keyChainService.saveToken(token: accessToken)
                } catch {
                    print("Error: cannot decode response data")
                }
            }
        }
        
        task.resume()
    }
}

extension LoginViewController {
    @objc private func updateUI() {
        loginFirstLabel.text = LocalizationManager.shared.strWithKey(key: "FpI-1q-Ccg.text")
        fbLoginButton.setTitle(LocalizationManager.shared.strWithKey(key: "eFe-XP-ca0.configuration.title"), for: .normal)
    }
}
