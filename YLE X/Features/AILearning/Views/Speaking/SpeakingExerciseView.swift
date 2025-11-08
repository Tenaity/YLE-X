//
//  SpeakingExerciseView.swift
//  YLE X
//
//  Created on November 7, 2025.
//  Phase 4: Speaking Practice Interface
//

import SwiftUI
import AVFoundation

struct SpeakingExerciseView: View {
    let exercise: SpeakingExercise

    @StateObject private var speechService = SpeechRecognitionService.shared
    @StateObject private var audioRecorder = AudioRecorder()

    @State private var currentAttempt = 0
    @State private var showFeedback = false
    @State private var pronunciationScore: PronunciationScore?
    @State private var isPlayingExample = false
    @State private var showPermissionAlert = false

    private let synthesizer = AVSpeechSynthesizer()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppSpacing.lg) {
                    // Exercise Header
                    exerciseHeader

                    // Target Text Display
                    targetTextSection

                    // IPA Display
                    ipaSection

                    // Example Audio Button
                    exampleAudioButton

                    // Waveform Visualizer
                    if speechService.isRecording || audioRecorder.isRecording {
                        waveformSection
                    }

                    // Recording Controls
                    recordingControls

                    // Status Display
                    statusDisplay

                    // Tips Section
                    if !exercise.tips.isEmpty && currentAttempt == 0 {
                        tipsSection
                    }
                }
                .padding(AppSpacing.lg)
            }
            .background(Color.appBackground.ignoresSafeArea())
            .navigationTitle("Speaking Practice")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                await requestPermissions()
            }
            .sheet(isPresented: $showFeedback) {
                if let score = pronunciationScore {
                    SpeakingFeedbackView(
                        score: score,
                        targetText: exercise.targetText,
                        onTryAgain: {
                            showFeedback = false
                            pronunciationScore = nil
                        },
                        onNext: {
                            // Navigate to next exercise
                            showFeedback = false
                        }
                    )
                }
            }
            .alert("Permission Required", isPresented: $showPermissionAlert) {
                Button("Open Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Please enable microphone and speech recognition permissions in Settings to use this feature.")
            }
        }
    }

    // MARK: - Exercise Header

    private var exerciseHeader: some View {
        VStack(spacing: AppSpacing.sm) {
            HStack {
                Image(systemName: exercise.type.icon)
                    .font(.title2)
                    .foregroundColor(exercise.difficulty.color)

                Text(exercise.type.rawValue)
                    .font(.headline)
                    .foregroundColor(.appText)

                Spacer()

                // Difficulty badge
                Text(exercise.difficulty.rawValue)
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, AppSpacing.sm)
                    .padding(.vertical, AppSpacing.xs)
                    .background(exercise.difficulty.color)
                    .cornerRadius(AppRadius.sm)
            }

            HStack {
                Text("Attempt \(currentAttempt)/\(exercise.maxAttempts)")
                    .font(.subheadline)
                    .foregroundColor(.appTextSecondary)

                Spacer()

                ForEach(0..<exercise.maxAttempts, id: \.self) { index in
                    Circle()
                        .fill(index < currentAttempt ? Color.appPrimary : Color.appTextSecondary.opacity(0.3))
                        .frame(width: 8, height: 8)
                }
            }
        }
        .padding(AppSpacing.md)
        .background(Color.appBackgroundSecondary)
        .cornerRadius(AppRadius.lg)
    }

    // MARK: - Target Text

    private var targetTextSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("Say this:")
                .font(.caption)
                .foregroundColor(.appTextSecondary)
                .textCase(.uppercase)

            Text(exercise.targetText)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.appText)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding(AppSpacing.lg)
                .background(
                    RoundedRectangle(cornerRadius: AppRadius.lg)
                        .fill(Color.appPrimary.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: AppRadius.lg)
                                .stroke(Color.appPrimary.opacity(0.3), lineWidth: 2)
                        )
                )
        }
    }

    // MARK: - IPA Section

    private var ipaSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text("Pronunciation:")
                .font(.caption)
                .foregroundColor(.appTextSecondary)
                .textCase(.uppercase)

            Text(exercise.ipaText)
                .font(.body)
                .foregroundColor(.appAccent)
                .frame(maxWidth: .infinity)
        }
        .padding(AppSpacing.md)
        .background(Color.appBackgroundSecondary)
        .cornerRadius(AppRadius.md)
    }

    // MARK: - Example Audio

    private var exampleAudioButton: some View {
        Button {
            playExample()
        } label: {
            HStack {
                Image(systemName: isPlayingExample ? "speaker.wave.3.fill" : "speaker.wave.2.fill")
                Text("Play Example")
            }
            .font(.subheadline.weight(.semibold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppSpacing.sm)
            .background(Color.appSecondary)
            .cornerRadius(AppRadius.md)
        }
        .disabled(speechService.isRecording)
    }

    // MARK: - Waveform

    private var waveformSection: some View {
        VStack(spacing: AppSpacing.xs) {
            Text("Listening...")
                .font(.caption)
                .foregroundColor(.appTextSecondary)

            BarWaveformView(
                samples: audioRecorder.waveformSamples,
                color: .appPrimary
            )
            .padding(.horizontal, AppSpacing.md)
        }
        .padding(AppSpacing.md)
        .background(Color.appBackgroundSecondary)
        .cornerRadius(AppRadius.lg)
    }

    // MARK: - Recording Controls

    private var recordingControls: some View {
        VStack(spacing: AppSpacing.md) {
            if speechService.isRecording {
                // Recording in progress
                VStack(spacing: AppSpacing.sm) {
                    ZStack {
                        Circle()
                            .stroke(Color.appError.opacity(0.3), lineWidth: 4)
                            .frame(width: 100, height: 100)

                        Circle()
                            .fill(Color.appError)
                            .frame(width: 80, height: 80)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(.white)
                                    .frame(width: 24, height: 24)
                            )
                    }
                    .onTapGesture {
                        stopRecordingAndAnalyze()
                    }

                    Text("Tap to Stop")
                        .font(.subheadline)
                        .foregroundColor(.appTextSecondary)

                    Text(String(format: "%.1fs", audioRecorder.recordingDuration))
                        .font(.caption.monospacedDigit())
                        .foregroundColor(.appTextSecondary)
                }
            } else {
                // Ready to record
                Button {
                    startRecording()
                } label: {
                    VStack(spacing: AppSpacing.sm) {
                        ZStack {
                            Circle()
                                .stroke(Color.appPrimary.opacity(0.3), lineWidth: 4)
                                .frame(width: 100, height: 100)

                            Circle()
                                .fill(Color.appPrimary)
                                .frame(width: 80, height: 80)
                                .overlay(
                                    Image(systemName: "mic.fill")
                                        .font(.system(size: 32))
                                        .foregroundColor(.white)
                                )
                        }

                        Text("Hold to Record")
                            .font(.headline)
                            .foregroundColor(.appPrimary)
                    }
                }
                .disabled(currentAttempt >= exercise.maxAttempts)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppSpacing.lg)
    }

    // MARK: - Status Display

    private var statusDisplay: some View {
        Group {
            if let error = speechService.errorMessage ?? audioRecorder.errorMessage {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                    Text(error)
                        .font(.caption)
                }
                .foregroundColor(.appError)
                .padding(AppSpacing.sm)
                .background(Color.appError.opacity(0.1))
                .cornerRadius(AppRadius.sm)
            }

            if !speechService.recognizedText.isEmpty && !speechService.isRecording {
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text("You said:")
                        .font(.caption)
                        .foregroundColor(.appTextSecondary)

                    Text(speechService.recognizedText)
                        .font(.body)
                        .foregroundColor(.appText)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(AppSpacing.md)
                .background(Color.appBackgroundSecondary)
                .cornerRadius(AppRadius.md)
            }
        }
    }

    // MARK: - Tips

    private var tipsSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack {
                Image(systemName: "lightbulb.fill")
                Text("Tips")
                    .font(.headline)
            }
            .foregroundColor(.appAccent)

            ForEach(Array(exercise.tips.enumerated()), id: \.offset) { _, tip in
                HStack(alignment: .top, spacing: AppSpacing.xs) {
                    Text("•")
                    Text(tip)
                        .font(.subheadline)
                }
                .foregroundColor(.appTextSecondary)
            }
        }
        .padding(AppSpacing.md)
        .background(Color.appAccent.opacity(0.1))
        .cornerRadius(AppRadius.lg)
    }

    // MARK: - Functions

    private func requestPermissions() async {
        let speechAuthorized = await speechService.requestAuthorization()

        if !speechAuthorized {
            showPermissionAlert = true
        }
    }

    private func startRecording() {
        do {
            try speechService.startRecording()
            try audioRecorder.startRecording()
            HapticManager.shared.playMedium()
        } catch {
            speechService.errorMessage = error.localizedDescription
        }
    }

    private func stopRecordingAndAnalyze() {
        speechService.stopRecording()
        _ = audioRecorder.stopRecording()

        HapticManager.shared.playLight()

        // Analyze pronunciation using AI Learning
        let score = AILearningService.shared.analyzePronunciation(
            expected: exercise.targetText,
            actual: speechService.recognizedText
        )
        pronunciationScore = score
        currentAttempt += 1

        // Show feedback after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            showFeedback = true
            HapticManager.shared.playSuccess()
        }
    }

    private func playExample() {
        let utterance = AVSpeechUtterance(string: exercise.targetText)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.4 // Slower for learning

        isPlayingExample = true
        synthesizer.speak(utterance)

        // Reset flag after estimated duration
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            isPlayingExample = false
        }
    }
}

// MARK: - Preview

#Preview {
    SpeakingExerciseView(exercise: SpeakingExercise.sample())
}
