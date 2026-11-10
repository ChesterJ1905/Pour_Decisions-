import SwiftUI

struct ColorGameView: View {
    @State private var targetRed: Double = Double.random(in: 0...1)//randomizes numbers to generate random color using RGB
    @State private var targetGreen: Double = Double.random(in: 0...1)
    @State private var targetBlue: Double = Double.random(in: 0...1)

    @State private var guessRed: Double = 0.5
    @State private var guessGreen: Double = 0.5
    @State private var guessBlue: Double = 0.5

    @State private var showingTarget = true
    @State private var hasSubmitted = false
    @State private var score: Int = 0
    @State private var timeRemaining: Int = 3//time that the initial color is shown before user has to recall the color

    var body: some View {//view of the game
        ZStack {
            AppGradientBackground()

            ScrollView {
                VStack(spacing: 22) {
                    Text("Color Match")
                        .font(.largeTitle.bold())
                        .foregroundStyle(.white)

                    if showingTarget {
                        VStack(spacing: 16) {
                            Text("Memorize this color")
                                .font(.title3.bold())
                                .foregroundStyle(.white)

                            RoundedRectangle(cornerRadius: 24)
                                .fill(targetColor)
                                .frame(height: 220)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 24)
                                        .stroke(.white.opacity(0.5), lineWidth: 2)
                                )

                            Text("\(timeRemaining)")
                                .font(.system(size: 42, weight: .bold))
                                .foregroundStyle(.white)
                        }
                    } else {
                        VStack(spacing: 18) {
                            Text("Recreate the color")
                                .font(.title3.bold())
                                .foregroundStyle(.white)

                            HStack(spacing: 16) {
                                VStack(spacing: 8) {
                                    Text("Your Color")
                                        .font(.headline)
                                        .foregroundStyle(.white)

                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(guessColor)
                                        .frame(height: 140)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(.white.opacity(0.45), lineWidth: 2)
                                        )
                                }

                                if hasSubmitted {
                                    VStack(spacing: 8) {
                                        Text("Target")
                                            .font(.headline)
                                            .foregroundStyle(.white)

                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(targetColor)
                                            .frame(height: 140)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 20)
                                                    .stroke(.white.opacity(0.45), lineWidth: 2)
                                            )
                                    }
                                }
                            }

                            sliderCard

                            if hasSubmitted {
                                VStack(spacing: 10) {
                                    Text("Score: \(score)/100")
                                        .font(.system(size: 32, weight: .bold))
                                        .foregroundStyle(.white)

                                    Text(scoreMessage)
                                        .font(.headline)
                                        .foregroundStyle(.white.opacity(0.95))
                                }
                                .padding(.top, 4)
                            }

                            if !hasSubmitted {
                                Button {
                                    submitGuess()
                                } label: {
                                    Text("Submit Guess")
                                        .font(.headline.bold())
                                        .foregroundStyle(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 14)
                                        .background(
                                            RoundedRectangle(cornerRadius: 16)
                                                .fill(.white.opacity(0.22))
                                        )
                                }
                            }

                            if hasSubmitted {
                                Button {
                                    startNewRound()
                                } label: {
                                    Text("New Color")
                                        .font(.headline.bold())
                                        .foregroundStyle(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 14)
                                        .background(
                                            RoundedRectangle(cornerRadius: 16)
                                                .fill(.white.opacity(0.22))
                                        )
                                }
                            }
                        }
                    }

                    Spacer(minLength: 30)
                }
                .padding()
                .frame(maxWidth: .infinity)
            }
            .scrollIndicators(.hidden)
        }
        .navigationTitle("Color Match")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            startCountdown()
        }
    }

    private var targetColor: Color {
        Color(red: targetRed, green: targetGreen, blue: targetBlue)
    }

    private var guessColor: Color {
        Color(red: guessRed, green: guessGreen, blue: guessBlue)
    }

    private var sliderCard: some View {
        VStack(spacing: 18) {
            sliderRow(title: "Red", value: $guessRed, tint: .red, targetValue: targetRed)
            sliderRow(title: "Green", value: $guessGreen, tint: .green, targetValue: targetGreen)
            sliderRow(title: "Blue", value: $guessBlue, tint: .blue, targetValue: targetBlue)
        }
        .padding()
        .background(.white.opacity(0.14))
        .clipShape(RoundedRectangle(cornerRadius: 22))
    }

    @ViewBuilder //builds the interactive sliders for the user to adjust the color
    private func sliderRow(title: String, value: Binding<Double>, tint: Color, targetValue: Double) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.white)

                Spacer()

                Text("\(Int(value.wrappedValue * 255))")
                    .font(.subheadline.bold())
                    .foregroundStyle(.white.opacity(0.9))
            }

            ZStack(alignment: .leading) {
                Slider(value: value, in: 0...1)
                    .tint(tint)

                if hasSubmitted {
                    GeometryReader { geo in
                        Circle()
                            .fill(Color.yellow)
                            .frame(width: 14, height: 14)
                            .overlay(
                                Circle()
                                    .stroke(Color.black.opacity(0.45), lineWidth: 1.5)
                            )
                            .position(
                                x: max(7, min(geo.size.width - 7, geo.size.width * targetValue)),
                                y: geo.size.height / 2
                            )
                    }
                    .allowsHitTesting(false)
                    .frame(height: 20)
                }
            }

            if hasSubmitted {
                Text("Yellow dot = correct position")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.8))
            }
        }
    }

    private func startNewRound() {//next iteration of the game
        targetRed = Double.random(in: 0...1)
        targetGreen = Double.random(in: 0...1)
        targetBlue = Double.random(in: 0...1)

        guessRed = 0.5
        guessGreen = 0.5
        guessBlue = 0.5

        hasSubmitted = false
        showingTarget = true
        timeRemaining = 3

        startCountdown()
    }

    private func startCountdown() {
        showingTarget = true
        timeRemaining = 3

        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if timeRemaining > 1 {
                timeRemaining -= 1
            } else {
                timer.invalidate()
                showingTarget = false
            }
        }
    }

    private func submitGuess() {
        let distance = colorDistance(
            r1: targetRed, g1: targetGreen, b1: targetBlue,
            r2: guessRed, g2: guessGreen, b2: guessBlue
        )

        let maxDistance = sqrt(3.0)
        let normalized = max(0, 1 - (distance / maxDistance))
        score = Int((normalized * 100).rounded())

        hasSubmitted = true
    }

    //math function to calculate a rating representing how close the user's color was to the true color
    private func colorDistance(
        r1: Double, g1: Double, b1: Double,
        r2: Double, g2: Double, b2: Double
    ) -> Double {
        let dr = r1 - r2
        let dg = g1 - g2
        let db = b1 - b2
        return sqrt(dr * dr + dg * dg + db * db)
    }

    private var scoreMessage: String {
        switch score {
        case 100: return "Perfect!"
        case 95...99: return "Almost perfect"
        case 85..<95: return "Really strong match"
        case 70..<85: return "Pretty close"
        case 50..<70: return "Not bad"
        default: return "Way off, try again"
        }
    }
}

#Preview {
    NavigationStack {
        ColorGameView()
    }
}
