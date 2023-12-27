//
//  Preferences.swift
//  Drag Alert
//
//  Created by Peter Molettiere on 12/26/23.
//

import Foundation

class Preferred {
    
    static let value = Preferred()
    static let lengthUnitLabel = "preferred.length.unit"
    static let lengthUnitNotificationName = NSNotification.Name(lengthUnitLabel)
    
    var lengthUnit: UnitLength {
        didSet {
            UserDefaults.standard.set(lengthUnit.symbol, forKey: Preferred.lengthUnitLabel)
            NotificationCenter.default.post(name: Preferred.lengthUnitNotificationName, object: lengthUnit)
        }
    }
    
    init() {
        lengthUnit = UserDefaults.standard.string(forKey: Preferred.lengthUnitLabel) == "ft" ? UnitLength.feet : UnitLength.meters
    }

}
