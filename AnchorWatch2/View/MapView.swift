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
                Button(vessel.isAnchored ? "Cancel" : "Anchor") {
                    if( vessel.isAnchored ) {
                        vessel.isAnchored = false
                    } else {
                        showAnchorUI.toggle()
                    }
                }
                .sheet(isPresented: $showAnchorUI, content: {
                    AnchoringView(vessel: vessel, willShow: $showAnchorUI)
                })
            }
            Map() {
                VesselMarker(vessel: vessel)
                if( vessel.isAnchored ) {
                    if let anchor = vessel.anchor {
                        AnchorMarker(anchor: anchor, loa: vessel.loa)
                    } 
                }
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

//#Preview {
//    let v = Vessel.new()
//    return MapView()
//        .modelContainer(for: Vessel.self, inMemory: true)
//}
