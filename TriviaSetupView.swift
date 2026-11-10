import SwiftUI

struct TriviaSetupView: View {
    @StateObject private var manager = TriviaGameManager()

    @State private var amount = 10
    @State private var category = TriviaCategory.all.first!
    @State private var difficulty: TriviaDifficulty = .any
    @State private var type: TriviaType = .multiple

    @Environment(\.colorScheme) private var colorScheme

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

            ScrollView {
                VStack(spacing: 20) {
                    Text("Trivia")
                        .font(.largeTitle.bold())
                        .foregroundStyle(.white)

                    VStack(alignment: .leading, spacing: 18) {
                        HStack {
                            Text("Questions")
                                .foregroundStyle(primaryText)

                            Spacer()

                            Text("\(amount)")
                                .fontWeight(.bold)
                                .foregroundStyle(primaryText)
                        }

                        Stepper("", value: $amount, in: 5...25)
                            .labelsHidden()

                        Picker("Category", selection: $category) {
                            ForEach(TriviaCategory.all) { item in
                                Text(item.name).tag(item)
                            }
                        }

                        Picker("Difficulty", selection: $difficulty) {
                            ForEach(TriviaDifficulty.allCases) { item in
                                Text(item.displayName).tag(item)
                            }
                        }

                        Picker("Type", selection: $type) {
                            ForEach(TriviaType.allCases) { item in
                                Text(item.displayName).tag(item)
                            }
                        }
                    }
                    .padding(24)
                    .background(cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 22)
                            .stroke(cardStroke, lineWidth: 1.2)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 22))

                    NavigationLink {
                        TriviaGameView(manager: manager)
                            .task {
                                await manager.startGame(
                                    amount: amount,
                                    category: category.id,
                                    difficulty: difficulty,
                                    type: type
                                )
                            }
                    } label: {
                        Text("Start Trivia")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(.blue)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }

                    Text("If the API fails, the game will switch to offline backup questions automatically.")
                        .font(.footnote)
                        .foregroundStyle(.white.opacity(0.85))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding()
            }
        }
        .navigationTitle("Trivia")
        .navigationBarTitleDisplayMode(.inline)
    }
}
