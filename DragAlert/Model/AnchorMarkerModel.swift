//
//  AnchorMarkerModel.swift
//  Drag Alert
//
//  Created by Peter Molettiere on 12/26/23.
//

import Foundation
import MapKit

protocol AnchorMarkerModel : ObservableObject {
    func getAnchorLocation() -> Location
    func getAlarmRadius() -> Double
    func getRodeLengthMeters() -> Double
    func getMaxErrorRadiusMeters() -> Double
    func getLocationLog() -> [Location]
}

extension Anchor : AnchorMarkerModel {
    static var centers: Dictionary<Bucket, [Location]> = Dictionary<Bucket, [Location]>()
    
    func getAnchorLocation() -> Location { location }
    func getAlarmRadius() -> Double { alarmRadiusAccuracyMeters }
    func getRodeLengthMeters() -> Double { rodeInUseAccuracyMeters }
    func getMaxErrorRadiusMeters() -> Double { maxErrorRadiusMeters }
    func getLocationLog() -> [Location] { locationCache }
}

extension AnchoringViewModel : AnchorMarkerModel {
    
    func getAnchorLocation() -> Location {
        if( selectedTab == .relative ) {
            return relativeLocation()
        } else {
            return getCurrentAnchorPosition()
        }
    }
    
    func getAlarmRadius() -> Double {
        let x = currentSwingRadiusMeters()
        // print( "alarm radius got \(x)")
        return x
    }
    
    func getMaxErrorRadiusMeters() -> Double {
        getAlarmRadius() + vessel.location.hAccuracy
    }
    
    func getRodeLengthMeters() -> Double {
        rodeLengthMeters
    }
    
    func getLocationLog() -> [Location] {
        if let anchor = vessel.anchor {
//            var m = anchor.getLocationLog().count - 100
//            if m < 0 { m = 0 }
//            return Array(anchor.getLocationLog()[m...])
            return anchor.getLocationLog()
        }
        return []
    }
}
