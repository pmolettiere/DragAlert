//
//  AnchorMarker.swift
//  Drag Alert
//
//  Created by Peter Molettiere on 12/8/23.
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
import MapKit

struct AnchorMarker: MapContent {
    @State var model: any AnchorMarkerModel
    
    init(model: any AnchorMarkerModel) {
        self.model = model
    }

    var body: some MapContent {
        // anchor icon
        Annotation(coordinate: model.getAnchorLocation().clLocation.coordinate ) {
            AnchorView(size: CGFloat(15))
        } label: {
            Text("")
        }
        // anchor icon accuracy circle
        MapCircle(center: model.getAnchorLocation().clLocation.coordinate, radius: model.getAnchorLocation().hAccuracy)
            .foregroundStyle(.yellow.opacity(0.2))

        // alarm radius
        MapCircle(center: model.getAnchorLocation().clLocation.coordinate, radius: model.getAlarmRadius())
            .stroke(Color.red)
            .stroke(lineWidth: CGFloat(3))
            .foregroundStyle(.yellow.opacity(0.2))
        
        // rode radius
        MapCircle(center: model.getAnchorLocation().clLocation.coordinate, radius: model.getRodeLengthMeters())
            .stroke(Color.yellow.opacity(0.4))
            .stroke(lineWidth: CGFloat(2))
            .foregroundStyle(.blue.opacity(0.1))
        
        // list of swing locations
        if( model.getLocationLog().count > 0 ) {
            ForEach( model.getLocationLog(), id: \.timestamp ) { log in
                MapCircle(center: log.clLocation.coordinate, radius: log.clLocation.horizontalAccuracy)
                    .foregroundStyle(.indigo.opacity( 0.5 / log.clLocation.horizontalAccuracy ))
            }
        }
    }
}
