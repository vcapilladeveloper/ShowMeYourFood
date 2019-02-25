//
//  TableViewManager.swift
//  ShowMeYourFood
//
//  Created by Victor Capilla Developer on 25/02/2019.
//  Copyright © 2019 VCapillaDev. All rights reserved.
//

import Foundation
import UIKit

protocol ManageProductsDelegate {
    func updateCart(_ count: Int, _ total: Double)
}

final class TableViewManager: NSObject {
    var products: [[String: Any]]?
    var categories: [[String: Any]]?
    var cartProducts = [String]()
    var total: Double = 0.0
    var manageProducts: ManageProductsDelegate?
}

extension TableViewManager: UITableViewDataSource, ProductCellDelegate {
    func selectedProduct(_ add: Bool,_ product: [String: Any]?) {
        
        if let p = product {
            if add {
                cartProducts.append(p["id"] as! String)
                total += p["total"] as! Double
                manageProducts?.updateCart(cartProducts.count, total)
            } else {
                cartProducts = cartProducts.filter({$0 != p["id"] as! String})
                total -= p["total"] as! Double
                manageProducts?.updateCart(cartProducts.count, total)
            }
        }
    }

    /// Return the number of sections for our table. In this case, the number of categories.
    ///
    /// - Parameter tableView: Instance of TableView.
    /// - Returns: Return the number of sections for the table
    func numberOfSections(in tableView: UITableView) -> Int {
        return categories?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = 0
        if let p = products, let c = categories {
            count = p.filter({$0["categoryId"] as? String == c[section]["id"] as? String }).count
        }

        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "productCell", for: indexPath) as? CellForFood else {
            return UITableViewCell()
        }
        var productsByCategory = [[String: Any]]()
        if let p = products, let c = categories {
             productsByCategory = p.filter({$0["categoryId"] as? String == c[indexPath.section]["id"] as? String })
        }
        let product = productsByCategory[indexPath.row]
        cell.product = product
        cell.productName.text = product["name"] as? String
        cell.productDescription.text = product["description"] as? String
        cell.productPrice.text = "\(product["total"] as? Double ?? 0.0)€"
        cell.delegate = self
 
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let c = categories {
            return (c[section]["name"] as! String)
        }
        return ""
    }
    
    
}
