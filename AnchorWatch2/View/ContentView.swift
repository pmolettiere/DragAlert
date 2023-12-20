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
    
    var body: some View {
        @Bindable var m = viewModel       // m is for model
        
        HStack {
            switch( m.currentView ) {
            case .setup :
                if let v = m.myVessel {
                    SetupVesselView(vessel: v)
                } else {
                    SetupVesselView()
                }
            case .anchor :
                AnchoringView(vessel: m.myVessel!)
            case .map :
                MapView(vessel: m.myVessel!)
            case .perm :
                PermissionView()
            }
        }
        .onAppear(){
            print("ContentView.onAppear")
            if( !UserDefaults.standard.bool(forKey: "doneSetup") ) {
                m.setAppView(.perm)
            } else {
                viewModel.initMyVessel()
                if viewModel.myVessel != nil {
                    m.setAppView(.map)
                }
            }
        }
    }
}



        


