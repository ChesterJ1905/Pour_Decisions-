import SwiftUI

struct MafiaSetupView: View {
    @State private var playerCount = 6
    @State private var mafiaCount = 1
    @State private var doctorEnabled = true
    @State private var detectiveEnabled = true

    var body: some View {
        TabView {
            MafiaSetupContent(
                playerCount: $playerCount,
                mafiaCount: $mafiaCount,
                doctorEnabled: $doctorEnabled,
                detectiveEnabled: $detectiveEnabled
            )
            .tabItem {
                Label("Setup", systemImage: "slider.horizontal.3")
            }

            MafiaRulesContent()
                .tabItem {
                    Label("How to Play", systemImage: "book")
                }
        }
        .navigationTitle("Mafia")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct MafiaSetupContent: View {
    @Binding var playerCount: Int
    @Binding var mafiaCount: Int
    @Binding var doctorEnabled: Bool
    @Binding var detectiveEnabled: Bool

    var body: some View {
        ZStack {
            AppGradientBackground()

            ScrollView {
                VStack(spacing: 18) {
                    settingsCard(title: "Players") {
                        VStack(spacing: 14) {
                            stepperRow(
                                title: "Number of Players",
                                valueText: "\(playerCount)"
                            ) {
                                Stepper("", value: $playerCount, in: 4...20)
                                    .labelsHidden()
                                    .onChange(of: playerCount) { _, newValue in
                                        let maxMafia = max(1, newValue - 1)
                                        if mafiaCount > maxMafia {
                                            mafiaCount = maxMafia
                                        }
                                    }
                            }

                            stepperRow(
                                title: "Number of Mafia",
                                valueText: "\(mafiaCount)"
                            ) {
                                Stepper("", value: $mafiaCount, in: 1...max(1, playerCount - 1))
                                    .labelsHidden()
                            }
                        }
                    }

                    settingsCard(title: "Special Roles") {
                        VStack(spacing: 12) {
                            Toggle("Include Doctor", isOn: $doctorEnabled)
                            Toggle("Include Detective", isOn: $detectiveEnabled)
                        }
                    }

                    settingsCard(title: "Role Summary") {
                        VStack(spacing: 10) {
                            summaryRow(title: "Mafia", value: "\(mafiaCount)")
                            summaryRow(title: "Doctor", value: doctorEnabled ? "1" : "0")
                            summaryRow(title: "Detective", value: detectiveEnabled ? "1" : "0")
                            summaryRow(title: "Citizens", value: "\(citizenCount)")
                        }
                    }

                    NavigationLink {
                        MafiaGameView(
                            playerCount: playerCount,
                            mafiaCount: mafiaCount,
                            includeMedic: doctorEnabled,
                            includeDetective: detectiveEnabled,
                            includeJester: false
                        )
                    } label: {
                        Text("Start Game")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .fill(Color.black)
                            )
                    }
                    .padding(.top, 4)
                }
                .padding(24)
                .frame(maxWidth: .infinity)
            }
            .background(
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .fill(Color.clear)
            )
            .clipShape(
                RoundedRectangle(cornerRadius: 30, style: .continuous)
            )
            .padding(14)
        }
    }

    var citizenCount: Int {
        max(0, playerCount - mafiaCount - (doctorEnabled ? 1 : 0) - (detectiveEnabled ? 1 : 0))
    }

    @ViewBuilder
    private func settingsCard<Content: View>(
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title)
                .font(.title3.bold())

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

    @ViewBuilder
    private func stepperRow<Control: View>(
        title: String,
        valueText: String,
        @ViewBuilder control: () -> Control
    ) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)

                Text(valueText)
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundStyle(.secondary)
            }

            Spacer()

            control()
        }
    }

    private func summaryRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
        }
        .foregroundStyle(.primary)
    }
}

struct MafiaRulesContent: View {
    var body: some View {
        ZStack {
            AppGradientBackground()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("How to Play")
                        .font(.title2)
                        .bold()

                    Text("Mafia is a social deduction game where each player is secretly assigned a role. The Mafia try to eliminate the other players, while the Town tries to figure out who the Mafia members are and vote them out.")

                    Text("Game Flow")
                        .font(.headline)

                    VStack(alignment: .leading, spacing: 10) {
                        Text("1. Everyone is assigned a secret role.")
                        Text("2. At night, the Mafia secretly choose a player to eliminate.")
                        Text("3. If included, the Doctor chooses someone to protect.")
                        Text("4. If included, the Detective investigates one player.")
                        Text("5. During the day, everyone discusses and votes on who they think is Mafia.")
                        Text("6. The game ends when all Mafia are eliminated or the Mafia outnumber the Town.")
                    }

                    Text("Roles")
                        .font(.headline)

                    roleCard(
                        title: "Mafia",
                        description: "Works secretly with the other Mafia members to eliminate players without getting caught."
                    )

                    roleCard(
                        title: "Citizen",
                        description: "Has no special power. Their job is to pay attention, discuss, and vote out the Mafia."
                    )

                    roleCard(
                        title: "Doctor",
                        description: "Can protect one player each night from being eliminated."
                    )

                    roleCard(
                        title: "Detective",
                        description: "Can investigate one player each night to try to identify the Mafia."
                    )
                }
                .padding(24)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .background(
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .fill(Color.clear)
            )
            .clipShape(
                RoundedRectangle(cornerRadius: 30, style: .continuous)
            )
            .padding(14)
        }
    }

    func roleCard(title: String, description: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.headline)

            Text(description)
                .font(.body)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(.systemBackground).opacity(0.96))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.primary.opacity(0.08), lineWidth: 1)
        )
        .clipShape(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
        )
        .shadow(color: .black.opacity(0.03), radius: 4, y: 2)
    }
}

#Preview {
    NavigationStack {
        MafiaSetupView()
    }
}
