//
//  ContentService.swift
//  YLE X
//
//  Intended path: Core/Services/
//  Created by Senior iOS Developer on 6/11/25.
//

import Foundation

// MARK: - Content Service
class ContentService {
    
    // MARK: - Vocabulary Loading
    func loadVocabulary(for level: YLELevel, topic: String?) async throws -> [VocabularyItem] {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        
        // Mock data for demonstration
        let mockVocabulary = createMockVocabulary(for: level, topic: topic)
        
        // In real implementation, this would:
        // 1. Check local cache first
        // 2. Fetch from Firebase if needed
        // 3. Update cache with new data
        // 4. Handle offline scenarios
        
        return mockVocabulary
    }
    
    // MARK: - Exercise Loading
    func loadExercises(for level: YLELevel, skill: Skill) async throws -> [Exercise] {
        try await Task.sleep(nanoseconds: 800_000_000) // 0.8 seconds
        
        let mockExercises = createMockExercises(for: level, skill: skill)
        return mockExercises
    }
    
    // MARK: - Mock Data Creation
    private func createMockVocabulary(for level: YLELevel, topic: String?) -> [VocabularyItem] {
        let topics = topic != nil ? [topic!] : ["Animals", "Colors", "Family", "Food", "Numbers"]
        var vocabulary: [VocabularyItem] = []
        
        for currentTopic in topics {
            let words = getWordsForTopic(currentTopic, level: level)
            
            for (index, word) in words.enumerated() {
                let item = VocabularyItem(
                    id: UUID().uuidString,
                    word: word.word,
                    meaning: word.meaning,
                    example: word.example,
                    imageName: "\(currentTopic.lowercased())_\(index + 1)",
                    audioName: word.word.lowercased().replacingOccurrences(of: " ", with: "_"),
                    level: level,
                    topic: currentTopic,
                    isLearned: false,
                    difficulty: word.difficulty,
                    points: word.points,
                    funFact: word.funFact,
                    memoryTip: word.memoryTip
                )
                vocabulary.append(item)
            }
        }
        
        return vocabulary
    }
    
    private func createMockExercises(for level: YLELevel, skill: Skill) -> [Exercise] {
        var exercises: [Exercise] = []
        
        let exerciseCount = level == .starters ? 5 : (level == .movers ? 8 : 12)
        
        for i in 1...exerciseCount {
            let exercise = Exercise(
                id: UUID().uuidString,
                level: level,
                skill: skill,
                question: generateQuestion(for: skill, index: i),
                options: generateOptions(for: skill, index: i),
                correctIndex: Int.random(in: 0...3),
                points: level == .starters ? 10 : (level == .movers ? 15 : 20),
                timeLimit: skill == .listening ? 45 : 30,
                hint: generateHint(for: skill),
                explanation: generateExplanation(for: skill),
                encouragement: generateEncouragement(),
                imageName: skill == .vocabulary ? "vocab_image_\(i)" : nil,
                audioName: skill == .listening ? "listening_audio_\(i)" : nil
            )
            exercises.append(exercise)
        }
        
        return exercises
    }
    
    // MARK: - Helper Methods
    private func getWordsForTopic(_ topic: String, level: YLELevel) -> [(word: String, meaning: String, example: String?, difficulty: DifficultyLevel, points: Int, funFact: String?, memoryTip: String?)] {
        switch topic {
        case "Animals":
            return [
                ("Cat", "Con mèo", "I have a black cat.", .easy, 10, "Mèo có thể nhìn thấy trong bóng tối!", "Mèo kêu 'meow'"),
                ("Dog", "Con chó", "The dog is very friendly.", .easy, 10, "Chó có thể ngửi mùi rất xa!", "Chó kêu 'woof'"),
                ("Bird", "Con chim", "The bird flies in the sky.", .medium, 15, "Chim có thể bay rất cao!", "Chim có cánh để bay"),
                ("Fish", "Con cá", "Fish live in water.", .easy, 10, "Cá thở bằng mang!", "Cá sống trong nước")
            ]
        case "Colors":
            return [
                ("Red", "Màu đỏ", "The apple is red.", .easy, 10, "Màu đỏ là màu của lửa!", "Đỏ như quả táo"),
                ("Blue", "Màu xanh dương", "The sky is blue.", .easy, 10, "Màu xanh dương như bầu trời!", "Xanh như đại dương"),
                ("Green", "Màu xanh lá", "Grass is green.", .easy, 10, "Màu xanh lá của thiên nhiên!", "Xanh như lá cây"),
                ("Yellow", "Màu vàng", "The sun is yellow.", .easy, 10, "Màu vàng rất sáng!", "Vàng như mặt trời")
            ]
        case "Family":
            return [
                ("Mother", "Mẹ", "My mother is kind.", .easy, 10, "Mẹ là người yêu thương nhất!", "Mom = Mẹ"),
                ("Father", "Bố", "My father is strong.", .easy, 10, "Bố bảo vệ gia đình!", "Dad = Bố"),
                ("Sister", "Chị/Em gái", "I love my sister.", .medium, 15, "Chị em luôn chơi cùng nhau!", "Sister là chị hoặc em gái"),
                ("Brother", "Anh/Em trai", "My brother is funny.", .medium, 15, "Anh em luôn giúp đỡ nhau!", "Brother là anh hoặc em trai")
            ]
        default:
            return [
                ("Hello", "Xin chào", "Hello, how are you?", .easy, 10, "Đây là lời chào đầu tiên!", "Hello = Xin chào"),
                ("Thank you", "Cảm ơn", "Thank you for helping me.", .easy, 10, "Lịch sự là điều quan trọng!", "Thanks = Cảm ơn ngắn gọn")
            ]
        }
    }
    
    private func generateQuestion(for skill: Skill, index: Int) -> String {
        switch skill {
        case .vocabulary:
            return "What does 'happy' mean in Vietnamese?"
        case .listening:
            return "Listen to the audio and choose the correct answer."
        case .speaking:
            return "Say the word 'beautiful' clearly."
        case .reading:
            return "Read the sentence and choose the correct meaning."
        case .writing:
            return "Write the correct spelling of the word you hear."
        case .grammar:
            return "Choose the correct form of the verb."
        }
    }
    
    private func generateOptions(for skill: Skill, index: Int) -> [String] {
        switch skill {
        case .vocabulary:
            return ["Buồn", "Vui vẻ", "Tức giận", "Sợ hãi"]
        case .listening:
            return ["Apple", "Orange", "Banana", "Grapes"]
        case .reading:
            return ["Một câu đơn giản", "Một câu phức tạp", "Một câu hỏi", "Một câu cảm thán"]
        default:
            return ["Option A", "Option B", "Option C", "Option D"]
        }
    }
    
    private func generateHint(for skill: Skill) -> String {
        switch skill {
        case .vocabulary: return "Nghĩ về cảm xúc tích cực!"
        case .listening: return "Lắng nghe kỹ phần đầu của từ."
        case .speaking: return "Nói chậm và rõ ràng."
        case .reading: return "Đọc từng từ một cách cẩn thận."
        case .writing: return "Nhớ chính tả từng chữ cái."
        case .grammar: return "Nghĩ về thì của động từ."
        }
    }
    
    private func generateExplanation(for skill: Skill) -> String {
        switch skill {
        case .vocabulary: return "'Happy' có nghĩa là 'vui vẻ', thể hiện cảm xúc tích cực."
        case .listening: return "Từ được phát âm với trọng âm ở âm tiết đầu."
        case .speaking: return "Phát âm đúng giúp người khác hiểu bạn tốt hơn."
        case .reading: return "Việc đọc hiểu giúp bạn nắm bắt ý nghĩa của câu."
        case .writing: return "Chính tả đúng rất quan trọng trong giao tiếp bằng văn bản."
        case .grammar: return "Ngữ pháp đúng giúp câu văn rõ ràng và dễ hiểu."
        }
    }
    
    private func generateEncouragement() -> String {
        let encouragements = [
            "Tuyệt vời! Bé làm rất tốt! 🌟",
            "Giỏi lắm! Tiếp tục phát huy nhé! 🎉",
            "Xuất sắc! Bé học rất nhanh! 🏆",
            "Thật tuyệt! Bé rất thông minh! 💫",
            "Làm tốt lắm! Bé là siêu sao! ⭐"
        ]
        return encouragements.randomElement() ?? encouragements[0]
    }
}