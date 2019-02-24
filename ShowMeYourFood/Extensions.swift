//
//  Extensions.swift
//  ShowMeYourFood
//
//  Created by Victor Capilla Developer on 23/02/2019.
//  Copyright © 2019 VCapillaDev. All rights reserved.
//

import Foundation
import UIKit

extension Notification.Name {
    static let error = Notification.Name("error")
}

extension UIViewController {
    /// Action to show the Alert when notification with error type is recived
    ///
    /// - Parameter notificaction: notificatin recived
    func showSimpleAlert(_ message: String) {
        
        let errorMessage = message
        
        let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { (alert) in
            
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    /// Show loader animation
    ///
    /// - Parameter hide: Specify if you want to hide in case is visible
    func loader(_ show: Bool) {
        let viewTag = 101
        if show {
            let blurEffect = UIBlurEffect(style: .dark)
            let blurredEffectView = UIVisualEffectView(effect: blurEffect)
            let size = self.view.frame.size
            let rect = CGRect(origin: CGPoint.zero, size: size)
            let baseView = UIView(frame: rect)
            baseView.tag = viewTag
            let activityIndicator = UIActivityIndicatorView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 30, height: 30)))
            activityIndicator.center = baseView.center
            blurredEffectView.frame = baseView.bounds
            baseView.addSubview(blurredEffectView)
            baseView.addSubview(activityIndicator)
            activityIndicator.startAnimating()
            self.view.addSubview(baseView)
        } else {
            if let baseView = self.view.viewWithTag(viewTag) {
                baseView.removeFromSuperview()
            }
        }
    }
}
