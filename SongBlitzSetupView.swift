import SwiftUI

struct SongBlitzSetupView: View {
    var body: some View {
        TabView {
            SongBlitzSetupFormView()
                .tabItem {
                    Label("Setup", systemImage: "slider.horizontal.3")
                }

            SongBlitzHowToPlayView()
                .tabItem {
                    Label("How to Play", systemImage: "questionmark.circle")
                }
        }
        .navigationTitle("Song Blitz")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct SongBlitzSetupFormView: View {
    @State private var playerOneName = ""
    @State private var playerTwoName = ""
    @State private var playTo = 5

    var body: some View {
        ZStack {
            AppGradientBackground()
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    Text("Song Blitz")
                        .font(.largeTitle.bold())
                        .multilineTextAlignment(.center)

                    Text("Race to name a song that contains the shown word.")
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal)

                    VStack(alignment: .leading, spacing: 18) {
                        Text("Game Setup")
                            .font(.title3.bold())

                        Stepper(value: $playTo, in: 1...50) {
                            HStack {
                                Text("Play To")
                                Spacer()
                                Text("\(playTo)")
                                    .font(.headline.bold())
                            }
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Player 1 Name")
                                .font(.headline)

                            TextField("Enter Player 1 name", text: $playerOneName)
                                .textFieldStyle(.roundedBorder)
                                .autocorrectionDisabled()
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Player 2 Name")
                                .font(.headline)

                            TextField("Enter Player 2 name", text: $playerTwoName)
                                .textFieldStyle(.roundedBorder)
                                .autocorrectionDisabled()
                        }
                    }
                    .padding()
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))

                    NavigationLink {
                        SongBlitzGameView(
                            playerOneName: finalPlayerOneName,
                            playerTwoName: finalPlayerTwoName,
                            playTo: playTo
                        )
                    } label: {
                        Text("Start Game")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }

                    Spacer(minLength: 24)
                }
                .padding()
                .padding(.bottom, 12)
            }
            .scrollContentBackground(.hidden)
        }
    }

    private var finalPlayerOneName: String {
        let trimmed = playerOneName.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "Player 1" : trimmed
    }

    private var finalPlayerTwoName: String {
        let trimmed = playerTwoName.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "Player 2" : trimmed
    }
}

private struct SongBlitzHowToPlayView: View {
    var body: some View {
        ZStack {
            AppGradientBackground()
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    Text("How to Play")
                        .font(.largeTitle.bold())

                    Text("Song Blitz is a fast music battle between two players.")
                        .font(.headline)
                        .foregroundStyle(.secondary)

                    VStack(alignment: .leading, spacing: 12) {
                        Text("1. Enter both player names and choose the score limit.")
                        Text("2. Go to the game and tap Ready when both players are set.")
                        Text("3. A countdown begins.")
                        Text("4. A random word appears on the screen.")
                        Text("5. Both players race to say a song title that includes that word.")
                        Text("6. Tap Player 1, Tie, or Player 2 based on the result.")
                        Text("7. Keep playing until one player reaches the selected score.")
                    }
                    .font(.body)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Example Words")
                            .font(.headline)

                        Text("Love, night, fire, baby, stars, heart, dance, road, dream, moon, light")
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .padding(.bottom, 24)
            }
            .scrollContentBackground(.hidden)
        }
    }
}

#Preview {
    NavigationStack {
        SongBlitzSetupView()
    }
}
