//
//  ContentView.swift
//  AnchorWatch2
//
//  Created by Peter Molettiere on 12/9/23.
//

import SwiftUI

struct ContentView: View {
    @Environment(ViewModel.self) private var viewModel

    var body: some View {
        @Bindable var m = viewModel       // m is for model
        if let myVessel = m.myVessel {
            MapView(vessel: myVessel)
        } else {
            Text("No vessel to track.")
        }
    }
}

#Preview {
    ContentView()
}
