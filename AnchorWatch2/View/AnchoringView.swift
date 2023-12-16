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
    var willShow: Binding<Bool>
    var gps: LocationObserver = LocationObserver()
    
    @State var tabSelection: Int?
    @State var rodeLength: Measurement<UnitLength> = Measurement(value: 0, unit: UnitLength.feet)
    
    init(vessel: Vessel, willShow: Binding<Bool>) {
        self.vessel = vessel
        self.willShow = willShow
        if let a = vessel.anchor {
            rodeLength = a.rodeLength
        }
    }
    
    var body: some View {
        TabView(selection: $tabSelection) {
            RelativeView(gps: gps, action: dropAnchor, measuredRadiusState: $rodeLength, maxRode: vessel.rode, maxDistance: vessel.maxDistanceFromAnchor)
                .tabItem {
                    Label("view.anchoring.relative", systemImage: "location.north.line.fill")
                }
            CurrentView(gps: gps, action: dropAnchor, measuredRadiusState: $rodeLength, max: vessel.rode)
                .tabItem {
                    Label("view.anchoring.current", systemImage: "location.fill")
                }
        }
        .onAppear() {
            LocationDelegate.instance.isTrackingHeading = true
            if let a = vessel.anchor {
                rodeLength = a.rodeLength
            }
        }
        .onDisappear() {
            LocationDelegate.instance.isTrackingHeading = false
        }
    }
    
    private func dropAnchor(location: CLLocationCoordinate2D) {
        let latitude = location.latitude
        let longitude = location.longitude
        let rodeLength: Measurement<UnitLength> = rodeLength.converted(to: UnitLength.meters)
        let newAnchor = Anchor(timestamp: Date.now, latitude: latitude, longitude: longitude, rodeLength: rodeLength, log: [], vessel: self.vessel)
        vessel.anchor = newAnchor
        vessel.isAnchored = true
        willShow.wrappedValue = false
    }
    
    struct RelativeView: View {
        @State var distance: Measurement<UnitLength> = Measurement<UnitLength>(value: 0, unit: UnitLength.feet)
        var gps: LocationObserver
        var action: (CLLocationCoordinate2D) -> ()
        var measuredRadiusState: Binding<Measurement<UnitLength>>
        var maxRode: Measurement<UnitLength>
        var maxDistance: Measurement<UnitLength> {
            didSet {
                UserDefaults.standard.set(maxDistance, forKey: "maxDistance")
            }
        }
        
        var body: some View {
            VStack {
                DistanceEditor("view.anchoring.rode", measurement: measuredRadiusState, max: maxRode )
                DistanceEditor("view.anchoring.distance", measurement: $distance, max: maxDistance )

                HStack {
                    Text("view.anchoring.bearing")
                    Text("\(gps.heading.formatted(.number.rounded(increment:1)))")
                }
                Button {
                    let origin = CLLocationCoordinate2D(latitude: gps.latitude, longitude: gps.longitude)
                    let final = locationWithBearing(bearing: gps.heading, distanceMeters: self.distance.converted(to: UnitLength.meters).value, origin: origin)
                    
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
                } label: {
                    Image("anchor")
                        .resizable()
                        .frame(width: CGFloat(50), height: CGFloat(50))
                        .colorInvert()
                }
            }
            .buttonStyle(.bordered)
            .onAppear(perform: {
                gps.isTrackingLocation = true
                gps.isTrackingHeading = true
                if let u = UserDefaults.standard.string(forKey: "lastAnchorDistance.unit") {
                    let v = UserDefaults.standard.double(forKey: "lastAnchorDistance.value")
                    distance = Measurement(value: v, unit: UnitLength(symbol: u) )
                }
            })
            .onDisappear(perform: {
                gps.isTrackingLocation = false
                gps.isTrackingHeading = false
                UserDefaults.standard.set(distance.value, forKey: "lastAnchorDistance.value")
                UserDefaults.standard.set(distance.unit.symbol, forKey: "lastAnchorDistance.unit")
            })

        }
    }
    
    struct CurrentView: View {
        var gps: LocationObserver
        var action: (CLLocationCoordinate2D) -> ()
        var measuredRadiusState: Binding<Measurement<UnitLength>>
        var max: Measurement<UnitLength>

        var body: some View {
            VStack {
                DistanceEditor("view.anchoring.rode", measurement: measuredRadiusState, max: max )
                HStack {
                    Text("view.multiple.latitude")
                    Text("\(gps.latitude.formatted(.number.rounded(increment:0.001)))")
                }
                HStack {
                    Text("view.multiple.longitude")
                    Text("\(gps.longitude.formatted(.number.rounded(increment:0.001)))")
                }
                Button() {
                    let final = CLLocationCoordinate2D(latitude: gps.latitude, longitude: gps.longitude)
                    
                    print("Dropping anchor at current position \(final.latitude.formatted(.number.rounded(increment:0.001))), \(final.longitude.formatted(.number.rounded(increment:0.001))).")
                    
                    action(final)
                } label: {
                    Image("anchor")
                        .resizable()
                        .frame(width: CGFloat(50), height: CGFloat(50))
                        .colorInvert()
                }
                .buttonStyle(.bordered)
            }
            .onAppear(perform: {
                gps.isTrackingLocation = true
            })
            .onDisappear(perform: {
                gps.isTrackingLocation = false
            })

        }
    }
}



