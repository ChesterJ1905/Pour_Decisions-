import SwiftUI

struct VerbalMemSetupView: View {
    
    @State private var totalLives = 3
    
    var body: some View {
        ZStack {
            AppGradientBackground()
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    
                    VStack(spacing: 8) {
                        Text("Verbal Memory")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                        
                        Text("See if a word is brand new or one you’ve already seen.")
                            .font(.headline)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.white.opacity(0.9))
                    }
                    .padding(.top, 16)
                    
                    VStack(spacing: 16) {
                        settingsCard
                        howToPlayCard
                        
                        NavigationLink {
                            VerbalMemGameView(totalLives: totalLives)
                        } label: {
                            Text("Start Game")
                                .font(.headline)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 18)
                                        .fill(
                                            LinearGradient(
                                                colors: [.orange, .red],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 18)
                                        .stroke(.white.opacity(0.35), lineWidth: 2)
                                )
                        }
                        .simultaneousGesture(
                            TapGesture().onEnded {
                                HapticsManager.medium()
                            }
                        )
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 24)
            }
        }
        .navigationTitle("Verbal Memory")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var settingsCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Game Settings")
                .font(.title3.bold())
                .foregroundStyle(.primary)
            
            HStack {
                Text("Lives")
                Spacer()
                Stepper(value: $totalLives, in: 1...10) {
                    Text("\(totalLives)")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .frame(minWidth: 40, alignment: .trailing)
                }
            }
            
            Text("You start with this many lives. Every wrong answer removes one.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial)
        )
    }
    
    private var howToPlayCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("How to Play")
                .font(.title3.bold())
            
            Text("You will be shown one word at a time.")
            Text("Tap **New** if you have never seen that word before in this round.")
            Text("Tap **Seen** if the word already appeared earlier in this round.")
            Text("Each correct answer adds to your score.")
            Text("Each wrong answer removes one life.")
            Text("The same word will not appear twice in a row.")
            Text("When all your lives are gone, the game ends.")
        }
        .font(.body)
        .foregroundStyle(.primary)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial)
        )
    }
}

#Preview {
    NavigationStack {
        VerbalMemSetupView()
    }
}
