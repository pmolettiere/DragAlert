//
//  SetupVessel.swift
//  AnchorWatch
//
//  Created by Peter Molettiere on 12/5/23.
//

import Foundation
import SwiftUI
import SwiftData
import MapKit

struct SetupVesselView : View {
    @Environment(ViewModel.self) private var viewModel
    @Environment(\.modelContext) private var modelContext

    @State var vesselName: String = ""
    @State var loa: Measurement<UnitLength> = Measurement(value: 40, unit: UnitLength.feet)
    @State var gps: LocationObserver = LocationObserver()
    
    var body: some View {
        Form {
            Text("Setup Your Vessel").font(.headline).padding()
            
            HStack {
                Text("view.setup.vessel.name")
                Spacer()
                TextField("view.setup.vessel.name", text: $vesselName )
                    .padding(10)
            }
            DistanceEditor("view.setup.vessel.loa", measurement: $loa)
            HStack {
                Text("view.multiple.latitude")
                Text("\(gps.latitude.formatted(.number.rounded(increment:0.001)))")
            }
            HStack {
                Text("view.multiple.longitude")
                Text("\(gps.longitude.formatted(.number.rounded(increment:0.001)))")
            }
            Button {
                let v = Vessel(uuid: UUID(), name: vesselName, loaMeters: loa.converted(to: UnitLength.meters).value, latitude: gps.latitude, longitude: gps.longitude, isAnchored: false, anchor: nil)
                modelContext.insert(v)
                viewModel.initMyVessel()
                v.startTrackingLocation()
            } label: {
                Text("view.setup.vessel.add")
            }
        }
        .onAppear(perform: {
            gps.isTrackingLocation = true
        })
        .onDisappear(perform: {
            gps.isTrackingLocation = false
        })
    }
}

#Preview {
    SetupVesselView()
//        .environment(ViewModel.preview)
//        .modelContainer(PreviewSampleData.container)
}
