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
final class Anchor {

    var location: Location = Location.nowhere
    var rodeInUseMeters: Double = 0
    var log: [Location] = []
    var vessel: Vessel? = nil
    
    @Transient
    var rodeInUseAccuracyMeters: Double {
        get { rodeInUseMeters + location.hAccuracy }
    }
    
    @Transient
    var alarmRadiusMeters: Double {
        get { rodeInUseMeters + (vessel?.loaMeters ?? 0) }
    }
    
    @Transient
    var alarmRadiusAccuracyMeters: Double {
        get { alarmRadiusMeters + location.hAccuracy }
    }

    init(timestamp: Date = Date.now, location: Location, rodeInUseMeters: Double, log: [Location] = [], vessel: Vessel? = nil) {
        self.location = location
        self.rodeInUseMeters = rodeInUseMeters
        self.log = log
        self.vessel = vessel
        
        self.log.sort(by: {$0.timestamp < $1.timestamp})
    }
        
//    enum CodingKeys : CodingKey {
//        case location, rodeLengthM, log, vessel
//    }
//
//    init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        self.location = try container.decode(Location.self, forKey: .location)
//        self.rodeInUseMeters = try container.decode(Double.self, forKey: .rodeLengthM)
//        self.log = try container.decode([Location].self, forKey: .log)
//        self.vessel = try container.decodeIfPresent(Vessel.self, forKey: .vessel)
//
//    }
//    
//    func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(location, forKey: .location)
//        try container.encode(rodeInUseMeters, forKey: .rodeLengthM)
//        try container.encode(log, forKey: .log)
//        try container.encode(vessel, forKey: .vessel)
//    }
}

extension Anchor {
    func update(log: Location) {
        let maxLogSize = 600
        self.log.sort(by: {$0.timestamp < $1.timestamp})
        self.log.removeAll(where: { entry in
            getBucket(of: entry) == getBucket(of: log)
        })
        self.log.append(log)
        if( self.log.count > maxLogSize ) {
            self.log.removeFirst(self.log.count - maxLogSize)
        }
    }
    
    /// Reduces lat/long locaitons into a set of bucketed tuples aligned along specific 0.002 degree boundaries, which
    /// corresponds to roughly square areas 3.7m on a side. Close to the poles, these squares become slightly more
    /// trapezoidal, and the horizontal distance becomes smaller.
    ///
    /// These bucket indices are calculated relative to the anchor location latitude and longitude.
    /// 
    func getBucket(of: Location) -> (Double, Double) {
        // 0.002 degrees of latitude is about 1.85m of distance along a great circle
        // 1000 promotes the bucket number to the left of the decimal point
        let latBucket = ((location.latitude - of.latitude) / 0.005 * 1000).rounded(.towardZero)
        let longBucket = ((location.longitude - of.longitude) / 0.005 * 1000).rounded(.towardZero)
        return (latBucket, longBucket)
    }
            
    func withinAlarmRadius(vessel: Vessel) -> Bool {
        location.isAccurateWithin(meters: alarmRadiusMeters, of: vessel.location)
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
