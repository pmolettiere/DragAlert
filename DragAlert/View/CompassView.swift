//
//  CompassView.swift
//  AnchorWatch2
//
//  Created by Peter Molettiere on 12/18/23.
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
