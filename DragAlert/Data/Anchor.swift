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
final class Anchor : @unchecked Sendable {

    var location: Location = Location.nowhere
    var rodeInUseMeters: Double = 0
    var bucketIdx: Dictionary<Bucket, Int> = Dictionary<Bucket, Int>()
    var vessel: Vessel? = nil
    
    @Transient
    var locationCache: [Location] = []
    
    @Transient
    var locationCacheIsDirty: Bool = true
    
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
    
    @Transient
    var maxErrorRadiusMeters: Double {
        get { alarmRadiusMeters + location.hAccuracy + (vessel?.location.hAccuracy ?? 0) }
    }
    
    init(timestamp: Date = Date.now, location: Location, rodeInUseMeters: Double, log: Dictionary<Bucket, Int> = Dictionary(), vessel: Vessel? = nil) {
        self.location = location
        self.rodeInUseMeters = rodeInUseMeters
        self.bucketIdx = log
        self.vessel = vessel
    }
}

extension Anchor {
    func update(location: Location) {
        let bucket = BucketCache.instance.get(of: location, from: self.location)
        var hits = 0
        if bucketIdx[bucket] != nil {
            hits = bucketIdx[bucket]!
        }
        hits += 1
        bucketIdx[bucket] = hits
        Task {
            await rebuildLocationCache()
        }
    }
    
    func rebuildLocationCache() async {
        let lcb = LocationCacheBuilder(bucketIdx: bucketIdx)
        locationCache = await lcb.rebuildLocationCache()
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
