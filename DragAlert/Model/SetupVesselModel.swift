//
//  SetupVesselModel.swift
//  Drag Alert
//
//  Created by Peter Molettiere on 12/26/23.
//

import Foundation

@Observable
class SetupVesselModel {
    var vessel: Vessel?
    var vesselName: String = ""
    var loa: MeasurementModel<UnitLength> = MeasurementModel(Measurement(value: 40, unit: UnitLength.feet))
    var rodeLength: MeasurementModel<UnitLength> = MeasurementModel(Measurement(value: 100, unit: UnitLength.feet))
    var gps: LocationObserver = LocationObserver()

    func readPrefs() {
        loa.unit = readPrefUnit("SetupVesselView.loa")
        rodeLength.unit = readPrefUnit("SetupVesselView.rodeLength")
    }
    
    func savePrefs() {
        savePrefUnit("SetupVesselView.loa", unit: loa.unit)
        savePrefUnit("SetupVesselView.rodeLength", unit: rodeLength.unit)
    }
    
    func readPrefUnit(_ label: String) -> UnitLength {
        UserDefaults.standard.string(forKey: "\(label).unit") == "ft" ? UnitLength.feet : UnitLength.meters
    }
    
    func savePrefUnit(_ label: String, unit: UnitLength) {
        UserDefaults.standard.set(unit.symbol, forKey: "\(label).unit")
    }
}
