import SwiftUI

struct ImposterGameView: View {
    let playerCount: Int
    let selectedCategory: String
    let showCategoryDuringReveal: Bool

    @AppStorage("vibration") private var vibration = true

    private enum Phase {
        case passPhone
        case revealRole
        case finished
    }

    @State private var phase: Phase = .passPhone
    @State private var currentPlayer = 1

    @State private var secretWord: String = ""
    @State private var imposterIndex: Int = 1
    @State private var activeCategory: String = "Random"

    var body: some View {
        ZStack {
            AppGradientBackground()

            VStack(spacing: 18) {
                Text("Imposter")
                    .font(.largeTitle)
                    .bold()

                Text("Player \(currentPlayer) of \(playerCount)")
                    .font(.headline)
                    .foregroundStyle(.secondary)

                if showCategoryDuringReveal || phase == .finished {
                    Text("Category: \(activeCategory)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                switch phase {
                case .passPhone:
                    passPhoneView
                case .revealRole:
                    revealRoleView
                case .finished:
                    finishedView
                }

                Spacer()
            }
            .padding(28)
            .navigationTitle("Imposter")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                startNewRound()
            }
        }
    }

    private var passPhoneView: some View {//assigning roles in setup view to each player
        VStack(spacing: 14) {
            Text("Pass the phone")
                .font(.title)
                .bold()

            Text("Hand the phone to Player \(currentPlayer).")
                .font(.title3)

            Text("Make sure nobody else is looking 👀")
                .foregroundStyle(.secondary)

            Button("Player \(currentPlayer) is ready") {
                if vibration { HapticsManager.medium() }
                phase = .revealRole
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .multilineTextAlignment(.center)
    }

    private var revealRoleView: some View {//picks whose imposter (random)
        let isImposter = currentPlayer == imposterIndex

        return VStack(spacing: 20) {
            Text("Your Role")
                .font(.headline)
                .foregroundStyle(.secondary)

            if isImposter {
                Text("IMPOSTER")
                    .font(.system(size: 40, weight: .black, design: .rounded))
                    .foregroundStyle(.red)

                if showCategoryDuringReveal {
                    Text("The category is:")
                        .foregroundStyle(.secondary)

                    Text(activeCategory)
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .multilineTextAlignment(.center)
                }

                Text("Blend in and don't get caught.")//special message only to impostor
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            } else {
                Text(secretWord)
                    .font(.system(size: 38, weight: .black, design: .rounded))
                    .multilineTextAlignment(.center)

                if showCategoryDuringReveal {
                    Text("Category: \(activeCategory)")
                        .foregroundStyle(.secondary)
                }

                Text("Use this word to play.")
                    .foregroundStyle(.secondary)
            }

            Button(currentPlayer == playerCount ? "Finish" : "Hide & Next Player") {//used for passing phone without revealing roles to one another
                if vibration { HapticsManager.medium() }
                nextPlayer()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)

            Button("Back") {
                if vibration { HapticsManager.light() }
                phase = .passPhone
            }
            .buttonStyle(.bordered)
        }
        .frame(maxWidth: 360)
        .padding(.vertical, 28)
        .padding(.horizontal, 24)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color(.systemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(
                    isImposter ? Color.red.opacity(0.65) : Color.primary.opacity(0.12),
                    lineWidth: 2
                )
        )
        .shadow(radius: 10)
    }

    private var finishedView: some View {
        VStack(spacing: 14) {
            Text("All set!")
                .font(.title)
                .bold()

            Text("Everyone has seen their role. Start the round.")
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Text("Category was: \(activeCategory)")
                .font(.headline)

            Button("Start New Round") {
                if vibration { HapticsManager.success() }//begins game
                startNewRound()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .multilineTextAlignment(.center)
    }

    private func startNewRound() {//when game finishes
        currentPlayer = 1
        phase = .passPhone
        imposterIndex = Int.random(in: 1...playerCount)

        let customCategories: [String: [String]] = {
            guard let dataString = UserDefaults.standard.string(forKey: "customImposterCategories"),
                  let data = dataString.data(using: .utf8),
                  let decoded = try? JSONDecoder().decode([ImposterSetupView.CustomImposterCategory].self, from: data) else {
                return [:]
            }

            var result: [String: [String]] = [:]
            for category in decoded {
                result[category.name] = category.words
            }
            return result
        }()

        let customNames = customCategories.keys.sorted()

        if selectedCategory == "Random" {
            let allCategories = ImposterCategories.categoryNames + customNames
            activeCategory = allCategories.randomElement() ?? "Animals"
        } else {
            activeCategory = selectedCategory
        }

        if let customWords = customCategories[activeCategory],
           let randomCustomWord = customWords.randomElement() {
            secretWord = randomCustomWord
        } else {
            secretWord = ImposterCategories.randomWord(for: activeCategory)
        }

        if vibration { HapticsManager.light() }
    }

    private func nextPlayer() {
        if currentPlayer < playerCount {
            currentPlayer += 1
            phase = .passPhone

            if vibration { HapticsManager.light() }
        } else {
            phase = .finished

            if vibration { HapticsManager.success() }
        }
    }
}

#Preview {
    NavigationStack {
        ImposterGameView(
            playerCount: 8,
            selectedCategory: "Random",
            showCategoryDuringReveal: true
        )
    }
}
