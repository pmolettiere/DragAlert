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
    @Environment(ContentView.StateMarker.self) var marker: ContentView.StateMarker

    @State var model: SetupVesselModel
    
    init() {
        _model = State(initialValue: SetupVesselModel())
    }
    
    init(vessel: Vessel) {
        _model = State(initialValue: SetupVesselModel())
        model.vessel = vessel
        model.vesselName = vessel.name
        model.loa = MeasurementModel(vessel.loa)
        model.rodeLength = MeasurementModel(vessel.rodeLength)
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
                    Text("view.multiple.latitude")
                    Text("\(model.gps.latitude.formatted(.number.rounded(increment:0.001)))")
                }
                HStack {
                    Text("view.multiple.longitude")
                    Text("\(model.gps.longitude.formatted(.number.rounded(increment:0.001)))")
                }
                Button {
                    if let v = model.vessel {
                        v.name = model.vesselName
                        v.loa = model.loa.measurement
                        v.rodeLength = model.rodeLength.measurement
                    } else {
                        let v = Vessel(uuid: UUID(), name: model.vesselName, loaMeters: model.loa.asUnit(UnitLength.meters).value, rodeMeters: model.rodeLength.asUnit(UnitLength.meters).value, latitude: model.gps.latitude, longitude: model.gps.longitude, isAnchored: false, anchor: nil)
                        viewModel.create(myVessel: v)
                    }
                    marker.state = .map
                } label: {
                    Text(model.vessel == nil ? "view.setup.vessel.add" : "view.setup.vessel.edit" )
                }
                .disabled(model.vesselName == "")
            }
            .onAppear(perform: {
                LocationDelegate.instance.isTrackingLocation = true
                model.gps.isTrackingLocation = true
//                if let lastRode = UserDefaults.standard.object(forKey: "SetupVesselView.rodeLength") as? Measurement<UnitLength> {
//                    rodeLength = lastRode
//                }
            })
            .onDisappear(perform: {
                model.gps.isTrackingLocation = false
//                UserDefaults.standard.set(rodeLength, forKey: "SetupVesselView.rode")
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

}
