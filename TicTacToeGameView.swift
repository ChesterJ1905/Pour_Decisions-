import SwiftUI

struct TicTacToeGameView: View {
    let mode: TicTacToeMode

    @AppStorage("drinkingMode") private var drinkingMode = false
    @AppStorage("vibration") private var vibration = true

    @State private var board: [String] = Array(repeating: "", count: 9)
    @State private var currentPlayer: String = "X"
    @State private var winner: String? = nil
    @State private var isDraw = false

    @State private var xMoveOrder: [Int] = []
    @State private var oMoveOrder: [Int] = []

    @State private var animateOldestPiece = false

    @State private var showDrinkAlert = false
    @State private var loser: String = ""

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 3)

    var body: some View {
        ZStack {
            AppGradientBackground()

            VStack(spacing: 22) {
                Text(mode.rawValue)
                    .font(.title.weight(.bold))
                    .foregroundStyle(.white)

                statusView

                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(0..<9, id: \.self) { index in
                        Button {
                            handleTap(index)
                        } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(squareFill(for: index))
                                    .frame(height: 105)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(squareBorder(for: index), lineWidth: squareBorderWidth(for: index))
                                    )

                                Text(board[index])
                                    .font(.system(size: 48, weight: .heavy, design: .rounded))
                                    .foregroundStyle(symbolColor(for: board[index]))
                                    .offset(x: shakeOffset(for: index))
                                    .animation(
                                        isOldestCurrentPlayerPiece(index)
                                        ? .easeInOut(duration: 0.12).repeatForever(autoreverses: true)
                                        : .default,
                                        value: animateOldestPiece
                                    )
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.top, 8)
                .onAppear { startOldestPieceAnimation() }
                .onChange(of: currentPlayer) { _, _ in startOldestPieceAnimation() }
                .onChange(of: xMoveOrder) { _, _ in startOldestPieceAnimation() }
                .onChange(of: oMoveOrder) { _, _ in startOldestPieceAnimation() }

                Button {
                    if vibration { HapticsManager.medium() }
                    resetGame()
                } label: {
                    Text("Reset Game")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(.black.opacity(0.3))
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(.white.opacity(0.35), lineWidth: 1)
                        )
                }
                .padding(.top, 6)

                Spacer()
            }
            .padding(24)
        }
        .navigationTitle("Game")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Drink Time 🍻", isPresented: $showDrinkAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("\(loser) has to finish their drink!")
        }
    }

    private var statusView: some View {
        VStack(spacing: 8) {
            if let winner {
                Text("\(winner) Wins!")
                    .font(.system(size: 30, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
            } else if isDraw {
                Text("It's a Draw!")
                    .font(.system(size: 28, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
            } else {
                Text("\(currentPlayer)'s Turn")
                    .font(.system(size: 28, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)

                if mode == .modern, let oldest = oldestPieceIndexForCurrentPlayer() {
                    Text("\(currentPlayer) at square \(oldest + 1) will disappear next")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.9))
                }
            }
        }
    }

    private func handleTap(_ index: Int) {
        guard board[index].isEmpty, winner == nil, !isDraw else {
            if vibration { HapticsManager.error() }
            return
        }

        if vibration { HapticsManager.light() }

        if mode == .modern {
            placeModernMove(at: index)
        } else {
            board[index] = currentPlayer
        }

        if let foundWinner = checkWinner() {
            winner = foundWinner
            animateOldestPiece = false

            if vibration { HapticsManager.success() }

            if drinkingMode {
                loser = (foundWinner == "X") ? "O" : "X"
                showDrinkAlert = true
            }
            return
        }

        if mode == .classic && !board.contains("") {
            isDraw = true
            animateOldestPiece = false

            if vibration { HapticsManager.medium() }
            return
        }

        currentPlayer = currentPlayer == "X" ? "O" : "X"
    }

    private func placeModernMove(at index: Int) {
        if currentPlayer == "X" {
            if xMoveOrder.count == 3 {
                let oldestIndex = xMoveOrder.removeFirst()
                board[oldestIndex] = ""
            }
            board[index] = "X"
            xMoveOrder.append(index)
        } else {
            if oMoveOrder.count == 3 {
                let oldestIndex = oMoveOrder.removeFirst()
                board[oldestIndex] = ""
            }
            board[index] = "O"
            oMoveOrder.append(index)
        }
    }

    private func checkWinner() -> String? {
        let winningCombos = [
            [0,1,2],[3,4,5],[6,7,8],
            [0,3,6],[1,4,7],[2,5,8],
            [0,4,8],[2,4,6]
        ]

        for combo in winningCombos {
            let a = combo[0], b = combo[1], c = combo[2]
            if !board[a].isEmpty && board[a] == board[b] && board[b] == board[c] {
                return board[a]
            }
        }
        return nil
    }

    private func resetGame() {
        board = Array(repeating: "", count: 9)
        currentPlayer = "X"
        winner = nil
        isDraw = false
        xMoveOrder = []
        oMoveOrder = []
        startOldestPieceAnimation()
    }

    private func symbolColor(for symbol: String) -> Color {
        switch symbol {
        case "X": return .red
        case "O": return .blue
        default: return .white
        }
    }

    private func oldestPieceIndexForCurrentPlayer() -> Int? {
        guard mode == .modern else { return nil }
        return currentPlayer == "X"
            ? (xMoveOrder.count == 3 ? xMoveOrder.first : nil)
            : (oMoveOrder.count == 3 ? oMoveOrder.first : nil)
    }

    private func isOldestCurrentPlayerPiece(_ index: Int) -> Bool {
        oldestPieceIndexForCurrentPlayer() == index && winner == nil && !isDraw
    }

    private func shakeOffset(for index: Int) -> CGFloat {
        guard isOldestCurrentPlayerPiece(index), animateOldestPiece else { return 0 }
        return 4
    }

    private func squareFill(for index: Int) -> Color {
        isOldestCurrentPlayerPiece(index) ? .white.opacity(0.75) : .white.opacity(0.65)
    }

    private func squareBorder(for index: Int) -> Color {
        isOldestCurrentPlayerPiece(index) ? .yellow.opacity(0.95) : .white.opacity(0.35)
    }

    private func squareBorderWidth(for index: Int) -> CGFloat {
        isOldestCurrentPlayerPiece(index) ? 3 : 1
    }

    private func startOldestPieceAnimation() {
        animateOldestPiece = false
        guard mode == .modern,
              oldestPieceIndexForCurrentPlayer() != nil,
              winner == nil,
              !isDraw else { return }

        DispatchQueue.main.async {
            animateOldestPiece = true
        }
    }
}
