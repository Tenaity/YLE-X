//
//  SpeechRecognitionService.swift
//  YLE X
//
//  Created on November 7, 2025.
//  Phase 4: Speech Recognition with Apple Speech Framework
//

import Foundation
import Speech
import AVFoundation
import Combine

@MainActor
class SpeechRecognitionService: NSObject, ObservableObject {
    static let shared = SpeechRecognitionService()

    // Published properties
    @Published var recognizedText = ""
    @Published var isRecording = false
    @Published var authorizationStatus: SFSpeechRecognizerAuthorizationStatus = .notDetermined
    @Published var errorMessage: String?

    // Speech recognition
    private let speechRecognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()

    override init() {
        // Initialize with US English
        self.speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
        super.init()
        self.speechRecognizer?.delegate = self
    }

    // MARK: - Authorization

    func requestAuthorization() async -> Bool {
        await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                Task { @MainActor in
                    self.authorizationStatus = status
                    continuation.resume(returning: status == .authorized)
                }
            }
        }
    }

    // MARK: - Recording

    func startRecording() throws {
        // Cancel previous task if any
        recognitionTask?.cancel()
        recognitionTask = nil
        recognizedText = ""
        errorMessage = nil

        // Configure audio session
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)

        // Create recognition request
        let inputNode = audioEngine.inputNode
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()

        guard let recognitionRequest = recognitionRequest else {
            throw SpeechRecognitionError.failedToCreateRequest
        }

        recognitionRequest.shouldReportPartialResults = true

        // If the device has on-device recognition, use it
        if #available(iOS 13, *) {
            recognitionRequest.requiresOnDeviceRecognition = false
        }

        // Create recognition task
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self = self else { return }

            Task { @MainActor in
                if let result = result {
                    self.recognizedText = result.bestTranscription.formattedString
                }

                if error != nil || result?.isFinal == true {
                    self.stopRecording()
                }
            }
        }

        // Configure microphone input
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            recognitionRequest.append(buffer)
        }

        // Start audio engine
        audioEngine.prepare()
        try audioEngine.start()

        isRecording = true
    }

    func stopRecording() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)

        recognitionRequest?.endAudio()
        recognitionRequest = nil

        recognitionTask?.cancel()
        recognitionTask = nil

        isRecording = false
    }

    // MARK: - Pronunciation Analysis

    func analyzePronunciation(expected: String, actual: String) -> PronunciationScore {
        let expectedWords = expected.lowercased()
            .components(separatedBy: CharacterSet.punctuationCharacters)
            .joined()
            .components(separatedBy: .whitespaces)
            .filter { !$0.isEmpty }

        let actualWords = actual.lowercased()
            .components(separatedBy: CharacterSet.punctuationCharacters)
            .joined()
            .components(separatedBy: .whitespaces)
            .filter { !$0.isEmpty }

        var wordScores: [WordScore] = []
        var correctCount = 0
        var totalWords = expectedWords.count

        // Compare word by word
        for (index, expectedWord) in expectedWords.enumerated() {
            if index < actualWords.count {
                let actualWord = actualWords[index]
                let similarity = calculateSimilarity(expectedWord, actualWord)

                let status: WordStatus
                let accuracy: Double

                if similarity >= 0.9 {
                    status = .correct
                    accuracy = 100
                    correctCount += 1
                } else if similarity >= 0.6 {
                    status = .mispronounced
                    accuracy = similarity * 100
                } else {
                    status = .mispronounced
                    accuracy = similarity * 100
                }

                wordScores.append(WordScore(
                    word: actualWord,
                    expected: expectedWord,
                    accuracy: accuracy,
                    status: status,
                    suggestion: status == .mispronounced ? "Try: \(expectedWord)" : nil
                ))
            } else {
                // Word was omitted
                wordScores.append(WordScore(
                    word: "",
                    expected: expectedWord,
                    accuracy: 0,
                    status: .omitted,
                    suggestion: "Remember to say: \(expectedWord)"
                ))
            }
        }

        // Check for inserted words
        if actualWords.count > expectedWords.count {
            for index in expectedWords.count..<actualWords.count {
                wordScores.append(WordScore(
                    word: actualWords[index],
                    expected: "",
                    accuracy: 0,
                    status: .inserted,
                    suggestion: "Extra word detected"
                ))
            }
        }

        // Calculate scores
        let accuracyScore = totalWords > 0 ? (Double(correctCount) / Double(totalWords)) * 100 : 0
        let completenessScore = totalWords > 0 ? (Double(min(actualWords.count, totalWords)) / Double(totalWords)) * 100 : 0
        let fluencyScore = calculateFluency(wordScores: wordScores)

        let overallScore = (accuracyScore * 0.4 + fluencyScore * 0.3 + completenessScore * 0.3)

        // Generate feedback
        var feedback: [String] = []
        if accuracyScore < 70 {
            feedback.append("Practice pronunciation of individual words")
        }
        if completenessScore < 80 {
            feedback.append("Try to speak all the words clearly")
        }
        if fluencyScore < 70 {
            feedback.append("Work on speaking more smoothly and naturally")
        }
        if feedback.isEmpty {
            feedback.append("Great job! Keep practicing to improve even more")
        }

        return PronunciationScore(
            overallScore: overallScore,
            accuracy: accuracyScore,
            fluency: fluencyScore,
            completeness: completenessScore,
            wordScores: wordScores,
            feedback: feedback
        )
    }

    // MARK: - Helper Functions

    private func calculateSimilarity(_ str1: String, _ str2: String) -> Double {
        // Levenshtein distance for word similarity
        let distance = levenshteinDistance(str1, str2)
        let maxLength = max(str1.count, str2.count)

        guard maxLength > 0 else { return 1.0 }

        return 1.0 - (Double(distance) / Double(maxLength))
    }

    private func levenshteinDistance(_ str1: String, _ str2: String) -> Int {
        let m = str1.count
        let n = str2.count

        var matrix = Array(repeating: Array(repeating: 0, count: n + 1), count: m + 1)

        for i in 0...m {
            matrix[i][0] = i
        }

        for j in 0...n {
            matrix[0][j] = j
        }

        for i in 1...m {
            for j in 1...n {
                let cost = str1[str1.index(str1.startIndex, offsetBy: i - 1)] ==
                           str2[str2.index(str2.startIndex, offsetBy: j - 1)] ? 0 : 1

                matrix[i][j] = min(
                    matrix[i - 1][j] + 1,       // deletion
                    matrix[i][j - 1] + 1,       // insertion
                    matrix[i - 1][j - 1] + cost // substitution
                )
            }
        }

        return matrix[m][n]
    }

    private func calculateFluency(wordScores: [WordScore]) -> Double {
        // Simple fluency metric based on accuracy distribution
        let correctWords = wordScores.filter { $0.status == .correct }.count
        let totalWords = wordScores.count

        guard totalWords > 0 else { return 0 }

        // Penalize for omissions and insertions more heavily
        let omissions = wordScores.filter { $0.status == .omitted }.count
        let insertions = wordScores.filter { $0.status == .inserted }.count

        let penalty = Double(omissions + insertions) * 10
        let baseScore = (Double(correctWords) / Double(totalWords)) * 100

        return max(0, baseScore - penalty)
    }

    // MARK: - Cleanup

    deinit {
        if audioEngine.isRunning {
            audioEngine.stop()
        }
    }
}

// MARK: - Speech Recognizer Delegate

extension SpeechRecognitionService: SFSpeechRecognizerDelegate {
    nonisolated func speechRecognizer(
        _ speechRecognizer: SFSpeechRecognizer,
        availabilityDidChange available: Bool
    ) {
        Task { @MainActor in
            if !available {
                self.errorMessage = "Speech recognition is not available"
            }
        }
    }
}

// MARK: - Errors

enum SpeechRecognitionError: LocalizedError {
    case failedToCreateRequest
    case notAuthorized
    case recognizerNotAvailable

    var errorDescription: String? {
        switch self {
        case .failedToCreateRequest:
            return "Failed to create speech recognition request"
        case .notAuthorized:
            return "Speech recognition not authorized. Please enable in Settings."
        case .recognizerNotAvailable:
            return "Speech recognizer is not available"
        }
    }
}
