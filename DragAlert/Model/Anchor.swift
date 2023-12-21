//
//  Item.swift
//  AnchorWatch
//
//  Created by Peter Molettiere on 11/29/23.
//

import Foundation
import SwiftData
import SwiftUI
import CoreLocation

@Model
final class Anchor : Codable {
    
    var timestamp = Date.now
    var latitude: Double = 0
    var longitude: Double = 0
    var rodeInUseMeters: Double = 0
    var log: [AnchorLog] = []
    var vessel: Vessel? = nil
    
    @Transient
    var rodeInUseMeasurement: Measurement<UnitLength> {
        get { Measurement(value: rodeInUseMeters, unit: .meters) }
        set { rodeInUseMeters = newValue.converted(to: .meters).value }
    }

    @Transient
    var vesselLOA: Measurement<UnitLength> {
        get {
            if let v = vessel {
                return v.loaMeasurement
            }
            return Measurement(value: 0, unit: .meters)
        }
    }
    
    @Transient
    var alarmRadiusMeasurement: Measurement<UnitLength> {
        get { Measurement(value: alarmRadiusMeters, unit: .meters) }
    }

    @Transient
    var alarmRadiusMeters: Double {
        get { rodeInUseMeters + (vessel?.loaMeters ?? 0) }
    }

    
    init(timestamp: Date = Date.now, latitude: Double = 0, longitude: Double = 0, rodeLength: Measurement<UnitLength> = Measurement(value: 50.0, unit: .feet), log: [AnchorLog] = [], vessel: Vessel? = nil) {
        self.timestamp = timestamp
        self.latitude = latitude
        self.longitude = longitude
        self.rodeInUseMeters = rodeLength.converted(to: .meters).value
        self.log = log
        self.vessel = vessel
    }
        
    enum CodingKeys : CodingKey {
        case timestamp, latitude, longitude, rodeLengthM, log, vessel
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.timestamp = try container.decode(Date.self, forKey: .timestamp)
        self.latitude = try container.decode(Double.self, forKey: .latitude)
        self.longitude = try container.decode(Double.self, forKey: .longitude)
        self.rodeInUseMeters = try container.decode(Double.self, forKey: .rodeLengthM)
        self.log = try container.decode([AnchorLog].self, forKey: .log)
        self.vessel = try container.decodeIfPresent(Vessel.self, forKey: .vessel)

    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(timestamp, forKey: .timestamp)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
        try container.encode(rodeInUseMeters, forKey: .rodeLengthM)
        try container.encode(log, forKey: .log)
        try container.encode(vessel, forKey: .vessel)
    }
}

extension Anchor {
    func update(log: AnchorLog) {
        self.log.append(log)
    }

    var coordinate: CLLocationCoordinate2D {
        get { CLLocationCoordinate2D(latitude: latitude, longitude: longitude) }
        set { latitude = newValue.latitude; longitude = newValue.longitude }
    }
    
    var coordinateLog: [CLLocationCoordinate2D] {
        var coords = [CLLocationCoordinate2D]()
        for anchorLog in log {
            coords.append(anchorLog.coordinate)
        }
        return coords
    }
    
    func contains(location: CLLocation) -> Bool {
        CLLocation(latitude: latitude, longitude: longitude).distance(from: location) < alarmRadiusMeters
    }
    
    func contains(location: CLLocationCoordinate2D) -> Bool {
        contains(location: CLLocation(latitude: location.latitude, longitude: location.longitude))
    }
    
    func triggerAlarmIfDragging() {
        if let v = vessel {
            if( v.isAnchored ) {
                if( !contains(location: v.coordinate) ) {
                    Alarm.instance.startPlaying()
                } else {
                    Alarm.instance.stopPlaying()
                }
            }
        }
    }
}