//
//  AnchorView.swift
//  Drag Alert
//
//  Created by Peter Molettiere on 12/20/23.
//

import SwiftUI

struct AnchorView: View {
    var color: Color
    var size: CGFloat
    
    init(color: Color = Color.black, size: CGFloat = CGFloat(30) ) {
        self.color = color
        self.size = size
    }
    
    var body: some View {
        Rectangle()
            .frame(width: size, height: size, alignment: .bottom)
            .foregroundColor(color)
            .mask(
                Image("anchor")
                    .resizable()
                    .scaledToFill()
            )
    }
}

#Preview {
    VStack {
        AnchorView()
        AnchorView(color: .blue)
        AnchorView(color: .red, size: CGFloat(40))
        AnchorView(color: .green, size: CGFloat(75))
    }
}
