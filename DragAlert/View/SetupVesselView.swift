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
    
    @MainActor
    init(model: SetupVesselModel) {
        _model = State( initialValue: model )
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
                Picker("view.editor.distance.unit", selection: $model.defaultUnit ) {
                    Text("view.editor.distance.feet").tag(UnitLength.feet)
                    Text("view.editor.distance.meters").tag(UnitLength.meters)
                }
                DistanceEditor("view.setup.vessel.loa", measurement: $model.loaMeters, maxMeters: 30, step: 1)
                DistanceEditor("view.setup.vessel.rodeLength", measurement: $model.rodeLengthMeters)
                HStack {
                    Spacer()
                    VesselLocationMap()
                        .frame(width: 350, height: 200)
                    Spacer()
                }
                Button {
                    if let v = model.vessel {
                        v.name = model.vesselName
                        v.loaMeters = model.loaMeters
                        v.totalRodeMeters = model.rodeLengthMeters
                        viewModel.setAppView( .map )
                    } else {
                        let v = Vessel(uuid: UUID(), name: model.vesselName, loaMeters: model.loaMeters, rodeMeters: model.rodeLengthMeters, location: model.gps.location, isAnchored: false, anchor: nil)
                        viewModel.create(myVessel: v)
                        viewModel.setAppView( .map )
                    }
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
