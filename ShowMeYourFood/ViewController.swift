//
//  ViewController.swift
//  ShowMeYourFood
//
//  Created by Victor Capilla Developer on 22/02/2019.
//  Copyright © 2019 VCapillaDev. All rights reserved.
//

import UIKit
import ModelsModule
import ConnectionModule
import PersistenceModule

class ViewController: UIViewController {

    var persistenceModule: PersistenceModule? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loader(true)
        do {
            persistenceModule = try PersistenceModule.open()
            ConnectionEngine.getResult(URL(string: (Bundle.main.object(forInfoDictionaryKey: "url") as? String)!)!) { (data, error) in
                            if error {
                                NotificationCenter.default.post(name: .error, object: ["message": "Can't get data form this site."])
                            } else if let d = data as? Data{
                
                                if let products: [Product] = DataModelEngine.modelSerializer(d) {
                                    do {
                                        try self.persistenceModule?.createTable(table: Product.self)
                                        try self.persistenceModule?.createTable(table: Category.self)
                                        for product in products {
                                            if let category = product.category {
                                                try self.persistenceModule?.insert(statement: "INSERT INTO Categories (id, name) VALUES ('\(category.id)', \(category.name))")
                                                try self.persistenceModule?.insert(statement: "INSERT INTO Products (id, name, description, storeID, productID, amount, total, fees, categoryId) VALUES ('\(product.id)', '\(product.name ?? "")', '\(product.description ?? "")', '\(product.storeID ?? "")', '\(product.productID )', \(product.amount ?? 0.0), \(product.total ?? 0.0), \(product.fees ?? 0.0), '\(category.id)',)")
                                                
                                            }
                                        }
                                    } catch {
                                        NotificationCenter.default.post(name: .error, object: ["message": error.localizedDescription])
                                    }
                
                                }
                            }
                        }
        } catch {
            NotificationCenter.default.post(name: .error, object: ["message": error.localizedDescription])
        }
    }
}

