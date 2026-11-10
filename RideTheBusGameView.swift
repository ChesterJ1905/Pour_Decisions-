import SwiftUI

struct RideTheBusGameView: View {
    struct Card: Equatable {
        let rank: Int
        let suit: String   // "club", "diamond", "heart", "spade"

        var isRed: Bool {
            suit == "diamond" || suit == "heart"
        }

        var rankText: String {
            switch rank {
            case 11: return "J"
            case 12: return "Q"
            case 13: return "K"
            case 14: return "A"
            default: return "\(rank)"
            }
        }

        var suitText: String {
            switch suit {
            case "club": return "Clubs"
            case "diamond": return "Diamonds"
            case "heart": return "Hearts"
            case "spade": return "Spades"
            default: return suit.capitalized
            }
        }
    }

    enum Stage {
        case color
        case higherLower
        case insideOutside
        case suit
        case won
        case lost
    }

    @AppStorage("drinkingMode") private var drinkingMode = false

    @State private var deck: [Card] = []
    @State private var revealedCards: [Card] = []
    @State private var stage: Stage = .color
    @State private var resultMessage = ""

    @State private var showDrinkAlert = false

    var body: some View {
        ZStack {
            AppGradientBackground()

            ScrollView {
                VStack {
                    VStack(spacing: 24) {
                        headerSection
                        cardSection
                        buttonSection

                        if stage == .won || stage == .lost {
                            Button {
                                HapticsManager.medium()
                                resetGame()
                            } label: {
                                Text("Play Again")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 54)
                            }
                            .buttonStyle(GameButtonStyle(background: .blue))
                        }
                    }
                    .frame(maxWidth: 430)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 28)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 28))
                    .shadow(color: .black.opacity(0.12), radius: 16, x: 0, y: 8)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 24)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .onAppear {
            resetGame()
        }
        .alert("Take a Sip", isPresented: $showDrinkAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("You lost this round. Take a sip.")
        }
    }

    private var headerSection: some View {
        VStack(spacing: 10) {
            Text("Ride the Bus")
                .font(.system(size: 32, weight: .bold))

            Text(stageTitle)
                .font(.title3)
                .fontWeight(.semibold)

            if !resultMessage.isEmpty {
                Text(resultMessage)
                    .font(.headline)
                    .foregroundStyle(messageColor)
                    .multilineTextAlignment(.center)
                    .padding(.top, 4)
            }
        }
    }

    private var cardSection: some View {
        VStack(spacing: 12) {
            Text("Cards")
                .font(.headline)
                .foregroundStyle(.secondary)

            HStack(spacing: 12) {
                ForEach(0..<4, id: \.self) { index in
                    if index < revealedCards.count {
                        GameCardView(card: revealedCards[index])
                    } else {
                        EmptyCardSlotView()
                    }
                }
            }
        }
    }

    private var stageTitle: String {
        switch stage {
        case .color:
            return "Guess Red or Black"
        case .higherLower:
            return "Guess Higher or Lower"
        case .insideOutside:
            return "Guess Inside or Outside"
        case .suit:
            return "Guess the Suit"
        case .won:
            return "You Win!"
        case .lost:
            return "You Lose!"
        }
    }

    private var messageColor: Color {
        switch stage {
        case .won:
            return .green
        case .lost:
            return .red
        default:
            return .primary
        }
    }

    @ViewBuilder
    private var buttonSection: some View {
        switch stage {
        case .color:
            ButtonRowView(
                firstTitle: "Red",
                firstColor: .red,
                firstAction: { guessColor(isRed: true) },
                secondTitle: "Black",
                secondColor: .black,
                secondAction: { guessColor(isRed: false) }
            )

        case .higherLower:
            ButtonRowView(
                firstTitle: "Higher",
                firstColor: .red,
                firstAction: { guessHigherLower(higher: true) },
                secondTitle: "Lower",
                secondColor: .black,
                secondAction: { guessHigherLower(higher: false) }
            )

        case .insideOutside:
            ButtonRowView(
                firstTitle: "Inside",
                firstColor: .red,
                firstAction: { guessInsideOutside(inside: true) },
                secondTitle: "Outside",
                secondColor: .black,
                secondAction: { guessInsideOutside(inside: false) }
            )

        case .suit:
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    SmallGuessButton(title: "Clubs", color: .black) {
                        guessSuit("club")
                    }

                    SmallGuessButton(title: "Diamonds", color: .red) {
                        guessSuit("diamond")
                    }
                }

                HStack(spacing: 12) {
                    SmallGuessButton(title: "Hearts", color: .red) {
                        guessSuit("heart")
                    }

                    SmallGuessButton(title: "Spades", color: .black) {
                        guessSuit("spade")
                    }
                }
            }

        case .won, .lost:
            EmptyView()
        }
    }

    private func resetGame() {
        deck = makeDeck().shuffled()
        revealedCards = []
        stage = .color
        resultMessage = "Make four correct guesses in a row."
        showDrinkAlert = false
    }

    private func drawCard() -> Card? {
        guard !deck.isEmpty else { return nil }
        return deck.removeFirst()
    }

    private func handleLoss(_ message: String) {
        resultMessage = message
        stage = .lost
        HapticsManager.error()

        if drinkingMode {
            showDrinkAlert = true
        }
    }

    private func guessColor(isRed: Bool) {
        HapticsManager.light()
        guard let card = drawCard() else { return }
        revealedCards.append(card)

        if card.isRed == isRed {
            resultMessage = "Correct! \(card.rankText) of \(card.suitText)."
            stage = .higherLower
            HapticsManager.success()
        } else {
            handleLoss("Wrong. It was the \(card.rankText) of \(card.suitText).")
        }
    }

    private func guessHigherLower(higher: Bool) {
        HapticsManager.light()
        guard revealedCards.count == 1 else { return }
        guard let newCard = drawCard() else { return }

        let first = revealedCards[0]
        revealedCards.append(newCard)

        if newCard.rank == first.rank {
            handleLoss("Wrong. Equal cards do not count.")
            return
        }

        let correct = higher ? (newCard.rank > first.rank) : (newCard.rank < first.rank)

        if correct {
            resultMessage = "Correct! \(newCard.rankText) is \(higher ? "higher" : "lower")."
            stage = .insideOutside
            HapticsManager.success()
        } else {
            handleLoss("Wrong. It was the \(newCard.rankText) of \(newCard.suitText).")
        }
    }

    private func guessInsideOutside(inside: Bool) {
        HapticsManager.light()
        guard revealedCards.count == 2 else { return }
        guard let newCard = drawCard() else { return }

        let first = revealedCards[0]
        let second = revealedCards[1]
        revealedCards.append(newCard)

        let low = min(first.rank, second.rank)
        let high = max(first.rank, second.rank)

        if newCard.rank == low || newCard.rank == high {
            handleLoss("Wrong. Matching an end value does not count.")
            return
        }

        let isInside = newCard.rank > low && newCard.rank < high
        let correct = inside ? isInside : !isInside

        if correct {
            resultMessage = "Correct! \(newCard.rankText) is \(inside ? "inside" : "outside")."
            stage = .suit
            HapticsManager.success()
        } else {
            handleLoss("Wrong. It was the \(newCard.rankText) of \(newCard.suitText).")
        }
    }

    private func guessSuit(_ guessedSuit: String) {
        HapticsManager.light()
        guard revealedCards.count == 3 else { return }
        guard let newCard = drawCard() else { return }

        revealedCards.append(newCard)

        if newCard.suit == guessedSuit {
            resultMessage = "Correct! Final card was the \(newCard.rankText) of \(newCard.suitText)."
            stage = .won
            HapticsManager.success()
        } else {
            handleLoss("Wrong. Final card was the \(newCard.rankText) of \(newCard.suitText).")
        }
    }

    private func makeDeck() -> [Card] {
        let suits = ["club", "diamond", "heart", "spade"]
        var cards: [Card] = []

        for suit in suits {
            for rank in 2...14 {
                cards.append(Card(rank: rank, suit: suit))
            }
        }

        return cards
    }
}

struct GameCardView: View {
    let card: RideTheBusGameView.Card

    var body: some View {
        PlayingCardView(rank: card.rank, suit: card.suit)
    }
}

struct PlayingCardView: View {
    let rank: Int
    let suit: String

    private var rankText: String {
        switch rank {
        case 11: return "J"
        case 12: return "Q"
        case 13: return "K"
        case 14: return "A"
        default: return "\(rank)"
        }
    }

    private var suitSymbol: String {
        switch suit {
        case "heart": return "♥"
        case "diamond": return "♦"
        case "club": return "♣"
        case "spade": return "♠"
        default: return "?"
        }
    }

    private var suitColor: Color {
        switch suit {
        case "heart", "diamond":
            return .red
        case "club", "spade":
            return .black
        default:
            return .gray
        }
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.white)

            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.black.opacity(0.12), lineWidth: 1.2)

            VStack(spacing: 6) {
                Text(rankText)
                    .font(.system(size: 24, weight: .heavy, design: .rounded))
                    .foregroundStyle(suitColor)

                Text(suitSymbol)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(suitColor)
            }
        }
        .frame(width: 72, height: 104)
        .shadow(color: .black.opacity(0.14), radius: 5, x: 0, y: 3)
    }
}

struct EmptyCardSlotView: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 18)
            .fill(Color.white.opacity(0.45))
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(Color.gray.opacity(0.35), style: StrokeStyle(lineWidth: 2, dash: [6]))
            )
            .frame(width: 72, height: 104)
    }
}

struct ButtonRowView: View {
    let firstTitle: String
    let firstColor: Color
    let firstAction: () -> Void
    let secondTitle: String
    let secondColor: Color
    let secondAction: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button(action: firstAction) {
                Text(firstTitle)
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .contentShape(Rectangle())
            }
            .buttonStyle(GameButtonStyle(background: firstColor))

            Button(action: secondAction) {
                Text(secondTitle)
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .contentShape(Rectangle())
            }
            .buttonStyle(GameButtonStyle(background: secondColor))
        }
    }
}

struct SmallGuessButton: View {
    let title: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .contentShape(Rectangle())
        }
        .buttonStyle(GameButtonStyle(background: color))
    }
}

struct GameButtonStyle: ButtonStyle {
    let background: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(background.opacity(configuration.isPressed ? 0.75 : 1))
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

#Preview {
    NavigationStack {
        RideTheBusGameView()
    }
}
