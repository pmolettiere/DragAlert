//
//  Heading.swift
//  Drag Alert
//
//  Created by Peter Molettiere on 12/26/23.
//

import Foundation
import MapKit

struct Heading : Codable {
    static let nowhere = Heading(timestamp: Date.distantPast, magneticHeading: 0, trueHeading: 0, accuracy: -1)
    
    var timestamp: Date
    var magneticHeading: Double
    var trueHeading: Double
    var accuracy: Double
    
    init(timestamp: Date, magneticHeading: Double, trueHeading: Double, accuracy: Double) {
        self.timestamp = timestamp
        self.magneticHeading = magneticHeading
        self.trueHeading = trueHeading
        self.accuracy = accuracy
    }
    
    init(heading: CLHeading) {
        self.timestamp = heading.timestamp
        self.magneticHeading = heading.magneticHeading
        self.trueHeading = heading.trueHeading
        self.accuracy = heading.headingAccuracy
    }
}
