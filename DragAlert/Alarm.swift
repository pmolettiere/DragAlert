//
//  AlarmPlayer.swift
//  AnchorWatch2
//
//  Created by Peter Molettiere on 12/13/23.
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

import AVFoundation

@Observable
final class Alarm : @unchecked Sendable {
    
    static let instance = Alarm()
    
    var player: AVAudioPlayer?
    var isEnabled: Bool = true {
        didSet {
            if( !isEnabled ) {
                stop()
                isPlaying = false
            }
        }
    }
    var isSnoozed: Bool = false
    var isPlaying: Bool = false
    var isTesting: Bool = false
    
    init() {
        guard let url = Bundle.main.url(forResource: "alarm", withExtension: "mp3") else { return }
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
            player = try AVAudioPlayer(contentsOf: url)
            guard let player = player else { return }
            player.numberOfLoops = -1 // play forever
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    private func play() {
        guard let player = player else { return }
        player.play()
    }
    
    func startPlaying() {
        if( isEnabled && !isSnoozed ) {
            isPlaying = true
            play()
        }
    }
    
    private func stop() {
        guard let player = player else { return }
        player.stop()
    }
    
    func stopPlaying() {
        if( isTesting ) { return }
        stop()
        isPlaying = false
    }
    
    func snooze() {
        if( isPlaying ) {
            stop()
            isSnoozed = true
            Timer.scheduledTimer(withTimeInterval: 120.0, repeats: false, block: {_ in
                self.isSnoozed = false
            })
        }
    }
    
    func test() {
        print("test")
        isTesting = true
        play()
        Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false, block: {_ in
            self.stop()
            self.isTesting = false
        })

    }
}
