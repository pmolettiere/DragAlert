//
//  Location.swift
//  Drag Alert
//
//  Created by Peter Molettiere on 12/26/23.
//

import MapKit
import SwiftData

struct Location : Codable, Equatable {
    static let nowhere = Location(timestamp: Date.distantPast, latitude: 0, longitude: 0, hAccuracy: -1, altitude: 0, vAccuracy: -1, speed: 0, sAccuracy: -1, course: 0, cAccuracy: -1)

    var timestamp: Date
    var latitude: Double
    var longitude: Double
    var hAccuracy: Double
    var altitude: Double
    var vAccuracy: Double

    var speed: Double // meters per second
    var sAccuracy: Double
    var course: Double // degrees, 0.0 - 359.9
    var cAccuracy: Double

    @Transient var clLocation: CLLocation {
        get { CLLocation(coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), altitude: altitude, horizontalAccuracy: hAccuracy, verticalAccuracy: vAccuracy, course: course, courseAccuracy: cAccuracy, speed: speed, speedAccuracy: sAccuracy, timestamp: timestamp) }
    }
    
    init(timestamp: Date, latitude: Double, longitude: Double, hAccuracy: Double, altitude: Double, vAccuracy: Double, speed: Double, sAccuracy: Double, course: Double, cAccuracy: Double) {
        self.timestamp = timestamp
        self.latitude = latitude
        self.longitude = longitude
        self.hAccuracy = hAccuracy
        self.altitude = altitude
        self.vAccuracy = vAccuracy
        self.speed = speed
        self.sAccuracy = sAccuracy
        self.course = course
        self.cAccuracy = cAccuracy
        
//        self.clLocation = CLLocation(coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), altitude: altitude, horizontalAccuracy: hAccuracy, verticalAccuracy: vAccuracy, course: course, courseAccuracy: cAccuracy, speed: speed, speedAccuracy: sAccuracy, timestamp: timestamp)
    }
    
    init(location: CLLocation) {
        self.timestamp = location.timestamp
        self.latitude = location.coordinate.latitude
        self.longitude = location.coordinate.longitude
        self.hAccuracy = location.horizontalAccuracy
        self.altitude = location.altitude
        self.vAccuracy = location.verticalAccuracy
        self.speed = location.speed
        self.sAccuracy = location.speedAccuracy
        self.course = location.course
        self.cAccuracy = location.courseAccuracy
        
//        self.clLocation = location
    }
    
    enum CodingKeys : CodingKey {
        case timestamp, latitude, longitude, hAccuracy, altitude, vAccuracy, speed, sAccuracy, course, cAccuracy
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.timestamp = try container.decode(Date.self, forKey: .timestamp)
        self.latitude = try container.decode(Double.self, forKey: .latitude)
        self.longitude = try container.decode(Double.self, forKey: .longitude)
        self.hAccuracy = try container.decode(Double.self, forKey: .hAccuracy)
        self.altitude = try container.decode(Double.self, forKey: .altitude)
        self.vAccuracy = try container.decode(Double.self, forKey: .vAccuracy)
        self.speed = try container.decode(Double.self, forKey: .speed)
        self.sAccuracy = try container.decode(Double.self, forKey: .sAccuracy)
        self.course = try container.decode(Double.self, forKey: .course)
        self.cAccuracy = try container.decode(Double.self, forKey: .cAccuracy)

//        self.clLocation = CLLocation(coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), altitude: altitude, horizontalAccuracy: hAccuracy, verticalAccuracy: vAccuracy, timestamp: timestamp)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(timestamp, forKey: .timestamp)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
        try container.encode(hAccuracy, forKey: .hAccuracy)
        try container.encode(altitude, forKey: .altitude)
        try container.encode(vAccuracy, forKey: .vAccuracy)
        try container.encode(speed, forKey: .speed)
        try container.encode(sAccuracy, forKey: .sAccuracy)
        try container.encode(course, forKey: .course)
        try container.encode(cAccuracy, forKey: .cAccuracy)
    }

    /// Returns the distance and accuracy between two Locations in meters
    func distance(from: Location) -> (meters: Double, accuracy: Double) {
        (clLocation.distance(from: from.clLocation), hAccuracy + from.hAccuracy)
    }
    
    /// Returns true if this AnchorLog is inside the given distance and the summed accuracy of the two
    ///  AnchorLogs. False indicates that this point is definitely outside the given distance, even considering
    ///  the accuracy of the two positions.
    func isWithin(meters: Double, of: Location) -> Bool {
        let (distance, accuracy) = distance(from: of)
        return distance < meters + accuracy
    }

    /// Returns a new Location, calculated to be distanceMeters away along bearing, with the same accuracy as this Location.
    func locationWithBearing(bearing:Double, distanceMeters:Double) -> Location {
        let bearingRadians = bearing * .pi / 180
        let distRadians = distanceMeters / (6372797.6) // earth radius in meters
        
        let lat1 = self.latitude * .pi / 180
        let lon1 = self.longitude * .pi / 180
        
        let lat2 = asin(sin(lat1) * cos(distRadians) + cos(lat1) * sin(distRadians) * cos(bearingRadians))
        let lon2 = lon1 + atan2(sin(bearingRadians) * sin(distRadians) * cos(lat1), cos(distRadians) - sin(lat1) * sin(lat2))
        
        return Location(timestamp: Date.now, latitude: lat2 * 180 / .pi, longitude: lon2 * 180 / .pi, hAccuracy: hAccuracy, altitude: altitude, vAccuracy: vAccuracy, speed: speed, sAccuracy: sAccuracy, course: course, cAccuracy: cAccuracy)
    }

}

extension CLLocation {
    convenience init(location: Location) {
        self.init(coordinate: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude), altitude: location.altitude, horizontalAccuracy: location.hAccuracy, verticalAccuracy: location.vAccuracy, course: location.course, courseAccuracy: location.cAccuracy, speed: location.speed, speedAccuracy: location.sAccuracy, timestamp: location.timestamp)
    }
}
