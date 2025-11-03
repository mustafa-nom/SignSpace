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
        // System sound for success
        AudioServicesPlaySystemSound(1057) // Success tone
    }
    
    func playError() {
        // System sound for error
        AudioServicesPlaySystemSound(1053) // Light buzz
    }
    
    func playProgress() {
        // System sound for progress
        AudioServicesPlaySystemSound(1104) // Navigation pop
    }
}
