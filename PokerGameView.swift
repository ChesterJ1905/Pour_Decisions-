import SwiftUI

struct PokerPlayer: Identifiable {
    let id = UUID()
    let name: String
    var stack: Int
    var currentBet: Int = 0
    var isFolded: Bool = false
}

struct PokerGameView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var players: [PokerPlayer]
    @State private var pot: Int = 0
    @State private var currentPlayerIndex = 0
    @State private var betAmount: Int = 0
    @State private var showWinnerSelection = false
    @State private var selectedWinnerIndices: Set<Int> = []
    
    let smallBlind: Int
    let bigBlind: Int

    init(players: [String], initialStack: Int, smallBlind: Int) {
        _players = State(initialValue: players.map { PokerPlayer(name: $0, stack: initialStack) })
        self.smallBlind = smallBlind
        self.bigBlind = smallBlind * 2
    }

    var body: some View {
        ZStack {
            AppGradientBackground()
            
            VStack(spacing: 20) {
                // Table Info
                VStack {
                    Text("Total Pot")
                        .font(.subheadline)
                    Text("$\(pot)")
                        .font(.system(size: 48, weight: .black, design: .rounded))
                }
                .foregroundStyle(.white)
                .padding()
                .background(.black.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 25))

                // Player List
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(players.indices, id: \.self) { index in
                            playerRow(for: index)
                        }
                    }
                }

                // Betting Controls
                VStack(spacing: 15) {
                    HStack {
                        Text("Current Bet: $\(betAmount)")
                            .font(.headline)
                        Spacer()
                        Button("Reset Bet") { betAmount = 0 }
                    }
                    .foregroundStyle(.white)

                    HStack(spacing: 10) {
                        chipButton(10)
                        chipButton(50)
                        chipButton(100)
                        chipButton(500)
                    }

                    HStack(spacing: 20) {
                        actionButton(title: "Fold", color: .red) { fold() }
                        actionButton(title: "Commit Bet", color: .green) { commitBet() }
                    }
                }
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 30))
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("End Hand") { showWinnerSelection = true }
                    .foregroundStyle(.white)
            }
        }
        .sheet(isPresented: $showWinnerSelection) {
            winnerPickerSheet
        }
    }

    //Components
    
    private func playerRow(for index: Int) -> some View {
        let player = players[index]
        return HStack {
            Circle()
                .fill(player.isFolded ? .gray : .blue)
                .frame(width: 10, height: 10)
            
            VStack(alignment: .leading) {
                Text(player.name).bold()
                Text("Stack: $\(player.stack)").font(.caption)
            }
            Spacer()
            if player.currentBet > 0 {
                Text("Bet: $\(player.currentBet)")
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(.white.opacity(0.2))
                    .clipShape(Capsule())
            }
        }
        .padding()
        .background(index == currentPlayerIndex ? .white.opacity(0.3) : .white.opacity(0.1))
        .foregroundStyle(.white)
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .onTapGesture { currentPlayerIndex = index }
    }

    private func chipButton(_ amount: Int) -> some View {
        Button {
            betAmount += amount
        } label: {
            Circle()
                .fill(.white.opacity(0.2))
                .frame(width: 60, height: 60)
                .overlay(Text("+\(amount)").font(.caption).bold().foregroundStyle(.white))
        }
    }

    private func actionButton(title: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .bold()
                .frame(maxWidth: .infinity)
                .padding()
                .background(color.opacity(0.8))
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 15))
        }
    }

    //Logic

    private func commitBet() {
        if players[currentPlayerIndex].stack >= betAmount {
            players[currentPlayerIndex].stack -= betAmount
            players[currentPlayerIndex].currentBet += betAmount
            pot += betAmount
            betAmount = 0
        }
    }
    
    private func awardPot() {
        guard !selectedWinnerIndices.isEmpty else { return }
        
        let winnerCount = selectedWinnerIndices.count
        let share = pot / winnerCount
        let remainder = pot % winnerCount // The "Odd Chip"
        
        for index in selectedWinnerIndices {
            players[index].stack += share
        }
        
        // Logic: Give the leftover $1 or "odd chip" to the first selected winner
        if remainder > 0, let firstWinner = selectedWinnerIndices.first {
            players[firstWinner].stack += remainder
        }
        
        HapticsManager.heavy()
        resetForNewHand()
        selectedWinnerIndices.removeAll()
        showWinnerSelection = false
    }

    private func fold() {
        players[currentPlayerIndex].isFolded = true
        betAmount = 0
    }

    private var winnerPickerSheet: some View {
        ZStack {
            AppGradientBackground()
            VStack(spacing: 20) {
                Text("Select Winner(s)")
                    .font(.title.bold())
                    .foregroundStyle(.white)
                    .padding(.top)
                
                Text("Tap all players who tied. The pot will split automatically.")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(players.indices, id: \.self) { index in
                            if !players[index].isFolded {
                                Button {
                                    if selectedWinnerIndices.contains(index) {
                                        selectedWinnerIndices.remove(index)
                                    } else {
                                        selectedWinnerIndices.insert(index)
                                    }
                                    HapticsManager.light()
                                } label: {
                                    HStack {
                                        Text(players[index].name)
                                            .font(.headline)
                                        Spacer()
                                        if selectedWinnerIndices.contains(index) {
                                            Image(systemName: "checkmark.circle.fill")
                                                .font(.title2)
                                        }
                                    }
                                    .padding()
                                    .background(selectedWinnerIndices.contains(index) ? .white.opacity(0.4) : .white.opacity(0.1))
                                    .foregroundStyle(.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 15))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 15)
                                            .stroke(.white.opacity(selectedWinnerIndices.contains(index) ? 0.6 : 0), lineWidth: 2)
                                    )
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                }

                Button {
                    awardPot()
                } label: {
                    Text(selectedWinnerIndices.count > 1 ? "Split Pot" : "Award Pot")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(selectedWinnerIndices.isEmpty ? Color.gray : Color.green)
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                        .padding()
                }
                .disabled(selectedWinnerIndices.isEmpty)
            }
        }
    }

    private func resetForNewHand() {
        pot = 0
        for i in 0..<players.count {
            players[i].currentBet = 0
            players[i].isFolded = false
        }
    }
}
