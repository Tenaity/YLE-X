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
import Combine

// MARK: - Firebase Configuration Manager
class FirebaseManager: ObservableObject {
    
    // ⚠️ LỖI 2: Không cần khai báo 'objectWillChange'
    // 'ObservableObject' sẽ tự động cung cấp 'objectWillChange'
    // var objectWillChange: ObservableObjectPublisher
    
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
            
            // Bật tính năng offline
            settings.isPersistenceEnabled = true
            
            // SỬA LỖI: Lấy hằng số "không giới hạn" và ép kiểu sang NSNumber
            let unlimitedCacheSize = FirestoreCacheSizeUnlimited as NSNumber
            
            // Đặt cache thành không giới hạn
            settings.cacheSettings = PersistentCacheSettings(sizeBytes: unlimitedCacheSize)
            
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
            
            guard let document = snapshot else {
                print("Snapshot is nil")
                return
            }
            
            // ⚠️ LỖI 5: Cách giải mã (decode) vòng vèo và tốn kém
            // Sử dụng Codable của FirestoreSwift hiệu quả hơn
            if document.exists {
                do {
                    // Tự động decode bằng 'data(as:)'
                    let progress = try document.data(as: UserProgress.self)
                    DispatchQueue.main.async {
                        self?.userProgress = progress
                    }
                } catch {
                    print("❌ Error decoding user progress: \(error.localizedDescription)")
                }
            } else {
                // Document không tồn tại, tạo mới
                self?.createInitialUserProgress(userId: userId)
            }
        }
    }
    
    func createInitialUserProgress(userId: String) {
        let initialProgress = UserProgress(userId: userId, level: .starters)
        saveUserProgress(initialProgress)
    }
    
    func saveUserProgress(_ progress: UserProgress) {
        do {
            // ⚠️ LỖI 6: Cách mã hóa (encode) vòng vèo
            // Sử dụng 'setData(from:)' để encode trực tiếp
            try firestore.collection("userProgress").document(progress.userId).setData(from: progress, merge: true) { error in
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
    // Phần này OK, vì bạn dùng 'doc.documentID' nên không cần Codable tự động
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
                
                let exercises: [Exercise] = (snapshot?.documents ?? []).compactMap { doc in
                    let data = doc.data()
                    guard let levelRaw = data["level"] as? String,
                          let level = YLELevel(rawValue: levelRaw),
                          let skillRaw = data["skill"] as? String,
                          let skill = Skill(rawValue: skillRaw),
                          let question = data["question"] as? String,
                          let options = data["options"] as? [String],
                          let correctIndex = data["correctIndex"] as? Int else { return nil }
                    
                    // Lấy các trường optional
                    let explanation = data["explanation"] as? String
                    let audioName = data["audioName"] as? String
                    let imageName = data["imageName"] as? String
                    
                    // SỬA: Thêm các trường optional vào init
                    return Exercise(id: doc.documentID,
                                    level: level,
                                    skill: skill,
                                    question: question,
                                    options: options,
                                    correctIndex: correctIndex,
                                    explanation: explanation,
                                    audioName: audioName,
                                    imageName: imageName)
                }
                
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
    // Phần này OK, lý do tương tự 'loadExercises'
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
            
            let items: [VocabularyItem] = (snapshot?.documents ?? []).compactMap { doc in
                let data = doc.data()
                guard let word = data["word"] as? String,
                      let meaning = data["meaning"] as? String,
                      let levelRaw = data["level"] as? String,
                      let level = YLELevel(rawValue: levelRaw),
                      let topic = data["topic"] as? String else { return nil }
                let example = data["example"] as? String
                let imageName = data["imageName"] as? String
                let audioName = data["audioName"] as? String
                return VocabularyItem(id: doc.documentID, word: word, meaning: meaning, example: example, imageName: imageName, audioName: audioName, level: level, topic: topic)
            }
            
            completion(items)
        }
    }
    
    //
    // 🔴 PHẦN DƯỚI ĐÂY BỊ LỖI LOGIC NGHIÊM TRỌNG (XEM GIẢI THÍCH)
    //
    
    // MARK: - Learning Session Tracking
    
    // ⚠️ LỖI 7: Lỗi logic - Hàm này không khớp với DataModel
    // 'LearningSession' cần 'userId', 'level', 'skill', 'exercises'
    // Code hiện tại của bạn gọi một 'init' không tồn tại.
    // Tôi sẽ sửa lại hàm này để nó khớp với DataModel
    func startLearningSession(level: YLELevel, skill: Skill, exercises: [Exercise]) -> String {
        guard let userId = currentUser?.uid else {
            // Không thể tạo session nếu không có user
            // Bạn nên xử lý lỗi này, ví dụ:
            print("❌ Cannot start session, user not logged in")
            return "" // Trả về ID rỗng
        }
        
        let session = LearningSession(
            userId: userId,
            level: level,
            skill: skill,
            exercises: exercises
        )
        
        saveLearningSession(session)
        return session.id
    }
    
    // ⚠️ LỖI 8: Lỗi logic - Hàm này không khớp với DataModel
    // Các trường như 'duration', 'pointsEarned', 'mood' KHÔNG có trong 'LearningSession'
    // Model của bạn chỉ có 'endTime', 'score', 'completed'
    func endLearningSession(sessionId: String, score: Double, mood: String? = nil) { // Giả sử 'ChildMood' là String
        guard let userId = currentUser?.uid else { return }
        
        // Chỉ cập nhật các trường có trong DataModel
        var sessionData: [String: Any] = [
            "userId": userId, // 'userId' đã có lúc tạo, nhưng update cũng không sao
            "score": score,
            "completed": true,
            "endTime": Timestamp(date: Date())
        ]
        
        // ⚠️ LỖI 9: 'mood' không có trong DataModel, nhưng nếu bạn muốn thêm
        // bạn phải xử lý 'nil' bằng 'NSNull()'
        sessionData["mood"] = mood ?? NSNull()
        
        firestore.collection("learningSessions").document(sessionId).updateData(sessionData) { error in
            if let error = error {
                print("❌ Error ending learning session: \(error.localizedDescription)")
            } else {
                print("✅ Learning session ended successfully")
            }
        }
        
        // ⚠️ LỖI 10: 'pointsEarned', 'exercisesCompleted' không có
        // updateProgressAfterSession(pointsEarned: pointsEarned, exercisesCompleted: exercisesCompleted)
    }
    
    private func saveLearningSession(_ session: LearningSession) {
        // ⚠️ LỖI 11: 'userId' đã có trong 'session'
        // 'guard let userId = currentUser?.uid else { return }' là không cần thiết
        
        do {
            // Dùng 'setData(from:)' để encode 'session' trực tiếp
            try firestore.collection("learningSessions").document(session.id).setData(from: session) { error in
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
    
    // ⚠️ LỖI 12: Lỗi logic - Hàm này không khớp với DataModel
    // 'UserProgress' KHÔNG có 'totalPoints' và 'streak'
    // Tên 'lastActiveDate' không đúng, nó là 'lastActivity'
    private func updateProgressAfterSession(pointsEarned: Int, exercisesCompleted: Int) {
        guard var progress = userProgress else { return }
        
        // 'progress.totalPoints += pointsEarned' // <-- LỖI: 'totalPoints' không tồn tại
        
        // SỬA: 'lastActiveDate' -> 'lastActivity'
        progress.lastActivity = Date()
        
        // 'streak' logic
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let lastActive = calendar.startOfDay(for: progress.lastActivity) // Dùng 'lastActivity'
        
        // SỬA: Dùng 'isDateInToday' cho đơn giản
        if !calendar.isDateInToday(lastActive) {
            let daysDifference = calendar.dateComponents([.day], from: lastActive, to: today).day ?? 0
            if daysDifference == 1 {
                // 'progress.streak += 1' // <-- LỖI: 'streak' không tồn tại
            } else if daysDifference > 1 {
                // 'progress.streak = 1' // <-- LỖI: 'streak' không tồn tại
            }
        }
        
        saveUserProgress(progress)
    }
    
    // MARK: - Notification Scheduling
    private func scheduleAchievementNotification(badgeName: String) { // Giả sử Badge là String
        // This would integrate with UNUserNotificationCenter
        print("🎉 Achievement unlocked: \(badgeName)")
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
