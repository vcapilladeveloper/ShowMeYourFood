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

// View Controller to show the products in a TableView and show cart information each time we 
// Touch the button inside cells. Implements ManageProducts Protocol
class ViewController: UIViewController, ManageProductsDelegate {
    // Each time we select the button inside a cell, this func is fired for update cart infromation.
    func updateCart(_ count: Int, _ total: Double) {
        cartProducts.text = "\(count)"
        cartPrice.text = "\(total)€"
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var cartProducts: UILabel!
    @IBOutlet weak var cartPrice: UILabel!
    @IBOutlet weak var restaurantTitle: UILabel!
    @IBOutlet weak var productCountTitle: UILabel!
    @IBOutlet weak var totalCartTitle: UILabel!
    
    var tableViewManager = TableViewManager()
    
    var persistenceModule: PersistenceModule? = nil
    var productsManager: ProductsManager? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = (tableViewManager as! UITableViewDataSource)
        tableViewManager.manageProducts = self
        restaurantTitle.text = LangStr.langStr("Label.resttitle")
        productCountTitle.text = LangStr.langStr("Label.products")
        totalCartTitle.text = LangStr.langStr("Label.total")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loader(true)
        // First of all open database, in case we recive an error, we get message in the catch.
        do {
            persistenceModule = try PersistenceModule.open()
            productsManager = ProductsManager(persistenceModule!)
            // Connect to get products
            ConnectionEngine.getResult(URL(string: (Bundle.main.object(forInfoDictionaryKey: "url") as? String)!)!) { (data, error) in
                            if error {
                                NotificationCenter.default.post(name: .error, object: ["message": LangStr.langStr("Error.getdata")])
                            } else if let d = data as? Data{
                                // If we can retrieve information and decode to desired type
                                var categories = [[String: Any]]()
                                if let products: [Product] = DataModelEngine.modelSerializer(d) {
                                    do {
                                        // Create tables for save Products and Categories
                                        try self.persistenceModule?.createTable(table: Product.self)
                                        try self.persistenceModule?.createTable(table: Category.self)
                                        // For each product, we need to get the cateogry. Add Category to their table and 
                                        // Insert products in their tables.
                                        products: for product in products {
                                            if let category = product.category {
                                                if categories.filter({($0["id"] as? String) == category.id}).count == 0 {
                                                    categories.append(["id": category.id, "name": category.name])
                                                }
                                                do {
                                                    let c = category.name.replacingOccurrences(of: "'", with: "")
                                                    try self.persistenceModule?.insert(statement: "INSERT INTO Categories (id, name, priority) VALUES ('\(category.id)', '\(c)', 10)")
                                                    let n = (product.name ?? "").replacingOccurrences(of: "'", with: "")
                                                    let d = (product.description ?? "").replacingOccurrences(of: "'", with: "")
                                                    let statement = "INSERT INTO Products (id, name, description, storeID, productID, amount, total, fees, categoryId) VALUES ('\(product.id)', '\(n)', '\(d)', '\(product.storeID ?? "")', '\(product.productID )', \(product.amount ?? 0.0), \(product.total ?? 0.0), \(product.fees ?? 0.0), '\(category.id)')"
                                                try self.persistenceModule?.insert(statement: statement)
                                                } catch {
                                                    NotificationCenter.default.post(name: .error, object: ["message": LangStr.langStr("Error.downloadandsave")])
                                                    break products
                                                }
                                            }
                                        }
                                        // After save data, we need to retrieve data to show in the table
                                        let data = self.productsManager?.getProducts()
                                        self.tableViewManager.products = data
                                        self.tableViewManager.categories = categories
                                        // Because we are managing data inside closure, we need to call UI modifications inside a 
                                        // main thread.
                                        DispatchQueue.main.async {
                                            self.tableView.reloadData()
                                            self.loader(false)
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
