//
//  AnchoringView.swift
//  AnchorWatch2
//
//  Created by Peter Molettiere on 12/6/23.
//

import SwiftUI
import MapKit

struct AnchoringView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(ViewModel.self) private var viewModel

    var vessel: Vessel
    var willShow: Binding<Bool>
    var gps: LocationObservationDelegate = LocationObservationDelegate()
    
    @State var tabSelection: Int?
    @State var rodeLength: Measurement<UnitLength> = Measurement(value: 0, unit: UnitLength.feet)
    
    init(vessel: Vessel, willShow: Binding<Bool>) {
        self.vessel = vessel
        self.willShow = willShow
    }
    
    var body: some View {
        TabView(selection: $tabSelection) {
            RelativeView(gps: gps, action: dropAnchor, measuredRadiusState: $rodeLength)
                .tabItem {
                    Label("Relative", systemImage: "location.north.line.fill")
                }
            CurrentView(gps: gps, action: dropAnchor, measuredRadiusState: $rodeLength)
                .tabItem {
                    Label("Current", systemImage: "location.fill")
                }
        }
        .onAppear() {
            viewModel.isTrackingHeading(isTracking: true)
            viewModel.isTrackingLocation(isTracking: true)
        }
    }
    
    private func dropAnchor(location: CLLocationCoordinate2D) {
        let latitude = location.latitude
        let longitude = location.longitude
        let rodeLength: Measurement<UnitLength> = rodeLength.converted(to: UnitLength.meters)
        let anchorRadius = Measurement(value: rodeLength.value + vessel.loaMeters, unit: UnitLength.meters)
        let newAnchor = Anchor(timestamp: Date.now, latitude: latitude, longitude: longitude, radius: anchorRadius, log: [], vessel: self.vessel)
        vessel.anchor = newAnchor
//        do { try modelContext.save() }
//        catch {
//            print("Failed to save modelContext.");
//        }
        vessel.isAnchored = true
        willShow.wrappedValue = false
    }
    
    struct RelativeView: View {
        @State var distance: Measurement<UnitLength> = Measurement<UnitLength>(value: 0, unit: UnitLength.feet)
        var gps: LocationObservationDelegate
        var action: (CLLocationCoordinate2D) -> ()
        var measuredRadiusState: Binding<Measurement<UnitLength>>
        
        var body: some View {
            VStack {
                DistanceEditor("Rode", measurement: measuredRadiusState)
                
                DistanceEditor("Distance", measurement: $distance)
                Text("Bearing: \(gps.heading.formatted(.number.rounded(increment:1)))")
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
            })
            .onDisappear(perform: {
                gps.isTrackingLocation = false
                gps.isTrackingHeading = false
            })

        }
    }
    
    struct CurrentView: View {
        var gps: LocationObservationDelegate
        var action: (CLLocationCoordinate2D) -> ()
        var measuredRadiusState: Binding<Measurement<UnitLength>>
        
        var body: some View {
            VStack {
                DistanceEditor("Rode", measurement: measuredRadiusState)
                Text("Latitude: \(gps.latitude.formatted(.number.rounded(increment:0.001)))")
                Text("Longitude: \(gps.longitude.formatted(.number.rounded(increment:0.001)))")
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



