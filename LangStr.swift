//
//  LangStr.swift
//  ShowMeYourFood
//
//  Created by Victor Capilla Developer on 25/02/2019.
//  Copyright © 2019 VCapillaDev. All rights reserved.
//

import Foundation

// Class to manage the Language strings localized
final class LangStr {
    
    final class func langStr(_ text: String) -> String {
        return NSLocalizedString(text, comment: text)
    }
    
}
