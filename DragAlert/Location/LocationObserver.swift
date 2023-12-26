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
    var location: Location = Location.nowhere
    var heading: Heading = Heading.nowhere

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
            let ha = lastLocation.horizontalAccuracy
            if( ha > 0 ) {  // less than 0 is an invalid location
                location = Location(location: lastLocation)
                locationCallback?()
            }
        }
    }
    
    @objc func didUpdateHeading(notification: Notification) {
        let headingUpdate: HeadingUpdate = notification.object as! HeadingUpdate
        let h: CLHeading = headingUpdate.heading
        if( h.headingAccuracy > 0.0 ) {
            self.heading = Heading(heading: h)
            headingCallback?()
        }
    }
}

