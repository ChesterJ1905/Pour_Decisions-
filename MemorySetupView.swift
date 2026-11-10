import SwiftUI

struct MemorySetupView: View {
    @State private var previewTime: Int = 3
    @State private var shapeCount: Int = 6
    @State private var roundCount: Int = 10
    @State private var selectedTab: Int = 0

    private let previewOptions = [2, 3, 4, 5]
    private let shapeOptions = [4, 6, 8, 10]

    var body: some View {
        ZStack {
            AppGradientBackground()

            VStack(spacing: 0) {
                Picker("", selection: $selectedTab) {
                    Text("Setup").tag(0)
                    Text("How to Play").tag(1)
                }
                .pickerStyle(.segmented)
                .padding()

                if selectedTab == 0 {
                    setupContent
                } else {
                    howToPlayContent
                }
            }
        }
        .navigationTitle("Memory")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var setupContent: some View {
        ScrollView {
            VStack(spacing: 20) {
                titleCard
                previewCard
                shapesCard
                roundsCard

                NavigationLink {
                    MemoryGameView(
                        previewTime: previewTime,
                        shapeCount: shapeCount,
                        totalRounds: roundCount
                    )
                } label: {
                    Text("Start Game")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.ultraThinMaterial)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(.white.opacity(0.22), lineWidth: 1)
                        )
                }
                .simultaneousGesture(TapGesture().onEnded {
                    HapticsManager.medium()
                })
            }
            .padding()
        }
    }

    private var titleCard: some View {
        VStack(spacing: 10) {
            Text("Icon Memory")
                .font(.largeTitle.bold())
                .multilineTextAlignment(.center)

            Text("Memorize the icons, then answer a question about their order, color, shape, or count.")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(.white.opacity(0.18), lineWidth: 1)
        )
    }

    private var previewCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Preview Time")
                .font(.headline)

            Picker("Preview Time", selection: $previewTime) {
                ForEach(previewOptions, id: \.self) { value in
                    Text("\(value)s").tag(value)
                }
            }
            .pickerStyle(.segmented)

            Text("How long the icons stay on screen before the question appears.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(.white.opacity(0.18), lineWidth: 1)
        )
    }

    private var shapesCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Number of Shapes")
                .font(.headline)

            Picker("Number of Shapes", selection: $shapeCount) {
                ForEach(shapeOptions, id: \.self) { value in
                    Text("\(value)").tag(value)
                }
            }
            .pickerStyle(.segmented)

            Text("More shapes makes the round harder.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(.white.opacity(0.18), lineWidth: 1)
        )
    }

    private var roundsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Rounds: \(roundCount)")
                .font(.headline)

            Stepper(value: $roundCount, in: 5...25) {
                Text("Choose how many rounds to play")
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(.white.opacity(0.18), lineWidth: 1)
        )
    }

    private var howToPlayContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("How to Play")
                    .font(.title2.bold())

                Text("1. A group of colored shapes appears on screen.")
                Text("2. Memorize the shapes, colors, order, and counts.")
                Text("3. After the preview countdown ends, the shapes disappear.")
                Text("4. Answer one question about what you saw.")
                Text("5. Try to get the best score over all rounds.")

                Text("Question Examples")
                    .font(.headline)
                    .padding(.top, 6)

                Text("• What color was the 3rd icon?")
                Text("• What shape was last?")
                Text("• How many stars were shown?")
                Text("• What order were the colors in?")
                Text("• What order were the shapes in?")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(.white.opacity(0.18), lineWidth: 1)
            )
            .padding()
        }
    }
}

#Preview {
    NavigationStack {
        MemorySetupView()
    }
}
