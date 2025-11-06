//
//  FirebaseManager.swift
//  YLE X
//
//  Created by Senior iOS Developer on 6/11/25.
//

import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import FirebaseFirestoreSwift

// MARK: - Firebase Configuration Manager
class FirebaseManager: ObservableObject {
    static let shared = FirebaseManager()
    
    let auth = Auth.auth()
    let firestore = Firestore.firestore()
    let storage = Storage.storage()
    
    @Published var currentUser: User?
    @Published var userProgress: UserProgress?
    
    private init() {
        configureFirebase()
        setupAuthListener()
    }
    
    private func configureFirebase() {
        guard let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") else {
            print("⚠️ GoogleService-Info.plist not found!")
            return
        }
        
        guard let options = FirebaseOptions(contentsOfFile: path) else {
            print("⚠️ Could not load Firebase options")
            return
        }
        
        FirebaseApp.configure(options: options)
        
        // Enable Firestore offline persistence
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = true
        settings.cacheSizeBytes = FirestoreCacheSizeUnlimited
        firestore.settings = settings
        
        print("✅ Firebase configured successfully")
    }
    
    private func setupAuthListener() {
        auth.addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                self?.currentUser = user
                if let user = user {
                    self?.loadUserProgress(userId: user.uid)
                } else {
                    self?.userProgress = nil
                }
            }
        }
    }
    
    // MARK: - User Progress Management
    func loadUserProgress(userId: String) {
        firestore.collection("userProgress").document(userId).addSnapshotListener { [weak self] snapshot, error in
            if let error = error {
                print("❌ Error loading user progress: \(error.localizedDescription)")
                return
            }
            
            guard let data = snapshot?.data() else {
                // Create new user progress if doesn't exist
                self?.createInitialUserProgress(userId: userId)
                return
            }
            
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: data)
                let progress = try JSONDecoder().decode(UserProgress.self, from: jsonData)
                DispatchQueue.main.async {
                    self?.userProgress = progress
                }
            } catch {
                print("❌ Error decoding user progress: \(error.localizedDescription)")
            }
        }
    }
    
    func createInitialUserProgress(userId: String) {
        let initialProgress = UserProgress(userId: userId, level: .starters)
        saveUserProgress(initialProgress)
    }
    
    func saveUserProgress(_ progress: UserProgress) {
        do {
            let data = try JSONEncoder().encode(progress)
            let dictionary = try JSONSerialization.jsonObject(with: data) as? [String: Any] ?? [:]
            
            firestore.collection("userProgress").document(progress.userId).setData(dictionary, merge: true) { error in
                if let error = error {
                    print("❌ Error saving user progress: \(error.localizedDescription)")
                } else {
                    print("✅ User progress saved successfully")
                }
            }
        } catch {
            print("❌ Error encoding user progress: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Exercise Management
    func loadExercises(for level: YLELevel, skill: Skill, completion: @escaping ([Exercise]) -> Void) {
        firestore.collection("exercises")
            .whereField("level", isEqualTo: level.rawValue)
            .whereField("skill", isEqualTo: skill.rawValue)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("❌ Error loading exercises: \(error.localizedDescription)")
                    completion([])
                    return
                }
                
                let exercises = snapshot?.documents.compactMap { document in
                    try? document.data(as: Exercise.self)
                } ?? []
                
                completion(exercises)
            }
    }
    
    func saveExerciseResult(exerciseId: String, isCorrect: Bool, timeSpent: TimeInterval) {
        guard let userId = currentUser?.uid else { return }
        
        let result: [String: Any] = [
            "userId": userId,
            "exerciseId": exerciseId,
            "isCorrect": isCorrect,
            "timeSpent": timeSpent,
            "timestamp": Timestamp(date: Date())
        ]
        
        firestore.collection("exerciseResults").addDocument(data: result) { error in
            if let error = error {
                print("❌ Error saving exercise result: \(error.localizedDescription)")
            } else {
                print("✅ Exercise result saved")
            }
        }
    }
    
    // MARK: - Vocabulary Management
    func loadVocabulary(for level: YLELevel, topic: String? = nil, completion: @escaping ([VocabularyItem]) -> Void) {
        var query: Query = firestore.collection("vocabulary")
            .whereField("level", isEqualTo: level.rawValue)
        
        if let topic = topic {
            query = query.whereField("topic", isEqualTo: topic)
        }
        
        query.getDocuments { snapshot, error in
            if let error = error {
                print("❌ Error loading vocabulary: \(error.localizedDescription)")
                completion([])
                return
            }
            
            let vocabulary = snapshot?.documents.compactMap { document in
                try? document.data(as: VocabularyItem.self)
            } ?? []
            
            completion(vocabulary)
        }
    }
    
    // MARK: - Learning Session Tracking
    func startLearningSession() -> String {
        let sessionId = UUID().uuidString
        let session = LearningSession(
            id: sessionId,
            date: Date(),
            duration: 0,
            exercisesCompleted: 0,
            pointsEarned: 0,
            accuracy: 0.0,
            skillsFocused: []
        )
        
        saveLearningSession(session)
        return sessionId
    }
    
    func endLearningSession(sessionId: String, duration: TimeInterval, exercisesCompleted: Int, pointsEarned: Int, accuracy: Double, skillsFocused: [Skill], mood: ChildMood?) {
        guard let userId = currentUser?.uid else { return }
        
        let sessionData: [String: Any] = [
            "userId": userId,
            "duration": duration,
            "exercisesCompleted": exercisesCompleted,
            "pointsEarned": pointsEarned,
            "accuracy": accuracy,
            "skillsFocused": skillsFocused.map { $0.rawValue },
            "mood": mood?.rawValue as Any,
            "endDate": Timestamp(date: Date())
        ]
        
        firestore.collection("learningSessions").document(sessionId).updateData(sessionData) { error in
            if let error = error {
                print("❌ Error ending learning session: \(error.localizedDescription)")
            } else {
                print("✅ Learning session ended successfully")
            }
        }
        
        // Update user progress
        updateProgressAfterSession(pointsEarned: pointsEarned, exercisesCompleted: exercisesCompleted)
    }
    
    private func saveLearningSession(_ session: LearningSession) {
        guard let userId = currentUser?.uid else { return }
        
        do {
            var sessionData = try Firestore.Encoder().encode(session)
            sessionData["userId"] = userId
            
            firestore.collection("learningSessions").document(session.id).setData(sessionData) { error in
                if let error = error {
                    print("❌ Error saving learning session: \(error.localizedDescription)")
                } else {
                    print("✅ Learning session started")
                }
            }
        } catch {
            print("❌ Error encoding learning session: \(error.localizedDescription)")
        }
    }
    
    private func updateProgressAfterSession(pointsEarned: Int, exercisesCompleted: Int) {
        guard var progress = userProgress else { return }
        
        progress.totalPoints += pointsEarned
        progress.lastActiveDate = Date()
        
        // Update streak
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let lastActive = calendar.startOfDay(for: progress.lastActiveDate)
        
        if calendar.dateInterval(of: .day, for: today)?.contains(lastActive) == false {
            let daysDifference = calendar.dateComponents([.day], from: lastActive, to: today).day ?? 0
            if daysDifference == 1 {
                progress.streak += 1
            } else if daysDifference > 1 {
                progress.streak = 1 // Reset streak but count today
            }
        }
        
        saveUserProgress(progress)
    }
    
    // MARK: - Notification Scheduling
    private func scheduleAchievementNotification(badge: Badge) {
        // This would integrate with UNUserNotificationCenter
        print("🎉 Achievement unlocked: \(badge.name)")
    }
}

// MARK: - Extensions for Firestore Codable
extension Timestamp: @unchecked Sendable {}

extension Date {
    init?(timestamp: Timestamp?) {
        guard let timestamp = timestamp else { return nil }
        self = timestamp.dateValue()
    }
}
