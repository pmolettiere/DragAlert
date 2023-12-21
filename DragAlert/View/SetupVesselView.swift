//
//  SetupVessel.swift
//  AnchorWatch
//
//  Created by Peter Molettiere on 12/5/23.
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
//                HStack {
//                    Text("view.multiple.latitude")
//                    Text("\(model.gps.latitude.formatted(.number.rounded(increment:0.001)))")
//                }
//                HStack {
//                    Text("view.multiple.longitude")
//                    Text("\(model.gps.longitude.formatted(.number.rounded(increment:0.001)))")
//                }
                VesselLocationMap()
                    .frame(width: 350, height: 200)

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
