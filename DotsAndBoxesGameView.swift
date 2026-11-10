import SwiftUI

struct DotsAndBoxesGameView: View {
    let playerNames: [String]
    let boardSize: Int

    @AppStorage("drinkingMode") private var drinkingMode = false

    @State private var horizontalLines: Set<LineID> = []
    @State private var verticalLines: Set<LineID> = []
    @State private var claimedBoxes: [BoxID: Int] = [:]//Variable that acts as the score tracker, more boxes = more points
    @State private var lineOwners: [EdgeID: Int] = [:]

    @State private var currentPlayer = 0
    @State private var showGameOverAlert = false
    @State private var showDrinkAlert = false
    @State private var loserNames = ""

    private let playerColors: [Color] = [.blue, .pink, .green, .orange]

    private var scores: [Int] {
        var result = Array(repeating: 0, count: playerNames.count)
        for owner in claimedBoxes.values {
            if owner < result.count {
                result[owner] += 1
            }
        }
        return result
    }

    private var totalBoxes: Int {//area of squares (squared)
        boardSize * boardSize
    }

    private var isGameOver: Bool {
        claimedBoxes.count == totalBoxes
    }

    var body: some View {
        ZStack {
            AppGradientBackground()
                .ignoresSafeArea()

            VStack(spacing: 12) {
                headerCard
                scoreRow

                Spacer(minLength: 0)

                boardSection

                Spacer(minLength: 0)

                footerBar
            }
            .padding(.horizontal, 16)
            .padding(.top, 10)
            .padding(.bottom, 16)
        }
        .navigationTitle("Dots & Boxes")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Game Over", isPresented: $showGameOverAlert) {
            Button("Play Again") {
                resetGame()
            }
            Button("OK", role: .cancel) { }
        } message: {
            Text(gameOverMessage)
        }
        .alert("Drink Time 🍻", isPresented: $showDrinkAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(drinkMessage)
        }
    }

    private var headerCard: some View {//top heading within game
        VStack(spacing: 6) {
            Text("Current Turn")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

            Text(playerNames[currentPlayer])
                .font(.title3.bold())
                .foregroundStyle(playerColors[currentPlayer % playerColors.count])
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .padding(.horizontal, 14)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(.white.opacity(0.15), lineWidth: 1)
        )
    }

    private var scoreRow: some View {
        HStack(spacing: 8) {
            ForEach(playerNames.indices, id: \.self) { index in
                VStack(spacing: 2) {
                    Text(playerNames[index])
                        .font(.caption.bold())
                        .lineLimit(1)
                        .minimumScaleFactor(0.65)

                    Text("\(scores[index])")
                        .font(.headline.bold())
                }
                .foregroundStyle(currentPlayer == index ? .white : .primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .padding(.horizontal, 6)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(
                            currentPlayer == index
                            ? playerColors[index % playerColors.count].opacity(0.95)
                            : Color.white.opacity(0.78)
                        )
                )
            }
        }
    }

    private var boardSection: some View {//layout og game with hard-coded measurements
        GeometryReader { geo in
            let availableWidth = geo.size.width
            let availableHeight = geo.size.height

            let side = min(availableWidth, availableHeight)
            let dotSize: CGFloat = 14
            let lineThickness: CGFloat = 12
            let step = (side - dotSize) / CGFloat(boardSize)

            ZStack {//fills in each line si played with red or blue when selected
                ForEach(0..<boardSize, id: \.self) { row in
                    ForEach(0..<boardSize, id: \.self) { col in
                        let box = BoxID(row: row, col: col)

                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(boxColor(box))
                            .frame(width: step - 24, height: step - 24)
                            .position(
                                x: CGFloat(col) * step + step / 2 + dotSize / 2,
                                y: CGFloat(row) * step + step / 2 + dotSize / 2
                            )

                        if let owner = claimedBoxes[box] {
                            Text(initials(for: playerNames[owner]))
                                .font(.subheadline.bold())
                                .foregroundStyle(.white)
                                .position(
                                    x: CGFloat(col) * step + step / 2 + dotSize / 2,
                                    y: CGFloat(row) * step + step / 2 + dotSize / 2
                                )
                        }
                    }
                }

                ForEach(0...boardSize, id: \.self) { row in
                    ForEach(0..<boardSize, id: \.self) { col in
                        let line = LineID(row: row, col: col)
                        let edge = EdgeID.horizontal(line)
                        let claimed = horizontalLines.contains(line)

                        Button {
                            claimHorizontal(line)
                        } label: {
                            Capsule()
                                .fill(claimed ? colorForEdge(edge) : Color.white.opacity(0.22))
                                .frame(width: step - 18, height: lineThickness)
                                .overlay(
                                    Capsule()
                                        .stroke(.white.opacity(claimed ? 0 : 0.3), lineWidth: 1)
                                )
                        }
                        .buttonStyle(.plain)
                        .disabled(claimed || isGameOver)
                        .position(
                            x: CGFloat(col) * step + step / 2 + dotSize / 2,
                            y: CGFloat(row) * step + dotSize / 2
                        )
                    }
                }

                ForEach(0..<boardSize, id: \.self) { row in
                    ForEach(0...boardSize, id: \.self) { col in
                        let line = LineID(row: row, col: col)
                        let edge = EdgeID.vertical(line)
                        let claimed = verticalLines.contains(line)

                        Button {
                            claimVertical(line)
                        } label: {
                            Capsule()
                                .fill(claimed ? colorForEdge(edge) : Color.white.opacity(0.22))
                                .frame(width: lineThickness, height: step - 18)
                                .overlay(
                                    Capsule()
                                        .stroke(.white.opacity(claimed ? 0 : 0.3), lineWidth: 1)
                                )
                        }
                        .buttonStyle(.plain)
                        .disabled(claimed || isGameOver)
                        .position(
                            x: CGFloat(col) * step + dotSize / 2,
                            y: CGFloat(row) * step + step / 2 + dotSize / 2
                        )
                    }
                }

                ForEach(0...boardSize, id: \.self) { row in
                    ForEach(0...boardSize, id: \.self) { col in
                        Circle()
                            .fill(.white)
                            .frame(width: dotSize, height: dotSize)
                            .shadow(radius: 2)
                            .position(
                                x: CGFloat(col) * step + dotSize / 2,
                                y: CGFloat(row) * step + dotSize / 2
                            )
                    }
                }
            }
            .frame(width: side, height: side, alignment: .center)
            .position(x: geo.size.width / 2, y: geo.size.height / 2)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var footerBar: some View {//bottom bar with the retart button and turn indicator
        HStack(spacing: 10) {
            Button {
                resetGame()
            } label: {
                Label("Restart", systemImage: "arrow.clockwise")
                    .font(.subheadline.bold())
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(.white.opacity(0.18))
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }

            Text("\(claimedBoxes.count)/\(totalBoxes)")
                .font(.subheadline.bold())
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(.black.opacity(0.18))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }

    private func claimHorizontal(_ line: LineID) {
        guard !horizontalLines.contains(line), !isGameOver else { return }

        horizontalLines.insert(line)
        lineOwners[.horizontal(line)] = currentPlayer

        let madeBox = checkBoxesAfterHorizontal(line)

        if !madeBox {
            currentPlayer = (currentPlayer + 1) % playerNames.count
        }

        handleGameEndIfNeeded()
    }

    private func claimVertical(_ line: LineID) {
        guard !verticalLines.contains(line), !isGameOver else { return }

        verticalLines.insert(line)
        lineOwners[.vertical(line)] = currentPlayer

        let madeBox = checkBoxesAfterVertical(line)

        if !madeBox {
            currentPlayer = (currentPlayer + 1) % playerNames.count
        }

        handleGameEndIfNeeded()
    }

    private func handleGameEndIfNeeded() {
        guard isGameOver else { return }

        showGameOverAlert = true

        if drinkingMode {
            let lowScore = scores.min() ?? 0
            let losers = scores.enumerated().filter { $0.element == lowScore }.map(\.offset)
            loserNames = losers.map { playerNames[$0] }.joined(separator: ", ")
            showDrinkAlert = true
        }
    }

    private func checkBoxesAfterHorizontal(_ line: LineID) -> Bool {//if box was completed with horizontal line
        var completedAny = false

        let possible = [
            BoxID(row: line.row - 1, col: line.col),
            BoxID(row: line.row, col: line.col)
        ]

        for box in possible where isValid(box) {
            if claimedBoxes[box] == nil && isComplete(box) {
                claimedBoxes[box] = currentPlayer
                completedAny = true
            }
        }

        return completedAny
    }

    private func checkBoxesAfterVertical(_ line: LineID) -> Bool {//if box was completed with vertical line
        var completedAny = false

        let possible = [
            BoxID(row: line.row, col: line.col - 1),
            BoxID(row: line.row, col: line.col)
        ]

        for box in possible where isValid(box) {
            if claimedBoxes[box] == nil && isComplete(box) {
                claimedBoxes[box] = currentPlayer
                completedAny = true
            }
        }

        return completedAny
    }

    private func isComplete(_ box: BoxID) -> Bool {
        let top = LineID(row: box.row, col: box.col)
        let bottom = LineID(row: box.row + 1, col: box.col)
        let left = LineID(row: box.row, col: box.col)
        let right = LineID(row: box.row, col: box.col + 1)

        return horizontalLines.contains(top)
            && horizontalLines.contains(bottom)
            && verticalLines.contains(left)
            && verticalLines.contains(right)
    }

    private func isValid(_ box: BoxID) -> Bool {
        box.row >= 0 && box.col >= 0 && box.row < boardSize && box.col < boardSize
    }

    private func boxColor(_ box: BoxID) -> Color {
        guard let owner = claimedBoxes[box] else { return .clear }
        return playerColors[owner % playerColors.count].opacity(0.72)
    }

    private func colorForEdge(_ edge: EdgeID) -> Color {//function when game
        if let owner = lineOwners[edge] {
            return playerColors[owner % playerColors.count]
        }
        return .white
    }

    private func resetGame() {
        horizontalLines.removeAll()
        verticalLines.removeAll()
        claimedBoxes.removeAll()
        lineOwners.removeAll()
        currentPlayer = 0
        showGameOverAlert = false
        showDrinkAlert = false
        loserNames = ""
    }

    private func initials(for name: String) -> String {
        let letters = name
            .split(separator: " ")
            .prefix(2)
            .map { String($0.prefix(1)).uppercased() }

        return letters.isEmpty ? "P" : letters.joined()
    }

    private var gameOverMessage: String {//when game finishes
        let highScore = scores.max() ?? 0
        let winners = scores.enumerated().filter { $0.element == highScore }.map(\.offset)

        if winners.count == 1, let winner = winners.first {
            return "\(playerNames[winner]) wins with \(highScore) boxes."
        } else {
            let names = winners.map { playerNames[$0] }.joined(separator: ", ")
            return "Tie between \(names) with \(highScore) boxes each."
        }
    }

    private var drinkMessage: String {
        if loserNames.isEmpty {
            return "The loser has to finish their drink!"
        } else {
            return "\(loserNames) ha\(loserNames.contains(",") ? "ve" : "s") to finish their drink!"
        }
    }
}

private struct LineID: Hashable {//each line struct
    let row: Int
    let col: Int
}

private struct BoxID: Hashable {
    let row: Int
    let col: Int
}

private enum EdgeID: Hashable {
    case horizontal(LineID)
    case vertical(LineID)
}

#Preview {
    NavigationStack {
        DotsAndBoxesGameView(
            playerNames: ["P1", "P2", "P3", "P4"],//usually only uses two players, but up to 4 works
            boardSize: 4
        )
    }
}
