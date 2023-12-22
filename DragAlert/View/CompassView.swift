//
//  CompassView.swift
//  Drag Alert
//
//  Created by Peter Molettiere on 12/18/23.
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

struct CompassView: View {
    @State var model = CompassViewModel()
    let compassSize = CGFloat(175)

    var body: some View {
        VStack {
            Image("compass.rose")
                .resizable()
                .colorInvert()
                .aspectRatio(1, contentMode: .fit)
                .frame(width: compassSize, height: compassSize)
                .rotationEffect(.degrees(model.gps.heading))
                .padding()
            HStack {
                Text("view.anchoring.bearing")
                Text("\(model.gps.heading.formatted(.number.rounded(increment:1)))")
            }
        }
        .background(Color.black)
        .padding()
        .onAppear(perform: {
            model.track()
        })

    }
}

@Observable
class CompassViewModel {
    var gps = LocationObserver()
    
    deinit {
        gps.isTrackingHeading = false;
    }
    
    func track() {
        gps.isTrackingHeading = true;
    }
}

#Preview {
    CompassView()
}
