//
//  AnchoringViewModel.swift
//  Drag Alert
//
//  Created by Peter Molettiere on 12/26/23.
//

import Foundation
import SwiftUI

@Observable
class AnchoringViewModel {
    var vessel: Vessel

    var gps: LocationObserver = LocationObserver()
    var selectedTab: AnchoringView.TabState = .relative
    
    var rodeLengthMeters: Double
    var distanceFromAnchorMeters: Double
    
    var willEdit: AnchoringView.EditState
    
    init(vessel: Vessel, state: AnchoringView.EditState) {
        self.vessel = vessel
        self.gps = LocationObserver()
        self.willEdit = state
        self.rodeLengthMeters = 0
        self.distanceFromAnchorMeters = 0
    }
    
    func track(location: Bool = false, heading: Bool = false) {
        gps.isTrackingLocation = location
        gps.isTrackingHeading = heading
        LocationDelegate.instance.isTrackingLocation = location
        LocationDelegate.instance.isTrackingHeading = heading
    }
    
    func dropAnchor(_ location: Location) {
        // if( vessel.isAnchored ) {
        if( willEdit == .edit ) {
            if let anchor = vessel.anchor {
                anchor.location = location
                anchor.rodeInUseMeters = rodeLengthMeters
            }
        } else {
            let newAnchor = Anchor(timestamp: Date.now, location: location, rodeInUseMeters: rodeLengthMeters, log: [], vessel: self.vessel)
            vessel.anchor = newAnchor
            vessel.isAnchored = true
        }
        print("AnchoringVew.dropAnchor() complete")
    }
    
    func relativeLocationWouldAlarm() -> Bool {
        let potentialAnchorLocation = relativeLocation()
        let vesselLocation = vessel.location
        return !vesselLocation.isAccurateWithin(meters: currentSwingRadiusMeters(), of: potentialAnchorLocation)
    }
    
    func currentSwingRadiusMeters() -> Double {
        vessel.loaMeters + rodeLengthMeters
    }

    func setAnchorAtRelativeBearing() {
        let final = relativeLocation()
        print("Dropping anchor at relative position \(final.latitude.formatted(.number.rounded(increment:0.001))), \(final.longitude.formatted(.number.rounded(increment:0.001)))");
        dropAnchor(final)
    }
    
    func relativeLocation() -> Location {
        gps.location.locationWithBearing(bearing: gps.heading.trueHeading, distanceMeters: distanceFromAnchorMeters)
    }
        
    func setAnchorAtCurrentPosition() {
        let final = getCurrentAnchorPosition()
        
        print("Dropping anchor at current position \(final.latitude.formatted(.number.rounded(increment:0.001))), \(final.longitude.formatted(.number.rounded(increment:0.001))).")
        
        dropAnchor(final)
    }
    
    func getCurrentAnchorPosition() -> Location {
        gps.location
    }
}
