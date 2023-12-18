//
//  AnchoringView.swift
//  AnchorWatch2
//
//  Created by Peter Molettiere on 12/6/23.
//

import SwiftUI
import MapKit

struct AnchoringView: View {
    @State var model: AnchoringViewModel
    
    init(vessel: Vessel) {
        _model = State(initialValue: AnchoringViewModel(vessel: vessel))
    }
    
    var body: some View {
        TabView(selection: $model.selectedTab) {
            RelativeView(model: model)
                .tabItem {
                    Label("view.anchoring.relative", systemImage: "location.north.line.fill")
                }
            CurrentView(model: model)
                .tabItem {
                    Label("view.anchoring.current", systemImage: "location.fill")
                }
        }
        .onAppear() {
            LocationDelegate.instance.isTrackingHeading = true
        }
        .onDisappear() {
            LocationDelegate.instance.isTrackingHeading = false
        }
    }
        
    struct RelativeView: View {
        @Environment(ContentView.StateMarker.self) var marker: ContentView.StateMarker
        var model: AnchoringViewModel
        
        init(model: AnchoringViewModel) {
            self.model = model
        }
        
        var body: some View {
            VStack {
                DistanceEditor("view.anchoring.rodeLength", measurement: model.rodeLength, max: model.maxRodeLength.measurement )
                DistanceEditor("view.anchoring.distance", measurement: model.distanceFromAnchor, max: model.maxDistanceFromAnchor.measurement )

                HStack {
                    Text("view.anchoring.bearing")
                    Text("\(model.gps.heading.formatted(.number.rounded(increment:1)))")
                }
                Button {
                    model.setAnchorAtRelativeBearing()
                    marker.state = .map
                } label: {
                    Image("anchor")
                        .resizable()
                        .frame(width: CGFloat(50), height: CGFloat(50))
                        .colorInvert()
                }
            }
            .buttonStyle(.bordered)
            .onAppear(perform: {
                model.track(location: true, heading: true)
            })
            .onDisappear(perform: {
                model.track()
            })

        }
    }
    
    struct CurrentView: View {
        @Environment(ContentView.StateMarker.self) var marker: ContentView.StateMarker
        var model: AnchoringViewModel

        var body: some View {
            VStack {
                DistanceEditor("view.anchoring.rodeLength", measurement: model.rodeLength, max: model.maxRodeLength.measurement )
                HStack {
                    Text("view.multiple.latitude")
                    Text("\(model.gps.latitude.formatted(.number.rounded(increment:0.001)))")
                }
                HStack {
                    Text("view.multiple.longitude")
                    Text("\(model.gps.longitude.formatted(.number.rounded(increment:0.001)))")
                }
                Button() {
                    model.setAnchorAtCurrentPosition()
                    marker.state = .map
                } label: {
                    Image("anchor")
                        .resizable()
                        .frame(width: CGFloat(50), height: CGFloat(50))
                        .colorInvert()
                }
                .buttonStyle(.bordered)
            }
            .onAppear(perform: {
                model.track(location: true)
            })
            .onDisappear(perform: {
                model.track()
            })

        }
    }
}

@Observable
class AnchoringViewModel {
    var vessel: Vessel

    var gps: LocationObserver = LocationObserver()
    var selectedTab: Int = 0
    
    var rodeLength: MeasurementModel<UnitLength>
    var distanceFromAnchor: MeasurementModel<UnitLength>
    
    var maxRodeLength: MeasurementModel<UnitLength>
    var maxDistanceFromAnchor: MeasurementModel<UnitLength>
    
    init(vessel: Vessel) {
        self.vessel = vessel
        self.gps = LocationObserver()
        self.maxRodeLength = MeasurementModel(vessel.rodeLength)
        self.maxDistanceFromAnchor = MeasurementModel(vessel.maxDistanceFromAnchor)
        self.rodeLength = MeasurementModel( vessel.rodeLength )
        self.distanceFromAnchor = MeasurementModel( vessel.rodeLength )
        
        self.rodeLength = MeasurementModel( readPrefMeasurement(label: "AnchoringView.RelativeView.rodeLength") )
        self.distanceFromAnchor = MeasurementModel( readPrefMeasurement(label: "AnchoringView.RelativeView.distance") )
    }
    
    func readPrefMeasurement(label: String) -> Measurement<UnitLength> {
        let unit = UserDefaults.standard.string(forKey: "\(label).unit") == "ft" ? UnitLength.feet : UnitLength.meters
        let value = UserDefaults.standard.double(forKey: "\(label).value")
        return Measurement<UnitLength>(value: value, unit: unit)
    }
    
    func savePrefMeasurements() {
        savePrefMeasurement("AnchoringView.RelativeView.rodeLength", measurement: distanceFromAnchor.measurement)
        savePrefMeasurement("AnchoringView.RelativeView.distance", measurement: rodeLength.measurement)
        func savePrefMeasurement(_ label: String, measurement: Measurement<UnitLength>) {
            UserDefaults.standard.set(measurement.value, forKey: "\(label).value")
            UserDefaults.standard.set(measurement.unit.symbol, forKey: "\(label).unit")
        }
    }
    
    func track(location: Bool = false, heading: Bool = false) {
        gps.isTrackingLocation = location
        gps.isTrackingHeading = heading
    }
    
    func dropAnchor(_ location: CLLocationCoordinate2D) {
        let latitude = location.latitude
        let longitude = location.longitude
        let rodeLength = self.rodeLength.asUnit(UnitLength.meters)
        let newAnchor = Anchor(timestamp: Date.now, latitude: latitude, longitude: longitude, rodeLength: rodeLength, log: [], vessel: self.vessel)
        vessel.anchor = newAnchor
        vessel.isAnchored = true
    }

    func setAnchorAtRelativeBearing() {
        let origin = CLLocationCoordinate2D(latitude: gps.latitude, longitude: gps.longitude)
        let final = locationWithBearing(bearing: gps.heading, distanceMeters: distanceFromAnchor.asUnit(UnitLength.meters).value, origin: origin)
        
        print("Dropping anchor at relative position \(final.latitude.formatted(.number.rounded(increment:0.001))), \(final.longitude.formatted(.number.rounded(increment:0.001)))");
        
        dropAnchor(final)
        
        func locationWithBearing(bearing:Double, distanceMeters:Double, origin:CLLocationCoordinate2D) -> CLLocationCoordinate2D {
            let bearingRadians = bearing * .pi / 180
            let distRadians = distanceMeters / (6372797.6) // earth radius in meters
            
            let lat1 = origin.latitude * .pi / 180
            let lon1 = origin.longitude * .pi / 180
            
            let lat2 = asin(sin(lat1) * cos(distRadians) + cos(lat1) * sin(distRadians) * cos(bearingRadians))
            let lon2 = lon1 + atan2(sin(bearingRadians) * sin(distRadians) * cos(lat1), cos(distRadians) - sin(lat1) * sin(lat2))
            
            return CLLocationCoordinate2D(latitude: lat2 * 180 / .pi, longitude: lon2 * 180 / .pi)
        }
    }
        
    func setAnchorAtCurrentPosition() {
        let final = CLLocationCoordinate2D(latitude: gps.latitude, longitude: gps.longitude)
        
        print("Dropping anchor at current position \(final.latitude.formatted(.number.rounded(increment:0.001))), \(final.longitude.formatted(.number.rounded(increment:0.001))).")
        
        dropAnchor(final)
    }
}

