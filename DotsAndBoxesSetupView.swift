import SwiftUI

struct DotsAndBoxesSetupView: View {
    @State private var selectedTab = 0
    @State private var playerCount = 2
    @State private var boardSize = 3

    @State private var player1 = "Player 1"
    @State private var player2 = "Player 2"
    @State private var player3 = "Player 3"
    @State private var player4 = "Player 4"

    private var playerNames: [String] {
        let rawNames = [player1, player2, player3, player4]
        return Array(rawNames.prefix(playerCount)).enumerated().map { index, name in
            let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
            return trimmed.isEmpty ? "Player \(index + 1)" : trimmed
        }
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            setupTab
                .tabItem {
                    Label("Setup", systemImage: "slider.horizontal.3")
                }
                .tag(0)

            howToPlayTab
                .tabItem {
                    Label("How to Play", systemImage: "questionmark.circle")
                }
                .tag(1)
        }
        .navigationTitle("Dots & Boxes")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var setupTab: some View {//allows for change in grid size and player amount
        ZStack {
            AppGradientBackground()
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    titleCard

                    sectionCard(title: "Players") {
                        VStack(spacing: 14) {
                            Stepper(value: $playerCount, in: 2...4) {
                                HStack {
                                    Text("Number of Players")
                                        .font(.headline)
                                    Spacer()
                                    Text("\(playerCount)")
                                        .font(.headline.bold())
                                }
                            }

                            playerField("Player 1 Name", text: $player1)
                            playerField("Player 2 Name", text: $player2)

                            if playerCount >= 3 {
                                playerField("Player 3 Name", text: $player3)
                            }

                            if playerCount >= 4 {
                                playerField("Player 4 Name", text: $player4)
                            }
                        }
                    }

                    sectionCard(title: "Board Size") {
                        VStack(spacing: 14) {
                            Picker("Board Size", selection: $boardSize) {
                                Text("3 x 3").tag(3)
                                Text("4 x 4").tag(4)
                                Text("5 x 5").tag(5)
                            }
                            .pickerStyle(.segmented)

                            Text(boardDescription)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }

                    NavigationLink {
                        DotsAndBoxesGameView(
                            playerNames: playerNames,
                            boardSize: boardSize
                        )
                    } label: {
                        Text("Start Game")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    colors: [.blue.opacity(0.9), .teal.opacity(0.9)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 16)//padding is used for safe alignment across devices
                .padding(.top, 12)
                .padding(.bottom, 24)
            }
            .scrollContentBackground(.hidden)
            .background(Color.clear)
        }
    }

    private var howToPlayTab: some View {
        ZStack {
            AppGradientBackground()
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    titleCard

                    sectionCard(title: "How to Play") {//set up's guide to playing the game, shows up when using bubble bar located at the bottom
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Dots & Boxes is a turn-based game where players take turns drawing one line between two adjacent dots.")

                            Text("Rules")
                                .font(.headline)
                                .padding(.top, 4)

                            Text("1. Tap an empty line to claim it.")
                            Text("2. If your move completes a box, you get that box and score a point.")
                            Text("3. If you complete a box, you take another turn.")
                            Text("4. If you do not complete a box, the turn moves to the next player.")
                            Text("5. When all boxes are claimed, the player with the most boxes wins.")
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    sectionCard(title: "Tips") {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("• Small boards are quicker.")
                            Text("• Bigger boards are more strategic.")
                            Text("• Try not to hand another player an easy box.")
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 24)
            }
            .scrollContentBackground(.hidden)
            .background(Color.clear)
        }
    }

    private var titleCard: some View {//shown on the set up screen, not the guide screen
        VStack(spacing: 10) {
            Image(systemName: "square.grid.3x3")
                .font(.system(size: 40))
                .foregroundStyle(.white)

            Text("Dots & Boxes")
                .font(.largeTitle.bold())
                .foregroundStyle(.white)

            Text("Draw lines, complete boxes, and beat your friends.")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundStyle(.white.opacity(0.9))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .padding(.horizontal, 20)
        .background(.white.opacity(0.14))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(.white.opacity(0.18), lineWidth: 1.5)
        )
    }

    private func sectionCard<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {//the cards that player set up and game size set up are drawn on
        VStack(alignment: .leading, spacing: 14) {
            Text(title)
                .font(.title3.bold())

            content()
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(.white.opacity(0.15), lineWidth: 1)
        )
    }

    private func playerField(_ title: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline.weight(.semibold))

            TextField(title, text: text)
                .textFieldStyle(.plain)
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(.white.opacity(0.7))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
    }

    private var boardDescription: String {
        switch boardSize {
        case 3: return "Quick game with 9 boxes."
        case 4: return "Balanced game with 16 boxes."
        default: return "Longer game with 25 boxes."
        }
    }
}

#Preview {
    NavigationStack {
        DotsAndBoxesSetupView()
    }
}
