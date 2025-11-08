//
//  IPALearningView.swift
//  YLE X
//
//  Created by Senior iOS Developer on 11/8/25.
//  Phase 5A: Interactive IPA Chart for Learning English Phonemes
//

import SwiftUI
import AVFoundation

struct IPALearningView: View {
    @State private var selectedPhoneme: IPAPhoneme?
    @State private var selectedCategory: PhonemeCategory = .vowels
    @State private var isPlayingAudio = false
    @State private var showPracticeSheet = false

    private let synthesizer = AVSpeechSynthesizer()

    var body: some View {
        ScrollView {
            VStack(spacing: AppSpacing.lg) {
                // Header
                ipaHeader

                // Category Selector
                categorySelector

                // Phoneme Grid
                phonemeGrid

                // Selected Phoneme Detail
                if let phoneme = selectedPhoneme {
                    phonemeDetailCard(phoneme)
                }
            }
            .padding(AppSpacing.lg)
        }
        .background(Color.appBackground.ignoresSafeArea())
        .navigationTitle("Learn IPA")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showPracticeSheet) {
            if let phoneme = selectedPhoneme {
                practicePronunciationSheet(phoneme)
            }
        }
    }

    // MARK: - IPA Header
    private var ipaHeader: some View {
        VStack(spacing: AppSpacing.md) {
            Text("🎤")
                .font(.system(size: 48))

            Text("International Phonetic Alphabet")
                .font(.title2.weight(.bold))
                .multilineTextAlignment(.center)

            Text("Learn the 44 sounds of English. Tap any phoneme to hear it!")
                .font(.subheadline)
                .foregroundColor(.appTextSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(AppSpacing.lg)
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.appPrimary.opacity(0.1),
                    Color.appAccent.opacity(0.05)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(AppRadius.lg)
    }

    // MARK: - Category Selector
    private var categorySelector: some View {
        HStack(spacing: AppSpacing.sm) {
            ForEach(PhonemeCategory.allCases, id: \.self) { category in
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        selectedCategory = category
                        selectedPhoneme = nil
                    }
                }) {
                    VStack(spacing: AppSpacing.xs) {
                        Text(category.emoji)
                            .font(.title2)

                        Text(category.rawValue)
                            .font(.caption.weight(.semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppSpacing.md)
                    .background(
                        selectedCategory == category ?
                        LinearGradient(
                            gradient: Gradient(colors: [Color.appPrimary, Color.appSecondary]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ) :
                        LinearGradient(
                            gradient: Gradient(colors: [Color.appSecondary.opacity(0.1), Color.appSecondary.opacity(0.05)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .foregroundColor(selectedCategory == category ? .white : .appText)
                    .cornerRadius(AppRadius.md)
                }
            }
        }
    }

    // MARK: - Phoneme Grid
    private var phonemeGrid: some View {
        let phonemes = IPAPhoneme.allPhonemes.filter { $0.category == selectedCategory }
        let columns = [
            GridItem(.adaptive(minimum: 80, maximum: 100), spacing: AppSpacing.md)
        ]

        return LazyVGrid(columns: columns, spacing: AppSpacing.md) {
            ForEach(phonemes) { phoneme in
                PhonemeCardView(
                    phoneme: phoneme,
                    isSelected: selectedPhoneme?.id == phoneme.id,
                    isPlayingAudio: isPlayingAudio && selectedPhoneme?.id == phoneme.id,
                    onTap: {
                        selectedPhoneme = phoneme
                        playPhonemeSound(phoneme)
                    }
                )
            }
        }
    }

    // MARK: - Phoneme Detail Card
    private func phonemeDetailCard(_ phoneme: IPAPhoneme) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text(phoneme.symbol)
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.appPrimary)

                    Text(phoneme.name)
                        .font(.headline.weight(.semibold))
                }

                Spacer()

                // Play button
                Button(action: {
                    playPhonemeSound(phoneme)
                }) {
                    ZStack {
                        Circle()
                            .fill(Color.appPrimary)
                            .frame(width: 56, height: 56)

                        Image(systemName: isPlayingAudio ? "speaker.wave.3.fill" : "speaker.wave.2.fill")
                            .font(.title3)
                            .foregroundColor(.white)
                    }
                }
            }

            Divider()

            // Description
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                Text("Description")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.appTextSecondary)

                Text(phoneme.description)
                    .font(.subheadline)
                    .foregroundColor(.appText)
            }

            // Example Words
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                Text("Example Words")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.appTextSecondary)

                ForEach(phoneme.exampleWords, id: \.self) { example in
                    HStack {
                        Text(example)
                            .font(.subheadline.weight(.medium))

                        Spacer()

                        Button(action: {
                            speakText(example)
                        }) {
                            Image(systemName: "speaker.fill")
                                .font(.caption)
                                .foregroundColor(.appPrimary)
                        }
                    }
                    .padding(AppSpacing.sm)
                    .background(Color.appSecondary.opacity(0.05))
                    .cornerRadius(AppRadius.sm)
                }
            }

            // Mouth Position Tip
            if !phoneme.mouthPositionTip.isEmpty {
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    Text("Mouth Position")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.appTextSecondary)

                    HStack(spacing: AppSpacing.sm) {
                        Image(systemName: "mouth")
                            .font(.title2)
                            .foregroundColor(.appAccent)

                        Text(phoneme.mouthPositionTip)
                            .font(.subheadline)
                            .foregroundColor(.appText)
                    }
                    .padding(AppSpacing.md)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.appAccent.opacity(0.05))
                    .cornerRadius(AppRadius.md)
                }
            }

            // Practice Button
            AppButton(
                title: "Practice This Sound",
                icon: "mic.fill",
                style: .primary,
                action: {
                    showPracticeSheet = true
                }
            )
        }
        .padding(AppSpacing.lg)
        .background(Color.white)
        .cornerRadius(AppRadius.lg)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
    }

    // MARK: - Practice Sheet
    private func practicePronunciationSheet(_ phoneme: IPAPhoneme) -> some View {
        let exercise = SpeakingExercise(
            id: UUID().uuidString,
            type: .wordRepetition,
            targetText: phoneme.exampleWords.first ?? phoneme.name,
            ipaText: phoneme.symbol,
            difficulty: .beginner,
            tips: [
                phoneme.mouthPositionTip,
                "Listen carefully to the example",
                "Practice slowly at first"
            ],
            maxAttempts: 5
        )

        return NavigationStack {
            SpeakingExerciseView(exercise: exercise)
                .navigationTitle("Practice \(phoneme.symbol)")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            showPracticeSheet = false
                        }
                    }
                }
        }
    }

    // MARK: - Helper Methods
    private func playPhonemeSound(_ phoneme: IPAPhoneme) {
        isPlayingAudio = true

        // Use the first example word as the sound
        let word = phoneme.exampleWords.first ?? phoneme.name
        speakText(word)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isPlayingAudio = false
        }
    }

    private func speakText(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.4 // Slower rate for learning
        synthesizer.speak(utterance)
    }
}

// MARK: - Phoneme Card View
struct PhonemeCardView: View {
    let phoneme: IPAPhoneme
    let isSelected: Bool
    let isPlayingAudio: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: AppSpacing.sm) {
                // Phoneme symbol
                Text(phoneme.symbol)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(isSelected ? .white : .appPrimary)

                // Name
                Text(phoneme.name)
                    .font(.caption2.weight(.medium))
                    .foregroundColor(isSelected ? .white.opacity(0.9) : .appTextSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                // Playing indicator
                if isPlayingAudio {
                    HStack(spacing: 2) {
                        ForEach(0..<3) { index in
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.white)
                                .frame(width: 3, height: 8)
                                .animation(
                                    Animation.easeInOut(duration: 0.4)
                                        .repeatForever()
                                        .delay(Double(index) * 0.15),
                                    value: isPlayingAudio
                                )
                        }
                    }
                    .frame(height: 8)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppSpacing.md)
            .background(
                isSelected ?
                LinearGradient(
                    gradient: Gradient(colors: [Color.appPrimary, Color.appSecondary]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ) :
                LinearGradient(
                    gradient: Gradient(colors: [Color.appSecondary.opacity(0.1), Color.appSecondary.opacity(0.05)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(AppRadius.md)
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.md)
                    .stroke(isSelected ? Color.appPrimary : Color.clear, lineWidth: 2)
            )
            .scaleEffect(isSelected ? 1.05 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - IPA Phoneme Model
struct IPAPhoneme: Identifiable {
    let id = UUID()
    let symbol: String
    let name: String
    let category: PhonemeCategory
    let description: String
    let exampleWords: [String]
    let mouthPositionTip: String

    static let allPhonemes: [IPAPhoneme] = vowels + consonants

    // MARK: - Vowels (12 phonemes)
    static let vowels: [IPAPhoneme] = [
        IPAPhoneme(
            symbol: "/iː/",
            name: "Long E",
            category: .vowels,
            description: "Long 'ee' sound as in 'see'",
            exampleWords: ["see", "bee", "tree"],
            mouthPositionTip: "Lips spread wide, tongue high and forward"
        ),
        IPAPhoneme(
            symbol: "/ɪ/",
            name: "Short I",
            category: .vowels,
            description: "Short 'i' sound as in 'sit'",
            exampleWords: ["sit", "bit", "hit"],
            mouthPositionTip: "Lips slightly spread, tongue high but relaxed"
        ),
        IPAPhoneme(
            symbol: "/e/",
            name: "Short E",
            category: .vowels,
            description: "Short 'e' sound as in 'bed'",
            exampleWords: ["bed", "red", "pen"],
            mouthPositionTip: "Mouth slightly open, tongue mid-high"
        ),
        IPAPhoneme(
            symbol: "/æ/",
            name: "Short A",
            category: .vowels,
            description: "Short 'a' sound as in 'cat'",
            exampleWords: ["cat", "hat", "map"],
            mouthPositionTip: "Mouth wide open, tongue low and forward"
        ),
        IPAPhoneme(
            symbol: "/ɑː/",
            name: "Long A",
            category: .vowels,
            description: "Long 'a' sound as in 'father'",
            exampleWords: ["father", "car", "park"],
            mouthPositionTip: "Mouth wide open, tongue low and back"
        ),
        IPAPhoneme(
            symbol: "/ɒ/",
            name: "Short O",
            category: .vowels,
            description: "Short 'o' sound as in 'hot'",
            exampleWords: ["hot", "dog", "box"],
            mouthPositionTip: "Lips rounded, mouth open, tongue low"
        ),
        IPAPhoneme(
            symbol: "/ɔː/",
            name: "Long O",
            category: .vowels,
            description: "Long 'aw' sound as in 'door'",
            exampleWords: ["door", "more", "four"],
            mouthPositionTip: "Lips rounded, tongue mid-back"
        ),
        IPAPhoneme(
            symbol: "/ʊ/",
            name: "Short U",
            category: .vowels,
            description: "Short 'u' sound as in 'book'",
            exampleWords: ["book", "good", "put"],
            mouthPositionTip: "Lips slightly rounded, tongue high and back"
        ),
        IPAPhoneme(
            symbol: "/uː/",
            name: "Long U",
            category: .vowels,
            description: "Long 'oo' sound as in 'food'",
            exampleWords: ["food", "blue", "moon"],
            mouthPositionTip: "Lips tightly rounded, tongue high and back"
        ),
        IPAPhoneme(
            symbol: "/ʌ/",
            name: "Schwa U",
            category: .vowels,
            description: "'uh' sound as in 'cup'",
            exampleWords: ["cup", "bus", "love"],
            mouthPositionTip: "Mouth slightly open, tongue relaxed in middle"
        ),
        IPAPhoneme(
            symbol: "/ɜː/",
            name: "R-colored",
            category: .vowels,
            description: "'er' sound as in 'bird'",
            exampleWords: ["bird", "her", "turn"],
            mouthPositionTip: "Lips neutral, tongue mid-high and curled back"
        ),
        IPAPhoneme(
            symbol: "/ə/",
            name: "Schwa",
            category: .vowels,
            description: "Unstressed 'uh' sound as in 'about'",
            exampleWords: ["about", "sofa", "banana"],
            mouthPositionTip: "Most relaxed vowel, mouth neutral"
        )
    ]

    // MARK: - Consonants (24 phonemes)
    static let consonants: [IPAPhoneme] = [
        IPAPhoneme(
            symbol: "/p/",
            name: "P",
            category: .consonants,
            description: "Voiceless 'p' sound",
            exampleWords: ["pen", "cap", "happy"],
            mouthPositionTip: "Lips together, release with a puff of air"
        ),
        IPAPhoneme(
            symbol: "/b/",
            name: "B",
            category: .consonants,
            description: "Voiced 'b' sound",
            exampleWords: ["ball", "cab", "rabbit"],
            mouthPositionTip: "Lips together, voice on, release"
        ),
        IPAPhoneme(
            symbol: "/t/",
            name: "T",
            category: .consonants,
            description: "Voiceless 't' sound",
            exampleWords: ["ten", "cat", "butter"],
            mouthPositionTip: "Tongue tip touches upper teeth ridge"
        ),
        IPAPhoneme(
            symbol: "/d/",
            name: "D",
            category: .consonants,
            description: "Voiced 'd' sound",
            exampleWords: ["dog", "bad", "ladder"],
            mouthPositionTip: "Tongue tip touches upper teeth ridge, voice on"
        ),
        IPAPhoneme(
            symbol: "/k/",
            name: "K",
            category: .consonants,
            description: "Voiceless 'k' sound",
            exampleWords: ["cat", "back", "school"],
            mouthPositionTip: "Back of tongue touches soft palate"
        ),
        IPAPhoneme(
            symbol: "/g/",
            name: "G",
            category: .consonants,
            description: "Voiced 'g' sound",
            exampleWords: ["go", "big", "tiger"],
            mouthPositionTip: "Back of tongue touches soft palate, voice on"
        ),
        IPAPhoneme(
            symbol: "/f/",
            name: "F",
            category: .consonants,
            description: "Voiceless 'f' sound",
            exampleWords: ["fan", "leaf", "coffee"],
            mouthPositionTip: "Upper teeth touch lower lip, blow air"
        ),
        IPAPhoneme(
            symbol: "/v/",
            name: "V",
            category: .consonants,
            description: "Voiced 'v' sound",
            exampleWords: ["van", "have", "river"],
            mouthPositionTip: "Upper teeth touch lower lip, voice on"
        ),
        IPAPhoneme(
            symbol: "/θ/",
            name: "Theta",
            category: .consonants,
            description: "Voiceless 'th' as in 'think'",
            exampleWords: ["think", "bath", "tooth"],
            mouthPositionTip: "Tongue between teeth, blow air"
        ),
        IPAPhoneme(
            symbol: "/ð/",
            name: "Eth",
            category: .consonants,
            description: "Voiced 'th' as in 'this'",
            exampleWords: ["this", "mother", "breathe"],
            mouthPositionTip: "Tongue between teeth, voice on"
        ),
        IPAPhoneme(
            symbol: "/s/",
            name: "S",
            category: .consonants,
            description: "Voiceless 's' sound",
            exampleWords: ["sun", "bus", "lesson"],
            mouthPositionTip: "Tongue near teeth ridge, hiss sound"
        ),
        IPAPhoneme(
            symbol: "/z/",
            name: "Z",
            category: .consonants,
            description: "Voiced 'z' sound",
            exampleWords: ["zoo", "is", "buzzing"],
            mouthPositionTip: "Tongue near teeth ridge, voice on"
        ),
        IPAPhoneme(
            symbol: "/ʃ/",
            name: "SH",
            category: .consonants,
            description: "'sh' sound as in 'ship'",
            exampleWords: ["ship", "fish", "nation"],
            mouthPositionTip: "Lips rounded, tongue back, blow air"
        ),
        IPAPhoneme(
            symbol: "/ʒ/",
            name: "ZH",
            category: .consonants,
            description: "'zh' sound as in 'measure'",
            exampleWords: ["measure", "vision", "beige"],
            mouthPositionTip: "Like /ʃ/ but with voice"
        ),
        IPAPhoneme(
            symbol: "/tʃ/",
            name: "CH",
            category: .consonants,
            description: "'ch' sound as in 'chair'",
            exampleWords: ["chair", "watch", "picture"],
            mouthPositionTip: "Start with /t/, end with /ʃ/"
        ),
        IPAPhoneme(
            symbol: "/dʒ/",
            name: "J",
            category: .consonants,
            description: "'j' sound as in 'jump'",
            exampleWords: ["jump", "badge", "age"],
            mouthPositionTip: "Start with /d/, end with /ʒ/"
        ),
        IPAPhoneme(
            symbol: "/m/",
            name: "M",
            category: .consonants,
            description: "'m' sound",
            exampleWords: ["man", "ham", "summer"],
            mouthPositionTip: "Lips together, voice through nose"
        ),
        IPAPhoneme(
            symbol: "/n/",
            name: "N",
            category: .consonants,
            description: "'n' sound",
            exampleWords: ["no", "pen", "winner"],
            mouthPositionTip: "Tongue touches teeth ridge, voice through nose"
        ),
        IPAPhoneme(
            symbol: "/ŋ/",
            name: "NG",
            category: .consonants,
            description: "'ng' sound as in 'sing'",
            exampleWords: ["sing", "long", "thinking"],
            mouthPositionTip: "Back of tongue touches soft palate, voice through nose"
        ),
        IPAPhoneme(
            symbol: "/h/",
            name: "H",
            category: .consonants,
            description: "'h' sound",
            exampleWords: ["hot", "house", "behind"],
            mouthPositionTip: "Breathe out with mouth open"
        ),
        IPAPhoneme(
            symbol: "/l/",
            name: "L",
            category: .consonants,
            description: "'l' sound",
            exampleWords: ["let", "ball", "yellow"],
            mouthPositionTip: "Tongue tip touches teeth ridge, air flows around sides"
        ),
        IPAPhoneme(
            symbol: "/r/",
            name: "R",
            category: .consonants,
            description: "'r' sound",
            exampleWords: ["red", "car", "sorry"],
            mouthPositionTip: "Tongue curled back, lips slightly rounded"
        ),
        IPAPhoneme(
            symbol: "/j/",
            name: "Y",
            category: .consonants,
            description: "'y' sound as in 'yes'",
            exampleWords: ["yes", "yellow", "onion"],
            mouthPositionTip: "Tongue high and forward, like /iː/ but moving"
        ),
        IPAPhoneme(
            symbol: "/w/",
            name: "W",
            category: .consonants,
            description: "'w' sound",
            exampleWords: ["we", "wind", "away"],
            mouthPositionTip: "Lips tightly rounded, then open"
        )
    ]
}

enum PhonemeCategory: String, CaseIterable {
    case vowels = "Vowels"
    case consonants = "Consonants"

    var emoji: String {
        switch self {
        case .vowels: return "🔤"
        case .consonants: return "🗣️"
        }
    }
}

// MARK: - Preview
struct IPALearningView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            IPALearningView()
        }
    }
}
