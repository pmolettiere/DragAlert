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
            
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button(vessel.isAnchored ? "Anchor" : "Cancel") {
                    showAnchorUI.toggle()
                    // vessel.toggleAnchor()
                }
                .sheet(isPresented: $showAnchorUI, content: {
                    AnchoringView(vessel: vessel, anchor: $vessel.lastAnchor, willShow: $showAnchorUI)
                })
            }
            Map() {
                VesselMarker(vessel: vessel)
                AnchorMarker(anchor: vessel.lastAnchor)
            }
            .mapStyle(.imagery)
            .mapCameraKeyframeAnimator(trigger: vessel.isAnchored) { initialCamera in
                let start = initialCamera.centerCoordinate
                let end = vessel.coordinate
                let travelDistance = start.distance(to: end)
                
                let duration = max(min(travelDistance / 30, 5), 1)
                let finalAltitude = travelDistance > 20 ? 500_000 : min(initialCamera.distance, 500_000)
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
    }
}

extension CLLocationCoordinate2D {
    /// Calculates a value that's proportional to the distance between two points.
    func distance(to coordinate: CLLocationCoordinate2D) -> Double {
        simd.distance(
            SIMD2<Double>(x: latitude, y: longitude),
            SIMD2<Double>(x: coordinate.latitude, y: coordinate.longitude))
    }
}

//#Preview {
//    let v = Vessel.new()
//    return MapView()
//        .modelContainer(for: Vessel.self, inMemory: true)
//}
