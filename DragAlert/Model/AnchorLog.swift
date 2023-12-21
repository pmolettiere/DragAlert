//
//  AnchorLog.swift
//  AnchorWatch
//
//  Created by Peter Molettiere on 12/1/23.
//

import Foundation
import SwiftData
import SwiftUI
import CoreLocation


struct AnchorLog : Codable {
    var timestamp = Date.now
    var latitude: Double = 0
    var longitude: Double = 0

    init(timestamp: Date = Date.now, latitude: Double = 0, longitude: Double = 0) {
        self.timestamp = timestamp
        self.latitude = latitude
        self.longitude = longitude
    }
    
    init(_ location: CLLocation) {
        self.timestamp = location.timestamp
        self.latitude = location.coordinate.latitude
        self.longitude = location.coordinate.longitude
    }
    
    enum CodingKeys : CodingKey {
        case timestamp, latitude, longitude
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.timestamp = try container.decode(Date.self, forKey: .timestamp)
        self.latitude = try container.decode(Double.self, forKey: .latitude)
        self.longitude = try container.decode(Double.self, forKey: .longitude)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(timestamp, forKey: .timestamp)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
    }
}

extension AnchorLog {
    var coordinate: CLLocationCoordinate2D {
        get { CLLocationCoordinate2D(latitude: latitude, longitude: longitude) }
        set { latitude = newValue.latitude; longitude = newValue.longitude }
    }
}
