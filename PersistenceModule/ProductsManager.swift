//
//  ProductsManager.swift
//  PersistenceModule
//
//  Created by Victor Capilla Developer on 24/02/2019.
//  Copyright © 2019 VCapillaDev. All rights reserved.
//

import Foundation
import SQLite3

// Class designed for manage the interactions with the Database for retrieve Products
open class ProductsManager {
    
    var selectStatement: String
    var persistenceModule: PersistenceModule?
    
    // Init instance with a persisntence module instance injection. 
    // We need the persistence module instance for not duplicate pointers to the database
    public init(_ persistenceModule: PersistenceModule) {
        // Setup the selectStatement by default for get products
        selectStatement = """
        SELECT id, name, description, total, categoryId
        FROM Products WHERE name NOT NULL;
        """
        self.persistenceModule = persistenceModule
    }
    
    // Call this function to retrieve all products from database
    open func getProducts() -> [[String: Any]]? {
        var result: [[String: Any]]? = nil
        var queryStatement: OpaquePointer? = nil
        // Prepare the statement to be executed
        do {
            // end the query
            defer{ sqlite3_finalize(queryStatement) }
            // If the selectStatement is executable, save inside queryStatement
            if sqlite3_prepare_v2(persistenceModule!.db, selectStatement, -1, &queryStatement, nil) == SQLITE_OK {
                // Execute the statement. It takes a ROW instead a OK because we retrive a row
                // Make a while bucle for get all objects from the select
                while sqlite3_step(queryStatement) == SQLITE_ROW {
                    // The first time we need to init result for insert values 
                    if result == nil {
                        result = [[String: Any]]()
                    }
                    
                    // Get ID in col0, name in col1, description in col2, total in col3 and categoryId in col4
                    var product = [String: Any]()
                    let queryResultCol0 = sqlite3_column_text(queryStatement, 0)
                    let id = String(cString: queryResultCol0!)
                    product["id"] = id
                    let queryResultCol1 = sqlite3_column_text(queryStatement, 1)
                    let name = String(cString: queryResultCol1!)
                    product["name"] = name
                    let queryResultCol2 = sqlite3_column_text(queryStatement, 2)
                    let description = String(cString: queryResultCol2!)
                    product["description"] = description
                    let queryResultCol3 = sqlite3_column_double(queryStatement, 3)
                    product["total"] = queryResultCol3
                    let queryResultCol4 = sqlite3_column_text(queryStatement, 4)
                    let categoryId = String(cString: queryResultCol4!)
                    product["categoryId"] = categoryId
                    result?.append(product)
                }
                
                return result
                
            } else {
                NotificationCenter.default.post(name: .error, object: ["message": "SELECT statement could not be prepared"])
            }
        } catch {
            NotificationCenter.default.post(name: .error, object: ["message": error.localizedDescription])
        }
        return result
    }
}
