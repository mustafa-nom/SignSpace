//
//  SoundManager.swift
//  SignSpace
//
//  Created by Mus Nom on 10/16/25.
//

import Foundation
import AVFoundation

class SoundManager {
    static let shared = SoundManager()
    
    private var audioPlayer: AVAudioPlayer?
    
    func playSuccess() {
        AudioServicesPlaySystemSound(1057) // Success tone
    }
    
    func playError() {
        AudioServicesPlaySystemSound(1053) // Light buzz
    }
    
    func playProgress() {
        AudioServicesPlaySystemSound(1104) // Navigation pop
    }
}
