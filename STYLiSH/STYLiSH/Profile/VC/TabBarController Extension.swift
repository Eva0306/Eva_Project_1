//
//  TabBarController Extension.swift
//  STYLiSH
//
//  Created by 楊芮瑊 on 2024/8/5.
//

import UIKit
import FacebookLogin

class tabBarController: UITabBarController, UITabBarControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
    }
    
    public func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
        let userInterfaceIndex = 3
        
        if let viewControllers = tabBarController.viewControllers,
           let index = viewControllers.firstIndex(of: viewController),
           index == userInterfaceIndex {
            
            if let accessToken = AccessToken.current, !accessToken.isExpired {
                
                return true
            } else {
                
                presentLoginViewController(isShowProfile: true)
                return false
            }
        }
        
        return true
    }
    
    public func presentLoginViewController(isShowProfile: Bool) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let loginViewController = storyboard.instantiateViewController(withIdentifier: "FBLoginView") as? LoginViewController {
            loginViewController.modalPresentationStyle = .custom
            loginViewController.transitioningDelegate = self
            self.present(loginViewController, animated: true, completion: nil)
            if isShowProfile {
                loginViewController.descriptionLabel.text = LocalizationManager.shared.strWithKey(key: "x1S-Od-uRm.profile.text")
            } else {
                loginViewController.descriptionLabel.text = LocalizationManager.shared.strWithKey(key: "x1S-Od-uRm.checkout.text")
            }
        }
    }
    
}

extension tabBarController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
            return LoginViewPresentationController(presentedViewController: presented, presenting: presenting)
        }
}
