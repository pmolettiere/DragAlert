//
//  Item.swift
//  Drag Alert
//
//  Created by Peter Molettiere on 11/29/23.
//
//    Copyright (C) <2023>  <Peter Molettiere>
//
//    This program is free software: you can redistribute it and/or modify
//    it under the terms of the GNU General Public License as published by
//    the Free Software Foundation, either version 3 of the License, or
//    (at your option) any later version.
//
//    This program is distributed in the hope that it will be useful,
//    but WITHOUT ANY WARRANTY; without even the implied warranty of
//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//    GNU General Public License for more details.
//
//    You should have received a copy of the GNU General Public License
//    along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

import Foundation
import SwiftData
import SwiftUI
import CoreLocation

@Model
final class Anchor : Codable {

    var location: Location = Location.nowhere
    var rodeInUseMeters: Double = 0
    var log: [Location] = []
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
    
    init(timestamp: Date = Date.now, location: Location, rodeLength: Measurement<UnitLength> = Measurement(value: 50.0, unit: .feet), log: [Location] = [], vessel: Vessel? = nil) {
        self.location = location
        self.rodeInUseMeters = rodeLength.converted(to: .meters).value
        self.log = log
        self.vessel = vessel
        
        self.log.sort(by: {$0.timestamp < $1.timestamp})
    }
        
    enum CodingKeys : CodingKey {
        case location, rodeLengthM, log, vessel
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.location = try container.decode(Location.self, forKey: .location)
        self.rodeInUseMeters = try container.decode(Double.self, forKey: .rodeLengthM)
        self.log = try container.decode([Location].self, forKey: .log)
        self.vessel = try container.decodeIfPresent(Vessel.self, forKey: .vessel)

    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(location, forKey: .location)
        try container.encode(rodeInUseMeters, forKey: .rodeLengthM)
        try container.encode(log, forKey: .log)
        try container.encode(vessel, forKey: .vessel)
    }
}

extension Anchor {
    func update(log: Location) {
        let maxLogSize = 1000
        let blockSize = 2.0
        self.log.removeAll(where: { entry in
            entry.isWithin(meters: blockSize, of: log)
        })
        self.log.sort(by: {$0.timestamp < $1.timestamp})
        self.log.append(log)
        if( self.log.count > maxLogSize ) {
            self.log.removeFirst(self.log.count - maxLogSize)
        }
    }
            
    func withinAlarmRadius(vessel: Vessel) -> Bool {
        location.isWithin(meters: alarmRadiusMeters, of: vessel.location)
    }
    
    func triggerAlarmIfDragging() {
        if let v = vessel {
            if( v.isAnchored ) {
                if( !withinAlarmRadius(vessel: v) ) {
                    Alarm.instance.startPlaying()
                } else {
                    Alarm.instance.stopPlaying()
                }
            }
        }
    }
}
