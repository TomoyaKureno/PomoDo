//
//  AudioManager.swift
//  PomoDo
//
//  Created by Academy on 03/03/26.
//

import Foundation
import AVFoundation
import Combine

final class AudioManager: ObservableObject {
    static let shared = AudioManager()
    var audioPlayer: AVAudioPlayer?
    
    func playSound(fileName: String, fileType: String) {
        if let path = Bundle.main.path(forResource: fileName, ofType: fileType) {
            let url = URL(fileURLWithPath: path)
            
            do {
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: .mixWithOthers)
                try AVAudioSession.sharedInstance().setActive(true)
                
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.play()
            } catch {
                print("Couldn't load audio file.")  
            }
        }
    }
}
