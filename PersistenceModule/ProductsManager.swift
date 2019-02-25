//
//  ProductsManager.swift
//  PersistenceModule
//
//  Created by Victor Capilla Developer on 24/02/2019.
//  Copyright © 2019 VCapillaDev. All rights reserved.
//

import Foundation
import SQLite3

open class ProductsManager {
    var selectStatement: String
    var persistenceModule: PersistenceModule?
    
    public init(_ persistenceModule: PersistenceModule) {
        selectStatement = """
        SELECT id, name, description, total, categoryId
        FROM Products WHERE name NOT NULL;
        """
        self.persistenceModule = persistenceModule
        /* selectStatement = """
         SELECT id, name, description, total
         FROM Products p WHERE name NOT NULL;
         """*/
    }
    
    open func getProducts() -> [[String: Any]]? {
        var result: [[String: Any]]? = nil
        var queryStatement: OpaquePointer? = nil
        // let persistenceModule: PersistenceModule?
        // 1 Prepare the statement to be executed
        do {
            // persistenceModule = try PersistenceModule.open()
            // 6 end the query
            defer{ sqlite3_finalize(queryStatement) }
            if sqlite3_prepare_v2(persistenceModule!.db, selectStatement, -1, &queryStatement, nil) == SQLITE_OK {
                // 2 Execute the statement. It takes a ROW instead a OK because we tetrive a row
                while sqlite3_step(queryStatement) == SQLITE_ROW {
                    if result == nil {
                        result = [[String: Any]]()
                    }
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
