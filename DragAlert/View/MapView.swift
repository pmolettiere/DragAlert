//
//  ContentView.swift
//  AnchorWatch
//
//  Created by Peter Molettiere on 11/29/23.
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
import SwiftData
import MapKit
import simd

struct MapView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(ViewModel.self) private var viewModel

    @State var vessel: Vessel
    
    @State var mapStyle: MapStyle = .standard
    @Namespace var mapScope
            
    var body: some View {
        @Bindable var m = viewModel       // m is for model
        
        ZStack(alignment: .topLeading) {
            VStack {
                MapCompass(scope: mapScope)
            }
            .mapControlVisibility(.visible)
            Map(scope: mapScope) {
                VesselMarker(locator: vessel)
                if( vessel.isAnchored ) {
                    if let anchor = vessel.anchor {
                        AnchorMarker(model: anchor)
                    }
                }
            }
            .mapStyle(mapStyle)
            .mapCameraKeyframeAnimator(trigger: vessel.isAnchored) { initialCamera in
                let start = initialCamera.centerCoordinate
                let end = vessel.coordinate
                let travelDistance = start.distance(to: end)
                
                let duration = max(min(travelDistance / 30, 5), 1)
                let finalAltitude = travelDistance > 20 ? 750_000 : min(initialCamera.distance, 750_000)
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
        .toolbar {
            MapToolbar(
                vessel: m.myVessel,
                editVessel: {
                    viewModel.setAppView(.setup)
                },
                newAnchor: {
                    if let v = viewModel.myVessel {
                        if( v.isAnchored ) {
                            v.isAnchored = false
                        } else {
                            viewModel.setAppView(.anchor)
                        }
                    }
                },
                resetAnchor: {
                    if let v = viewModel.myVessel {
                        if v.anchor != nil {
                            v.isAnchored = true
                            Alarm.instance.isEnabled = true
                        }
                    }
                },
                cancelAnchor: {
                    if let v = viewModel.myVessel {
                        if( v.isAnchored ) {
                            v.isAnchored = false
                        }
                    }
                })
        }
        .onAppear() {
            print("MapView.map onAppear")
            mapStyle = .imagery
            LocationDelegate.instance.isTrackingLocation = true
            LocationDelegate.instance.trackLocationInBackground(true)
        }
        .onDisappear() {
            print("MapView.map onDisappear")
            LocationDelegate.instance.isTrackingLocation = false
            LocationDelegate.instance.trackLocationInBackground(false)
        }
    }
}

