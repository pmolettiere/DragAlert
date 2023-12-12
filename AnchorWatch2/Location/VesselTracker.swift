//
//  VesselTracker.swift
//  AnchorWatch2
//
//  Created by Peter Molettiere on 12/6/23.
//

import Foundation
import MapKit

@MainActor
class VesselTracker {
    static let shared = VesselTracker()  // Create a single, shared instance of the object.

    private let manager: CLLocationManager
    private let locationDelegate: LocationDelegate
    private var background: CLBackgroundActivitySession?

    private var trackedVessel: Vessel? = nil
    private var compass: Compass? = nil

    @Published
    var isTracking: Bool = UserDefaults.standard.bool(forKey: "isTracking") {
        didSet {
            UserDefaults.standard.set(isTracking, forKey: "isTracking")
            // isTracking ? self.background = CLBackgroundActivitySession() : self.background?.invalidate()
        }
    }

    init() {
        self.locationDelegate = LocationDelegate()
        self.manager = CLLocationManager()
        manager.delegate = locationDelegate
    }
    
    func track(vessel: Vessel) {
        trackedVessel = vessel
        
        if manager.authorizationStatus != .authorizedAlways {
            manager.requestAlwaysAuthorization()
        }
        print("VesselTracker: authorization status: \(manager.authorizationStatus)")

        Task() {
            do {
                isTracking = true;
                let updates = CLLocationUpdate.liveUpdates()
                for try await update in updates {
                    if( !isTracking ) { break; }  // exit infinite for try loop
                    if let location = update.location {
                        trackedVessel!.update(location)
                    }
                }
            } catch {
                print("VesselTracker: Could not start location updates")
            }
            return
        }
    }

    func getCompass() -> Compass {
        if( compass != nil ) { return compass! }
            
        if manager.authorizationStatus != .authorizedAlways {
            manager.requestWhenInUseAuthorization()
        }
        print("VesselTracker: authorization status: \(manager.authorizationStatus)")
        
        let newCompass: Compass = Compass()
        locationDelegate.updateHeadings(compass: newCompass)

        Task() {
            do {
                newCompass.isTracking = true;
                manager.startUpdatingHeading()
                let updates = CLLocationUpdate.liveUpdates()
                for try await update in updates {
                    if( !newCompass.isTracking ) {
                        manager.stopUpdatingHeading()
                        break; // exit infinite for try loop
                    }
                    if let location = update.location {
                        newCompass.latitude = location.coordinate.latitude
                        newCompass.longitude = location.coordinate.longitude
                    }
                }
            } catch {
                print("VesselTracker: Could not start location updates")
            }
            return
        }
        
        compass = newCompass
        return newCompass
    }

    
    func restart() {
        if let vessel = trackedVessel {
            track(vessel: vessel)
        }
    }
    
    func cancel(vessel: Vessel) {
        if( trackedVessel == vessel ) {
            isTracking = false
        }
    }
    
}

@Observable
class Compass {
    var isTracking = false
    var heading = 0.0
    var latitude = 0.0
    var longitude = 0.0
}
