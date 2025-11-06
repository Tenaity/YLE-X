//
//  FirebaseManager.swift
//  YLE X
//
//  Intended path: Core/Services/
//  Created by Senior iOS Developer on 6/11/25.
//

import Foundation
import SwiftUI
import Combine
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

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
        let initialProgress = UserProgress(
            userId: userId,
            level: .starters,
            totalPoints: 0,
            streak: 0,
            badges: [],
            completedExercises: [],
            learnedVocabulary: [],
            skillProgress: [:],
            lastActiveDate: Date()
        )
        
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
}

// MARK: - Extensions for Firestore Codable
extension Timestamp: @unchecked Sendable {}

extension Date {
    init?(timestamp: Timestamp?) {
        guard let timestamp = timestamp else { return nil }
        self = timestamp.dateValue()
    }
}