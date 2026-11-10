//
//  FingerRouletteSetupView.swift
//  Pour Decision
//
//  Created by CS3714 on 3/25/26.
//
//No settings are adjusted by the player in set up view for this game, the nature dictates that in gameview, the number of players are decded when game starts

import SwiftUI

struct FingerRouletteSetupView: View {
    var body: some View {
        ZStack {
            AppGradientBackground()//Throughout all setups/game views, this swift file is called to apply the two-color background

            VStack(spacing: 24) {
                Spacer()

                Image(systemName: "hand.raised.fingers.spread.fill")
                    .font(.system(size: 70))
                    .foregroundStyle(.white)

                Text("Finger Roulette")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.white)

                VStack(spacing: 14) {
                    Text("How to Play")
                        .font(.title2.bold())
                        .foregroundStyle(.white)

                    Text("Everyone places one finger on the screen. When the round starts, the app tracks every finger touching the phone and randomly selects one winner.")
                        .font(.body)
                        .foregroundStyle(.white.opacity(0.92))
                        .multilineTextAlignment(.center)

                    Text("Max of 4 players")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.75))
                        .multilineTextAlignment(.center)
                }
                .padding()
                .background(.white.opacity(0.10))
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .padding(.horizontal)

                Spacer()

                NavigationLink {
                    FingerRouletteGameView()//takes user to game view
                } label: {
                    Text("Start Game")//button only works if 4 people or less are tapped in, apple doesn't allow more than 5 registered "touches" at a time
                        .font(.headline.bold())
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                }
                .simultaneousGesture(
                    TapGesture().onEnded {
                        HapticsManager.medium()
                    }
                )
                .padding(.horizontal)

                Spacer()
                    .frame(height: 30)
            }
            .padding()
        }
        .navigationTitle("Finger Roulette")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        FingerRouletteSetupView()
    }
}
