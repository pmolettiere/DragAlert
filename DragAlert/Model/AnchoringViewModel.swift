//
//  AnchoringViewModel.swift
//  Drag Alert
//
//  Created by Peter Molettiere on 12/26/23.
//

import Foundation

@Observable
class AnchoringViewModel {
    var vessel: Vessel

    var gps: LocationObserver = LocationObserver()
    var selectedTab: AnchoringView.TabState = .relative
    
    var rodeLength: MeasurementModel<UnitLength>
    var distanceFromAnchor: MeasurementModel<UnitLength>
    
    var maxRodeLength: MeasurementModel<UnitLength>
    var maxDistanceFromAnchor: MeasurementModel<UnitLength>
    
    var willEdit: AnchoringView.EditState
    
    init(vessel: Vessel, state: AnchoringView.EditState) {
        self.vessel = vessel
        self.gps = LocationObserver()
        self.maxRodeLength = MeasurementModel(vessel.totalRodeMeasurement)
        self.maxDistanceFromAnchor = MeasurementModel(vessel.maxDistanceFromAnchor)
        self.willEdit = state
        
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
    
    func dropAnchor(_ location: Location) {
        let rodeLength = self.rodeLength.asUnit(UnitLength.meters)
        
        // if( vessel.isAnchored ) {
        if( willEdit == .edit ) {
            if let anchor = vessel.anchor {
                anchor.location = location
                anchor.rodeInUseMeasurement = rodeLength
            }
        } else {
            let newAnchor = Anchor(timestamp: Date.now, location: location, rodeLength: rodeLength, log: [], vessel: self.vessel)
            vessel.anchor = newAnchor
            vessel.isAnchored = true
        }
        print("AnchoringVew.dropAnchor() complete")
    }
    
    func relativeLocationWouldAlarm() -> Bool {
        let potentialAnchorLocation = relativeLocation()
        let vesselLocation = vessel.location
        return !vesselLocation.isWithin(meters: currentSwingRadiusMeters(), of: potentialAnchorLocation)
    }
    
    func currentSwingRadiusMeters() -> Double {
        vessel.loaMeters + rodeLength.asUnit(UnitLength.meters).value
    }

    func setAnchorAtRelativeBearing() {
        let final = relativeLocation()
        print("Dropping anchor at relative position \(final.latitude.formatted(.number.rounded(increment:0.001))), \(final.longitude.formatted(.number.rounded(increment:0.001)))");
        dropAnchor(final)
    }
    
    func relativeLocation() -> Location {
        gps.location.locationWithBearing(bearing: gps.heading.trueHeading, distanceMeters: distanceFromAnchor.asUnit(.meters).value)
    }
        
    func setAnchorAtCurrentPosition() {
        let final = getCurrentAnchorPosition()
        
        print("Dropping anchor at current position \(final.latitude.formatted(.number.rounded(increment:0.001))), \(final.longitude.formatted(.number.rounded(increment:0.001))).")
        
        dropAnchor(final)
    }
    
    func getCurrentAnchorPosition() -> Location {
        gps.location
    }
}
