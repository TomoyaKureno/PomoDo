//
//  AudioManager.swift
//  PomoDo
//
//  Created by Academy on 03/03/26.
//

import AVFoundation

@MainActor
final class SoundManager {
    static let shared = SoundManager()
    private var player: AVAudioPlayer?
    
    func setupAudioSession() {
        // penting untuk background audio
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try session.setActive(true)
        } catch {
            print("AudioSession error:", error)
        }
    }
    
    func play(_ name: String, ext: String = "mp3", loop: Bool = false) {
        guard let url = Bundle.main.url(forResource: name, withExtension: ext) else {
            print("Sound not found:", name)
            return
        }
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.numberOfLoops = loop ? -1 : 0
            player?.prepareToPlay()
            player?.play()
        } catch {
            print("AVAudioPlayer error:", error)
        }
    }
    
    func stop() { player?.stop() }
    
    /// Alarm bunyi 10 detik (loop lalu stop)
    func playAlarm10Seconds() {
        play("alarm", loop: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) { [weak self] in
            self?.stop()
        }
    }
}
