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
    var vessel: Vessel

    var body: some MapContent {
        Annotation(coordinate: vessel.coordinate ) {
            ZStack {
                Image(systemName: "sailboat.circle")
//                Circle()
//                    .stroke( Color.red )
//                    .foregroundColor( Color.black.opacity(0) )
            }
        } label: {
            Text(vessel.name)
        }
        .tag(vessel)
        .annotationTitles(.hidden)
        if( vessel.isAnchored ) {
            if let anchor = vessel.anchors?.last {
                AnchorMarker(anchor: anchor)
            }
        }
    }
}

//#Preview {
//    ModelContainerPreview(PreviewSampleData.inMemoryContainer) {
//        VStack {
//            SelectionCircle(vessel: .salacia, selected: true)
//            SelectionCircle(vessel: .via, selected: false)
//            SelectionCircle(vessel: .jubel, selected: false)
//        }
//    }
//}
