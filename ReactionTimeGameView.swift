import SwiftUI

struct ReactionTimeGameView: View {
    let totalRounds: Int

    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    @State private var currentRound = 1
    @State private var gameState: ReactionState = .ready
    @State private var reactionTimes: [Double] = []
    @State private var startDate: Date?
    @State private var waitTask: DispatchWorkItem?
    @State private var showFalseStartAlert = false
    @State private var hasTriggeredTouch = false
    @State private var inputLocked = false

    enum ReactionState {
        case ready
        case waiting
        case tapNow
        case result
        case finished
    }

    var body: some View {
        ZStack {
            AppGradientBackground()

            VStack(spacing: 18) {
                topBar
                roundCard
                playArea
                statsCard

                if gameState == .finished {
                    finishedButtons
                }

                Spacer(minLength: 8)
            }
            .padding()
        }
        .navigationTitle("Reaction Time")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Too Soon!", isPresented: $showFalseStartAlert) {
            Button("Try Again", role: .cancel) {
                resetCurrentRound()
            }
        } message: {
            Text("Wait until the screen turns green before tapping.")
        }
        .onDisappear {
            waitTask?.cancel()
        }
    }

    private var cardFill: Color {
        colorScheme == .dark ? .white.opacity(0.12) : .white.opacity(0.78)
    }

    private var cardStroke: Color {
        colorScheme == .dark ? .white.opacity(0.18) : .black.opacity(0.08)
    }

    private var primaryText: Color {
        colorScheme == .dark ? .white : .black
    }

    private var secondaryText: Color {
        colorScheme == .dark ? .white.opacity(0.84) : .black.opacity(0.68)
    }

    private var actionFill: Color {
        colorScheme == .dark ? .white : .black.opacity(0.82)
    }

    private var actionText: Color {
        colorScheme == .dark ? .black : .white
    }

    private var topBar: some View {
        HStack {
            Button {
                HapticsManager.light()
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.headline.bold())
                    .foregroundStyle(primaryText)
                    .padding(12)
                    .background(cardFill, in: Circle())
                    .overlay(
                        Circle().stroke(cardStroke, lineWidth: 1)
                    )
            }

            Spacer()

            Text("Reaction Time")
                .font(.title2.bold())
                .foregroundStyle(primaryText)

            Spacer()

            Circle()
                .fill(.clear)
                .frame(width: 44, height: 44)
        }
    }

    private var roundCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Round")
                    .font(.subheadline)
                    .foregroundStyle(secondaryText)

                Text("\(min(currentRound, totalRounds)) / \(totalRounds)")
                    .font(.title2.bold())
                    .foregroundStyle(primaryText)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text("State")
                    .font(.subheadline)
                    .foregroundStyle(secondaryText)

                Text(stateLabel)
                    .font(.headline.bold())
                    .foregroundStyle(primaryText)
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(cardFill)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(cardStroke, lineWidth: 1)
        )
    }

    private var playArea: some View {
        ZStack {
            VStack(spacing: 16) {
                Image(systemName: stateIcon)
                    .font(.system(size: 54, weight: .bold))
                    .foregroundStyle(.white)

                Text(mainMessage)
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white)

                Text(subMessage)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white.opacity(0.9))
                    .padding(.horizontal, 8)
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: 300)
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .fill(playAreaColor)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .stroke(.white.opacity(0.15), lineWidth: 1)
            )
        }
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    handleTapAreaPressed()
                }
        )
        .animation(nil, value: gameState)
    }

    private var statsCard: some View {
        VStack(spacing: 14) {
            HStack(spacing: 12) {
                statBox(title: "Last", value: lastTimeText)
                statBox(title: "Best", value: bestTimeText)
            }

            statBox(title: "Average", value: averageTimeText)
        }
    }

    private func statBox(title: String, value: String) -> some View {
        VStack(spacing: 6) {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(secondaryText)

            Text(value)
                .font(.title3.bold())
                .foregroundStyle(primaryText)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(cardFill)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(cardStroke, lineWidth: 1)
        )
    }

    private var finishedButtons: some View {
        VStack(spacing: 12) {
            Button {
                HapticsManager.medium()
                restartGame()
            } label: {
                HStack {
                    Spacer()
                    Label("Play Again", systemImage: "arrow.clockwise")
                        .font(.headline.bold())
                        .foregroundStyle(actionText)
                    Spacer()
                }
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(actionFill)
                )
            }
            .buttonStyle(.plain)

            Button {
                HapticsManager.light()
                dismiss()
            } label: {
                HStack {
                    Spacer()
                    Label("Back", systemImage: "house")
                        .font(.headline.bold())
                        .foregroundStyle(primaryText)
                    Spacer()
                }
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(cardFill)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(cardStroke, lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
        }
    }

    private var stateLabel: String {
        switch gameState {
        case .ready: return "Ready"
        case .waiting: return "Waiting..."
        case .tapNow: return "TAP!"
        case .result: return "Recorded"
        case .finished: return "Finished"
        }
    }

    private var stateIcon: String {
        switch gameState {
        case .ready: return "hand.tap.fill"
        case .waiting: return "hourglass"
        case .tapNow: return "bolt.fill"
        case .result: return "checkmark.circle.fill"
        case .finished: return "trophy.fill"
        }
    }

    private var mainMessage: String {
        switch gameState {
        case .ready:
            return "Tap to Ready Up"
        case .waiting:
            return "Wait..."
        case .tapNow:
            return "TAP!"
        case .result:
            return lastTimeText
        case .finished:
            return "Done!"
        }
    }

    private var subMessage: String {
        switch gameState {
        case .ready:
            return "Tap this box when you're ready."
        case .waiting:
            return "Do not tap until the screen turns green."
        case .tapNow:
            return "Tap now."
        case .result:
            return currentRound >= totalRounds
                ? "Tap this box to finish."
                : "Tap this box for the next round."
        case .finished:
            return "Best: \(bestTimeText) • Average: \(averageTimeText)"
        }
    }

    private var playAreaColor: Color {
        switch gameState {
        case .ready:
            return .blue.opacity(0.82)
        case .waiting:
            return .red.opacity(0.86)
        case .tapNow:
            return .green.opacity(0.88)
        case .result:
            return .orange.opacity(0.9)
        case .finished:
            return .purple.opacity(0.85)
        }
    }

    private var lastTimeText: String {
        guard let last = reactionTimes.last else { return "-- ms" }
        return "\(Int(last)) ms"
    }

    private var bestTimeText: String {
        guard let best = reactionTimes.min() else { return "-- ms" }
        return "\(Int(best)) ms"
    }

    private var averageTimeText: String {
        guard !reactionTimes.isEmpty else { return "-- ms" }
        let avg = reactionTimes.reduce(0, +) / Double(reactionTimes.count)
        return "\(Int(avg)) ms"
    }

    private func handleTapAreaPressed() {
        guard !inputLocked, !hasTriggeredTouch else { return }

        hasTriggeredTouch = true
        inputLocked = true

        // Small buffer to stop multiple triggers from one press
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            inputLocked = false
            hasTriggeredTouch = false
        }

        switch gameState {
        case .ready:
            startRound()

        case .waiting:
            waitTask?.cancel()
            HapticsManager.medium()
            showFalseStartAlert = true

        case .tapNow:
            recordReaction()

        case .result:
            if currentRound >= totalRounds {
                gameState = .finished
                HapticsManager.medium()
            } else {
                currentRound += 1
                gameState = .ready
                HapticsManager.light()
            }

        case .finished:
            break
        }
    }

    private func startRound() {
        HapticsManager.light()
        gameState = .waiting
        startDate = nil
        waitTask?.cancel()

        let delay = Double.random(in: 2.0...5.0)

        let task = DispatchWorkItem {
            startDate = Date()
            gameState = .tapNow
            HapticsManager.medium()
        }

        waitTask = task
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: task)
    }

    private func recordReaction() {
        guard let startDate else { return }

        let reaction = Date().timeIntervalSince(startDate) * 1000
        reactionTimes.append(reaction)

        var transaction = Transaction()
        transaction.disablesAnimations = true

        withTransaction(transaction) {
            self.startDate = nil
            gameState = .result
        }

        HapticsManager.medium()
    }

    private func resetCurrentRound() {
        waitTask?.cancel()
        gameState = .ready
        startDate = nil
    }

    private func restartGame() {
        waitTask?.cancel()
        currentRound = 1
        reactionTimes = []
        startDate = nil
        gameState = .ready
    }
}
