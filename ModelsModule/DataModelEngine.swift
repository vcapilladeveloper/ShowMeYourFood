//
//  DataModelEngine.swift
//  ModelsModule
//
//  Created by Victor Capilla Developer on 23/02/2019.
//  Copyright © 2019 VCapillaDev. All rights reserved.
//

import Foundation
import UIKit

// Extends Notification names to add Error to the cases of names.
extension Notification.Name {
    static let error = Notification.Name("error")
}

// Class designed to manage data object and convert to some generic type
open class DataModelEngine: NSObject {
    
    // Function that recibe Data and, setting some Codable type, generetes objects for this type decoding Data.
    open class func modelSerializer<T: Codable>(_ data: Data) -> T? {
        
        let decoder = JSONDecoder()
        do {
            let genericData = try decoder.decode(T.self, from: data)
            return genericData
        } catch {
            // Send Notification to the notification Center, managed inside AppDelegate and showed in actual ViewController
            NotificationCenter.default.post(name: .error, object: ["message": error.localizedDescription])
            return nil
        }
    }
}
