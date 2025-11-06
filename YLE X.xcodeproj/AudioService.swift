//
//  AudioService.swift
//  YLE X
//
//  Intended path: Core/Services/
//  Created by Senior iOS Developer on 6/11/25.
//

import Foundation
import SwiftUI
import Combine
import AVFoundation

// MARK: - Audio Service for Kids Learning
class AudioService: NSObject, ObservableObject {
    static let shared = AudioService()
    
    // Audio players
    private var audioPlayer: AVAudioPlayer?
    private var backgroundMusicPlayer: AVAudioPlayer?
    private var voiceRecorder: AVAudioRecorder?
    
    // Published properties for UI
    @Published var isPlaying = false
    @Published var isRecording = false
    @Published var currentPlaybackTime: TimeInterval = 0
    @Published var totalDuration: TimeInterval = 0
    @Published var volume: Float = 1.0 {
        didSet {
            audioPlayer?.volume = volume
            backgroundMusicPlayer?.volume = volume * 0.3
        }
    }
    
    // Audio session
    private let audioSession = AVAudioSession.sharedInstance()
    private var playbackTimer: Timer?
    
    // Sound effects cache
    private var soundEffectsCache: [String: AVAudioPlayer] = [:]
    
    override init() {
        super.init()
        setupAudioSession()
        preloadSoundEffects()
    }
    
    // MARK: - Audio Session Setup
    private func setupAudioSession() {
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetooth])
            try audioSession.setActive(true)
            print("✅ Audio session configured successfully")
        } catch {
            print("❌ Audio session configuration failed: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Sound Effects Management
    private func preloadSoundEffects() {
        let soundEffects = SoundManager.SoundEffect.allCases
        
        for effect in soundEffects {
            if let url = Bundle.main.url(forResource: effect.rawValue, withExtension: "mp3") {
                do {
                    let player = try AVAudioPlayer(contentsOf: url)
                    player.prepareToPlay()
                    player.volume = 0.7
                    soundEffectsCache[effect.rawValue] = player
                } catch {
                    print("❌ Could not preload sound effect \(effect.rawValue): \(error.localizedDescription)")
                }
            }
        }
        
        print("✅ Preloaded \(soundEffectsCache.count) sound effects")
    }
    
    func playEffect(_ effect: SoundManager.SoundEffect) {
        guard let player = soundEffectsCache[effect.rawValue] else {
            print("⚠️ Sound effect not found: \(effect.rawValue)")
            return
        }
        
        player.stop()
        player.currentTime = 0
        player.play()
    }
    
    // MARK: - Text-to-Speech
    func speakText(_ text: String, language: String = "en-US", rate: Float = 0.4) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: language)
        utterance.rate = rate
        utterance.pitchMultiplier = 1.1
        utterance.volume = volume
        
        let synthesizer = AVSpeechSynthesizer()
        synthesizer.speak(utterance)
        
        print("🗣️ Speaking: \(text)")
    }
}