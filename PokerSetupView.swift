import SwiftUI

struct PokerSetupView: View {
    @State private var playerCount = 2
    @State private var playerNames: [String] = ["Player 1", "Player 2", "Player 3", "Player 4", "Player 5", "Player 6", "Player 7"]
    @State private var startingStack = 1000
    @State private var smallBlind = 10
    
    
    @State private var startGame = false
    
    var body: some View {
        ZStack {
            AppGradientBackground()
            
            ScrollView {
                VStack(spacing: 20) {
                    Text("Poker Setup")
                        .font(.largeTitle.bold())
                        .foregroundStyle(.white)
                        .padding(.top)

                    // Game Settings Card
                    VStack(spacing: 15) {
                        settingStepper(title: "Players", value: $playerCount, range: 2...7)
                        
                        settingStepper(title: "Starting Stack", value: $startingStack, range: 100...10000, step: 100)
                        settingStepper(title: "Small Blind", value: $smallBlind, range: 5...500, step: 5)
                    }
                    .padding()
                    .background(.white.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 22))

                    // Player Names Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Player Names")
                            .font(.headline)
                            .foregroundStyle(.white)
                        
                        ForEach(0..<playerCount, id: \.self) { index in
                            TextField("Player \(index + 1)", text: $playerNames[index])
                                .textFieldStyle(.plain)
                                .padding()
                                .background(.white.opacity(0.5))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    
                    NavigationLink(destination: PokerGameView(
                        players: Array(playerNames.prefix(playerCount)),
                        initialStack: startingStack,
                        smallBlind: smallBlind
                    )) {
                        Text("Start Poker Night")
                            .font(.title3.bold())
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 18).fill(.white.opacity(0.2)))
                            .overlay(RoundedRectangle(cornerRadius: 18).stroke(.white.opacity(0.3), lineWidth: 1.5))
                    }
                    .padding(.top)
                }
                .padding()
            }
        }
        .navigationTitle("Setup")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func settingStepper(title: String, value: Binding<Int>, range: ClosedRange<Int>, step: Int = 1) -> some View {
        HStack {
            Text(title).foregroundStyle(.white).bold()
            Spacer()
            Stepper("\(value.wrappedValue)", value: value, in: range, step: step)
                .labelsHidden()
                .background(.white.opacity(0.1))
                .cornerRadius(8)
            Text("\(value.wrappedValue)").foregroundStyle(.white).frame(width: 60)
        }
    }
}
