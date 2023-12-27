//
//  VesselMarkerModel.swift
//  Drag Alert
//
//  Created by Peter Molettiere on 12/26/23.
//

import Foundation
import MapKit

protocol VesselLocator : Observable {
    func getCoordinate() -> CLLocationCoordinate2D
    func getName() -> String
}

extension Vessel : VesselLocator {
    func getCoordinate() -> CLLocationCoordinate2D {
        location.clLocation.coordinate
    }
    func getName() -> String {
        name
    }
}

extension LocationObserver : VesselLocator {
    func getCoordinate() -> CLLocationCoordinate2D {
        return location.clLocation.coordinate
    }
    func getName() -> String {
        ""
    }
}
