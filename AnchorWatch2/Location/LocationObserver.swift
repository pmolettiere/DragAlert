//
//  File.swift
//  AnchorWatch2
//
//  Created by Peter Molettiere on 12/13/23.
//

import Foundation
import MapKit

@Observable
class LocationObserver {
    var latitude: Double = 0
    var longitude: Double = 0
    var heading: Double = 0
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
    
    init() {
        isTrackingHeading = false
        isTrackingLocation = false
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
    }
    
    @objc func didUpdateHeading(notification: Notification) {
        let headingUpdate: HeadingUpdate = notification.object as! HeadingUpdate
        heading = headingUpdate.heading.trueHeading
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
