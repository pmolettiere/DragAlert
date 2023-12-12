//
//  AnchoringView.swift
//  AnchorWatch2
//
//  Created by Peter Molettiere on 12/6/23.
//

import SwiftUI
import MapKit

struct AnchoringView: View {
    
    var vessel: Vessel
    var anchor: Binding<Anchor>
    var willShow: Binding<Bool>
    
    var body: some View {
        let compass: Compass = VesselTracker.shared.getCompass()
        @State var tabSelection: Int?

        Form {
//            Text("Radius: \(anchor.wrappedValue.radius.value.formatted(.number))")
//            Slider(value: anchor.radius.value, in: 0...300, step: 25)
            MeasurementEditor("Radius", measurement: anchor.radius, range: 0...300, step: 20)
            Section("Anchor Location") {
                TabView(selection: $tabSelection) {
                    RelativeView(anchor: anchor, compass: compass, action: dropAnchor)
                        .tabItem {
                            Label("Relative", systemImage: "location.north.line.fill")
                        }
                    CurrentView(compass: compass, action: dropAnchor)
                        .tabItem {
                            Label("Current", systemImage: "location.fill")
                        }
                }
                .scaledToFill()
                .frame(maxWidth: .infinity)
            }
        }
    }
    
    private func dropAnchor(location: CLLocationCoordinate2D) {
        let latitude = location.latitude
        let longitude = location.longitude
        let radius = anchor.radius.wrappedValue
        let newAnchor = Anchor(timestamp: Date.now, latitude: latitude, longitude: longitude, radius: radius, log: [], vessel: self.vessel)
        vessel.anchors?.append(newAnchor)
        vessel.isAnchored = true
        willShow.wrappedValue = false
    }
    
    struct RelativeView: View {
        var anchor: Binding<Anchor>
        @State private var distance: Measurement<UnitLength> = Measurement(value: 150, unit: UnitLength.feet)
        @State private var bearing: Double = 0.0
        var compass: Compass
        var action: (CLLocationCoordinate2D) -> ()
        
        var body: some View {
            VStack {
                MeasurementEditor("Distance", measurement: $distance, range: 0...300, step: 10)
                HStack {
                    Text("Bearing: \(compass.heading.formatted(.number.rounded(increment:1)))")
                }
                Spacer()
                Button("Drop at Relative Position") {
                    let origin = CLLocationCoordinate2D(latitude: compass.latitude, longitude: compass.longitude)
                    let final = locationWithBearing(bearing: self.bearing, distanceMeters: self.distance.converted(to: UnitLength.meters).value, origin: origin)

                    print("Dropping anchor at relative position \(final.latitude.formatted(.number.rounded(increment:0.001))), \(final.longitude.formatted(.number.rounded(increment:0.001)))");
                    
                    action(final)
                    
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
                Spacer()
            }
        }
    }

    struct CurrentView: View {
        var compass: Compass
        var action: (CLLocationCoordinate2D) -> ()

        var body: some View {
            VStack {
                Text("Latitude: \(compass.latitude.formatted(.number.rounded(increment:0.001)))")
                Text("Longitude: \(compass.longitude.formatted(.number.rounded(increment:0.001)))")
                Spacer()
                Button("Drop at Current Position") {
                    let final = CLLocationCoordinate2D(latitude: compass.latitude, longitude: compass.longitude)

                    print("Dropping anchor at current position \(final.latitude.formatted(.number.rounded(increment:0.001))), \(final.longitude.formatted(.number.rounded(increment:0.001))).")
                    
                    action(final)
                }
                Spacer()
            }
        }
    }
}


