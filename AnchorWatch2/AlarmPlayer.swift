//
//  AlarmPlayer.swift
//  AnchorWatch2
//
//  Created by Peter Molettiere on 12/13/23.
//

import AVFoundation

class AlarmPlayer {
    
    static let instance = AlarmPlayer()
    
    var player: AVAudioPlayer?
    
    init() {
        guard let url = Bundle.main.url(forResource: "alarm", withExtension: "mp3") else { return }
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            player = try AVAudioPlayer(contentsOf: url)
            guard let player = player else { return }
            player.numberOfLoops = -1 // play forever
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func startPlaying() {
        guard let player = player else { return }
        player.play()
    }
    
    func stopPlaying() {
        guard let player = player else { return }
        player.stop()
    }
}
