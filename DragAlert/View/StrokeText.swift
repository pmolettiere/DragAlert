//
//  StrokeText.swift
//  Drag Alert
//
//  https://stackoverflow.com/questions/57334125/how-to-make-text-stroke-in-swiftui
//

import SwiftUI

struct StrokeText: View {
    let text: LocalizedStringKey
    let width: CGFloat
    let color: Color

    var body: some View {
        ZStack{
            ZStack{
                Text(text).offset(x:  width, y:  width)
                Text(text).offset(x: -width, y: -width)
                Text(text).offset(x: -width, y:  width)
                Text(text).offset(x:  width, y: -width)
            }
            .foregroundColor(color)
            Text(text)
        }
    }
}
