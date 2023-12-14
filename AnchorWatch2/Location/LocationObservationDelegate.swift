//
//  File.swift
//  AnchorWatch2
//
//  Created by Peter Molettiere on 12/13/23.
//

import Foundation
import MapKit

@Observable
class LocationObservationDelegate {
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
        if let lastLocation: CLLocation = locations.last {
            latitude = lastLocation.coordinate.latitude
            longitude = lastLocation.coordinate.longitude

            if( isAnchored ) {
                if let currentAnchor = anchor {
                    locations.forEach() {
                        currentAnchor.update(log: AnchorLog($0))
                    }
                    if( !currentAnchor.contains(location: lastLocation) ) {
                        Alarm.instance.startPlaying()
                    } else {
                        Alarm.instance.stopPlaying()
                    }
                } else {
                    print("Anchored vessel missing Anchor record. Failing to update anchor log.")
                }
            } else {
                Alarm.instance.stopPlaying()
            }
        }
    }
}
