//
//  VesselLocationMap.swift
//  Drag Alert
//
//  Created by Peter Molettiere on 12/20/23.
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

import SwiftUI
import MapKit

struct VesselLocationMap: View {
    @State private var position: MapCameraPosition
    @State private var region: MKCoordinateRegion
        
    @State var anchorLocationModel : (any AnchorMarkerModelProtocol)?
    @State var gps = LocationObserver()

    init( model: (any AnchorMarkerModelProtocol)? = nil ) {
        _anchorLocationModel = State(initialValue: model)
        let r = MKCoordinateRegion(center: model?.getAnchorLocation() ?? CLLocationCoordinate2D(latitude: 0, longitude: 0), latitudinalMeters: 500, longitudinalMeters: 500)
        _region = State( initialValue: r )
        _position = State( initialValue: .region( r ) )

        self.gps.locationCallback = updateLocation
    }
    
    func updateLocation() {
        region.center = CLLocationCoordinate2D(latitude: gps.latitude, longitude: gps.longitude)
    }

    var body: some View {
        ZStack {
            Map( position: $position ) {
                VesselMarker(locator: gps)
                if( anchorLocationModel != nil ) {
                    AnchorMarker(model: anchorLocationModel!)
                }
            }
            .scaledToFill()
            .mapStyle(.imagery)
            .mapCameraKeyframeAnimator(trigger: gps.latitude ) { initialCamera in
                let start = initialCamera.centerCoordinate
                let end = CLLocationCoordinate2D(latitude: gps.latitude, longitude: gps.longitude)
                let travelDistance = start.distance(to: end)
                
                let duration = max(min(travelDistance / 30, 5), 1)
                let finalAltitude = travelDistance > 20 ? 500 : min(initialCamera.distance, 500)
                let middleAltitude = finalAltitude * max(min(travelDistance / 5, 1.5), 1)
                
                KeyframeTrack(\MapCamera.centerCoordinate) {
                    CubicKeyframe(end, duration: duration)
                }
                KeyframeTrack(\MapCamera.distance) {
                    CubicKeyframe(middleAltitude, duration: duration / 2)
                    CubicKeyframe(finalAltitude, duration: duration / 2)
                }
            }
        }
        .onAppear() {
            print("VesselLocationMap onAppear")
            gps.isTrackingLocation = true
            updateLocation()
        }
        .onDisappear() {
            print("VesselLocationMap onDisppear")
            gps.isTrackingLocation = false
        }
    }
}

