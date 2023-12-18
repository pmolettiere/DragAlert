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
    
    @Observable
    class StateMarker {
        var state: AppState = .setup
        enum AppState {
            case perm, setup, map, anchor
        }
    }
    
    @State var marker: StateMarker = StateMarker()
    
    var body: some View {
        @Bindable var m = viewModel       // m is for model
        HStack {
            if let v = m.myVessel {
                switch( marker.state ) {
                case .setup :  SetupVesselView(vessel: v)
                case .anchor : AnchoringView(vessel: v)
                default :  MapView(vessel: v)
                }
            } else {
                switch( marker.state ) {
                case .perm : PermissionView()
                default : SetupVesselView()
                }
            }
        }
        .environment(marker)
        .onAppear(){
            if( !UserDefaults.standard.bool(forKey: "doneSetup") ) {
                marker.state = .perm
            } else {
                viewModel.initMyVessel()
                if viewModel.myVessel != nil {
                    marker.state = .map
                }
            }
        }
    }
}


        


