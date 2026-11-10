import SwiftUI

struct SongBlitzGameView: View {
    let playerOneName: String
    let playerTwoName: String
    let playTo: Int

    @AppStorage("drinkingMode") private var drinkingMode = false
    @AppStorage("vibration") private var vibration = true

    @State private var playerOneScore = 0
    @State private var playerTwoScore = 0

    @State private var currentWord = ""
    @State private var countdownNumber: Int? = nil
    @State private var roundActive = false
    @State private var gameOver = false
    @State private var winnerName = ""

    @State private var usedWords: [String] = []

    @State private var showDrinkAlert = false
    @State private var loserName = ""

    private let words = [
        "love", "baby", "heart", "night", "day", "dream", "fire", "light",
        "stars", "moon", "sun", "sky", "blue", "gold", "rain", "wind",
        "home", "road", "car", "train", "dance", "party", "kiss", "girl",
        "boy", "woman", "man", "angel", "devil", "sweet", "wild", "free",
        "broken", "happy", "sad", "cry", "smile", "world", "time", "life",
        "music", "song", "voice", "sound", "beat", "radio", "summer", "winter",
        "spring", "fall", "cold", "hot", "dark", "bright", "good", "bad",
        "young", "old", "crazy", "beautiful", "alone", "together", "forever", "again",
        "tonight", "morning", "midnight", "weekend", "city", "street", "river", "ocean",
        "water", "mountain", "heaven", "hell", "king", "queen", "money", "rich",
        "empty", "lost", "found", "run", "walk", "ride", "fly", "hold",
        "touch", "call", "phone", "name", "eyes", "arms", "hands", "body",
        "mind", "soul", "shake", "stop", "go", "wait", "change", "memory",
        "yesterday", "tomorrow", "now", "back", "front", "up", "down", "high",
        "low", "left", "right", "black", "white", "red", "green", "yellow",
        "pink", "purple", "silver", "diamond", "rose", "flower", "dust", "storm",
        "thunder", "lightning", "snow", "ice", "beach", "sea", "boat", "ship",
        "hotel", "bar", "whiskey", "wine", "drunk", "trouble", "danger", "enemy",
        "friend", "family", "mother", "father", "brother", "sister", "daughter", "son",
        "school", "teacher", "church", "hotel", "door", "window", "room", "floor",
        "mirror", "shadow", "picture", "movie", "dancefloor", "disco", "neon", "guitar",
        "drums", "piano", "band", "crowd", "stage", "spotlight", "fame", "glory",
        "secret", "truth", "lie", "promise", "chance", "choice", "game", "fight",
        "power", "control", "dangerous", "magic", "fever", "desire", "passion", "lonely",
        "faith", "hope", "grace", "pain", "fear", "sin", "ghost", "hero",
        "villain", "bullet", "kissed", "burn", "shine", "fade", "echo", "silence"
    ]

    var body: some View {
        ZStack {
            AppGradientBackground()
                .ignoresSafeArea()

            VStack(spacing: 20) {
                scoreBoard
                    .padding(.top, 8)

                Spacer()

                if gameOver {
                    gameOverView
                } else if let countdown = countdownNumber {
                    countdownView(number: countdown)
                } else if roundActive {
                    wordRevealView
                } else {
                    readyView
                }

                Spacer()

                if roundActive && !gameOver {
                    resultButtonsRow
                }
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .navigationTitle("Song Blitz")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Drink Time 🍻", isPresented: $showDrinkAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("\(loserName) has to finish their drink!")
        }
    }

    private var scoreBoard: some View {
        HStack(spacing: 16) {
            playerScoreCard(name: playerOneName, score: playerOneScore)
            playerScoreCard(name: playerTwoName, score: playerTwoScore)
        }
    }

    private func playerScoreCard(name: String, score: Int) -> some View {
        VStack(spacing: 8) {
            Text(name)
                .font(.headline)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.8)

            Text("\(score)")
                .font(.system(size: 34, weight: .bold))
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
    }

    private var readyView: some View {
        VStack(spacing: 18) {
            Text("Next Round")
                .font(.title.bold())

            Text("Tap ready when both players are prepared.")
                .font(.headline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button {
                if vibration { HapticsManager.medium() }
                startCountdown()
            } label: {
                Text("Ready")
                    .font(.title3.bold())
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
            }
            .padding(.top, 8)
        }
    }

    private func countdownView(number: Int) -> some View {
        VStack(spacing: 16) {
            Text("Get Ready")
                .font(.title.bold())

            Text("\(number)")
                .font(.system(size: 90, weight: .heavy, design: .rounded))
                .contentTransition(.numericText())
        }
    }

    private var wordRevealView: some View {
        VStack(spacing: 10) {
            Text("Song Word")
                .font(.title2.bold())
                .foregroundStyle(.secondary)

            Text(currentWord.capitalized)
                .font(.system(size: 44, weight: .heavy, design: .rounded))
                .multilineTextAlignment(.center)
                .padding()
                .frame(maxWidth: .infinity)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24))
        }
    }

    private var resultButtonsRow: some View {
        HStack(spacing: 12) {
            Button {
                givePoint(to: 1)
            } label: {
                Text(playerOneName)
                    .font(.headline)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.blue)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }

            Button {
                handleTie()
            } label: {
                Text("Tie")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.orange)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }

            Button {
                givePoint(to: 2)
            } label: {
                Text(playerTwoName)
                    .font(.headline)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.purple)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
        }
    }

    private var gameOverView: some View {
        VStack(spacing: 18) {
            Text("Game Over")
                .font(.largeTitle.bold())

            Text("\(winnerName) Wins!")
                .font(.title.bold())

            Text("Final Score: \(playerOneName) \(playerOneScore) - \(playerTwoScore) \(playerTwoName)")
                .font(.headline)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

            Button {
                if vibration { HapticsManager.medium() }
                resetGame()
            } label: {
                Text("Play Again")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .padding(.top, 8)
        }
    }

    private func startCountdown() {
        currentWord = ""
        roundActive = false

        Task {
            for number in (1...3).reversed() {
                await MainActor.run {
                    countdownNumber = number
                    if vibration { HapticsManager.light() }
                }
                try? await Task.sleep(nanoseconds: 1_000_000_000)
            }

            await MainActor.run {
                countdownNumber = nil
                currentWord = nextWord()
                roundActive = true
                if vibration { HapticsManager.success() }
            }
        }
    }

    private func nextWord() -> String {
        let remainingWords = words.filter { !usedWords.contains($0) }

        let selectedWord: String
        if let random = remainingWords.randomElement() {
            selectedWord = random
        } else {
            usedWords.removeAll()
            selectedWord = words.randomElement() ?? "love"
        }

        usedWords.append(selectedWord)
        return selectedWord
    }

    private func givePoint(to player: Int) {
        guard roundActive else {
            if vibration { HapticsManager.error() }
            return
        }

        if vibration { HapticsManager.light() }

        if player == 1 {
            playerOneScore += 1
            if playerOneScore >= playTo {
                winnerName = playerOneName
                gameOver = true

                if vibration { HapticsManager.success() }

                if drinkingMode {
                    loserName = playerTwoName
                    showDrinkAlert = true
                }
            }
        } else {
            playerTwoScore += 1
            if playerTwoScore >= playTo {
                winnerName = playerTwoName
                gameOver = true

                if vibration { HapticsManager.success() }

                if drinkingMode {
                    loserName = playerOneName
                    showDrinkAlert = true
                }
            }
        }

        if !gameOver {
            roundActive = false
            currentWord = ""
        }
    }

    private func handleTie() {
        guard roundActive else {
            if vibration { HapticsManager.error() }
            return
        }

        if vibration { HapticsManager.medium() }

        roundActive = false
        currentWord = ""
    }

    private func resetGame() {
        playerOneScore = 0
        playerTwoScore = 0
        currentWord = ""
        countdownNumber = nil
        roundActive = false
        gameOver = false
        winnerName = ""
        usedWords.removeAll()
        showDrinkAlert = false
        loserName = ""
    }
}

#Preview {
    NavigationStack {
        SongBlitzGameView(
            playerOneName: "Alex",
            playerTwoName: "Jordan",
            playTo: 5
        )
    }
}
