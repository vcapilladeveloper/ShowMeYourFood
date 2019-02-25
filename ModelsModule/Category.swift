//
//  Category.swift
//  ModelsModule
//
//  Created by Victor Capilla Developer on 22/02/2019.
//  Copyright © 2019 VCapillaDev. All rights reserved.
//

import Foundation
import PersistenceModule

public class Category: Codable {
    public let id: String
    public let priority: Int
    public let name: String
}

extension Category: SQLTable {

    public static var createStatement: String {
        return """
            CREATE TABLE IF NOT EXISTS Categories (
            id TEXT NOT NULL,
            priority INTEGER NOT NULL,
            name TEXT NOT NULL);
        """
    }
}
