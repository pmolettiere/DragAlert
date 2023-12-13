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
    var position: NotificationDelegate
    
    @State var tabSelection: Int?
    @State var measuredRadiusState: Measurement<UnitLength> = Measurement(value: 100, unit: UnitLength.feet)
    
    init(vessel: Vessel, willShow: Binding<Bool>) {
        self.vessel = vessel
        self.willShow = willShow
        self.position = NotificationDelegate()
        NotificationCenter.default.addObserver(position, selector: #selector(NotificationDelegate.didUpdateLocation), name: LocationNotifications.updateLocation.asNotificationName(), object: nil)
        NotificationCenter.default.addObserver(position, selector: #selector(NotificationDelegate.didUpdateHeading), name: LocationNotifications.updateHeading.asNotificationName(), object: nil)
    }
    
    var body: some View {
        TabView(selection: $tabSelection) {
            RelativeView(compass: position, action: dropAnchor)
                .tabItem {
                    Label("Relative", systemImage: "location.north.line.fill")
                }
            CurrentView(compass: position, action: dropAnchor)
                .tabItem {
                    Label("Current", systemImage: "location.fill")
                }
                .padding()
        }
        
    }
    
    private func dropAnchor(location: CLLocationCoordinate2D) {
        let latitude = location.latitude
        let longitude = location.longitude
        let radius: Measurement<UnitLength> = measuredRadiusState.converted(to: UnitLength.meters)
        let newAnchor = Anchor(timestamp: Date.now, latitude: latitude, longitude: longitude, radius: radius, log: [], vessel: self.vessel)
        vessel.anchors?.append(newAnchor)
        vessel.isAnchored = true
        willShow.wrappedValue = false
    }
    
    struct RelativeView: View {
        @State private var distance: Measurement<UnitLength> = Measurement(value: 150, unit: UnitLength.feet)
        var compass: NotificationDelegate
        var action: (CLLocationCoordinate2D) -> ()
        
        var body: some View {
            Form {
                Section("Relative Anchor Location") {
                    DistanceEditor("Distance", measurement: $distance)
                    HStack {
                        Text("Bearing: \(compass.heading.formatted(.number.rounded(increment:1)))")
                    }
                    Button {
                        let origin = CLLocationCoordinate2D(latitude: compass.latitude, longitude: compass.longitude)
                        let final = locationWithBearing(bearing: compass.heading, distanceMeters: self.distance.converted(to: UnitLength.meters).value, origin: origin)
                        
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
                    .buttonStyle(.bordered)
                }
                .frame(alignment: .center)
                .padding()
            }

        }
    }

    struct CurrentView: View {
        var compass: NotificationDelegate
        var action: (CLLocationCoordinate2D) -> ()

        var body: some View {
            Form {
                Section("Absolute Anchor Position") {
                    Text("Latitude: \(compass.latitude.formatted(.number.rounded(increment:0.001)))")
                    Text("Longitude: \(compass.longitude.formatted(.number.rounded(increment:0.001)))")
                    Button() {
                        let final = CLLocationCoordinate2D(latitude: compass.latitude, longitude: compass.longitude)
                        
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
                .frame(alignment: .center)
                .padding()
            }
        }
    }
}

@Observable
class NotificationDelegate {
    var latitude: Double = 0
    var longitude: Double = 0
    var heading: Double = 0
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: LocationNotifications.updateLocation.asNotificationName(), object: nil)
        NotificationCenter.default.removeObserver(self, name: LocationNotifications.updateHeading.asNotificationName(), object: nil)
    }
        
    @objc func didUpdateLocation(notification: Notification) {
        let locationUpdate: LocationUpdate = notification.object as! LocationUpdate
        let locations = locationUpdate.locations
        if let lastLocation: CLLocation = locations.last {
            latitude = lastLocation.coordinate.latitude
            longitude = lastLocation.coordinate.longitude
        }
    }
    
    @objc func didUpdateHeading(notification: Notification) {
        let headingUpdate: HeadingUpdate = notification.object as! HeadingUpdate
        heading = headingUpdate.heading.trueHeading
    }
}


