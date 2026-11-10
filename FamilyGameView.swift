import SwiftUI
import AVFoundation

struct FamilyGameView: View {
    enum Phase {//Phase: acts as a temporary gamestate before discussion of game (irl) begins
        case reveal
        case revealFinished
        case hostBoard
    }

    enum NameState: String, CaseIterable {
        case fresh
        case mentioned
        case guessed

        var title: String {
            switch self {
            case .fresh: return "Fresh"
            case .mentioned: return "Mentioned"
            case .guessed: return "Guessed"
            }
        }

        var tint: Color {
            switch self {
            case .fresh: return .blue
            case .mentioned: return .orange
            case .guessed: return .red
            }
        }

        func next() -> NameState {//clicking on list's button to change the attribute of each name
            switch self {
            case .fresh: return .mentioned
            case .mentioned: return .guessed
            case .guessed: return .fresh
            }
        }
    }

    struct HostSecretItem: Identifiable {//Host can view lis of names during game to track names mentioned and guessed
        let id = UUID()
        let value: String
        var state: NameState = .fresh
    }

    @Environment(\.dismiss) private var dismiss

    let secretEntries: [FamilySecretEntry]

    @State private var phase: Phase = .reveal
    @State private var revealOrder: [HostSecretItem] = []
    @State private var revealIndex = 0
    @State private var hostSecrets: [HostSecretItem] = []

    private let speaker = AVSpeechSynthesizer()

    var body: some View {
        ZStack {
            AppGradientBackground()

            switch phase {
            case .reveal:
                revealView
            case .revealFinished:
                revealFinishedView
            case .hostBoard:
                hostBoardView
            }
        }
        .navigationTitle("Family")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                }
            }
        }
        .onAppear {
            setupGame()
        }
    }

    private var revealView: some View {//shows each name in slides, allows for audio to play names
        VStack(spacing: 20) {
            Spacer()

            VStack(spacing: 12) {
                Text("Reveal Names")
                    .font(.largeTitle.bold())

                Text("The host can read each name out loud when ready.")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                Text("Name \(min(revealIndex + 1, revealOrder.count)) of \(revealOrder.count)")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
            }

            Text(currentRevealText)
                .font(.system(size: 38, weight: .heavy, design: .rounded))
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.6)
                .frame(maxWidth: .infinity, minHeight: 260)
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 28))
                .overlay(
                    RoundedRectangle(cornerRadius: 28)
                        .stroke(Color.white.opacity(0.16), lineWidth: 1)
                )
                .padding(.horizontal)

            VStack(spacing: 12) {
                Button {
                    HapticsManager.light()
                    speak(currentRevealText)
                } label: {
                    Label("Read Name Aloud", systemImage: "speaker.wave.2.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .padding(.horizontal)
                }
                .buttonStyle(.bordered)

                Button {
                    advanceReveal()
                } label: {
                    Text(revealIndex == revealOrder.count - 1 ? "Finish Reveal" : "Next Name")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .padding(.horizontal)
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(.horizontal)

            Spacer()
        }
    }

    private var revealFinishedView: some View {//After slides, host an view the name list to begin tracking game
        VStack(spacing: 22) {
            Spacer()

            VStack(spacing: 14) {
                Text("Reveal Complete")
                    .font(.largeTitle.bold())
                    .multilineTextAlignment(.center)

                Text("The names have all been shown.")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                Text("Now let everyone start guessing before the host opens the list.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            VStack(spacing: 12) {
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 58))
                    .padding(.bottom, 4)

                Text("Make your guesses first")
                    .font(.title3.bold())

                Text("When the host is ready, tap the button below to open the board.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(24)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 28))
            .overlay(
                RoundedRectangle(cornerRadius: 28)
                    .stroke(Color.white.opacity(0.16), lineWidth: 1)
            )
            .padding(.horizontal)

            Button {
                HapticsManager.medium()
                phase = .hostBoard
            } label: {
                Text("Open Host Board")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .padding(.horizontal)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal)

            Spacer()
        }
    }

    private var hostBoardView: some View {//location of name list for host
        ScrollView {
            VStack(spacing: 18) {
                infoCard {
                    VStack(spacing: 10) {
                        Text("Host Board")
                            .font(.largeTitle.bold())

                        Text("Tap a name to cycle it from fresh to mentioned to guessed.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }

                infoCard {
                    VStack(alignment: .leading, spacing: 14) {
                        Text("All Names")
                            .font(.title3.bold())

                        ForEach(hostSecrets.indices, id: \.self) { index in
                            let item = hostSecrets[index]

                            Button {
                                cycleSecretState(at: index)
                            } label: {
                                HStack(spacing: 12) {
                                    Text(item.value)
                                        .font(.headline)
                                        .foregroundStyle(.primary)
                                        .frame(maxWidth: .infinity, alignment: .leading)

                                    Text(item.state.title)
                                        .font(.subheadline.bold())
                                        .foregroundStyle(.white)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(item.state.tint)
                                        .clipShape(Capsule())
                                }
                                .padding()
                                .background(Color(.systemBackground).opacity(0.92))
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                            }
                        }
                    }
                }
            }
            .padding()
            .padding(.bottom, 24)
        }
    }

    private var currentRevealText: String {
        guard revealOrder.indices.contains(revealIndex) else { return "Ready" }
        return revealOrder[revealIndex].value
    }

    //functions
    private func setupGame() {
        let shuffled = secretEntries.shuffled().map { HostSecretItem(value: $0.value) }
        revealOrder = shuffled
        hostSecrets = shuffled
    }

    private func advanceReveal() {
        HapticsManager.medium()

        if revealIndex < revealOrder.count - 1 {
            revealIndex += 1
        } else {
            phase = .revealFinished
        }
    }

    private func cycleSecretState(at index: Int) {
        guard hostSecrets.indices.contains(index) else { return }
        hostSecrets[index].state = hostSecrets[index].state.next()
        HapticsManager.light()
    }

    private func speak(_ text: String) {
        guard !text.isEmpty else { return }
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = 0.48
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0
        speaker.stopSpeaking(at: .immediate)
        speaker.speak(utterance)
    }

    private func infoCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Color.white.opacity(0.16), lineWidth: 1)
            )
    }
}
