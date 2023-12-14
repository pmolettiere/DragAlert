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
    var isTrackingLocation: Bool = UserDefaults.standard.bool(forKey: "isTrackingLocation") {
        didSet {
            UserDefaults.standard.set(isTrackingLocation, forKey: "isTrackingLocation")
            if isTrackingLocation {
                manager.startUpdatingLocation()
                self.background = CLBackgroundActivitySession()
            } else {
                manager.stopUpdatingLocation()
                if( !isTrackingHeading ) { self.background?.invalidate() }
            }
        }
    }

    @Published
    var isTrackingHeading: Bool = UserDefaults.standard.bool(forKey: "isTrackingHeading") {
        didSet {
            UserDefaults.standard.set(isTrackingHeading, forKey: "isTrackingHeading")
            if isTrackingHeading {
                manager.startUpdatingHeading()
                self.background = CLBackgroundActivitySession()
            } else {
                manager.stopUpdatingHeading()
                if( !isTrackingLocation ) { self.background?.invalidate() }
            }
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        print("AnchorWatch.locationDelegate: locationManagerDidChangeAuthorization: \(manager.authorizationStatus)")
        NotificationCenter.default.post(name: LocationNotifications.authStatus.asNotificationName(), object: LocationAuthStatusNotification(authStatus: manager.authorizationStatus))
    }
    
    func requestWhenInUseAuthorization() {
        manager.requestWhenInUseAuthorization()
    }
    
    func requestAlwaysAuthorization() {
        manager.requestAlwaysAuthorization()
    }
    
    func requestAuthStatus() {
        NotificationCenter.default.post(name: LocationNotifications.authStatus.asNotificationName(), object: LocationAuthStatusNotification(authStatus: manager.authorizationStatus))
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError: Error) {
        print("AnchorWatch.locationDelegate: didFailWithError")
        NotificationCenter.default.post(name: LocationNotifications.failure.asNotificationName(), object: LocationFailure(error: didFailWithError))

    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations: [CLLocation]) {
//        print("AnchorWatch.locationDelegate: didUpdateLocations")
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
//        print("AnchorWatch.locationDelegate: didUpdateHeading")
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
