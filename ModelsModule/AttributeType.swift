//
//  AttributeType.swift
//  ModelsModule
//
//  Created by Victor Capilla Developer on 22/02/2019.
//  Copyright © 2019 VCapillaDev. All rights reserved.
//

import Foundation
import PersistenceModule

// Attribute_type model implementing codable to generate objects from requested data.
public struct AttributeType: Codable {
    let id: String
    let attributes: [Attribute]
    let unique: Bool
    let name: String
}


// Implements SQLTable protocol, setting up the createStatement 
// computed variable for the creation of table in data base
extension AttributeType: SQLTable {

    public static var createStatement: String {
        return """
            CREATE TABLE IF NOT EXISTS AttributeTypes (
            id TEXT PRIMARY KEY NOT NULL,
            uniqueAttribute INTEGER NOT NULL,
            name TEXT NOT NULL);
        """
    }
}
