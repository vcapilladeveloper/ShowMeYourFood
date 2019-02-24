//
//  Attribute.swift
//  ModelsModule
//
//  Created by Victor Capilla Developer on 22/02/2019.
//  Copyright © 2019 VCapillaDev. All rights reserved.
//

import Foundation
import PersistenceModule

public struct Attribute: Codable {
    let id: String
    let total, amount, fees: Double
    let name: String
}

extension Attribute: SQLTable {

    public static var createStatement: String {
        return """
            CREATE TABLE IF NOT EXISTS Attribute (
            id TEXT PRIMARY KEY NOT NULL,
            total REAL NOT NULL,
            amount REAL NOT NULL,
            fees REAL NOT NULL,
            name TEXT NOT NULL);
        """
    }
}
