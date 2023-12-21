//
//  AnchorView.swift
//  AnchorWatch2
//
//  Created by Peter Molettiere on 12/8/23.
//

import SwiftUI
import MapKit

struct AnchorMarker: MapContent {
    @State var model: any AnchorMarkerModelProtocol
    
    init(model: any AnchorMarkerModelProtocol) {
        self.model = model
        withObservationTracking({
            _ = model.getAlarmRadius()
            _ = model.getAnchorLocation()
            _ = model.getCoordinateLog()
            _ = model.getRodeLengthMeters()
            _ = model.objectWillChange
            // print("AnchorMarker model change subscription")
        }, onChange: {
            //print("AnchorMarker observed model change")
        })
        //print("AnchorMarker created")
    }

    var body: some MapContent {
        Annotation(coordinate: model.getAnchorLocation()) {
            AnchorView(size: CGFloat(15))
        } label: {
//            Text("\(model.getAlarmRadius()) \(model.getRodeLengthMeters()) \(model.getAnchorLocation().latitude) \(model.getAnchorLocation().longitude) \(model.getCoordinateLog().count)")
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
        if( selectedTab == AnchoringViewModel.Tab.relative.rawValue ) {
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
