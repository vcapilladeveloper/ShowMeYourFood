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

class ViewController: UIViewController, ManageProductsDelegate {
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
        
        do {
            persistenceModule = try PersistenceModule.open()
            productsManager = ProductsManager(persistenceModule!)
            ConnectionEngine.getResult(URL(string: (Bundle.main.object(forInfoDictionaryKey: "url") as? String)!)!) { (data, error) in
                            if error {
                                NotificationCenter.default.post(name: .error, object: ["message": LangStr.langStr("Error.getdata")])
                            } else if let d = data as? Data{
                                var categories = [[String: Any]]()
                                if let products: [Product] = DataModelEngine.modelSerializer(d) {
                                    do {
                                        try self.persistenceModule?.createTable(table: Product.self)
                                        try self.persistenceModule?.createTable(table: Category.self)
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
                                        let data = self.productsManager?.getProducts()
                                        self.tableViewManager.products = data
                                        self.tableViewManager.categories = categories
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
