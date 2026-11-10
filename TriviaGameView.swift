import SwiftUI
import UIKit

struct TriviaGameView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    @AppStorage("vibration") private var vibration = true
    @AppStorage("drinkingMode") private var drinkingMode = false

    @ObservedObject var manager: TriviaGameManager

    @State private var feedbackText: String? = nil
    @State private var feedbackCorrect = false
    @State private var showDrinkAlert = false
    @State private var drinkMessage = ""

    private var cardBackground: Color {
        colorScheme == .dark ? Color.black.opacity(0.5) : Color.white.opacity(0.80)
    }

    private var cardStroke: Color {
        colorScheme == .dark ? Color.white.opacity(0.18) : Color.black.opacity(0.18)
    }

    private var primaryText: Color {
        colorScheme == .dark ? .white : .black
    }

    var body: some View {
        ZStack {
            AppGradientBackground()

            VStack(spacing: 18) {
                if manager.isLoading {
                    ProgressView()
                        .tint(.white)
                } else if manager.gameFinished {
                    resultsView
                } else if let question = manager.currentQuestion {
                    VStack(spacing: 12) {
                        HStack {
                            Text(manager.progressText)
                                .foregroundStyle(.secondary)

                            Spacer()

                            if manager.isOfflineMode {
                                Text("Offline Mode")
                                    .font(.caption.bold())
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(Color.orange.opacity(0.22))
                                    .foregroundStyle(.orange)
                                    .clipShape(Capsule())
                            }
                        }

                        Text(manager.decodeHTML(question.question))
                            .font(.title2.bold())
                            .multilineTextAlignment(.center)
                            .foregroundStyle(primaryText)
                    }
                    .padding(24)
                    .background(cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 22)
                            .stroke(cardStroke, lineWidth: 1.2)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 22))

                    if let feedbackText {
                        Text(feedbackText)
                            .font(.title3.bold())
                            .foregroundStyle(feedbackCorrect ? .green : .red)
                    }

                    ForEach(manager.currentAnswers, id: \.self) { answer in
                        Button {
                            answerTapped(answer, question)
                        } label: {
                            HStack {
                                Text(manager.decodeHTML(answer))
                                    .foregroundStyle(primaryText)
                                    .multilineTextAlignment(.leading)

                                Spacer()

                                if manager.selectedAnswer != nil {
                                    if answer == question.correct_answer {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundStyle(.green)
                                    } else if answer == manager.selectedAnswer {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundStyle(.red)
                                    }
                                }
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(answerColor(answer, question))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(cardStroke, lineWidth: 1)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        .disabled(manager.selectedAnswer != nil)
                    }

                    Spacer()

                    Text("Score: \(manager.score)")
                        .foregroundStyle(.white)
                } else if let error = manager.errorMessage {
                    VStack(spacing: 16) {
                        Text("Trivia Unavailable")
                            .font(.title2.bold())
                            .foregroundStyle(primaryText)

                        Text(error)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(primaryText)

                        Button("Back to Setup") {
                            dismiss()
                        }
                        .padding()
                        .background(.blue)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .padding(24)
                    .background(cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 22)
                            .stroke(cardStroke, lineWidth: 1.2)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 22))
                }
            }
            .padding()
        }
        .navigationTitle("Trivia")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Drink Penalty", isPresented: $showDrinkAlert) {
            Button("OK") {}
        } message: {
            Text(drinkMessage)
        }
    }

    private func answerTapped(_ answer: String, _ question: TriviaQuestion) {
        manager.chooseAnswer(answer)

        let correct = answer == question.correct_answer
        feedbackCorrect = correct
        feedbackText = correct ? "Correct" : "Wrong"

        if vibration {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(correct ? .success : .error)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            feedbackText = nil
            manager.nextQuestion()
        }
    }

    private func answerColor(_ answer: String, _ question: TriviaQuestion) -> Color {
        guard manager.selectedAnswer != nil else {
            return cardBackground
        }

        if answer == question.correct_answer {
            return Color.green.opacity(0.35)
        }

        if answer == manager.selectedAnswer {
            return Color.red.opacity(0.35)
        }

        return cardBackground
    }

    private var resultsView: some View {
        let wrong = manager.questions.count - manager.score
        let percentWrong = manager.questions.isEmpty
            ? 0
            : Int((Double(wrong) / Double(manager.questions.count)) * 100)

        return VStack(spacing: 20) {
            Text("Round Complete")
                .font(.largeTitle.bold())
                .foregroundStyle(primaryText)

            Text("Score \(manager.score)/\(manager.questions.count)")
                .foregroundStyle(primaryText)

            if manager.isOfflineMode {
                Text("This round used offline backup questions.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            Button("Play Again") {
                Task {
                    await manager.restartSameGame()
                }
            }
            .padding()
            .background(.blue)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 14))

            Button("Back to Setup") {
                dismiss()
            }
        }
        .onAppear {
            if drinkingMode {
                drinkMessage = "You got \(percentWrong)% wrong. Finish \(percentWrong)% of your drink."
                showDrinkAlert = true
            }
        }
    }
}
