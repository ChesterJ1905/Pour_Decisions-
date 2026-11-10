import SwiftUI

struct ImposterHowToPlayView: View {
    var body: some View {
        ZStack {
            AppGradientBackground()

            List {
                Section("Goal") {
                    Text("One player is the imposter. Everyone else gets the same secret word. The imposter must blend in without knowing the word.")
                }

                Section("How To Play") {//Belongs in setup view, is shown when using the bubble bar to navigate
                    Text("1. Pick a category or use Random.")
                    Text("2. Pass the phone around so each player can reveal their role privately.")
                    Text("3. Most players will see the same word.")
                    Text("4. One player will be the imposter.")
                    Text("5. Everyone gives clues and tries to figure out who the imposter is.")
                    Text("6. Vote on who you think the imposter is.")
                }

                Section("Tips") {
                    Text("Give clues that are helpful, but not too obvious.")
                    Text("If you're the imposter, listen carefully and try to blend in.")
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.clear)
        }
        .navigationTitle("How To Play")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        ImposterHowToPlayView()
    }
}
