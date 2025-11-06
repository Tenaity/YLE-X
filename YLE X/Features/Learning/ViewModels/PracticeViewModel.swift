import Foundation
import Combine

final class PracticeViewModel: ObservableObject {
    @Published var exercises: [Exercise] = []
    @Published var currentIndex: Int = 0
    @Published var selectedIndex: Int? = nil
    @Published var score: Int = 0
    @Published var finished: Bool = false

    func loadMock(level: YLELevel, skill: Skill) {
        exercises = [
            Exercise(id: "1", level: level, skill: skill, question: "Chọn từ đúng: A ___ cat.", options: ["an", "a"], correctIndex: 1),
            Exercise(id: "2", level: level, skill: skill, question: "Từ đồng nghĩa với 'small'?", options: ["tiny", "huge"], correctIndex: 0)
        ]
        currentIndex = 0
        selectedIndex = nil
        score = 0
        finished = false
    }

    func submit() {
        guard currentIndex < exercises.count else { return }
        if let selectedIndex, selectedIndex == exercises[currentIndex].correctIndex {
            score += 1
        }
        if currentIndex == exercises.count - 1 {
            finished = true
        } else {
            currentIndex += 1
            self.selectedIndex = nil
        }
    }
}
