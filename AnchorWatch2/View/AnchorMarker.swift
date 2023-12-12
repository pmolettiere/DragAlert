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
            Image("anchor.pin")
                .resizable()
                .frame(width: CGFloat(30), height: CGFloat(35), alignment: .center)
        } label: {
            Text("")
        }
        let radius : CLLocationDistance = anchor.radius.converted(to: UnitLength.meters).value
        MapCircle(center: anchor.coordinate, radius: radius)
            .stroke(Color.red)
            .stroke(lineWidth: CGFloat(2))
            .foregroundStyle(.clear)
        MapPolyline(coordinates: anchor.coordinateLog, contourStyle: .straight)
            .stroke(Color.blue)
    }
}
