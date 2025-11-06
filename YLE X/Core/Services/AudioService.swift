//
//  AudioService.swift
//  YLE X
//
//  Created by Senior iOS Developer on 6/11/25.
//

import Foundation
import AVFoundation
import Combine
import FirebaseStorage

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
            backgroundMusicPlayer?.volume = volume * 0.3 // Background music quieter
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
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [])
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
            } else {
                print("⚠️ Sound file not found: \(effect.rawValue).mp3")
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
    
    // MARK: - Vocabulary Audio Playback
    func playVocabularyWord(_ word: VocabularyItem, completion: @escaping (Bool) -> Void) {
        guard let audioName = word.audioName else {
            completion(false)
            return
        }
        
        // Try local bundle first
        if let localURL = Bundle.main.url(forResource: audioName, withExtension: "mp3") {
            playAudio(from: localURL, completion: completion)
        } else {
            // Download from Firebase Storage if not local
            downloadAndPlayAudio(audioName: audioName, completion: completion)
        }
    }
    
    private func downloadAndPlayAudio(audioName: String, completion: @escaping (Bool) -> Void) {
        let storageRef = FirebaseManager.shared.storage.reference().child("audio/vocabulary/\(audioName).mp3")
        
        // Check if already cached locally
        let localURL = getCacheURL(for: audioName)
        
        if FileManager.default.fileExists(atPath: localURL.path) {
            playAudio(from: localURL, completion: completion)
            return
        }
        
        // Download from Firebase
        storageRef.write(toFile: localURL) { [weak self] url, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Audio download failed: \(error.localizedDescription)")
                    completion(false)
                } else {
                    self?.playAudio(from: localURL, completion: completion)
                }
            }
        }
    }
    
    private func getCacheURL(for audioName: String) -> URL {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsPath.appendingPathComponent("audio_cache").appendingPathComponent("\(audioName).mp3")
    }
    
    // MARK: - General Audio Playback
    func playAudio(from url: URL, completion: @escaping (Bool) -> Void) {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self
            audioPlayer?.volume = volume
            
            guard let player = audioPlayer else {
                completion(false)
                return
            }
            
            totalDuration = player.duration
            currentPlaybackTime = 0
            
            let success = player.play()
            isPlaying = success
            
            if success {
                startPlaybackTimer()
            }
            
            completion(success)
            
        } catch {
            print("❌ Audio playback failed: \(error.localizedDescription)")
            completion(false)
        }
    }
    
    func pauseAudio() {
        audioPlayer?.pause()
        isPlaying = false
        stopPlaybackTimer()
    }
    
    func resumeAudio() {
        let success = audioPlayer?.play() ?? false
        isPlaying = success
        if success {
            startPlaybackTimer()
        }
    }
    
    func stopAudio() {
        audioPlayer?.stop()
        audioPlayer = nil
        isPlaying = false
        currentPlaybackTime = 0
        totalDuration = 0
        stopPlaybackTimer()
    }
    
    // MARK: - Background Music
    func playBackgroundMusic(named fileName: String, loop: Bool = true) {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "mp3") else {
            print("⚠️ Background music file not found: \(fileName)")
            return
        }
        
        do {
            backgroundMusicPlayer = try AVAudioPlayer(contentsOf: url)
            backgroundMusicPlayer?.volume = volume * 0.3
            backgroundMusicPlayer?.numberOfLoops = loop ? -1 : 0
            backgroundMusicPlayer?.play()
            print("✅ Background music started: \(fileName)")
        } catch {
            print("❌ Background music failed: \(error.localizedDescription)")
        }
    }
    
    func stopBackgroundMusic() {
        backgroundMusicPlayer?.stop()
        backgroundMusicPlayer = nil
    }
    
    // MARK: - Voice Recording for Speaking Exercises
    func startRecording(to url: URL) -> Bool {
        do {
            let settings: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44100.0,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            
            voiceRecorder = try AVAudioRecorder(url: url, settings: settings)
            voiceRecorder?.delegate = self
            voiceRecorder?.isMeteringEnabled = true
            
            let success = voiceRecorder?.record() ?? false
            isRecording = success
            
            if success {
                print("✅ Voice recording started")
            }
            
            return success
        } catch {
            print("❌ Voice recording failed: \(error.localizedDescription)")
            return false
        }
    }
    
    func stopRecording() {
        voiceRecorder?.stop()
        voiceRecorder = nil
        isRecording = false
        print("✅ Voice recording stopped")
    }
    
    func getRecordingLevel() -> Float {
        guard let recorder = voiceRecorder, recorder.isRecording else { return 0 }
        recorder.updateMeters()
        return recorder.averagePower(forChannel: 0)
    }
    
    // MARK: - Playback Timer
    private func startPlaybackTimer() {
        stopPlaybackTimer()
        playbackTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.updatePlaybackTime()
        }
    }
    
    private func stopPlaybackTimer() {
        playbackTimer?.invalidate()
        playbackTimer = nil
    }
    
    private func updatePlaybackTime() {
        guard let player = audioPlayer else { return }
        currentPlaybackTime = player.currentTime
    }
    
    // MARK: - Text-to-Speech for Reading Assistance
    func speakText(_ text: String, language: String = "en-US", rate: Float = 0.4) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: language)
        utterance.rate = rate // Slower for children
        utterance.pitchMultiplier = 1.1 // Slightly higher pitch for friendliness
        utterance.volume = volume
        
        let synthesizer = AVSpeechSynthesizer()
        synthesizer.speak(utterance)
        
        print("🗣️ Speaking: \(text)")
    }
    
    // MARK: - Audio Analysis for Pronunciation
    func analyzePronunciation(recordedURL: URL, targetWord: String, completion: @escaping (Float) -> Void) {
        // This is a placeholder for pronunciation analysis
        // In a real app, you might use:
        // - Speech Recognition APIs
        // - Machine Learning models
        // - Third-party pronunciation analysis services
        
        DispatchQueue.global(qos: .userInitiated).async {
            // Simulate analysis delay
            Thread.sleep(forTimeInterval: 1.0)
            
            // Return mock score (0.0 to 1.0)
            let mockScore = Float.random(in: 0.6...1.0)
            
            DispatchQueue.main.async {
                completion(mockScore)
            }
        }
        
        print("🎙️ Analyzing pronunciation for: \(targetWord)")
    }
    
    // MARK: - Audio Settings Management
    func setVolume(_ newVolume: Float) {
        volume = max(0.0, min(1.0, newVolume))
    }
    
    func muteAll() {
        audioPlayer?.volume = 0
        backgroundMusicPlayer?.volume = 0
    }
    
    func unmuteAll() {
        audioPlayer?.volume = volume
        backgroundMusicPlayer?.volume = volume * 0.3
    }
}

// MARK: - AVAudioPlayerDelegate
extension AudioService: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if player == audioPlayer {
            isPlaying = false
            currentPlaybackTime = 0
            stopPlaybackTimer()
            print("✅ Audio playback finished")
        }
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        print("❌ Audio decode error: \(error?.localizedDescription ?? "Unknown")")
        isPlaying = false
        stopPlaybackTimer()
    }
}

// MARK: - AVAudioRecorderDelegate
extension AudioService: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        isRecording = false
        print("✅ Voice recording finished successfully: \(flag)")
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        print("❌ Voice recording error: \(error?.localizedDescription ?? "Unknown")")
        isRecording = false
    }
}

// MARK: - Audio Helper Extensions
extension AudioService {
    // Create audio cache directory
    func createAudioCacheDirectory() {
        let cacheURL = getCacheURL(for: "").deletingLastPathComponent()
        
        if !FileManager.default.fileExists(atPath: cacheURL.path) {
            do {
                try FileManager.default.createDirectory(at: cacheURL, withIntermediateDirectories: true)
                print("✅ Audio cache directory created")
            } catch {
                print("❌ Failed to create audio cache directory: \(error.localizedDescription)")
            }
        }
    }
    
    // Clear audio cache
    func clearAudioCache() {
        let cacheURL = getCacheURL(for: "").deletingLastPathComponent()
        
        do {
            let files = try FileManager.default.contentsOfDirectory(at: cacheURL, includingPropertiesForKeys: nil)
            for file in files {
                try FileManager.default.removeItem(at: file)
            }
            print("✅ Audio cache cleared")
        } catch {
            print("❌ Failed to clear audio cache: \(error.localizedDescription)")
        }
    }
    
    // Get cache size
    func getAudioCacheSize() -> Int64 {
        let cacheURL = getCacheURL(for: "").deletingLastPathComponent()
        
        guard let enumerator = FileManager.default.enumerator(at: cacheURL, includingPropertiesForKeys: [.fileSizeKey]) else {
            return 0
        }
        
        var totalSize: Int64 = 0
        
        for case let url as URL in enumerator {
            do {
                let resourceValues = try url.resourceValues(forKeys: [.fileSizeKey])
                totalSize += Int64(resourceValues.fileSize ?? 0)
            } catch {
                continue
            }
        }
        
        return totalSize
    }
}
