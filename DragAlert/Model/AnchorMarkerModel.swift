//
//  AnchorMarkerModel.swift
//  Drag Alert
//
//  Created by Peter Molettiere on 12/26/23.
//

import Foundation
import MapKit

protocol AnchorMarkerModelProtocol : ObservableObject {
    func getAnchorLocation() -> CLLocationCoordinate2D
    func getAlarmRadius() -> Double
    func getRodeLengthMeters() -> Double
    func getCoordinateLog() -> [CLLocationCoordinate2D]
}

extension Anchor : AnchorMarkerModelProtocol {
    func getAnchorLocation() -> CLLocationCoordinate2D { location.clLocation.coordinate }
    func getAlarmRadius() -> Double { alarmRadiusMeters }
    func getRodeLengthMeters() -> Double { rodeInUseMeters }
    func getCoordinateLog() -> [CLLocationCoordinate2D] { coordinateLog }
}

extension AnchoringViewModel : AnchorMarkerModelProtocol {
    
    func getAnchorLocation() -> CLLocationCoordinate2D {
        if( selectedTab == .relative ) {
            return relativeLocation().clLocation.coordinate
        } else {
            return getCurrentAnchorPosition().clLocation.coordinate
        }
    }
    
    func getAlarmRadius() -> Double {
        let x = currentSwingRadiusMeters()
        // print( "alarm radius got \(x)")
        return x
    }
    
    func getRodeLengthMeters() -> Double {
        rodeLength.asUnit(UnitLength.meters).value
    }
    
    func getCoordinateLog() -> [CLLocationCoordinate2D] {
        []
    }
}
