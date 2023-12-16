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

    @State var vesselName: String = ""
    @State var loa: Measurement<UnitLength> = Measurement(value: 40, unit: UnitLength.feet)
    @State var rode: Measurement<UnitLength> = Measurement(value: 328, unit: UnitLength.feet)
    @State var gps: LocationObserver = LocationObserver()
    
    var body: some View {
        Form {
            Section("Setup Your Vessel") {
                HStack {
                    Text("view.setup.vessel.name")
                    Spacer()
                    TextField("view.setup.vessel.name", text: $vesselName )
                        .padding(10)
                }
                DistanceEditor("view.setup.vessel.loa", measurement: $loa, max: Measurement(value: 100, unit: UnitLength.feet), step: 1)
                DistanceEditor("view.setup.vessel.rode", measurement: $rode)
                HStack {
                    Text("view.multiple.latitude")
                    Text("\(gps.latitude.formatted(.number.rounded(increment:0.001)))")
                }
                HStack {
                    Text("view.multiple.longitude")
                    Text("\(gps.longitude.formatted(.number.rounded(increment:0.001)))")
                }
                Button {
                    let v = Vessel(uuid: UUID(), name: vesselName, loaMeters: loa.converted(to: UnitLength.meters).value, rodeMeters: rode.converted(to: UnitLength.meters).value, latitude: gps.latitude, longitude: gps.longitude, isAnchored: false, anchor: nil)
                    viewModel.create(myVessel: v)
                } label: {
                    Text("view.setup.vessel.add")
                }
            }
            .onAppear(perform: {
                LocationDelegate.instance.isTrackingLocation = true
                gps.isTrackingLocation = true
//                if let lastRode = UserDefaults.standard.object(forKey: "SetupVesselView.rode") as? Measurement<UnitLength> {
//                    rode = lastRode
//                }
            })
            .onDisappear(perform: {
                gps.isTrackingLocation = false
//                UserDefaults.standard.set(rode, forKey: "SetupVesselView.rode")
            })
        }
    }
}

#Preview {
    SetupVesselView()
//        .environment(ViewModel.preview)
//        .modelContainer(PreviewSampleData.container)
}
