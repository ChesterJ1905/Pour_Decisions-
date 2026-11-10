//
//  ColorGameSetupView.swift
//  Pour Decision
//
//  Created by CS3714 on 3/31/26.
//

import SwiftUI

struct ColorGameSetupView: View {
    var body: some View {
        ZStack {
           AppGradientBackground()

            VStack(spacing: 24) {
                Spacer()

                Text("Color Match")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.white)

                VStack(alignment: .leading, spacing: 14) {//Intro guide to the game
                    Label("A color will appear for 3 seconds.", systemImage: "eye.fill")
                    Label("Memorize it as best you can.", systemImage: "brain.head.profile")
                    Label("Use the sliders to recreate it.", systemImage: "slider.horizontal.3")
                    Label("Get a score out of 100.", systemImage: "star.fill")
                }
                .font(.headline)
                .foregroundStyle(.white)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.white.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 22))

                NavigationLink {
                    ColorGameView()
                } label: {
                    Text("Start Game")//button to enter Color game
                        .font(.title3.bold())
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 18)
                                .fill(.white.opacity(0.22))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(.white.opacity(0.35), lineWidth: 1.5)
                        )
                }

                Spacer()
            }
            .padding()
        }
        .navigationTitle("Color Match")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        ColorGameSetupView()
    }
}
