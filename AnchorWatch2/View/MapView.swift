//
//  ContentView.swift
//  AnchorWatch
//
//  Created by Peter Molettiere on 11/29/23.
//

import SwiftUI
import SwiftData
import MapKit
import simd
import AQUI

struct MapView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(ViewModel.self) private var viewModel
    @Environment(ContentView.StateMarker.self) var marker: ContentView.StateMarker

    @State var vessel: Vessel
    
    @State var mapStyle: MapStyle = .standard
    @Namespace var mapScope
    @State var isAlarmEnabled: Bool = Alarm.instance.isEnabled {
        didSet {
            Alarm.instance.isEnabled = isAlarmEnabled
        }
    }
            
    var body: some View {
        @Bindable var m = viewModel       // m is for model
        
        ZStack(alignment: .topLeading) {
            VStack {
                MapCompass(scope: mapScope)
            }
            .mapControlVisibility(.visible)
            Map(scope: mapScope) {
                VesselMarker(vessel: vessel)
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
            .onAppear() {
                mapStyle = .imagery
            }
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    Menu("view.map.alarm") {
                        Toggle(isOn: $isAlarmEnabled) {
                            Text("view.map.alarm.enable")
                        }
                        Button() {
                            Alarm.instance.snooze()
                        } label: {
                            Text("view.map.alarm.snooze")
                        }
                        .disabled(!Alarm.instance.isPlaying)
                        Button() {
                            Alarm.instance.test()
                        } label: {
                            Text("view.map.alarm.test")
                        }
                        .disabled(Alarm.instance.isPlaying)
                    }
                }
                ToolbarItem(placement: .bottomBar) {
                    Button() {
                        marker.state = .setup
                    } label: {
                        Text("view.map.edit.vessel")
                    }
                }
                ToolbarItem(placement: .bottomBar) {
                    Menu("view.map.anchor") {
                        Button() {
                            if let v = m.myVessel {
                                if( v.isAnchored ) {
                                    v.isAnchored = false
                                } else {
                                    marker.state = .anchor
                                }
                            }
                        } label: {
                            Text("view.map.new")
                        }
                        .disabled(m.myVessel?.isAnchored ?? true)
                        
                        Button() {
                            if let v = m.myVessel {
                                if v.anchor != nil {
                                    v.isAnchored = true
                                    Alarm.instance.isEnabled = true
                                }
                            }
                        } label: {
                            Text("view.map.reset")
                        }
                        .disabled(m.myVessel?.isAnchored ?? true)
                        
                        Button() {
                            if let v = m.myVessel {
                                if( v.isAnchored ) {
                                    v.isAnchored = false
                                }
                            }
                        } label: {
                            Text("view.map.cancel")
                        }
                        .disabled(!(m.myVessel?.isAnchored ?? false))
                    }
                }
            }
        }
        .onAppear() {
            LocationDelegate.instance.isTrackingLocation = true
        }
    }
}

//#Preview {
//    let v = Vessel.new()
//    return MapView()
//        .modelContainer(for: Vessel.self, inMemory: true)
//}
