//
//  SetupVessel.swift
//  AnchorWatch
//
//  Created by Peter Molettiere on 12/5/23.
//

import Foundation
import SwiftUI
import SwiftData

struct SetupVesselView : View {
    @Environment(ViewModel.self) private var viewModel
    @Environment(\.modelContext) private var modelContext

    @State var vesselName: String = ""
    @State var loa: Measurement<UnitLength> = Measurement(value: 40, unit: UnitLength.feet)
    @State var latitude: Double = 0
    @State var longitude: Double = 0
        
    var body: some View {
        Form {
            HStack {
                Text("Vessel Name")
                Spacer()
                TextField("Vessel Name", text: $vesselName )
                    .padding(10)
            }
            DistanceEditor("LOA", measurement: $loa)
            Text("Latitude: \(latitude)")
            Text("Latitude: \(latitude)")
            Button {
                let v = Vessel(uuid: UUID(), name: vesselName, loaMeters: loa.converted(to: UnitLength.meters).value, latitude: latitude, longitude: longitude, isAnchored: false, anchor: [])
                modelContext.insert(v)
                viewModel.initMyVessel()
                v.startTrackingLocation()
            } label: {
                Text("Add Vessel")
            }
        }
    }
}

#Preview {
    SetupVesselView()
//        .environment(ViewModel.preview)
//        .modelContainer(PreviewSampleData.container)
}
