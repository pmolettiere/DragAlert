//
//  VesselLocationMap.swift
//  Drag Alert
//
//  Created by Peter Molettiere on 12/20/23.
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

struct VesselLocationMap: View {
        
    @State var anchorLocationModel : (any AnchorMarkerModel)?
    @State var gps = LocationObserver()

    init( model: (any AnchorMarkerModel)? = nil ) {
        _anchorLocationModel = State(initialValue: model)
    }
    
    var body: some View {
        ZStack {
            Map() {
                VesselMarker(locator: gps)
                if( anchorLocationModel != nil ) {
                    AnchorMarker(model: anchorLocationModel!)
                }
            }
            .scaledToFill()
            .mapStyle(.imagery)
        }
        .onAppear() {
            print("VesselLocationMap onAppear")
            gps.isTrackingLocation = true
        }
        .onDisappear() {
            print("VesselLocationMap onDisppear")
            gps.isTrackingLocation = false
        }
    }
}

