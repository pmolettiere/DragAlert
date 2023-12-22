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
        //print("AnchoringView.init()")
    }
    
    enum TabState : Int {
        case relative = 0, current
    }
    
    var body: some View {
        TabView(selection: $model.selectedTab) {
            RelativeView(model: model)
                .tag(TabState.relative)
                .tabItem {
                    Label("view.anchoring.relative", systemImage: "location.north.line.fill")
                }
                .padding()
            CurrentView(model: model)
                .tag(TabState.current)
                .tabItem {
                    Label("view.anchoring.current", systemImage: "location.fill")
                }
                .padding()
        }
        .onAppear() {
            LocationDelegate.instance.isTrackingHeading = true
            print("AnchoringView.onAppear()")
        }
        .onDisappear() {
            //LocationDelegate.instance.isTrackingHeading = false
            print("AnchoringView.onDisappear()")
        }
    }
        
    struct RelativeView: View {
        @Environment(ViewModel.self) private var viewModel
        var model: AnchoringViewModel
        
        init(model: AnchoringViewModel) {
            self.model = model
            //print("AnchoringView.RelativeView.init()")
        }
        
        var body: some View {
            VStack {
                VesselLocationMap(model: model)
                
                Spacer()
                //CompassView()
                
                DistanceEditor("view.anchoring.rodeLength", measurement: model.rodeLength, max: model.maxRodeLength.measurement )
                DistanceEditor("view.anchoring.distance", measurement: model.distanceFromAnchor, max: model.maxDistanceFromAnchor.measurement )
                // Text(model.relativeLocationWouldAlarm() ? "view.anchoring.would.alarm" : "view.anchoring.no.alarm")
                //    .foregroundColor(model.relativeLocationWouldAlarm() ? Color.red : Color.white)
                //    .padding()
                
                Button {
                    model.setAnchorAtRelativeBearing()
                    viewModel.setAppView( .map )
                    print("AnchoringView.RelativeView.button complete")
                } label: {
                    Text("view.anchoring.button.relative")
                    AnchorView(color: model.relativeLocationWouldAlarm() ? Color.blue : Color.gray, size: CGFloat(50))
                }
                .disabled(model.relativeLocationWouldAlarm())
            }
            .onAppear(perform: {
                model.track(location: true, heading: true)
                print("AnchoringView.RelativeView.onAppear()")
            })
            .onDisappear(perform: {
                // model.track()
                print("AnchoringView.RelativeView.onDisappear()")
            })
        }
    }
    
    struct CurrentView: View {
        @Environment(ViewModel.self) private var viewModel
        var model: AnchoringViewModel

        var body: some View {
            VStack {
                VesselLocationMap(model: model)
                
                Spacer()
                
                DistanceEditor("view.anchoring.rodeLength", measurement: model.rodeLength, max: model.maxRodeLength.measurement )
                    .padding()
                Button() {
                    model.setAnchorAtCurrentPosition()
                    viewModel.setAppView( .map )
                    print("AnchoringView.CurrentView.button complete")
                } label: {
                    Text("view.anchoring.button.current")
                    AnchorView(color: Color.blue, size: CGFloat(50))
                }
            }
            .onAppear(perform: {
                model.track(location: true, heading: true)
                print("AnchoringView.CurrentView.onAppear()")
            })
            .onDisappear(perform: {
                // model.track()
                print("AnchoringView.CurrentView.onDisappear()")
            })
        }
    }
}

@Observable 
class AnchoringViewModel {
    var vessel: Vessel

    var gps: LocationObserver = LocationObserver()
    var selectedTab: AnchoringView.TabState = .relative
    
    var rodeLength: MeasurementModel<UnitLength>
    var distanceFromAnchor: MeasurementModel<UnitLength>
    
    var maxRodeLength: MeasurementModel<UnitLength>
    var maxDistanceFromAnchor: MeasurementModel<UnitLength>
    
    init(vessel: Vessel) {
        self.vessel = vessel
        self.gps = LocationObserver()
        self.maxRodeLength = MeasurementModel(vessel.totalRodeMeasurement)
        self.maxDistanceFromAnchor = MeasurementModel(vessel.maxDistanceFromAnchor)
        
        // placeholders until prefs read below, ignore value being set
        self.rodeLength = MeasurementModel( vessel.totalRodeMeasurement )
        self.distanceFromAnchor = MeasurementModel( vessel.totalRodeMeasurement )
        // first phase of init() complete, now prefs read can complete
        
        self.rodeLength = MeasurementModel( readPrefMeasurement(label: "AnchoringView.RelativeView.rodeLength") )
        self.distanceFromAnchor = MeasurementModel( readPrefMeasurement(label: "AnchoringView.RelativeView.distance") )
    }
    
    deinit {
        savePrefMeasurements()
    }

    func readPrefMeasurement(label: String) -> Measurement<UnitLength> {
        let unit = UserDefaults.standard.string(forKey: "\(label).unit") == "ft" ? UnitLength.feet : UnitLength.meters
        let value = UserDefaults.standard.double(forKey: "\(label).value")
        print("readPref \(label) \(value) \(unit)")
        return Measurement<UnitLength>(value: value, unit: unit)
    }
    
    func savePrefMeasurements() {
        savePrefMeasurement("AnchoringView.RelativeView.distance", measurement: distanceFromAnchor.measurement)
        savePrefMeasurement("AnchoringView.RelativeView.rodeLength", measurement: rodeLength.measurement)
        func savePrefMeasurement(_ label: String, measurement: Measurement<UnitLength>) {
            UserDefaults.standard.set(measurement.value, forKey: "\(label).value")
            UserDefaults.standard.set(measurement.unit.symbol, forKey: "\(label).unit")
            print("savePref \(label) \(measurement.value) \(measurement.unit)")
        }
    }
    
    func track(location: Bool = false, heading: Bool = false) {
        gps.isTrackingLocation = location
        gps.isTrackingHeading = heading
        LocationDelegate.instance.isTrackingLocation = location
        LocationDelegate.instance.isTrackingHeading = heading
    }
    
    func dropAnchor(_ location: CLLocationCoordinate2D) {
        let latitude = location.latitude
        let longitude = location.longitude
        let rodeLength = self.rodeLength.asUnit(UnitLength.meters)
        let newAnchor = Anchor(timestamp: Date.now, latitude: latitude, longitude: longitude, rodeLength: rodeLength, log: [], vessel: self.vessel)
        vessel.anchor = newAnchor
        vessel.isAnchored = true
        print("AnchoringVew.dropAnchor() complete")
    }
    
    func relativeLocationWouldAlarm() -> Bool {
        let location = relativeLocation()
        let anchor = CLLocation(latitude: location.latitude, longitude: location.longitude)
        return CLLocation(latitude: gps.latitude, longitude: gps.longitude).distance(from: anchor) >= currentSwingRadiusMeters()
    }
    
    func currentSwingRadiusMeters() -> Double {
        vessel.loaMeters + rodeLength.asUnit(UnitLength.meters).value
    }

    func setAnchorAtRelativeBearing() {
        let final = relativeLocation()
        print("Dropping anchor at relative position \(final.latitude.formatted(.number.rounded(increment:0.001))), \(final.longitude.formatted(.number.rounded(increment:0.001)))");
        dropAnchor(final)
    }
    
    func relativeLocation() -> CLLocationCoordinate2D {
        let origin = CLLocationCoordinate2D(latitude: gps.latitude, longitude: gps.longitude)
        let final = locationWithBearing(bearing: gps.heading, distanceMeters: distanceFromAnchor.asUnit(UnitLength.meters).value, origin: origin)
        //print("relativeLocation with \(distanceFromAnchor.asUnit(.meters).value)m distance")
        
        func locationWithBearing(bearing:Double, distanceMeters:Double, origin:CLLocationCoordinate2D) -> CLLocationCoordinate2D {
            let bearingRadians = bearing * .pi / 180
            let distRadians = distanceMeters / (6372797.6) // earth radius in meters
            
            let lat1 = origin.latitude * .pi / 180
            let lon1 = origin.longitude * .pi / 180
            
            let lat2 = asin(sin(lat1) * cos(distRadians) + cos(lat1) * sin(distRadians) * cos(bearingRadians))
            let lon2 = lon1 + atan2(sin(bearingRadians) * sin(distRadians) * cos(lat1), cos(distRadians) - sin(lat1) * sin(lat2))
            
            return CLLocationCoordinate2D(latitude: lat2 * 180 / .pi, longitude: lon2 * 180 / .pi)
        }
        
        return final
    }
        
    func setAnchorAtCurrentPosition() {
        let final = getCurrentAnchorPosition()
        
        print("Dropping anchor at current position \(final.latitude.formatted(.number.rounded(increment:0.001))), \(final.longitude.formatted(.number.rounded(increment:0.001))).")
        
        dropAnchor(final)
    }
    
    func getCurrentAnchorPosition() -> CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: gps.latitude, longitude: gps.longitude)
    }
}

