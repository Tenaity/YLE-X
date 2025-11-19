//
//  AudioPlayerService.swift
//  YLE X
//
//  Created on 11/18/25.
//  3-Tier Audio Strategy: Cambridge → Legacy → TTS
//

import Foundation
import AVFoundation
import Combine

// MARK: - Audio Accent

enum AudioAccent: String, CaseIterable {
    case british = "british"
    case american = "american"

    var displayName: String {
        switch self {
        case .british: return "British"
        case .american: return "American"
        }
    }

    var flag: String {
        switch self {
        case .british: return "🇬🇧"
        case .american: return "🇺🇸"
        }
    }

    var languageCode: String {
        switch self {
        case .british: return "en-GB"
        case .american: return "en-US"
        }
    }
}

// MARK: - Audio Player Service

@MainActor
class AudioPlayerService: NSObject, ObservableObject {
    // MARK: - Published Properties

    @Published var isPlaying = false
    @Published var currentAccent: AudioAccent = .british
    @Published var error: AudioError?
    @Published var audioSource: AudioSource = .none

    // MARK: - Private Properties

    private var audioPlayer: AVAudioPlayer?
    private let speechSynthesizer = AVSpeechSynthesizer()
    private var currentWord: String?

    // MARK: - Audio Source

    enum AudioSource: String {
        case cambridge = "Cambridge"
        case legacy = "Legacy"
        case tts = "Text-to-Speech"
        case none = "None"

        var displayName: String { rawValue }
    }

    // MARK: - Audio Error

    enum AudioError: LocalizedError {
        case downloadFailed
        case playbackFailed
        case invalidURL

        var errorDescription: String? {
            switch self {
            case .downloadFailed:
                return "Failed to download audio"
            case .playbackFailed:
                return "Failed to play audio"
            case .invalidURL:
                return "Invalid audio URL"
            }
        }
    }

    // MARK: - Initialization

    override init() {
        super.init()
        setupAudioSession()
        speechSynthesizer.delegate = self
    }

    // MARK: - Audio Session Setup

    private func setupAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [])
            try session.setActive(true)
        } catch {
            print("❌ Failed to setup audio session: \(error)")
        }
    }

    // MARK: - Main Play Method (3-Tier Strategy)

    func playAudio(for word: DictionaryWord, accent: AudioAccent) {
        currentWord = word.word
        currentAccent = accent
        error = nil

        let pronunciationData = accent == .british
            ? word.pronunciation.british
            : word.pronunciation.american

        // Tier 1: Cambridge Audio (Priority)
        if pronunciationData.hasAudio && pronunciationData.audioSource.lowercased().contains("cambridge") {
            playFromURL(
                pronunciationData.audioUrl,
                source: .cambridge
            )
            return
        }

        // Tier 2: Legacy Audio (Fallback)
        if pronunciationData.hasAudio {
            playFromURL(
                pronunciationData.audioUrl,
                source: .legacy
            )
            return
        }

        // Tier 3: TTS (Final Fallback - Always Works!)
        playTTS(
            text: word.word,
            accent: accent
        )
    }

    // MARK: - Tier 1 & 2: URL-based Audio

    private func playFromURL(_ urlString: String, source: AudioSource) {
        guard let url = URL(string: urlString) else {
            error = .invalidURL
            // Fallback to TTS
            if let word = currentWord {
                playTTS(text: word, accent: currentAccent)
            }
            return
        }

        isPlaying = true
        audioSource = source

        Task {
            do {
                // Download audio data
                let (data, _) = try await URLSession.shared.data(from: url)

                // Create audio player
                audioPlayer = try AVAudioPlayer(data: data)
                audioPlayer?.delegate = self
                audioPlayer?.prepareToPlay()
                audioPlayer?.play()

            } catch {
                print("❌ Audio download/play failed: \(error)")
                self.error = .downloadFailed
                isPlaying = false

                // Fallback to TTS
                if let word = currentWord {
                    playTTS(text: word, accent: currentAccent)
                }
            }
        }
    }

    // MARK: - Tier 3: Text-to-Speech (Always Works)

    private func playTTS(text: String, accent: AudioAccent) {
        // Stop any current playback
        stop()

        isPlaying = true
        audioSource = .tts

        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: accent.languageCode)
        utterance.rate = 0.45 // Slower for learning (0.0 - 1.0)
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0

        speechSynthesizer.speak(utterance)
    }

    // MARK: - Playback Control

    func stop() {
        // Stop URL-based audio
        audioPlayer?.stop()
        audioPlayer = nil

        // Stop TTS
        if speechSynthesizer.isSpeaking {
            speechSynthesizer.stopSpeaking(at: .immediate)
        }

        isPlaying = false
    }

    func toggleAccent() {
        currentAccent = currentAccent == .british ? .american : .british
    }

    // MARK: - Preview Audio (Quick Test)

    func previewWord(_ word: String, accent: AudioAccent = .british) {
        playTTS(text: word, accent: accent)
    }
}

// MARK: - AVAudioPlayerDelegate

extension AudioPlayerService: AVAudioPlayerDelegate {
    nonisolated func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        Task { @MainActor in
            isPlaying = false

            if !flag {
                error = .playbackFailed
            }
        }
    }

    nonisolated func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        Task { @MainActor in
            isPlaying = false
            self.error = .playbackFailed
            print("❌ Audio decode error: \(error?.localizedDescription ?? "Unknown")")
        }
    }
}

// MARK: - AVSpeechSynthesizerDelegate

extension AudioPlayerService: AVSpeechSynthesizerDelegate {
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        Task { @MainActor in
            isPlaying = false
        }
    }

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        Task { @MainActor in
            isPlaying = false
        }
    }
}

// MARK: - Preview Helpers

#if DEBUG
extension AudioPlayerService {
    static let preview: AudioPlayerService = {
        let service = AudioPlayerService()
        return service
    }()
}
#endif
