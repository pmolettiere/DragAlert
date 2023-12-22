//
//  AnchorView.swift
//  AnchorWatch2
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
    @State var model: any AnchorMarkerModelProtocol
    
    init(model: any AnchorMarkerModelProtocol) {
        self.model = model
    }

    var body: some MapContent {
        Annotation(coordinate: model.getAnchorLocation()) {
            AnchorView(size: CGFloat(15))
        } label: {
            Text("")
        }
        MapCircle(center: model.getAnchorLocation(), radius: model.getAlarmRadius())
            .stroke(Color.red)
            .stroke(lineWidth: CGFloat(3))
            .foregroundStyle(.yellow.opacity(0.2))
        MapCircle(center: model.getAnchorLocation(), radius: model.getRodeLengthMeters())
            .stroke(Color.yellow.opacity(0.4))
            .stroke(lineWidth: CGFloat(2))
            .foregroundStyle(.blue.opacity(0.1))
        if( model.getCoordinateLog().count > 0 ) {
            MapPolyline(coordinates: model.getCoordinateLog(), contourStyle: .straight)
                .stroke(Color.indigo, lineWidth: 3)
        }
    }
}

protocol AnchorMarkerModelProtocol : ObservableObject {
    func getAnchorLocation() -> CLLocationCoordinate2D
    func getAlarmRadius() -> Double
    func getRodeLengthMeters() -> Double
    func getCoordinateLog() -> [CLLocationCoordinate2D]
}

extension Anchor : AnchorMarkerModelProtocol {
    func getAnchorLocation() -> CLLocationCoordinate2D { coordinate }
    func getAlarmRadius() -> Double { alarmRadiusMeters }
    func getRodeLengthMeters() -> Double { rodeInUseMeters }
    func getCoordinateLog() -> [CLLocationCoordinate2D] { coordinateLog }
}

extension AnchoringViewModel : AnchorMarkerModelProtocol {
    
    func getAnchorLocation() -> CLLocationCoordinate2D {
        if( selectedTab == .relative ) {
            return relativeLocation()
        } else {
            return getCurrentAnchorPosition()
        }
    }
    
    func getAlarmRadius() -> Double {
        let x = currentSwingRadiusMeters()
        // print( "alarm radius got \(x)")
        return x
    }
    
    func getRodeLengthMeters() -> Double {
        rodeLength.asUnit(UnitLength.meters).value
    }
    
    func getCoordinateLog() -> [CLLocationCoordinate2D] {
        []
    }
}
