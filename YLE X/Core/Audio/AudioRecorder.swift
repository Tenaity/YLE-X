//
//  AudioRecorder.swift
//  YLE X
//
//  Created on November 7, 2025.
//  Phase 4: Audio Recording with AVFoundation
//

import Foundation
import AVFoundation
import Combine

@MainActor
class AudioRecorder: NSObject, ObservableObject {
    // Published properties
    @Published var isRecording = false
    @Published var recordingDuration: TimeInterval = 0
    @Published var currentPower: Float = 0  // For waveform visualization
    @Published var errorMessage: String?

    // Audio recorder
    private var audioRecorder: AVAudioRecorder?
    private var audioPlayer: AVAudioPlayer?
    private var recordingTimer: Timer?
    private var meteringTimer: Timer?

    // Recording URL
    private var recordingURL: URL?

    // Waveform samples
    private(set) var waveformSamples: [Float] = []
    private let maxSamples = 100

    // MARK: - Recording

    func startRecording(filename: String = UUID().uuidString) throws {
        // Stop any existing recording
        _ = stopRecording()

        // Configure audio session
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
        try audioSession.setActive(true)

        // Create recording URL
        let documentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        recordingURL = documentPath.appendingPathComponent("\(filename).m4a")

        guard let url = recordingURL else {
            throw AudioRecorderError.invalidURL
        }

        // Configure recording settings
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        // Create recorder
        audioRecorder = try AVAudioRecorder(url: url, settings: settings)
        audioRecorder?.delegate = self
        audioRecorder?.isMeteringEnabled = true
        audioRecorder?.prepareToRecord()

        // Start recording
        guard audioRecorder?.record() == true else {
            throw AudioRecorderError.failedToStartRecording
        }

        isRecording = true
        recordingDuration = 0
        waveformSamples = []

        // Start duration timer
        recordingTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            Task { @MainActor in
                self.recordingDuration += 0.1
            }
        }

        // Start metering timer for waveform
        meteringTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            Task { @MainActor in
                self.updateMetering()
            }
        }
    }

    func stopRecording() -> AudioRecording? {
        audioRecorder?.stop()
        recordingTimer?.invalidate()
        meteringTimer?.invalidate()

        recordingTimer = nil
        meteringTimer = nil
        isRecording = false

        guard let url = recordingURL else { return nil }

        let recording = AudioRecording(
            url: url,
            duration: recordingDuration,
            timestamp: Date(),
            waveformSamples: waveformSamples
        )

        recordingDuration = 0
        currentPower = 0

        return recording
    }

    // MARK: - Playback

    func playRecording(url: URL) throws {
        // Stop any existing playback
        stopPlayback()

        // Create player
        audioPlayer = try AVAudioPlayer(contentsOf: url)
        audioPlayer?.prepareToPlay()
        audioPlayer?.play()
    }

    func stopPlayback() {
        audioPlayer?.stop()
        audioPlayer = nil
    }

    // MARK: - File Management

    func deleteRecording(url: URL) throws {
        try FileManager.default.removeItem(at: url)
    }

    func getAllRecordings() -> [AudioRecording] {
        let documentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]

        guard let files = try? FileManager.default.contentsOfDirectory(
            at: documentPath,
            includingPropertiesForKeys: [.creationDateKey],
            options: [.skipsHiddenFiles]
        ) else {
            return []
        }

        return files
            .filter { $0.pathExtension == "m4a" }
            .compactMap { url in
                guard let attributes = try? FileManager.default.attributesOfItem(atPath: url.path),
                      let creationDate = attributes[.creationDate] as? Date else {
                    return nil
                }

                return AudioRecording(
                    url: url,
                    duration: 0, // Would need to load audio file to get actual duration
                    timestamp: creationDate,
                    waveformSamples: []
                )
            }
            .sorted { $0.timestamp > $1.timestamp }
    }

    // MARK: - Metering

    private func updateMetering() {
        guard let recorder = audioRecorder else { return }

        recorder.updateMeters()

        // Get average power for channel 0
        let power = recorder.averagePower(forChannel: 0)

        // Normalize power (-160 to 0) to (0 to 1)
        let normalizedPower = max(0, min(1, 1 - abs(power) / 160))

        currentPower = normalizedPower

        // Add to waveform samples
        if waveformSamples.count >= maxSamples {
            waveformSamples.removeFirst()
        }
        waveformSamples.append(normalizedPower)
    }

    // MARK: - Cleanup

    deinit {
        // Manual cleanup without calling @MainActor methods
        audioRecorder?.stop()
        recordingTimer?.invalidate()
        meteringTimer?.invalidate()
        audioPlayer?.stop()
    }
}

// MARK: - Audio Recorder Delegate

extension AudioRecorder: AVAudioRecorderDelegate {
    nonisolated func audioRecorderDidFinishRecording(
        _ recorder: AVAudioRecorder,
        successfully flag: Bool
    ) {
        Task { @MainActor in
            if !flag {
                self.errorMessage = "Recording failed"
            }
        }
    }

    nonisolated func audioRecorderEncodeErrorDidOccur(
        _ recorder: AVAudioRecorder,
        error: Error?
    ) {
        Task { @MainActor in
            self.errorMessage = error?.localizedDescription ?? "Unknown recording error"
        }
    }
}

// MARK: - Errors

enum AudioRecorderError: LocalizedError {
    case invalidURL
    case failedToStartRecording
    case permissionDenied

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid recording URL"
        case .failedToStartRecording:
            return "Failed to start recording"
        case .permissionDenied:
            return "Microphone permission denied. Please enable in Settings."
        }
    }
}
