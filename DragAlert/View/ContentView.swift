//
//  ContentView.swift
//  Drag Alert
//
//  Created by Peter Molettiere on 12/9/23.
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

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(ViewModel.self) private var viewModel
    
    var body: some View {
        @Bindable var m = viewModel       // m is for model
        
        HStack {
            switch( m.currentView ) {
            case .setup :
                SetupVesselView(model: m.setupModel)
            case .new_anchor :
                AnchoringView(model: m.anchoringModel!, state: .new)
            case .edit_anchor :
                AnchoringView(model: m.anchoringModel!, state: .edit)
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



        


