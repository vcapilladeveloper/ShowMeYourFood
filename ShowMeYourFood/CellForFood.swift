//
//  CellForFood.swift
//  ShowMeYourFood
//
//  Created by Victor Capilla Developer on 25/02/2019.
//  Copyright © 2019 VCapillaDev. All rights reserved.
//

import Foundation
import UIKit


protocol ProductCellDelegate {
    func selectedProduct(_ add: Bool, _ product: [String: Any]?)
}

final class CellForFood: UITableViewCell {
    var product: [String: Any]?
    var delegate: ProductCellDelegate?
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var productPrice: UILabel!
    @IBOutlet weak var productDescription: UILabel!
    
    @IBAction func addRemoveProduct(_ sender: UIButton) {
        
        if sender.currentImage == #imageLiteral(resourceName: "remove") {
            sender.setImage( #imageLiteral(resourceName: "add"), for: .normal)
            delegate?.selectedProduct(false, product)
        } else {
            sender.setImage( #imageLiteral(resourceName: "remove"), for: .normal)
            delegate?.selectedProduct(true, product)
        }
        
    }
    
    
    
}
