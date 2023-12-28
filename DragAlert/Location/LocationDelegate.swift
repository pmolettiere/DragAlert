//
//  LocationDelegate.swift
//  Drag Alert
//
//  Created by Peter Molettiere on 12/4/23.
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
import simd

class LocationDelegate : NSObject {
    
    static let instance = LocationDelegate()
    
    private let manager: CLLocationManager
    private var background: CLBackgroundActivitySession?
    
    override init() {
        self.manager = CLLocationManager()
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.activityType = CLActivityType.otherNavigation
        manager.pausesLocationUpdatesAutomatically = false
        print("LocationDelegate.init() called.")
    }
    
    @Published
    var isTrackingLocation: Bool = UserDefaults.standard.bool(forKey: "isTrackingLocation") {
        didSet {
            UserDefaults.standard.set(isTrackingLocation, forKey: "isTrackingLocation")
            if isTrackingLocation {
                manager.startUpdatingLocation()
            } else {
                manager.stopUpdatingLocation()
            }
        }
    }
    
    @Published
    var isTrackingHeading: Bool = UserDefaults.standard.bool(forKey: "isTrackingHeading") {
        didSet {
            UserDefaults.standard.set(isTrackingHeading, forKey: "isTrackingHeading")
            if isTrackingHeading {
                manager.startUpdatingHeading()
            } else {
                manager.stopUpdatingHeading()
            }
        }
    }
    
    func trackLocationInBackground(_ isEnabled: Bool) {
        if( background == nil) { background = CLBackgroundActivitySession() }
        manager.allowsBackgroundLocationUpdates = isEnabled
        manager.showsBackgroundLocationIndicator = isEnabled
        if( isEnabled ) {
            manager.startUpdatingLocation()
        }
        print("Background tracking set to \(isEnabled)")
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
    
    func allowsBackground() -> Bool {
        manager.allowsBackgroundLocationUpdates && manager.showsBackgroundLocationIndicator
    }
}

extension LocationDelegate : CLLocationManagerDelegate {

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        print("AnchorWatch.locationDelegate: locationManagerDidChangeAuthorization: \(manager.authorizationStatus)")
        NotificationCenter.default.post(name: LocationNotifications.authStatus.asNotificationName(), object: LocationAuthStatusNotification(authStatus: manager.authorizationStatus))
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError: Error) {
        print("AnchorWatch.locationDelegate: didFailWithError")
        NotificationCenter.default.post(name: LocationNotifications.failure.asNotificationName(), object: LocationFailure(error: didFailWithError))

    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations: [CLLocation]) {
        //print("AnchorWatch.locationDelegate: didUpdateLocations")
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
        //print("AnchorWatch.locationDelegate: didUpdateHeading")
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
