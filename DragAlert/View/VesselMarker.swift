//
//  VesselMarker.swift
//  Drag Alert
//
//  Copied from Apple DataCache example app "QuakeMarker"
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

/// A map annotation that represents a single vessel.
struct VesselMarker: MapContent {
    @State var locator: LocationProvider

    var body: some MapContent {
        Annotation(coordinate: locator.getCoordinate() ) {
            ZStack {
                Image(systemName: "sailboat")
                    .resizable()
                    .frame(width: CGFloat(20), height: CGFloat(20), alignment: .center)
            }
        } label: {
            Text(locator.getName())
        }
    }
}
