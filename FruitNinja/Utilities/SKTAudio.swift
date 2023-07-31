//
//  SKTAudio.swift
//  FruitNinja
//
//  Created by thaxz on 31/07/23.
//

import Foundation
import AVFoundation

class SKTAudio {
    
    static let shared = SKTAudio()
    private var bgMusic: AVAudioPlayer!
    private var soundEffect: AVAudioPlayer!
    
    func playBGMusic(_ fn: String){
        guard let url = Bundle.main.url(forResource: fn, withExtension: nil) else {return}
        do {
            try bgMusic = AVAudioPlayer(contentsOf: url)
            bgMusic.numberOfLoops = -1
            bgMusic.prepareToPlay()
            bgMusic.play()
        } catch {}
    }
    
    func stopBGMusic(){
        if bgMusic != nil {
            if bgMusic.isPlaying {
                bgMusic.stop()
            }
        }
    }
    
    func playSoundEffect(_ fn: String){
        guard let url = Bundle.main.url(forResource: fn, withExtension: nil) else {return}
        do {
            try soundEffect = AVAudioPlayer(contentsOf: url)
            soundEffect.numberOfLoops = 0
            soundEffect.prepareToPlay()
            soundEffect.play()
        } catch {}
    }
    
    func stopSoundEffect(){
        if soundEffect != nil {
            if soundEffect.isPlaying {
                soundEffect.stop()
            }
        }
    }
    
}
