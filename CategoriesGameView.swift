import SwiftUI

struct CategoriesGameView: View {
    let themeName: String
    let categoryPrompt: String
    let players: [String]
    let baseTimeLimit: Int
    let frenzyMode: Bool

    @AppStorage("drinkingMode") private var drinkingMode = false //Pulls drinking mode from App Storage, stored into drinkingMode variable
    @Environment(\.dismiss) private var dismiss

    @State private var currentPlayerIndex = 0
    @State private var timeRemaining = 5
    @State private var turnNumber = 1

    @State private var timer: Timer?
    @State private var gameOver = false
    @State private var losingPlayer = ""
    @State private var showLoseAlert = false

    private let playerColors: [Color] = [
        .red, .blue, .green, .orange, .purple, .pink, .teal, .yellow, .indigo, .mint, .cyan, .brown
    ]

    var body: some View {
        ZStack {//layers text on top of background (color)
            currentPlayerColor
                .ignoresSafeArea()

            VStack(spacing: 24) {// Displays config settings for user to enter names, time limit, and select category to play
                Spacer()

                Text(categoryPrompt)
                    .font(.system(size: 34, weight: .heavy, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white)
                    .padding(.horizontal)

                Text(currentPlayerName)
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Text("\(timeRemaining)")
                    .font(.system(size: 110, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)

                Text("Tap anywhere to pass to the next player")//where the big button is to play game
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white.opacity(0.95))
                    .padding(.horizontal)

                if frenzyMode {
                    Text("Frenzy Mode")
                        .font(.headline.bold())
                        .foregroundStyle(.white.opacity(0.95))
                }

                Spacer()
            }
            .padding()
        }
        .contentShape(Rectangle())
        .onTapGesture {
            handleTap()
        }
        .navigationTitle("Categories")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            startTurn()
        }
        .onDisappear {
            stopTimer()
        }
        .alert(drinkingMode ? "\(losingPlayer) Lost" : "Time's Up", isPresented: $showLoseAlert) {
            Button("Play Again") {
                restartGame()
            }

            Button("Back") {
                dismiss()
            }
        } message: {
            Text(
                drinkingMode
                ? "\(losingPlayer) ran out of time.\n\nFinish your drink."//Shown to user if drinking mode is on
                : "\(losingPlayer) ran out of time and lost the round."
            )
        }
    }
    
    //variables for game state

    private var currentPlayerName: String {
        guard players.indices.contains(currentPlayerIndex) else { return "Player" }
        return players[currentPlayerIndex]
    }

    private var currentPlayerColor: Color {
        playerColors[currentPlayerIndex % playerColors.count]
    }

    private var currentTurnLimit: Int {
        guard frenzyMode else { return baseTimeLimit }

        if turnNumber <= 2 {
            return baseTimeLimit
        } else if turnNumber <= 4 {
            return max(3, baseTimeLimit - 1)
        } else {
            return max(2, baseTimeLimit - 2)
        }
    }

    private func startTurn() {
        stopTimer()
        timeRemaining = currentTurnLimit
        HapticsManager.medium()

        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            tick()
        }
    }

    private func tick() {
        guard !gameOver else { return }

        if timeRemaining > 1 {
            timeRemaining -= 1
            HapticsManager.light()
        } else {
            timeRemaining = 0
            loseRound()
        }
    }

    private func handleTap() {
        guard !gameOver else { return }
        HapticsManager.light()
        advanceTurn()
    }

    private func advanceTurn() {
        stopTimer()
        currentPlayerIndex = (currentPlayerIndex + 1) % players.count
        turnNumber += 1
        startTurn()
    }

    private func loseRound() {
        stopTimer()
        gameOver = true
        losingPlayer = currentPlayerName
        HapticsManager.heavy()
        showLoseAlert = true
    }

    private func restartGame() {
        gameOver = false
        currentPlayerIndex = 0
        turnNumber = 1
        losingPlayer = ""
        startTurn()
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}
