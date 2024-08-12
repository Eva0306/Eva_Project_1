//
//  LoginViewPresentationController.swift
//  STYLiSH
//
//  Created by 楊芮瑊 on 2024/8/5.
//

import UIKit

class LoginViewPresentationController: UIPresentationController {
    
    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView = containerView else { return .zero }
        let containerBounds = containerView.bounds
        let height: CGFloat = containerBounds.height / 4
        let frame =  CGRect(x: 0, y: containerBounds.height - height, width: containerBounds.width, height: height)
        
        presentedView?.layer.cornerRadius = 10
        presentedView?.layer.masksToBounds = true
        
        return frame
    }

    override func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()
        
        guard let containerView = containerView else { return }
        
        let dimmingView = UIView(frame: containerView.bounds)
        dimmingView.backgroundColor = UIColor(white: 0.0, alpha: 0.5)
        dimmingView.alpha = 0.0
        containerView.addSubview(dimmingView)
        
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            dimmingView.alpha = 1.0
        })
    }

    override func dismissalTransitionWillBegin() {
        super.dismissalTransitionWillBegin()
        
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            self.containerView?.subviews.last?.alpha = 0.0
        }, completion: { _ in
            self.containerView?.subviews.last?.removeFromSuperview()
        })
    }
}

