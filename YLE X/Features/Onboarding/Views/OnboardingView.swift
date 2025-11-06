//
//  OnboardingView.swift
//  YLE X
//
//  Created by Senior iOS Developer on 6/11/25.
//

import SwiftUI
import FirebaseAuth
import Combine
import AVFoundation
import UserNotifications

// MARK: - Onboarding Flow for Kids
struct OnboardingView: View {
    @StateObject private var onboardingManager = OnboardingManager()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            // Animated background
            AnimatedBackgroundView()
            
            TabView(selection: $onboardingManager.currentStep) {
                ForEach(OnboardingStep.allCases) { step in
                    OnboardingStepView(step: step, manager: onboardingManager)
                        .tag(step)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .animation(.kidsGentle, value: onboardingManager.currentStep)
        }
        .navigationBarHidden(true)
        .onAppear {
            AudioService.shared.playBackgroundMusic(named: "onboarding_music", loop: true)
        }
        .onDisappear {
            AudioService.shared.stopBackgroundMusic()
        }
    }
}

// MARK: - Onboarding Steps
enum OnboardingStep: Int, CaseIterable, Identifiable {
    case welcome = 0
    case levelSelection
    case parentSetup
    case permissions
    case ready
    
    var id: Int { rawValue }
    
    var title: String {
        switch self {
        case .welcome: return "Chào mừng đến YLE X! 🌟"
        case .levelSelection: return "Chọn level phù hợp 📚"
        case .parentSetup: return "Thông tin phụ huynh 👨‍👩‍👧‍👦"
        case .permissions: return "Cài đặt quyền truy cập 🔧"
        case .ready: return "Sẵn sàng bắt đầu! 🚀"
        }
    }
    
    var description: String {
        switch self {
        case .welcome: return "Ứng dụng học tiếng Anh vui nhộn dành cho các bé!"
        case .levelSelection: return "Hãy chọn level phù hợp với độ tuổi của bé"
        case .parentSetup: return "Thiết lập thông tin để theo dõi tiến trình học tập"
        case .permissions: return "Cho phép ứng dụng sử dụng micro và thông báo"
        case .ready: return "Tất cả đã sẵn sàng! Cùng bắt đầu học nhé!"
        }
    }
    
    var emoji: String {
        switch self {
        case .welcome: return "🎉"
        case .levelSelection: return "🎯"
        case .parentSetup: return "👨‍👩‍👧‍👦"
        case .permissions: return "🔐"
        case .ready: return "🚀"
        }
    }
    
    var primaryColor: Color {
        switch self {
        case .welcome: return .kidsPrimary
        case .levelSelection: return .startersGreen
        case .parentSetup: return .moversBlue
        case .permissions: return .flyersPurple
        case .ready: return .kidsSuccess
        }
    }
}

// MARK: - Individual Step View
struct OnboardingStepView: View {
    let step: OnboardingStep
    @ObservedObject var manager: OnboardingManager
    
    var body: some View {
        VStack(spacing: KidsSpacing.xxxl) {
            Spacer()
            
            // Step content
            stepContent
            
            Spacer()
            
            // Navigation buttons
            navigationButtons
        }
        .padding(KidsSpacing.xl)
    }
    
    @ViewBuilder
    private var stepContent: some View {
        switch step {
        case .welcome:
            WelcomeStepView()
        case .levelSelection:
            LevelSelectionStepView(manager: manager)
        case .parentSetup:
            ParentSetupStepView(manager: manager)
        case .permissions:
            PermissionsStepView(manager: manager)
        case .ready:
            ReadyStepView()
        }
    }
    
    private var navigationButtons: some View {
        HStack(spacing: KidsSpacing.lg) {
            // Back button
            if step != .welcome {
                KidsButton(
                    title: "Quay lại",
                    emoji: "👈",
                    color: .gray
                ) {
                    manager.previousStep()
                }
            }
            
            Spacer()
            
            // Progress indicator
            OnboardingProgressIndicator(
                currentStep: step.rawValue,
                totalSteps: OnboardingStep.allCases.count
            )
            
            Spacer()
            
            // Next/Finish button
            KidsButton(
                title: step == .ready ? "Bắt đầu!" : "Tiếp tục",
                emoji: step == .ready ? "🎉" : "👉",
                color: step.primaryColor
            ) {
                if step == .ready {
                    manager.completeOnboarding()
                } else {
                    manager.nextStep()
                }
            }
            .disabled(!manager.canProceed(from: step))
            .opacity(manager.canProceed(from: step) ? 1.0 : 0.5)
        }
    }
}

// MARK: - Welcome Step
struct WelcomeStepView: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: KidsSpacing.xl) {
            // Animated mascot or logo
            Text("🌟")
                .font(.system(size: 120))
                .scaleEffect(isAnimating ? 1.2 : 1.0)
                .rotationEffect(.degrees(isAnimating ? 5 : -5))
                .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: isAnimating)
            
            Text("Chào mừng đến YLE X!")
                .font(.kidsDisplayLarge)
                .foregroundColor(.kidsPrimary)
                .multilineTextAlignment(.center)
            
            Text("Ứng dụng học tiếng Anh vui nhộn dành cho các bé! 🎈")
                .font(.kidsTitle)
                .foregroundColor(.kidsSecondaryText)
                .multilineTextAlignment(.center)
                .lineLimit(nil)
            
            VStack(spacing: KidsSpacing.md) {
                FeatureHighlight(icon: "🎮", title: "Học qua trò chơi", description: "Vui vẻ như chơi game")
                FeatureHighlight(icon: "🏆", title: "Hệ thống huy hiệu", description: "Thu thập huy hiệu khi học tốt")
                FeatureHighlight(icon: "📈", title: "Theo dõi tiến độ", description: "Phụ huynh xem được kết quả")
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
}

// MARK: - Feature Highlight Component
struct FeatureHighlight: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: KidsSpacing.md) {
            Text(icon)
                .font(.system(size: 32))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.kidsHeadline)
                    .foregroundColor(.kidsPrimary)
                
                Text(description)
                    .font(.kidsBody)
                    .foregroundColor(.kidsSecondaryText)
            }
            
            Spacer()
        }
        .padding(KidsSpacing.lg)
        .background(
            RoundedRectangle(cornerRadius: KidsRadius.large)
                .fill(Color.white.opacity(0.8))
                .kidsShadow(level: .light)
        )
    }
}

// MARK: - Level Selection Step
struct LevelSelectionStepView: View {
    @ObservedObject var manager: OnboardingManager
    
    var body: some View {
        VStack(spacing: KidsSpacing.xl) {
            Text("Bé bao nhiêu tuổi? 🎂")
                .font(.kidsDisplayMedium)
                .foregroundColor(.kidsPrimary)
                .multilineTextAlignment(.center)
            
            Text("Chọn level phù hợp với độ tuổi của bé")
                .font(.kidsTitle)
                .foregroundColor(.kidsSecondaryText)
                .multilineTextAlignment(.center)
            
            VStack(spacing: KidsSpacing.lg) {
                ForEach(YLELevel.allCases) { level in
                    OnboardingLevelCard(
                        level: level,
                        isSelected: manager.selectedLevel == level
                    ) {
                        manager.selectLevel(level)
                    }
                }
            }
        }
    }
}

// MARK: - Onboarding Level Card
struct OnboardingLevelCard: View {
    let level: YLELevel
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            HapticManager.shared.playMedium()
            AudioService.shared.playEffect(.buttonTap)
            action()
        }) {
            HStack(spacing: KidsSpacing.lg) {
                Text(level.emoji)
                    .font(.system(size: 40))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(level.title)
                        .font(.kidsTitle)
                        .foregroundColor(.kidsPrimaryText)
                    
                    Text(level.ageRange)
                        .font(.kidsBody)
                        .foregroundColor(level.primaryColor)
                        .fontWeight(.semibold)
                    
                    Text(level.description)
                        .font(.kidsCaption)
                        .foregroundColor(.kidsSecondaryText)
                }
                
                Spacer()
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? level.primaryColor : .gray)
            }
            .padding(KidsSpacing.lg)
            .background(
                RoundedRectangle(cornerRadius: KidsRadius.large)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: KidsRadius.large)
                            .stroke(isSelected ? level.primaryColor : Color.gray.opacity(0.3), lineWidth: isSelected ? 3 : 1)
                    )
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
            .animation(.kidsGentle, value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Parent Setup Step
struct ParentSetupStepView: View {
    @ObservedObject var manager: OnboardingManager
    
    var body: some View {
        VStack(spacing: KidsSpacing.xl) {
            Text("Thông tin phụ huynh 👨‍👩‍👧‍👦")
                .font(.kidsDisplayMedium)
                .foregroundColor(.kidsPrimary)
                .multilineTextAlignment(.center)
            
            Text("Giúp chúng tôi cá nhân hóa trải nghiệm cho bé")
                .font(.kidsTitle)
                .foregroundColor(.kidsSecondaryText)
                .multilineTextAlignment(.center)
            
            VStack(spacing: KidsSpacing.lg) {
                ParentInfoField(
                    title: "Tên của bé",
                    placeholder: "Nhập tên bé",
                    text: $manager.childName,
                    emoji: "👶"
                )
                
                ParentInfoField(
                    title: "Tên phụ huynh",
                    placeholder: "Nhập tên phụ huynh",
                    text: $manager.parentName,
                    emoji: "👨‍👩‍👧‍👦"
                )
                
                // Learning goals
                VStack(alignment: .leading, spacing: KidsSpacing.md) {
                    HStack {
                        Text("🎯")
                        Text("Mục tiêu hàng ngày")
                            .font(.kidsHeadline)
                            .foregroundColor(.kidsPrimary)
                        Spacer()
                    }
                    
                    HStack {
                        Text("\(Int(manager.dailyGoalMinutes)) phút")
                            .font(.kidsBody)
                            .foregroundColor(.kidsSecondaryText)
                        
                        Slider(value: $manager.dailyGoalMinutes, in: 5...60, step: 5)
                            .accentColor(.moversBlue)
                        
                        Text("60 phút")
                            .font(.kidsCaption)
                            .foregroundColor(.gray)
                    }
                }
                .padding(KidsSpacing.lg)
                .background(
                    RoundedRectangle(cornerRadius: KidsRadius.large)
                        .fill(Color.white)
                        .kidsShadow(level: .light)
                )
            }
        }
    }
}

// MARK: - Parent Info Field
struct ParentInfoField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    let emoji: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: KidsSpacing.sm) {
            HStack {
                Text(emoji)
                Text(title)
                    .font(.kidsHeadline)
                    .foregroundColor(.kidsPrimary)
                Spacer()
            }
            
            TextField(placeholder, text: $text)
                .font(.kidsBody)
                .padding(KidsSpacing.md)
                .background(
                    RoundedRectangle(cornerRadius: KidsRadius.medium)
                        .fill(Color.gray.opacity(0.1))
                )
        }
        .padding(KidsSpacing.lg)
        .background(
            RoundedRectangle(cornerRadius: KidsRadius.large)
                .fill(Color.white)
                .kidsShadow(level: .light)
        )
    }
}

// MARK: - Permissions Step
struct PermissionsStepView: View {
    @ObservedObject var manager: OnboardingManager
    
    var body: some View {
        VStack(spacing: KidsSpacing.xl) {
            Text("Cài đặt quyền truy cập 🔧")
                .font(.kidsDisplayMedium)
                .foregroundColor(.kidsPrimary)
                .multilineTextAlignment(.center)
            
            Text("Để có trải nghiệm tốt nhất, chúng tôi cần:")
                .font(.kidsTitle)
                .foregroundColor(.kidsSecondaryText)
                .multilineTextAlignment(.center)
            
            VStack(spacing: KidsSpacing.lg) {
                PermissionCard(
                    icon: "🎤",
                    title: "Microphone",
                    description: "Để luyện tập phát âm",
                    isGranted: manager.microphonePermission,
                    requestAction: {
                        manager.requestMicrophonePermission()
                    }
                )
                
                PermissionCard(
                    icon: "🔔",
                    title: "Thông báo",
                    description: "Để nhắc nhở học tập hàng ngày",
                    isGranted: manager.notificationPermission,
                    requestAction: {
                        manager.requestNotificationPermission()
                    }
                )
            }
            
            Text("Bé có thể thay đổi quyền này trong Cài đặt sau")
                .font(.kidsCaption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
    }
}

// MARK: - Permission Card
struct PermissionCard: View {
    let icon: String
    let title: String
    let description: String
    let isGranted: Bool
    let requestAction: () -> Void
    
    var body: some View {
        HStack(spacing: KidsSpacing.lg) {
            Text(icon)
                .font(.system(size: 32))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.kidsHeadline)
                    .foregroundColor(.kidsPrimary)
                
                Text(description)
                    .font(.kidsBody)
                    .foregroundColor(.kidsSecondaryText)
            }
            
            Spacer()
            
            if isGranted {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.kidsSuccess)
            } else {
                Button("Cho phép") {
                    requestAction()
                }
                .font(.kidsCaption)
                .foregroundColor(.white)
                .padding(.horizontal, KidsSpacing.md)
                .padding(.vertical, KidsSpacing.xs)
                .background(
                    Capsule()
                        .fill(Color.kidsPrimary)
                )
            }
        }
        .padding(KidsSpacing.lg)
        .background(
            RoundedRectangle(cornerRadius: KidsRadius.large)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: KidsRadius.large)
                        .stroke(isGranted ? Color.kidsSuccess : Color.gray.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - Ready Step
struct ReadyStepView: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: KidsSpacing.xl) {
            Text("🚀")
                .font(.system(size: 120))
                .scaleEffect(isAnimating ? 1.3 : 1.0)
                .animation(.kidsPlayful.repeatForever(autoreverses: true), value: isAnimating)
            
            Text("Tất cả đã sẵn sàng!")
                .font(.kidsDisplayLarge)
                .foregroundColor(.kidsSuccess)
                .multilineTextAlignment(.center)
            
            Text("Cùng bắt đầu hành trình học tiếng Anh thú vị nhé!")
                .font(.kidsTitle)
                .foregroundColor(.kidsSecondaryText)
                .multilineTextAlignment(.center)
            
            VStack(spacing: KidsSpacing.md) {
                ReadySummaryItem(icon: "🎯", text: "Level được chọn sẵn")
                ReadySummaryItem(icon: "👨‍👩‍👧‍👦", text: "Thông tin đã thiết lập")
                ReadySummaryItem(icon: "🔧", text: "Quyền truy cập đã cấp")
                ReadySummaryItem(icon: "🎉", text: "Sẵn sàng học tập!")
            }
        }
        .onAppear {
            isAnimating = true
            AudioService.shared.playEffect(.celebration)
        }
    }
}

// MARK: - Ready Summary Item
struct ReadySummaryItem: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: KidsSpacing.md) {
            Text(icon)
                .font(.system(size: 20))
            
            Text(text)
                .font(.kidsBody)
                .foregroundColor(.kidsPrimaryText)
            
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.kidsSuccess)
        }
        .padding(.horizontal, KidsSpacing.lg)
    }
}

// MARK: - Progress Indicator
struct OnboardingProgressIndicator: View {
    let currentStep: Int
    let totalSteps: Int
    
    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<totalSteps, id: \.self) { step in
                Circle()
                    .fill(step <= currentStep ? Color.kidsPrimary : Color.gray.opacity(0.3))
                    .frame(width: 8, height: 8)
                    .scaleEffect(step == currentStep ? 1.3 : 1.0)
                    .animation(.kidsGentle, value: currentStep)
            }
        }
    }
}

// MARK: - Animated Background
struct AnimatedBackgroundView: View {
    @State private var animate = false
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.kidsBackground,
                    Color.kidsPrimary.opacity(0.1),
                    Color.kidsSecondary.opacity(0.1)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Floating shapes
            ForEach(0..<5) { index in
                Circle()
                    .fill(Color.kidsPrimary.opacity(0.1))
                    .frame(width: CGFloat.random(in: 50...120))
                    .offset(
                        x: CGFloat.random(in: -200...200),
                        y: animate ? CGFloat.random(in: -300...300) : CGFloat.random(in: -100...100)
                    )
                    .animation(
                        .linear(duration: Double.random(in: 3...6))
                        .repeatForever(autoreverses: true)
                        .delay(Double.random(in: 0...2)),
                        value: animate
                    )
            }
        }
        .onAppear {
            animate = true
        }
    }
}

// MARK: - Onboarding Manager
class OnboardingManager: ObservableObject {
    @Published var currentStep: OnboardingStep = .welcome
    @Published var selectedLevel: YLELevel?
    @Published var childName: String = ""
    @Published var parentName: String = ""
    @Published var dailyGoalMinutes: Double = 15
    @Published var microphonePermission = false
    @Published var notificationPermission = false
    
    func nextStep() {
        guard let nextStep = OnboardingStep(rawValue: currentStep.rawValue + 1) else { return }
        
        withAnimation(.kidsGentle) {
            currentStep = nextStep
        }
        
        AudioService.shared.playEffect(.buttonTap)
    }
    
    func previousStep() {
        guard let previousStep = OnboardingStep(rawValue: currentStep.rawValue - 1) else { return }
        
        withAnimation(.kidsGentle) {
            currentStep = previousStep
        }
        
        AudioService.shared.playEffect(.buttonTap)
    }
    
    func selectLevel(_ level: YLELevel) {
        selectedLevel = level
    }
    
    func canProceed(from step: OnboardingStep) -> Bool {
        switch step {
        case .welcome:
            return true
        case .levelSelection:
            return selectedLevel != nil
        case .parentSetup:
            return !childName.isEmpty && !parentName.isEmpty
        case .permissions:
            return true // Optional permissions
        case .ready:
            return true
        }
    }
    
    func requestMicrophonePermission() {
        AVAudioSession.sharedInstance().requestRecordPermission { [weak self] (granted: Bool) in
            DispatchQueue.main.async {
                self?.microphonePermission = granted
                if granted {
                    AudioService.shared.playEffect(.correctAnswer)
                }
            }
        }
    }
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] (granted: Bool, _) in
            DispatchQueue.main.async {
                self?.notificationPermission = granted
                if granted {
                    AudioService.shared.playEffect(.correctAnswer)
                }
            }
        }
    }
    
    func completeOnboarding() {
        // Save onboarding data
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        UserDefaults.standard.set(selectedLevel?.rawValue, forKey: "selectedLevel")
        UserDefaults.standard.set(childName, forKey: "childName")
        UserDefaults.standard.set(parentName, forKey: "parentName")
        UserDefaults.standard.set(dailyGoalMinutes, forKey: "dailyGoalMinutes")
        
        // Create initial user progress if signed in
        if let userId = FirebaseManager.shared.currentUser?.uid {
            FirebaseManager.shared.createInitialUserProgress(userId: userId)
        }
        
        AudioService.shared.playEffect(.levelComplete)
        print("✅ Onboarding completed successfully")
    }
}

#Preview {
    OnboardingView()
}
