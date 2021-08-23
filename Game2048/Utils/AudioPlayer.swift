//
//  AudioPlayer.swift
//  Game2048
//
//  Created by Sree Sai Raghava Dandu on 23/08/21.
//

import AVFoundation

var player: AVAudioPlayer?
func playSound(){
    guard let url = Bundle.main.url(forResource: "pop", withExtension: "wav") else { return }
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback,mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            player = try AVAudioPlayer(contentsOf: url,fileTypeHint: AVFileType.wav.rawValue)
            
            guard let player = player else { return }
            player.play()
        } catch let error {
            print(error)
        }
    }
