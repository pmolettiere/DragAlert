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
    var latitude: Double = 0
    var longitude: Double = 0
    var isAnchored = false
    
    @Transient
    var loa: Measurement<UnitLength> {
        get { Measurement(value: loaMeters, unit: UnitLength.meters) }
        set { loaMeters = newValue.converted(to: UnitLength.meters).value }
    }
    
    @Relationship(deleteRule: .cascade)
    var anchors: [Anchor]? = []
    
    @Transient
    var lastAnchor : Anchor {
        get {
            if let anchor = anchors?.last {
                return anchor
            }
            return Anchor.new()
        }
        set {
            anchors?.append(newValue)
        }
    }

    init(uuid: UUID = UUID(), name: String = "", loaMeters: Double, latitude: Double = 0, longitude: Double = 0, isAnchored: Bool = false, anchor: [Anchor]? = []) {
        self.uuid = uuid
        self.name = name
        self.loaMeters = loaMeters
        self.latitude = latitude
        self.longitude = longitude
        self.isAnchored = isAnchored
        self.anchors = anchor
    }
    
    enum CodingKeys : CodingKey {
        case uuid, name, loaMeters, latitude, longitude, isAnchored, anchors
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.uuid = try container.decode(UUID.self, forKey: .uuid)
        self.name = try container.decode(String.self, forKey: .name)
        self.loaMeters = try container.decode(Double.self, forKey: .loaMeters)
        self.latitude = try container.decode(Double.self, forKey: .latitude)
        self.longitude = try container.decode(Double.self, forKey: .longitude)
        self.isAnchored = try container.decode(Bool.self, forKey: .isAnchored)
        self.anchors = try container.decodeIfPresent([Anchor].self, forKey: .anchors)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(uuid, forKey: .uuid)
        try container.encode(name, forKey: .name)
        try container.encode(loaMeters, forKey: .loaMeters)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
        try container.encode(isAnchored, forKey: .isAnchored)
        try container.encodeIfPresent(anchors, forKey: .anchors)
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

extension Vessel {
    
    // one minute is 1nm, or 1852m, making 1m = 0.0005399568035 minutes
    /// A filter that checks for a date and text in the quake's location name.
    static func predicate(
        searchText: String
    ) -> Predicate<Vessel> {
        return #Predicate<Vessel> { vessel in
            vessel.name == searchText
        }
    }
    
    static func predicate() -> Predicate<Vessel> {
        return #Predicate<Vessel> { vessel in
            !vessel.name.isEmpty
        }
    }

    /// Reports the total number of quakes.
    static func totalVessels(modelContext: ModelContext) -> Int {
        (try? modelContext.fetchCount(FetchDescriptor<Vessel>())) ?? 0
    }
}

extension Vessel {
    static func new() -> Vessel {
        Vessel(uuid: UUID(), name: "My Vessel", loaMeters: 14, latitude: 0.0, longitude: 0.0, isAnchored: false, anchor: [Anchor.new()])
    }
}
