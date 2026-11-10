//
//  TicTacToeSetupView.swift
//  Pour Decision
//
//  Created by CS3714 on 3/25/26.
//

import SwiftUI

enum TicTacToeMode: String, CaseIterable, Identifiable {
    case classic = "Classic Tic-Tac-Toe"
    case modern = "Modern Tic-Tac-Toe"

    var id: String { rawValue }

    var description: String {
        switch self {
        case .classic:
            return "Normal tic-tac-toe. Place Xs and Os until someone gets 3 in a row or the board fills."
        case .modern:
            return "Each player can only have 3 pieces on the board at once. When you place a 4th piece, your oldest one disappears."
        }
    }
}

struct TicTacToeSetupView: View {
    @State private var selectedMode: TicTacToeMode = .classic

    var body: some View {
        ZStack {
            AppGradientBackground()

            VStack(spacing: 24) {
                Spacer()

                Text("Tic-Tac-Toe")
                    .font(.system(size: 38, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)

                Text("Choose a mode")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.9))

                VStack(spacing: 16) {
                    ForEach(TicTacToeMode.allCases) { mode in
                        Button {
                            selectedMode = mode
                        } label: {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text(mode.rawValue)
                                        .font(.headline)
                                        .foregroundStyle(.white)

                                    Spacer()

                                    Image(systemName: selectedMode == mode ? "largecircle.fill.circle" : "circle")
                                        .font(.title3)
                                        .foregroundStyle(.white)
                                }

                                Text(mode.description)
                                    .font(.subheadline)
                                    .foregroundStyle(.white.opacity(0.85))
                                    .multilineTextAlignment(.leading)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(.white.opacity(selectedMode == mode ? 0.22 : 0.12))
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(.white.opacity(0.25), lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }

                NavigationLink {
                    TicTacToeGameView(mode: selectedMode)
                } label: {
                    Text("Start Game")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(.black.opacity(0.25))
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(.white.opacity(0.3), lineWidth: 1)
                        )
                }
                .padding(.top, 8)

                Spacer()
            }
            .padding(24)
        }
        .navigationTitle("Tic-Tac-Toe")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        TicTacToeSetupView()
    }
}
