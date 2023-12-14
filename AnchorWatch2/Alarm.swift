//
//  AlarmPlayer.swift
//  AnchorWatch2
//
//  Created by Peter Molettiere on 12/13/23.
//

import AVFoundation

final class Alarm : @unchecked Sendable {
    
    static let instance = Alarm()
    
    var player: AVAudioPlayer?
    var isEnabled: Bool = true {
        didSet {
            if( !isEnabled ) {
                stop()
            }
        }
    }
    var isSnoozed: Bool = false
    var isPlaying: Bool = false
    
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
        stop()
        isPlaying = false
    }
    
    func snooze() {
        if( isPlaying ) {
            stop()
            isSnoozed = true
            Timer.scheduledTimer(withTimeInterval: 120.0, repeats: false, block: {_ in
                self.isSnoozed = true
            })
        }
    }
}
