//
//  LocationDelegate.swift
//  AnchorWatch
//
//  Created by Peter Molettiere on 12/4/23.
//

import Foundation
import MapKit
import simd

class LocationDelegate : NSObject, CLLocationManagerDelegate {
    
    private let manager: CLLocationManager
    private var background: CLBackgroundActivitySession?

    override init() {
        self.manager = CLLocationManager()
        super.init()
        manager.delegate = self
    }
    
    @Published
    var isTracking: Bool = UserDefaults.standard.bool(forKey: "isTracking") {
        didSet {
            UserDefaults.standard.set(isTracking, forKey: "isTracking")
            // isTracking ? self.background = CLBackgroundActivitySession() : self.background?.invalidate()
        }
    }
        
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        print("AnchorWatch.locationDelegate: locationManagerDidChangeAuthorization: \(manager.authorizationStatus)")
        switch manager.authorizationStatus {
        case .authorizedWhenInUse:  // Location services are available.
            NotificationCenter.default.post(name: LocationNotifications.authStatus.asNotificationName(), object: LocationAuthStatusNotification(isAuthorized: true))
            break
            
        case .restricted, .denied:  // Location services currently unavailable.
            NotificationCenter.default.post(name: LocationNotifications.authStatus.asNotificationName(), object: LocationAuthStatusNotification(isAuthorized: false))
            break
            
        case .notDetermined:        // Authorization not determined yet.
            manager.requestWhenInUseAuthorization()
            break
            
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError: Error) {
        print("AnchorWatch.locationDelegate: didFailWithError")
        NotificationCenter.default.post(name: LocationNotifications.failure.asNotificationName(), object: LocationFailure(error: didFailWithError))

    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations: [CLLocation]) {
        print("AnchorWatch.locationDelegate: didUpdateLocations")
        NotificationCenter.default.post(name: LocationNotifications.updateLocation.asNotificationName(), object: LocationUpdate(locations: didUpdateLocations))
    }
    
    func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
        print("AnchorWatch.locationDelegate: locationManagerDidPauseLocationUpdates")
        NotificationCenter.default.post(name: LocationNotifications.pauseLocations.asNotificationName(), object: nil)
    }
    
    func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager) {
        print("AnchorWatch.locationDelegate: locationManagerDidResumeLocationUpdates")
        NotificationCenter.default.post(name: LocationNotifications.resumeLocations.asNotificationName(), object: nil)
    }

    func locationManager(_ manager: CLLocationManager, didUpdateHeading: CLHeading) {
        print("AnchorWatch.locationDelegate: didUpdateHeading")
        NotificationCenter.default.post(name: LocationNotifications.updateHeading.asNotificationName(), object: HeadingUpdate(heading: didUpdateHeading))
    }
}

extension CLLocationCoordinate2D {
    /// Calculates a value that's proportional to the distance between two points.
    func distance(to coordinate: CLLocationCoordinate2D) -> Double {
        simd.distance(
            SIMD2<Double>(x: latitude, y: longitude),
            SIMD2<Double>(x: coordinate.latitude, y: coordinate.longitude))
    }
}

extension Vessel {
    func startTrackingLocation() {
        NotificationCenter.default.addObserver(self, selector: #selector(locationDidUpdate), name: LocationNotifications.updateLocation.asNotificationName(), object: nil)
    }
    
    @objc func locationDidUpdate( notification: Notification ) {
        let locationUpdate: LocationUpdate = notification.object as! LocationUpdate
        let locations = locationUpdate.locations
        if let lastLocation: CLLocation = locations.last {
            latitude = lastLocation.coordinate.latitude
            longitude = lastLocation.coordinate.longitude
        }
        if( isAnchored ) {
            if let currentAnchor = anchors?.last {
                locations.forEach() {
                    currentAnchor.update(log: AnchorLog($0))
                }
            } else {
                print("Anchored vessel missing Anchor record. Failing to update anchor log.")
            }
        }
    }
}



