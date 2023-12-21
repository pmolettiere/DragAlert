//
//  VesselMarker.swift
//  AnchorWatch
//
//  Copied from Apple DataCache example app "QuakeMarker"
//

import SwiftUI
import MapKit

/// A map annotation that represents a single vessel.
struct VesselMarker: MapContent {
    @State var locator: VesselLocator

    var body: some MapContent {
        Annotation(coordinate: locator.getCoordinate() ) {
            ZStack {
                Image(systemName: "sailboat")
                    .resizable()
                    .frame(width: CGFloat(20), height: CGFloat(20), alignment: .center)
            }
        } label: {
            Text(locator.getName())
        }
    }
}

protocol VesselLocator : Observable {
    func getCoordinate() -> CLLocationCoordinate2D
    func getName() -> String
}

extension Vessel : VesselLocator {
    func getCoordinate() -> CLLocationCoordinate2D {
        coordinate
    }
    func getName() -> String {
        name
    }
}

extension LocationObserver : VesselLocator {
    func getCoordinate() -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    func getName() -> String {
        ""
    }
}
