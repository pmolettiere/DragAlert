//
//  LocationObserver.swift
//  Drag Alert
//
//  Created by Peter Molettiere on 12/13/23.
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
import MapKit

@Observable
class LocationObserver {
    var latitude: Double = 0
    var longitude: Double = 0
    var heading: Double = 0
    
    var locationCallback: (() -> Void)?
    var headingCallback: (() -> Void)?
    
    var isTrackingLocation: Bool {
        didSet {
            if( isTrackingLocation ) {
                NotificationCenter.default.addObserver(self, selector: #selector(didUpdateLocation), name: LocationNotifications.updateLocation.asNotificationName(), object: nil)
            } else {
                NotificationCenter.default.removeObserver(self, name: LocationNotifications.updateLocation.asNotificationName(), object: nil)
            }
        }
    }
    var isTrackingHeading: Bool {
        didSet {
            if( isTrackingHeading ) {
                NotificationCenter.default.addObserver(self, selector: #selector(didUpdateHeading), name: LocationNotifications.updateHeading.asNotificationName(), object: nil)
            } else {
                NotificationCenter.default.removeObserver(self, name: LocationNotifications.updateHeading.asNotificationName(), object: nil)
            }
        }
    }
    
    init(locationCallback: (() ->Void)? = nil, headingCallback: (() ->Void)? = nil ) {
        isTrackingHeading = false
        isTrackingLocation = false
        self.locationCallback = locationCallback
        self.headingCallback = headingCallback
    }
        
    deinit {
        NotificationCenter.default.removeObserver(self, name: LocationNotifications.updateLocation.asNotificationName(), object: nil)
        NotificationCenter.default.removeObserver(self, name: LocationNotifications.updateHeading.asNotificationName(), object: nil)
    }
        
    @objc func didUpdateLocation(notification: Notification) {
        let locationUpdate: LocationUpdate = notification.object as! LocationUpdate
        let locations = locationUpdate.locations
        if let lastLocation: CLLocation = locations.last {
            latitude = lastLocation.coordinate.latitude
            longitude = lastLocation.coordinate.longitude
        }
        locationCallback?()
    }
    
    @objc func didUpdateHeading(notification: Notification) {
        let headingUpdate: HeadingUpdate = notification.object as! HeadingUpdate
        heading = headingUpdate.heading.trueHeading
        headingCallback?()
    }
}

extension Vessel {
    func startTrackingLocation() {
        NotificationCenter.default.addObserver(self, selector: #selector(locationDidUpdate), name: LocationNotifications.updateLocation.asNotificationName(), object: nil)
    }
    
    func stopTrackingLocation() {
        NotificationCenter.default.removeObserver(self, name: LocationNotifications.updateLocation.asNotificationName(), object: nil)
    }

    @objc func locationDidUpdate( notification: Notification ) {
        let locationUpdate: LocationUpdate = notification.object as! LocationUpdate
        let locations = locationUpdate.locations
        locations.forEach { location in
            latitude = location.coordinate.latitude
            longitude = location.coordinate.longitude
            if( isAnchored ) {
                anchor?.update(log: AnchorLog(location))
                anchor?.triggerAlarmIfDragging()
            } else {
                Alarm.instance.stopPlaying()
            }
        }
    }
    
}
