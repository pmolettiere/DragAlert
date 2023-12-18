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
    
    @State var vessel: Vessel
    @State var showAnchorUI: Bool = false
    @State var alarmEnable: Bool = true {
        didSet {
            Alarm.instance.isEnabled = alarmEnable
        }
    }
    
    @State private var path = NavigationPath()
    @State var mapStyle: MapStyle = .standard
    @Namespace var mapScope
            
    var body: some View {
        VStack {
            NavigationStack(path: $path) {
                ZStack(alignment: .topLeading) {
                    VStack {
                        MapCompass(scope: mapScope)
                            .mapControlVisibility(.visible)
                    }
                    Map(scope: mapScope) {
                        VesselMarker(vessel: vessel)
                        if( vessel.isAnchored ) {
                            if let anchor = vessel.anchor {
                                AnchorMarker(anchor: anchor)
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
                    .onAppear() {
                        mapStyle = .imagery
                    }
                    .sheet(isPresented: $showAnchorUI, content: {
                        AnchoringView(vessel: vessel, isShowing: $showAnchorUI)
                    })
                }
                .toolbar {
                    ToolbarItem(placement: .bottomBar) {
                        Menu("view.map.alarm") {
                            Toggle(isOn: $alarmEnable) {
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
                            path.append("VesselSetup")
                        } label: {
                            Text("view.map.edit.vessel")
                        }
                    }
                    ToolbarItem(placement: .bottomBar) {
                        Menu("view.map.anchor") {
                            Button() {
                                if( vessel.isAnchored ) {
                                    vessel.isAnchored = false
                                } else {
                                    showAnchorUI.toggle()
                                }
                            } label: {
                                Text("view.map.new")
                            }
                            .disabled(vessel.isAnchored)
                            
                            Button() {
                                if vessel.anchor != nil {
                                    vessel.isAnchored = true
                                    Alarm.instance.isEnabled = true
                                }
                            } label: {
                                Text("view.map.reset")
                            }
                            .disabled(vessel.isAnchored)
                            
                            Button() {
                                if( vessel.isAnchored ) {
                                    vessel.isAnchored = false
                                } else {
                                    showAnchorUI.toggle()
                                }
                            } label: {
                                Text("view.map.cancel")
                            }
                            .disabled(!vessel.isAnchored)
                        }
                    }
                }
                .navigationDestination(for: String.self) { view in
                    if view == "VesselSetup" {
                        SetupVesselView(vessel: vessel)
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
