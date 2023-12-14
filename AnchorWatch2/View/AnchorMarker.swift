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
    var loa: Measurement<UnitLength>

    var body: some MapContent {
        Annotation(coordinate: anchor.coordinate) {
            Image("anchor")
                .resizable()
                .colorInvert()
                .frame(width: CGFloat(20), height: CGFloat(25), alignment: .center)
        } label: {
            Text("")
        }
        let radius : CLLocationDistance = anchor.radius.converted(to: UnitLength.meters).value
        MapCircle(center: anchor.coordinate, radius: radius)
            .stroke(Color.red)
            .stroke(lineWidth: CGFloat(2))
            .foregroundStyle(.clear)
        if let v = anchor.vessel {
            let rodeLength : CLLocationDistance = anchor.radiusMeters - v.loaMeters
            MapCircle(center: anchor.coordinate, radius: rodeLength)
                .stroke(Color.yellow.opacity(0.3))
                .stroke(lineWidth: CGFloat(1))
                .foregroundStyle(.clear)
        }
        MapPolyline(coordinates: anchor.coordinateLog, contourStyle: .straight)
            .stroke(Color.blue)
    }
}
