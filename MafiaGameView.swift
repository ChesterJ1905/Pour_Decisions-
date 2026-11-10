import SwiftUI

struct MafiaGameView: View {
    let playerCount: Int
    let mafiaCount: Int
    let includeMedic: Bool
    let includeDetective: Bool
    let includeJester: Bool
    
    private enum Phase {
        case passPhone
        case revealRole
        case finished
    }
    
    @State private var phase: Phase = .passPhone
    @State private var currentPlayer = 1
    @State private var roles: [String] = []
    
    @State private var selectedPlayerToReview = 1
    @State private var showingReviewedRole = false
    
    @Environment(\.colorScheme) private var colorScheme
    
    private var cardBackground: Color {
        colorScheme == .dark ? Color.black.opacity(0.35) : Color.white.opacity(0.6)
    }
    
    var body: some View {
        ZStack {
            AppGradientBackground() 
            
            VStack(spacing: 20) {
                
                // Title
                Text("Mafia")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top)
                
                if phase != .finished {
                    Text("Player \(currentPlayer) of \(playerCount)")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                // Main Card
                VStack(spacing: 20) {
                    switch phase {
                    case .passPhone:
                        passPhoneView
                    case .revealRole:
                        revealRoleView
                    case .finished:
                        finishedView
                    }
                }
                .padding()
                .frame(maxWidth: 500)
                .background(cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 25))
                .overlay(
                    RoundedRectangle(cornerRadius: 25)
                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                )
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Mafia")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if roles.isEmpty {
                roles = makeRoles()
            }
        }
    }
    
    // MARK: - Views
    
    private var passPhoneView: some View {
        VStack(spacing: 16) {
            Text("Pass the phone")
                .font(.title2)
                .bold()
            
            Text("Hand the phone to Player \(currentPlayer).")
                .font(.body)
            
            Text("Make sure nobody else is looking.")
                .font(.footnote)
                .foregroundStyle(.secondary)
            
            Button("I'm Ready") {
                phase = .revealRole
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .multilineTextAlignment(.center)
    }
    
    private var revealRoleView: some View {
        VStack(spacing: 16) {
            if roles.indices.contains(currentPlayer - 1) {
                let role = roles[currentPlayer - 1]
                
                Text("Your role is")
                    .foregroundStyle(.secondary)
                
                Text(role)
                    .font(.system(size: 38, weight: .black, design: .rounded))
                    .foregroundStyle(roleColor(for: role))
                
                Text(roleDescription(for: role))
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                
                Button(currentPlayer == playerCount ? "Finish" : "Next Player") {
                    nextPlayer()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                
                Button("Back") {
                    phase = .passPhone
                }
                .buttonStyle(.bordered)
            } else {
                ProgressView()
            }
        }
        .multilineTextAlignment(.center)
    }
    
    private var finishedView: some View {
        VStack(spacing: 16) {
            Text("All roles assigned")
                .font(.title2)
                .bold()
            
            Text("Review any player's role below.")
                .font(.footnote)
                .foregroundStyle(.secondary)
            
            Picker("Player", selection: $selectedPlayerToReview) {
                ForEach(1...playerCount, id: \.self) { player in
                    Text("Player \(player)").tag(player)
                }
            }
            .pickerStyle(.menu)
            
            Button(showingReviewedRole ? "Hide Role" : "View Role") {
                showingReviewedRole.toggle()
            }
            .buttonStyle(.borderedProminent)
            
            if showingReviewedRole,
               roles.indices.contains(selectedPlayerToReview - 1) {
                
                let role = roles[selectedPlayerToReview - 1]
                
                VStack(spacing: 8) {
                    Text("Player \(selectedPlayerToReview)")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    
                    Text(role)
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(roleColor(for: role))
                    
                    Text(roleDescription(for: role))
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top)
            }
        }
        .multilineTextAlignment(.center)
    }
    
    // MARK: - Logic
    
    private func nextPlayer() {
        if currentPlayer < playerCount {
            currentPlayer += 1
            phase = .passPhone
        } else {
            phase = .finished
        }
    }
    
    private func makeRoles() -> [String] {
        var result: [String] = []
        
        for _ in 0..<mafiaCount {
            result.append("Mafia")
        }
        
        if includeMedic { result.append("Medic") }
        if includeDetective { result.append("Detective") }
        if includeJester { result.append("Jester") }
        
        while result.count < playerCount {
            result.append("Villager")
        }
        
        return result.shuffled()
    }
    
    private func roleDescription(for role: String) -> String {
        switch role {
        case "Villager":
            return "Find the mafia and vote them out."
        case "Mafia":
            return "Eliminate players without getting caught."
        case "Medic":
            return "Protect one player each night."
        case "Detective":
            return "Investigate one player each night."
        case "Jester":
            return "Get yourself voted out to win."
        default:
            return ""
        }
    }
    
    private func roleColor(for role: String) -> Color {
        switch role {
        case "Mafia": return .red
        case "Medic": return .green
        case "Detective": return .blue
        default: return .primary
        }
    }
}

#Preview {
    NavigationStack {
        MafiaGameView(
            playerCount: 8,
            mafiaCount: 2,
            includeMedic: true,
            includeDetective: true,
            includeJester: false
        )
    }
}
