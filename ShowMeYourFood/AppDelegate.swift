//
//  AppDelegate.swift
//  ShowMeYourFood
//
//  Created by Victor Capilla Developer on 22/02/2019.
//  Copyright © 2019 VCapillaDev. All rights reserved.
//

import UIKit
import PersistenceModule

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        // Action to add Observer to catch the notification in case is need to show an Alert Error.
        NotificationCenter.default.addObserver(self, selector: #selector(showSimpleAlert(_:)), name: .error, object: nil)
        return true
    }

    @objc func showSimpleAlert(_ notificaction: Notification) {
        var errorMessage = "Ups, something went wrong!"
        if let data = notificaction.object as? [String: String], let message = data["message"] {
            errorMessage = message
        }
        window?.rootViewController!.showSimpleAlert(errorMessage)
    }
}

