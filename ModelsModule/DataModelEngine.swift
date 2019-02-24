//
//  DataModelEngine.swift
//  ModelsModule
//
//  Created by Victor Capilla Developer on 23/02/2019.
//  Copyright © 2019 VCapillaDev. All rights reserved.
//

import Foundation
import UIKit

extension Notification.Name {
    static let error = Notification.Name("error")
}

open class DataModelEngine: NSObject {
    open class func modelSerializer<T: Codable>(_ data: Data) -> T? {
        
        let decoder = JSONDecoder()
        do {
            let genericData = try decoder.decode(T.self, from: data)
            return genericData
        } catch {
            NotificationCenter.default.post(name: .error, object: ["message": error.localizedDescription])
            return nil
        }
    }
}
