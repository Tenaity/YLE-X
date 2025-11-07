//
//  PetCompanionView.swift
//  YLE X
//
//  Created by Senior iOS Developer on 6/11/25.
//

import SwiftUI

struct PetCompanionView: View {
    @StateObject private var gamificationService = GamificationService.shared
    @State private var animatePet = false
    @State private var showPetAnimation = false
    @State private var petAnimationType: PetInteraction = .idle
    @State private var showAdoptSheet = false

    enum PetInteraction {
        case idle
        case feeding
        case playing
    }

    var pet: VirtualPet? {
        gamificationService.virtualPet
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color.appBackground, Color.appPrimary.opacity(0.05)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                if let pet = pet {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: AppSpacing.xl) {
                            // Pet Display
                            petDisplayCard(pet: pet)
                                .scaleEffect(animatePet ? 1 : 0.8)
                                .opacity(animatePet ? 1 : 0)

                            // Pet Stats
                            petStatsCard(pet: pet)
                                .opacity(animatePet ? 1 : 0)
                                .offset(y: animatePet ? 0 : 20)

                            // Pet Level & Experience
                            petProgressCard(pet: pet)
                                .opacity(animatePet ? 1 : 0)
                                .offset(y: animatePet ? 0 : 20)

                            // Interaction Buttons
                            interactionButtons(pet: pet)
                                .opacity(animatePet ? 1 : 0)
                                .offset(y: animatePet ? 0 : 20)

                            // Pet Information
                            petInfoCard(pet: pet)
                                .opacity(animatePet ? 1 : 0)
                                .offset(y: animatePet ? 0 : 20)
                        }
                        .padding(.horizontal, AppSpacing.lg)
                        .padding(.vertical, AppSpacing.xl)
                    }
                } else {
                    // No Pet State
                    VStack(spacing: AppSpacing.lg) {
                        Image(systemName: "heart.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.appPrimary.opacity(0.5))

                        Text("No Pet Yet")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.appText)

                        Text("Adopt your first pet companion!")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.appTextSecondary)

                        Button(action: { showAdoptSheet = true }) {
                            HStack(spacing: AppSpacing.sm) {
                                Image(systemName: "heart.fill")
                                Text("Adopt Pet")
                            }
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, AppSpacing.md)
                            .background(
                                RoundedRectangle(cornerRadius: AppRadius.lg)
                                    .fill(Color.appPrimary)
                                    .appShadow(level: .medium)
                            )
                        }
                        .padding(.horizontal, AppSpacing.lg)
                    }
                    .frame(maxHeight: .infinity)
                    .frame(maxWidth: .infinity)
                }
            }
            .navigationTitle("My Pet")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showAdoptSheet) {
                PetAdoptionView()
                    .presentationDetents([.large])
            }
            .task {
                do {
                    try await gamificationService.fetchVirtualPet()
                    withAnimation(.appBouncy.delay(0.2)) {
                        animatePet = true
                    }
                } catch {
                    print("Error loading pet: \(error)")
                }
            }
        }
    }

    // MARK: - Pet Display Card
    private func petDisplayCard(pet: VirtualPet) -> some View {
        VStack(spacing: AppSpacing.lg) {
            ZStack {
                // Background
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.appPrimary.opacity(0.1),
                                Color.appPrimary.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 220, height: 220)
                    .appShadow(level: .heavy)

                // Pet Emoji with Animation
                VStack(spacing: AppSpacing.md) {
                    Text(petEmoji(pet.type))
                        .font(.system(size: 100))
                        .scaleEffect(showPetAnimation ? 1.1 : 1.0)
                        .animation(.spring(response: 0.6, dampingFraction: 0.7), value: showPetAnimation)
                        .onTapGesture {
                            withAnimation {
                                showPetAnimation = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    showPetAnimation = false
                                }
                            }
                        }

                    Text(pet.name)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.appText)

                    HStack(spacing: 4) {
                        ForEach(0..<pet.level, id: \.self) { _ in
                            Image(systemName: "star.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.appAccent)
                        }
                        ForEach(0..<(5 - pet.level), id: \.self) { _ in
                            Image(systemName: "star")
                                .font(.system(size: 12))
                                .foregroundColor(.appTextSecondary.opacity(0.3))
                        }
                    }
                }
            }

            Text("Tap the pet to interact!")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.appTextSecondary)
        }
        .padding(AppSpacing.xl)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.xl)
                .fill(Color(UIColor.secondarySystemBackground))
                .appShadow(level: .medium)
        )
    }

    // MARK: - Pet Stats Card
    private func petStatsCard(pet: VirtualPet) -> some View {
        VStack(spacing: AppSpacing.md) {
            // Happiness
            VStack(spacing: AppSpacing.sm) {
                HStack {
                    Image(systemName: "smileyface.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.appAccent)

                    Text("Happiness")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.appText)

                    Spacer()

                    Text("\(pet.happiness)%")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.appAccent)
                }

                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: AppRadius.sm)
                            .fill(Color.appTextSecondary.opacity(0.2))

                        RoundedRectangle(cornerRadius: AppRadius.sm)
                            .fill(
                                LinearGradient(
                                    colors: [.appAccent, .appAccent.opacity(0.7)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * Double(pet.happiness) / 100)
                    }
                }
                .frame(height: 8)
            }

            // Health
            VStack(spacing: AppSpacing.sm) {
                HStack {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.appError)

                    Text("Health")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.appText)

                    Spacer()

                    Text("\(pet.health)%")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.appError)
                }

                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: AppRadius.sm)
                            .fill(Color.appTextSecondary.opacity(0.2))

                        RoundedRectangle(cornerRadius: AppRadius.sm)
                            .fill(
                                LinearGradient(
                                    colors: [.appError, .appError.opacity(0.7)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * Double(pet.health) / 100)
                    }
                }
                .frame(height: 8)
            }
        }
        .padding(AppSpacing.lg)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.lg)
                .fill(Color(UIColor.secondarySystemBackground))
                .appShadow(level: .light)
        )
    }

    // MARK: - Pet Progress Card
    private func petProgressCard(pet: VirtualPet) -> some View {
        VStack(spacing: AppSpacing.md) {
            HStack {
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text("Level")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.appTextSecondary)

                    Text("\(pet.level)/5")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.appText)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: AppSpacing.xs) {
                    Text("Experience")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.appTextSecondary)

                    Text("\(pet.experience) XP")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.appAccent)
                }
            }

            // XP Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: AppRadius.md)
                        .fill(Color.appTextSecondary.opacity(0.2))

                    RoundedRectangle(cornerRadius: AppRadius.md)
                        .fill(
                            LinearGradient(
                                colors: [.appSuccess, .appSuccess.opacity(0.7)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * Double(pet.experience % 100) / 100)
                }
            }
            .frame(height: 10)
        }
        .padding(AppSpacing.lg)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.lg)
                .fill(Color(UIColor.secondarySystemBackground))
                .appShadow(level: .light)
        )
    }

    // MARK: - Interaction Buttons
    private func interactionButtons(pet: VirtualPet) -> some View {
        HStack(spacing: AppSpacing.md) {
            // Feed Button
            Button(action: {
                Task {
                    await feedPet(pet)
                }
            }) {
                VStack(spacing: AppSpacing.sm) {
                    Image(systemName: "fork.knife")
                        .font(.system(size: 24, weight: .bold))

                    Text("Feed")
                        .font(.system(size: 14, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppSpacing.lg)
                .background(
                    RoundedRectangle(cornerRadius: AppRadius.lg)
                        .fill(Color.appSuccess)
                        .appShadow(level: .medium)
                )
            }

            // Play Button
            Button(action: {
                Task {
                    await playWithPet(pet)
                }
            }) {
                VStack(spacing: AppSpacing.sm) {
                    Image(systemName: "gamecontroller.fill")
                        .font(.system(size: 24, weight: .bold))

                    Text("Play")
                        .font(.system(size: 14, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppSpacing.lg)
                .background(
                    RoundedRectangle(cornerRadius: AppRadius.lg)
                        .fill(Color.appAccent)
                        .appShadow(level: .medium)
                )
            }
        }
    }

    // MARK: - Pet Info Card
    private func petInfoCard(pet: VirtualPet) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack {
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text("Pet Type")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.appTextSecondary)

                    Text(pet.type.rawValue.capitalized)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.appText)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: AppSpacing.xs) {
                    Text("Adopted")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.appTextSecondary)

                    Text(adoptedDateString(pet.adoptedAt))
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.appText)
                }
            }
            .padding(AppSpacing.lg)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.lg)
                    .fill(Color(UIColor.secondarySystemBackground))
                    .appShadow(level: .light)
            )

            // Care Tips
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                Text("Care Tips")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.appText)

                HStack(spacing: AppSpacing.sm) {
                    Image(systemName: "info.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.appInfo)

                    Text("Feed your pet daily to keep them healthy!")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.appTextSecondary)
                }

                HStack(spacing: AppSpacing.sm) {
                    Image(systemName: "info.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.appInfo)

                    Text("Play with your pet to increase happiness!")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.appTextSecondary)
                }
            }
            .padding(AppSpacing.lg)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.lg)
                    .fill(Color.appInfo.opacity(0.1))
                    .appShadow(level: .subtle)
            )
        }
    }

    // MARK: - Helper Methods
    private func petEmoji(_ type: VirtualPet.PetType) -> String {
        switch type {
        case .dragon: return "🐉"
        case .cat: return "🐱"
        case .fox: return "🦊"
        case .unicorn: return "🦄"
        case .phoenix: return "🔥"
        }
    }

    private func adoptedDateString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }

    private func feedPet(_ pet: VirtualPet) async {
        do {
            try await gamificationService.feedPet()
            HapticManager.shared.playSuccess()
        } catch {
            print("Error feeding pet: \(error)")
            HapticManager.shared.playError()
        }
    }

    private func playWithPet(_ pet: VirtualPet) async {
        do {
            try await gamificationService.playWithPet()
            HapticManager.shared.playSuccess()
        } catch {
            print("Error playing with pet: \(error)")
            HapticManager.shared.playError()
        }
    }
}

// MARK: - Pet Adoption View
struct PetAdoptionView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var gamificationService = GamificationService.shared
    @State private var selectedPetType: VirtualPet.PetType = .dragon
    @State private var petName: String = ""
    @State private var isAdopting = false

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color.appBackground, Color.appPrimary.opacity(0.05)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: AppSpacing.xl) {
                        Text("Choose Your Pet")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.appText)

                        // Pet Selection Grid
                        VStack(spacing: AppSpacing.md) {
                            ForEach([VirtualPet.PetType.dragon, .cat, .fox, .unicorn, .phoenix], id: \.self) { type in
                                petTypeCard(type)
                            }
                        }

                        // Name Input
                        VStack(alignment: .leading, spacing: AppSpacing.sm) {
                            Text("Pet Name")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.appText)

                            TextField("Enter a name", text: $petName)
                                .font(.system(size: 16, weight: .medium))
                                .padding(AppSpacing.md)
                                .background(
                                    RoundedRectangle(cornerRadius: AppRadius.lg)
                                        .fill(Color(UIColor.secondarySystemBackground))
                                )
                        }

                        // Adopt Button
                        Button(action: adoptPet) {
                            HStack(spacing: AppSpacing.sm) {
                                Image(systemName: "heart.fill")
                                Text("Adopt \(selectedPetType.rawValue.capitalized)")
                            }
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, AppSpacing.md)
                            .background(
                                RoundedRectangle(cornerRadius: AppRadius.lg)
                                    .fill(Color.appPrimary)
                                    .appShadow(level: .medium)
                            )
                        }
                        .disabled(petName.isEmpty || isAdopting)
                        .opacity(petName.isEmpty || isAdopting ? 0.6 : 1.0)

                        Spacer()
                    }
                    .padding(.horizontal, AppSpacing.lg)
                    .padding(.vertical, AppSpacing.xl)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }

    private func petTypeCard(_ type: VirtualPet.PetType) -> some View {
        Button(action: { HapticManager.shared.playLight(); selectedPetType = type }) {
            HStack(spacing: AppSpacing.md) {
                Text(petEmoji(type))
                    .font(.system(size: 48))

                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text(type.rawValue.capitalized)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.appText)

                    Text(petDescription(type))
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.appTextSecondary)
                }

                Spacer()

                if selectedPetType == type {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.appSuccess)
                }
            }
            .padding(AppSpacing.lg)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.lg)
                    .fill(selectedPetType == type ? Color.appPrimary.opacity(0.1) : Color(UIColor.secondarySystemBackground))
                    .appShadow(level: selectedPetType == type ? .medium : .light)
            )
        }
    }

    private func petEmoji(_ type: VirtualPet.PetType) -> String {
        switch type {
        case .dragon: return "🐉"
        case .cat: return "🐱"
        case .fox: return "🦊"
        case .unicorn: return "🦄"
        case .phoenix: return "🔥"
        }
    }

    private func petDescription(_ type: VirtualPet.PetType) -> String {
        switch type {
        case .dragon: return "Mythical and powerful"
        case .cat: return "Cute and curious"
        case .fox: return "Smart and clever"
        case .unicorn: return "Magical and rare"
        case .phoenix: return "Legendary and majestic"
        }
    }

    private func adoptPet() {
        isAdopting = true
        Task {
            do {
                try await gamificationService.adoptPet(type: selectedPetType, name: petName)
                HapticManager.shared.playSuccess()
                dismiss()
            } catch {
                print("Error adopting pet: \(error)")
                HapticManager.shared.playError()
                isAdopting = false
            }
        }
    }
}

#Preview {
    PetCompanionView()
}
