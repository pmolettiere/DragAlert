//
//  VolumeSlider.swift
//  Drag Alert
//
//  https://mtanriverdi.medium.com/swiftui-volume-slider-3fee7b238015
//
// In use:
//  VolumeSlider()
//     .frame(height: 40)
//     .padding(.horizontal)

import SwiftUI
import MediaPlayer
import UIKit

struct VolumeSlider: UIViewRepresentable {
   func makeUIView(context: Context) -> MPVolumeView {
      MPVolumeView(frame: .zero)
   }

   func updateUIView(_ view: MPVolumeView, context: Context) {}
}

