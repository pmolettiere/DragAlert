//
//  LocatorMap.swift
//  Drag Alert
//
//  Created by Peter Molettiere on 12/20/23.
//

import SwiftUI
import MapKit

struct VesselLocationMap: View {

    @State private var position: MapCameraPosition
    @State private var region: MKCoordinateRegion
    
    //(center: CLLocationCoordinate2D(latitude: 0, longitude: 0), latitudinalMeters: 100, longitudinalMeters: 100)

//    private let bounds = MapCameraBounds(minimumDistance: 0.0, maximumDistance: 800.0)
    
    @State var anchorLocationModel : (any AnchorMarkerModelProtocol)?
    @State var gps = LocationObserver()

    init( model: (any AnchorMarkerModelProtocol)? = nil ) {
        _anchorLocationModel = State(initialValue: model)
        let r = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 0, longitude: 0), latitudinalMeters: 500, longitudinalMeters: 500)
        _region = State( initialValue: r )
        _position = State( initialValue: .region( r ) )

        self.gps.locationCallback = updateLocation

        
        withObservationTracking({
            _ = model?.getAlarmRadius()
            _ = model?.getAnchorLocation()
            _ = model?.getCoordinateLog()
            _ = model?.getRodeLengthMeters()
            _ = model?.objectWillChange
            //print("VesselLocationMap model change subscription")
        }, onChange: {
            //print("VesselLocationMap observed model change")
        })
        //print("VesselLocationMap created")
    }
    
    func updateLocation() {
        region.center = CLLocationCoordinate2D(latitude: gps.latitude, longitude: gps.longitude)
    }

    var body: some View {
        ZStack {
            Map( position: $position ) {
                VesselMarker(locator: gps)
                if( anchorLocationModel != nil ) {
                    AnchorMarker(model: anchorLocationModel!)
                }
            }
            .scaledToFill()
            .mapStyle(.imagery)
            .mapCameraKeyframeAnimator(trigger: gps.latitude ) { initialCamera in
                let start = initialCamera.centerCoordinate
                let end = CLLocationCoordinate2D(latitude: gps.latitude, longitude: gps.longitude)
                let travelDistance = start.distance(to: end)
                
                let duration = max(min(travelDistance / 30, 5), 1)
                let finalAltitude = travelDistance > 20 ? 500 : min(initialCamera.distance, 500)
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
        .onAppear() {
            print("VesselLocationMap onAppear")
            gps.isTrackingLocation = true
            updateLocation()
        }
        .onDisappear() {
            print("VesselLocationMap onDisppear")
            gps.isTrackingLocation = false
        }
    }
}

