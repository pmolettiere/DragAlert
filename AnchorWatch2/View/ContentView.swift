//
//  ContentView.swift
//  AnchorWatch2
//
//  Created by Peter Molettiere on 12/9/23.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(ViewModel.self) private var viewModel
    
    @State var doneSetup = false
    
    var body: some View {
        @Bindable var m = viewModel       // m is for model
        VStack {
            if( !doneSetup ) {
                SetupView(doneSetup: $doneSetup)
            } else {
                if let myVessel = m.myVessel {
                    MapView(vessel: myVessel)
                } else {
                    SetupVesselView()
                }
            }
        }
        .onAppear(){
            doneSetup = UserDefaults.standard.bool(forKey: "doneSetup")
            if( doneSetup ) {
                viewModel.initMyVessel()
            }
        }
    }
}

#Preview {
    ContentView()
}
