//
//  AttributeType.swift
//  ModelsModule
//
//  Created by Victor Capilla Developer on 22/02/2019.
//  Copyright © 2019 VCapillaDev. All rights reserved.
//

import Foundation
import PersistenceModule

public struct AttributeType: Codable {
    let id: String
    let attributes: [Attribute]
    let unique: Bool
    let name: String
}

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
