//
//  ReactionTimeSetupView.swift
//  Pour Decision
//
//  Created by CS3714 on 4/1/26.
//

import SwiftUI

struct ReactionTimeSetupView: View {
    @State private var roundCount = 3
    @Environment(\.colorScheme) private var colorScheme
    private var cardFill: Color {
        colorScheme == .dark ? .white.opacity(0.12) : .white.opacity(0.78)
    }

    private var cardStroke: Color {
        colorScheme == .dark ? .white.opacity(0.18) : .black.opacity(0.08)
    }

    private var primaryText: Color {
        colorScheme == .dark ? .white : .black
    }

    private var secondaryText: Color {
        colorScheme == .dark ? .white.opacity(0.85) : .black.opacity(0.72)
    }

    private var buttonText: Color {
        colorScheme == .dark ? .black : .white
    }

    private var buttonFill: Color {
        colorScheme == .dark ? .white : .black.opacity(0.8)
    }
    var body: some View {
        ZStack {
            AppGradientBackground()

            ScrollView {
                VStack(spacing: 20) {
                    headerCard
                    setupCard
                    howToPlayCard
                }
                .padding()
                .padding(.bottom, 24)
            }
        }
        .navigationTitle("Reaction Time")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var headerCard: some View {
        VStack(spacing: 10) {
            Image(systemName: "bolt.circle.fill")
                .font(.system(size: 48))
                .foregroundStyle(.white)

            Text("Reaction Time")
                .font(.largeTitle.bold())
                .foregroundStyle(.white)

            Text("Wait for the screen to turn green, then tap as fast as you can.")
                .font(.headline)
                .multilineTextAlignment(.center)
                .foregroundStyle(.white.opacity(0.9))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(.white.opacity(0.14))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(.white.opacity(0.18), lineWidth: 1)
        )
    }

    private var setupCard: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Game Setup")
                .font(.title2.bold())
                .foregroundStyle(.white)

            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("Rounds")
                        .font(.headline)
                        .foregroundStyle(.white)

                    Spacer()

                    Text("\(roundCount)")
                        .font(.headline.bold())
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.white.opacity(0.16), in: Capsule())
                }

                Stepper("", value: $roundCount, in: 1...10)
                    .labelsHidden()
                    .tint(.white)
            }

            NavigationLink {
                ReactionTimeGameView(totalRounds: roundCount)
            } label: {
                HStack {
                    Spacer()
                    Label("Start Game", systemImage: "play.fill")
                        .font(.headline.bold())
                        .foregroundStyle(.black)
                    Spacer()
                }
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(.white)
                )
            }
            .simultaneousGesture(TapGesture().onEnded {
                HapticsManager.medium()
            })
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(.white.opacity(0.12))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(.white.opacity(0.18), lineWidth: 1)
        )
    }

    private var howToPlayCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("How to Play")
                .font(.title3.bold())
                .foregroundStyle(.white)

            VStack(alignment: .leading, spacing: 10) {
                Text("1. Tap **Start Round**.")
                Text("2. Wait while the screen stays red.")
                Text("3. As soon as it turns green, tap immediately.")
                Text("4. If you tap too early, it counts as a false start and that round resets.")
                Text("5. At the end, compare your best and average reaction times.")
            }
            .font(.body)
            .foregroundStyle(.white.opacity(0.92))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(.white.opacity(0.12))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(.white.opacity(0.18), lineWidth: 1)
        )
    }
}
