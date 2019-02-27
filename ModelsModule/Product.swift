//
//  Product.swift
//  ModelsModule
//
//  Created by Victor Capilla Developer on 22/02/2019.
//  Copyright © 2019 VCapillaDev. All rights reserved.
//

import Foundation
import PersistenceModule

// Product model implementing codable for generate objects from requested data.
public class Product: Codable{
    
    public let storeID: String?
    public let productID: String
    public let amount: Double?
    public let id: String
    public let total, fees: Double?
    public let name, description: String?
    public let priority: Int?
    public let keywords: [String]?
    public let dinners: Int?
    public let category: Category?
    public let attributeTypes: [AttributeType]?
    
    // Because some keys from Encode are not the same like recived from server, we must make the assignation
    enum CodingKeys: String, CodingKey {
        case storeID = "storeId"
        case productID = "productId"
        case amount, id, total, fees, name, description, priority, keywords, dinners
        case category
        case attributeTypes = "attribute_types"
    }
}


// Implements SQLTable protocol, setting up the createStatement 
// computed variable for the creation of table in data base
extension Product: SQLTable {

    public static var createStatement: String {
        return """
            CREATE TABLE IF NOT EXISTS Products (
            id TEXT PRIMARY KEY,
            name TEXT,
            description TEXT,
            storeID TEXT,
            productID TEXT NOT NULL,
            amount REAL,
            total REAL,
            fees REAL,
            priority INTEGER,
            dinners INTEGER,
            categoryId INTEGER);
        """
    }
}
