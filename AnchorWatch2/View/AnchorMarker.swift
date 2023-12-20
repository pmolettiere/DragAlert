//
//  AnchorView.swift
//  AnchorWatch2
//
//  Created by Peter Molettiere on 12/8/23.
//

import SwiftUI
import MapKit

struct AnchorMarker: MapContent {
    var anchor: Anchor

    var body: some MapContent {
        Annotation(coordinate: anchor.coordinate) {
            Image("anchor")
                .resizable()
                .colorInvert()
                .frame(width: CGFloat(20), height: CGFloat(25), alignment: .center)
        } label: {
            Text("")
        }
        MapCircle(center: anchor.coordinate, radius: anchor.radiusM)
            .stroke(Color.red)
            .stroke(lineWidth: CGFloat(2))
            .foregroundStyle(.clear)
        if anchor.vessel != nil {
            let rodeLength : CLLocationDistance = anchor.rodeLengthM
            MapCircle(center: anchor.coordinate, radius: rodeLength)
                .stroke(Color.yellow.opacity(0.3))
                .stroke(lineWidth: CGFloat(1))
                .foregroundStyle(.clear)
        }
        if( anchor.log.count > 0 ) {
            MapPolyline(coordinates: anchor.coordinateLog, contourStyle: .straight)
                .stroke(Color.blue)
        }
    }
}
