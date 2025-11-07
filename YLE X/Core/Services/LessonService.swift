//
//  LessonService.swift
//  YLE X
//
//  Created by Senior iOS Developer on 6/11/25.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import Combine

@MainActor
class LessonService: ObservableObject {
    static let shared = LessonService()

    @Published var lessons: [Lesson] = []
    @Published var userProgress: [String: UserLessonProgress] = [:]
    @Published var isLoading = false
    @Published var error: Error?

    private let db = Firestore.firestore()
    private var lessonsCache: [String: Lesson] = [:]
    private var listeners: [ListenerRegistration] = []

    private init() {}

    // MARK: - Fetch Lessons
    func fetchLessons(for level: YLELevel) async throws -> [Lesson] {
        isLoading = true
        defer { isLoading = false }

        let levelQuery = level.rawValue.lowercased()
        print("[LessonService] Fetching lessons for level: \(levelQuery)")

        let snapshot = try await db.collection("lessons")
            .whereField("level", isEqualTo: levelQuery)
            .order(by: "order")
            .getDocuments()

        print("[LessonService] Query returned \(snapshot.documents.count) documents")

        let lessons = try snapshot.documents.compactMap { doc -> Lesson? in
            let data = doc.data()
            print("[LessonService] Document data: \(data)")
            return try doc.data(as: Lesson.self)
        }

        print("[LessonService] Successfully parsed \(lessons.count) lessons")

        // Cache lessons
        lessons.forEach { lesson in
            if let id = lesson.id {
                lessonsCache[id] = lesson
            }
        }

        self.lessons = lessons
        return lessons
    }

    // MARK: - Fetch Exercises
    func fetchExercises(for lessonId: String) async throws -> [LessonExercise] {
        let snapshot = try await db.collection("lessons")
            .document(lessonId)
            .collection("exercises")
            .order(by: "order")
            .getDocuments()

        return try snapshot.documents.compactMap { doc in
            try doc.data(as: LessonExercise.self)
        }
    }

    // MARK: - Fetch User Progress
    func fetchUserProgress() async throws {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "LessonService", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
        }

        let snapshot = try await db.collection("userProgress")
            .document(userId)
            .collection("lessons")
            .getDocuments()

        var progress: [String: UserLessonProgress] = [:]
        for doc in snapshot.documents {
            if let lessonProgress = try? doc.data(as: UserLessonProgress.self) {
                progress[lessonProgress.lessonId] = lessonProgress
            }
        }

        self.userProgress = progress
    }

    // MARK: - Save Lesson Result
    func saveLessonResult(_ result: LessonResult) async throws {
        guard let userId = Auth.auth().currentUser?.uid,
              let lessonId = result.lesson.id else {
            throw NSError(domain: "LessonService", code: 401, userInfo: [NSLocalizedDescriptionKey: "Invalid data"])
        }

        let progress = UserLessonProgress(
            lessonId: lessonId,
            completed: true,
            score: result.score,
            stars: result.stars,
            attempts: (userProgress[lessonId]?.attempts ?? 0) + 1,
            completedAt: Date(),
            exercisesCompleted: []  // Will be updated during exercise flow
        )

        try db.collection("userProgress")
            .document(userId)
            .collection("lessons")
            .document(lessonId)
            .setData(from: progress, merge: true)

        // Update local cache
        userProgress[lessonId] = progress

        // Update user XP
        try await updateUserXP(userId: userId, xpToAdd: result.xpEarned)
    }

    // MARK: - Update User XP
    private func updateUserXP(userId: String, xpToAdd: Int) async throws {
        let userRef = db.collection("users").document(userId)

        try await db.runTransaction { transaction, errorPointer in
            let userDoc: DocumentSnapshot
            do {
                userDoc = try transaction.getDocument(userRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }

            let currentXP = userDoc.data()?["totalXP"] as? Int ?? 0
            let newXP = currentXP + xpToAdd

            transaction.updateData([
                "totalXP": newXP,
                "lastUpdated": FieldValue.serverTimestamp()
            ], forDocument: userRef)

            return nil
        }
    }

    // MARK: - Real-time Listener
    func startListeningToProgress() {
        guard let userId = Auth.auth().currentUser?.uid else { return }

        let listener = db.collection("userProgress")
            .document(userId)
            .collection("lessons")
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self, let snapshot = snapshot else { return }

                Task { @MainActor in
                    var progress: [String: UserLessonProgress] = [:]
                    for doc in snapshot.documents {
                        if let lessonProgress = try? doc.data(as: UserLessonProgress.self) {
                            progress[lessonProgress.lessonId] = lessonProgress
                        }
                    }
                    self.userProgress = progress
                }
            }

        listeners.append(listener)
    }

    func stopListening() {
        listeners.forEach { $0.remove() }
        listeners.removeAll()
    }

    // MARK: - Helper Methods
    func getCachedLesson(_ lessonId: String) -> Lesson? {
        lessonsCache[lessonId]
    }

    func isLessonCompleted(_ lessonId: String) -> Bool {
        userProgress[lessonId]?.completed ?? false
    }

    func getLessonStars(_ lessonId: String) -> Int {
        userProgress[lessonId]?.stars ?? 0
    }

    func getProgress(for lessonId: String) -> UserLessonProgress? {
        userProgress[lessonId]
    }

    // MARK: - Calculate Stars
    func calculateStars(percentage: Double) -> Int {
        switch percentage {
        case 0.9...1.0: return 3
        case 0.7..<0.9: return 2
        case 0.5..<0.7: return 1
        default: return 0
        }
    }
}
