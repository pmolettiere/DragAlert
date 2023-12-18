//
//  Vessel.swift
//  AnchorWatch
//
//  Created by Peter Molettiere on 12/1/23.
//

import Foundation
import SwiftData
import SwiftUI
import CoreLocation
import simd

@Model
final class Vessel : Codable {
    var uuid = UUID()
    var name = String()
    var loaMeters: Double = 0
    var rodeMeters: Double = 0
    var latitude: Double = 0
    var longitude: Double = 0
    var isAnchored = false
    
    @Transient
    var loa: Measurement<UnitLength> {
        get { Measurement(value: loaMeters, unit: UnitLength.meters) }
        set { loaMeters = newValue.converted(to: UnitLength.meters).value }
    }
    
    @Transient
    var rodeLength: Measurement<UnitLength> {
        get { Measurement(value: rodeMeters, unit: UnitLength.meters) }
        set { rodeMeters = newValue.converted(to: UnitLength.meters).value }
    }
    
    @Transient
    var maxDistanceFromAnchor: Measurement<UnitLength> {
        get { Measurement(value: rodeMeters + loaMeters, unit: UnitLength.meters) }
    }
    
    var anchor: Anchor?
    
    init(uuid: UUID = UUID(), name: String = "", loaMeters: Double, rodeMeters: Double, latitude: Double = 0, longitude: Double = 0, isAnchored: Bool = false, anchor: Anchor? = nil) {
        self.uuid = uuid
        self.name = name
        self.loaMeters = loaMeters
        self.rodeMeters = rodeMeters
        self.latitude = latitude
        self.longitude = longitude
        self.isAnchored = isAnchored
        self.anchor = anchor
    }
    
    enum CodingKeys : CodingKey {
        case uuid, name, loaMeters, rodeMeters, latitude, longitude, isAnchored, anchor
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.uuid = try container.decode(UUID.self, forKey: .uuid)
        self.name = try container.decode(String.self, forKey: .name)
        self.loaMeters = try container.decode(Double.self, forKey: .loaMeters)
        self.rodeMeters = try container.decode(Double.self, forKey: .rodeMeters)
        self.latitude = try container.decode(Double.self, forKey: .latitude)
        self.longitude = try container.decode(Double.self, forKey: .longitude)
        self.isAnchored = try container.decode(Bool.self, forKey: .isAnchored)
        self.anchor = try container.decodeIfPresent(Anchor.self, forKey: .anchor)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(uuid, forKey: .uuid)
        try container.encode(name, forKey: .name)
        try container.encode(loaMeters, forKey: .loaMeters)
        try container.encode(rodeMeters, forKey: .rodeMeters)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
        try container.encode(isAnchored, forKey: .isAnchored)
        try container.encodeIfPresent(anchor, forKey: .anchor)
    }
    
    func distance(to: Vessel) -> Double {
        return coordinate.distance(to: to.coordinate)
    }
}

extension Vessel : Equatable, Identifiable, Hashable {
    var id: UUID { uuid }

    static func == (lhs: Vessel, rhs: Vessel) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension Vessel {
    var coordinate: CLLocationCoordinate2D {
        get { CLLocationCoordinate2D(latitude: latitude, longitude: longitude) }
        set { latitude = newValue.latitude; longitude = newValue.longitude }
    }
}

