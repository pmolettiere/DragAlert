//
//  LocationDelegate.swift
//  AnchorWatch
//
//  Created by Peter Molettiere on 12/4/23.
//

import Foundation
import MapKit

class LocationDelegate : NSObject, CLLocationManagerDelegate {
    
    private var compass : Compass? = nil
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        print("AnchorWatch.locationDelegate: locationManagerDidChangeAuthorization: \(manager.authorizationStatus)")
        switch manager.authorizationStatus {
           case .authorizedWhenInUse:  // Location services are available.
//               enableLocationFeatures()
               break
               
           case .restricted, .denied:  // Location services currently unavailable.
//               disableLocationFeatures()
               break
               
           case .notDetermined:        // Authorization not determined yet.
              manager.requestWhenInUseAuthorization()
               break
               
           default:
               break
           }
    }
    
    /*
    func locationManager(_ manager: CLLocationManager, didFailWithError: Error) {
        print("AnchorWatch.locationDelegate: didFailWithError")
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations: [CLLocation]) {
        print("AnchorWatch.locationDelegate: didUpdateLocations")
    }
    
    func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
        print("AnchorWatch.locationDelegate: locationManagerDidPauseLocationUpdates")
    }
    
    func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager) {
        print("AnchorWatch.locationDelegate: locationManagerDidResumeLocationUpdates")
    }
     */

    func locationManager(_ manager: CLLocationManager, didUpdateHeading: CLHeading) {
        print("AnchorWatch.locationDelegate: didUpdateHeading")
        if let c = compass {
            if c.isTracking {
                c.heading = didUpdateHeading.trueHeading
                print("AnchorWatch.locationDelegate: didUpdateHeading delivered heading update")
            } else {
                manager.stopUpdatingHeading()
                compass = nil
                print("AnchorWatch.locationDelegate: didUpdateHeading released headingPointer")
            }
        }
    }
    
    func updateHeadings(compass: Compass) {
        self.compass = compass;
    }

}
