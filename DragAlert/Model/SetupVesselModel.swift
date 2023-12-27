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
    var loaMeters: Double = 15
    var rodeLengthMeters: Double = 60
    var gps: LocationObserver = LocationObserver()
    var defaultUnit: UnitLength = Preferred.value.lengthUnit {
        didSet {
            Preferred.value.lengthUnit = defaultUnit
        }
    }
    
    func setVessel(_ vessel: Vessel) {
        self.vessel = vessel
        self.vesselName = vessel.name
        self.loaMeters = vessel.loaMeters
        self.rodeLengthMeters = vessel.totalRodeMeters
    }
}
