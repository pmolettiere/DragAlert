//
//  SetupVessel.swift
//  Drag Alert
//
//  Created by Peter Molettiere on 12/5/23.
//
//    Copyright (C) <2023>  <Peter Molettiere>
//
//    This program is free software: you can redistribute it and/or modify
//    it under the terms of the GNU General Public License as published by
//    the Free Software Foundation, either version 3 of the License, or
//    (at your option) any later version.
//
//    This program is distributed in the hope that it will be useful,
//    but WITHOUT ANY WARRANTY; without even the implied warranty of
//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//    GNU General Public License for more details.
//
//    You should have received a copy of the GNU General Public License
//    along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

import Foundation
import SwiftUI
import MapKit

struct SetupVesselView : View {
    @Environment(ViewModel.self) private var viewModel

    @State var model: SetupVesselModel
    
    init() {
        _model = State(initialValue: SetupVesselModel())
    }
    
    init(vessel: Vessel) {
        _model = State(initialValue: SetupVesselModel())
        model.vessel = vessel
        model.vesselName = vessel.name
        model.loa = MeasurementModel(vessel.loaMeasurement)
        model.rodeLength = MeasurementModel(vessel.totalRodeMeasurement)
        model.readPrefs()
    }
    
    var body: some View {
        Form {
            Section("Setup Your Vessel") {
                HStack {
                    Text("view.setup.vessel.name")
                    Spacer()
                    TextField("view.setup.vessel.name", text: $model.vesselName )
                        .padding(10)
                }
                DistanceEditor("view.setup.vessel.loa", measurement: model.loa, max: Measurement(value: 100, unit: UnitLength.feet), step: 1)
                DistanceEditor("view.setup.vessel.rodeLength", measurement: model.rodeLength)
                HStack {
                    Spacer()
                    VesselLocationMap()
                        .frame(width: 350, height: 200)
                    Spacer()
                }
                Button {
                    if let v = model.vessel {
                        v.name = model.vesselName
                        v.loaMeasurement = model.loa.measurement
                        v.totalRodeMeasurement = model.rodeLength.measurement
                    } else {
                        let v = Vessel(uuid: UUID(), name: model.vesselName, loaMeters: model.loa.asUnit(UnitLength.meters).value, rodeMeters: model.rodeLength.asUnit(UnitLength.meters).value, latitude: model.gps.latitude, longitude: model.gps.longitude, isAnchored: false, anchor: nil)
                        viewModel.create(myVessel: v)
                    }
                    viewModel.setAppView( .map )
                } label: {
                    Text(model.vessel == nil ? "view.setup.vessel.add" : "view.setup.vessel.edit" )
                }
                .disabled(model.vesselName == "")
            }
            .onAppear(perform: {
                LocationDelegate.instance.isTrackingLocation = true
                model.gps.isTrackingLocation = true
            })
            .onDisappear(perform: {
                model.gps.isTrackingLocation = false
            })
        }
    }
}

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
