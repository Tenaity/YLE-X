//
//  SoundManager.swift
//  YLE X
//
//  Created by Senior iOS Developer on 6/11/25.
//

import Foundation
import AVFoundation
import Combine

// MARK: - Sound Manager
class SoundManager: ObservableObject {
    static let shared = SoundManager()
    
    private var audioPlayers: [String: AVAudioPlayer] = [:]
    private var backgroundMusicPlayer: AVAudioPlayer?
    
    @Published var isSoundEnabled: Bool = true
    @Published var isMusicEnabled: Bool = true
    
    private init() {
        setupAudioSession()
    }
    
    // MARK: - Sound Effects Enum
    enum SoundEffect: String, CaseIterable {
        // Success and achievement sounds
        case success = "success"
        case celebration = "celebration"
        case levelComplete = "level_complete"
        case correctAnswer = "correct_answer"
        case starCollected = "star_collected"
        case badgeEarned = "badge_earned"
        
        // Interaction sounds
        case buttonTap = "button_tap"
        case cardFlip = "card_flip"
        case popup = "popup"
        case swipeNext = "swipe_next"
        case slideTransition = "slide_transition"
        
        // Feedback sounds
        case wrongAnswer = "wrong_answer" // Alias for incorrectAnswer
        case incorrectAnswer = "incorrect_answer"
        case tryAgain = "try_again"
        case hint = "hint"
        case tick = "tick"
        
        // Character and fun sounds
        case characterGreeting = "character_greeting"
        case characterCelebration = "character_celebration"
        case magicSparkle = "magic_sparkle"
        case bouncy = "bouncy"
        case playful = "playful"
        
        // Educational sounds
        case vocabularyIntro = "vocabulary_intro"
        case lessonStart = "lesson_start"
        case exerciseComplete = "exercise_complete"
        case recordingStart = "recording_start"
        case recordingStop = "recording_stop"
        
        var description: String {
            switch self {
            case .success:
                return "General success sound"
            case .celebration:
                return "Celebration sound"
            case .levelComplete:
                return "Level completion celebration"
            case .correctAnswer:
                return "Correct answer feedback"
            case .starCollected:
                return "Star collection sound"
            case .badgeEarned:
                return "Badge earned celebration"
            case .buttonTap:
                return "Button tap feedback"
            case .cardFlip:
                return "Card flip sound"
            case .popup:
                return "Popup appearance"
            case .swipeNext:
                return "Swipe to next sound"
            case .slideTransition:
                return "Slide transition"
            case .incorrectAnswer:
                return "Incorrect answer feedback"
            case .tryAgain:
                return "Try again encouragement"
            case .hint:
                return "Hint sound"
            case .tick:
                return "Tick sound"
            case .characterGreeting:
                return "Character greeting"
            case .characterCelebration:
                return "Character celebration"
            case .magicSparkle:
                return "Magic sparkle effect"
            case .bouncy:
                return "Bouncy interaction"
            case .playful:
                return "Playful interaction"
            case .vocabularyIntro:
                return "Vocabulary introduction"
            case .lessonStart:
                return "Lesson start sound"
            case .exerciseComplete:
                return "Exercise completion"
            case .recordingStart:
                return "Recording start"
            case .recordingStop:
                return "Recording stop"
            case .wrongAnswer:
                return "Incorrect answer feedback"
            }
        }
    }
    
    // MARK: - Background Music
    enum BackgroundMusic: String, CaseIterable {
        case mainMenu = "main_menu_music"
        case learning = "learning_music"
        case exercise = "exercise_music"
        case celebration = "celebration_music"
        case calm = "calm_music"
        case playful = "playful_music"
        
        var description: String {
            switch self {
            case .mainMenu:
                return "Main menu background music"
            case .learning:
                return "Learning session music"
            case .exercise:
                return "Exercise background music"
            case .celebration:
                return "Celebration music"
            case .calm:
                return "Calm background music"
            case .playful:
                return "Playful background music"
            }
        }
    }
}

// MARK: - Sound Configuration
extension SoundManager {
    static let defaultVolume: Float = 0.7
    static let backgroundMusicVolume: Float = 0.3
    static let voiceVolume: Float = 1.0
    
    static let audioFileExtension = "mp3"
    static let audioFormat = kAudioFormatMPEG4AAC
    static let audioSampleRate: Double = 44100.0
    static let audioChannels = 1
    
    // MARK: - Audio Session Setup
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Audio session setup error: \(error)")
        }
    }
    
    // MARK: - Sound Playing Methods
    func playSound(_ effect: SoundEffect) {
        guard isSoundEnabled else { return }
        
        let soundName = effect.rawValue
        
        guard let url = Bundle.main.url(forResource: soundName, withExtension: Self.audioFileExtension) else {
            print("Sound file not found: \(soundName)")
            return
        }
        
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.volume = Self.defaultVolume
            audioPlayers[soundName] = player
            player.play()
        } catch {
            print("Error playing sound: \(error)")
        }
    }
    
    func playBackgroundMusic(_ music: BackgroundMusic) {
        guard isMusicEnabled else { return }
        
        let musicName = music.rawValue
        
        guard let url = Bundle.main.url(forResource: musicName, withExtension: Self.audioFileExtension) else {
            print("Music file not found: \(musicName)")
            return
        }
        
        do {
            backgroundMusicPlayer = try AVAudioPlayer(contentsOf: url)
            backgroundMusicPlayer?.volume = Self.backgroundMusicVolume
            backgroundMusicPlayer?.numberOfLoops = -1
            backgroundMusicPlayer?.play()
        } catch {
            print("Error playing background music: \(error)")
        }
    }
    
    func stopBackgroundMusic() {
        backgroundMusicPlayer?.stop()
        backgroundMusicPlayer = nil
    }
}
