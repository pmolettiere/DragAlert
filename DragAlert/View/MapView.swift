//
//  MapView.swift
//  Drag Alert
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

import Foundation
import SwiftUI
import SwiftData
import MapKit
import MediaPlayer
import simd

struct MapView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(ViewModel.self) private var viewModel

    @State var vessel: Vessel
    
    @State var mapStyle: MapStyle = .standard
    @Namespace var mapScope
    
    @State var alarm = Alarm.instance
    @State var volume = VolumeObserver()
                
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
                let end = CLLocation(location: vessel.location).coordinate
                let travelDistance = start.distance(to: end)
                
                let duration = max(min(travelDistance / 30, 5), 1)
                let finalAltitude = travelDistance > 20 ? 1_000 : min(initialCamera.distance, 1_000)
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
        .overlay(alignment: .top) {
            if( volume.displayVolumeControl ) {
                VStack {
                    if( volume.volumeBelowWarningThreshold ) {
                        StrokeText(text: "view.map.warn.volume.low", width: 0.7, color: .white)
                            .foregroundColor(.red)
                            .font(.headline)
                    } else {
                        Text("view.map.volume")
                            .font(.headline)
                            .foregroundStyle(Color.white)
                    }
                    
                    VolumeSlider()
                        .frame(height: 40)
                        .padding(.horizontal)
                    Spacer()
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
                            viewModel.setAppView(.new_anchor)
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
                adjustAnchor: {
                    if let v = viewModel.myVessel {
                        if( v.isAnchored ) {
                            viewModel.setAppView(.edit_anchor)
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
            UIApplication.shared.isIdleTimerDisabled = true
        }
        .onDisappear() {
            print("MapView.map onDisappear")
            LocationDelegate.instance.isTrackingLocation = false
            LocationDelegate.instance.trackLocationInBackground(false)
            UIApplication.shared.isIdleTimerDisabled = false
        }
    }
}

