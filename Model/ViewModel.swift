//
//  ViewModel.swift
//  AnchorWatch
//

import Foundation
import SwiftData
import SwiftUI

@MainActor
@Observable class ViewModel {
    var container: ModelContainer
    var locationDelegate: LocationDelegate
    
    var myVessel: Vessel?
    
    init(_ container: ModelContainer) {
        self.container = container
        self.locationDelegate = LocationDelegate.instance
    }
    
    func initMyVessel() {
        let context = container.mainContext
        var fd = FetchDescriptor<Vessel>()
        fd.fetchLimit = 1
        fd.includePendingChanges = true
        
        do {
            if let myVessel = try context.fetch(fd).first {
                self.myVessel = myVessel
                locationDelegate.isTrackingLocation = true
                self.myVessel?.startTrackingLocation()
                
                if let anchor = myVessel.anchor {
                    if( myVessel.isAnchored ) {
                        if( !anchor.contains(location: myVessel.coordinate) ) {
                            Alarm.instance.stopPlaying()
                        } else {
                            Alarm.instance.stopPlaying()
                        }
                    }
                }
            }
        } catch {
            fatalError("Could not retrieve or create own vessel: \(error)")
        }
    }
    
    func requestWhenInUseAuthorization() {
        locationDelegate.requestWhenInUseAuthorization()
    }
    
    func requestAlwaysAuthorization() {
        locationDelegate.requestAlwaysAuthorization()
    }
    
    func requestAuthStatus() {
        locationDelegate.requestAuthStatus()
    }
    
    func isTrackingLocation(isTracking: Bool) {
        locationDelegate.isTrackingLocation = isTracking
    }
    
    func isTrackingHeading(isTracking: Bool) {
        locationDelegate.isTrackingHeading = isTracking
    }

}
