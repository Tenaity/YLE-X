import SwiftUI

struct ExerciseView: View {
    @StateObject var viewModel = PracticeViewModel()
    let level: YLELevel
    let skill: Skill

    var body: some View {
        VStack {
            if viewModel.exercises.isEmpty {
                Text("Đang chuẩn bị bài tập...")
                    .onAppear { viewModel.loadMock(level: level, skill: skill) }
            } else if viewModel.finished {
                VStack(spacing: 12) {
                    Text("Hoàn thành!")
                        .font(.largeTitle).bold()
                    Text("Điểm: \(viewModel.score)/\(viewModel.exercises.count)")
                    Button("Làm lại") { viewModel.loadMock(level: level, skill: skill) }
                }
            } else {
                let exercise = viewModel.exercises[viewModel.currentIndex]
                VStack(spacing: 16) {
                    Text("\(viewModel.currentIndex + 1)/\(viewModel.exercises.count)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(exercise.question)
                        .font(.title3)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    ForEach(exercise.options.indices, id: \.self) { idx in
                        Button {
                            viewModel.selectedIndex = idx
                        } label: {
                            HStack {
                                Text(exercise.options[idx])
                                Spacer()
                                if viewModel.selectedIndex == idx {
                                    Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
                                }
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(8)
                        }
                        .buttonStyle(.plain)
                    }

                    Button("Nộp bài") { viewModel.submit() }
                        .buttonStyle(.borderedProminent)
                        .padding(.top, 8)
                }
                .padding()
            }
        }
        .navigationTitle(skill.title)
    }
}
