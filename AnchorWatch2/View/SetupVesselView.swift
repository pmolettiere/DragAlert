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

    @State var newVessel: Vessel
        
    init() {
        self.newVessel = Vessel(uuid: UUID(), name: "", loaMeters: 14, latitude: 0.0, longitude: 0.0, isAnchored: false, anchor: [])
    }

    var body: some View {
        Form {
            Section(header: Text("Configure Your Vessel")) {
                HStack {
                    Text("Vessel Name")
                    Spacer()
                    TextField("Vessel Name", text: $newVessel.name )
                        .padding(10)
                }
                
                MeasurementEditor("LOA", measurement: $newVessel.loa, range: 0...125, step: 1)
            }
        }
                        
        Button {
//                newVessel.coordinate = locationsHandler.lastLocation.coordinate
//                modelContext.insert(newVessel)
//                viewModel.update(modelContext: modelContext)
//                LocationsHandler.shared.bind(to: newVessel)
//                viewModel.myVessel = newVessel
        } label: {
            Text("Add Vessel")
        }
        
    }
}

#Preview {
    SetupVesselView()
//        .environment(ViewModel.preview)
//        .modelContainer(PreviewSampleData.container)
}
