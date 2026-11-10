import SwiftUI

struct RideTheBusSetupView: View {
    var body: some View {
        TabView {
            RideTheBusGameView()
                .tabItem {
                    Label("Play", systemImage: "play.circle")
                }

            RideTheBusInfoView()
                .tabItem {
                    Label("How to Play", systemImage: "book")
                }
        }
        .navigationTitle("Ride the Bus")
        .navigationBarTitleDisplayMode(.inline)
    }
}

import SwiftUI

struct RideTheBusInfoView: View {
    var body: some View {
        ZStack {
            AppGradientBackground()

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    infoCard {
                        Text("How to Play")
                            .font(.title2)
                            .bold()

                        Text("Ride the Bus is a single-player card guessing game. The goal is to make four correct guesses in a row.")
                    }

                    infoCard {
                        Text("Game Order")
                            .font(.headline)

                        VStack(alignment: .leading, spacing: 10) {
                            Text("1. Guess whether the first card will be red or black.")
                            Text("2. Guess whether the second card will be higher or lower than the first card.")
                            Text("3. Guess whether the third card will be inside or outside the first two card values.")
                            Text("4. Guess the suit of the final card.")
                        }
                    }

                    infoCard {
                        Text("Rules")
                            .font(.headline)

                        VStack(alignment: .leading, spacing: 10) {
                            Text("• If you get any guess wrong, the game resets and you lose.")
                            Text("• Equal values do not count as higher or lower.")
                            Text("• If the third card matches one of the first two values, it does not count as inside or outside.")
                            Text("• You must complete all four guesses correctly to win.")
                        }
                    }

                    infoCard {
                        Text("Roles")
                            .font(.headline)

                        Text("This is a single-player game, so there are no special roles.")
                    }
                }
                .padding(24)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .clipShape(
                RoundedRectangle(cornerRadius: 30, style: .continuous)
            )
            .padding(14)
        }
    }

    @ViewBuilder
    private func infoCard<Content: View>(
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            content()
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color(.systemBackground).opacity(0.96))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color.primary.opacity(0.08), lineWidth: 1)
        )
        .clipShape(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
        )
        .shadow(color: .black.opacity(0.03), radius: 4, y: 2)
    }
}
#Preview {
    NavigationStack {
        RideTheBusSetupView(
            
        )
    }
}
