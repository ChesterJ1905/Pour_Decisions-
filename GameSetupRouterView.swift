//
//  GameSetupRouterView.swift
//  Pour Decision
//
//  Created by CS3714 on 3/4/26.
//
//Homepage's logic for pressing a button to take user to a specific game's setup view

import SwiftUI

struct GameSetupRouterView: View {
    let game: GameType

    @ViewBuilder
    var body: some View {
        switch game {
        case .imposter:
            ImposterSetupView()
        case .mafia:
            MafiaSetupView()
        case .rideTheBus:
            RideTheBusSetupView()
        case .scoreTracker:
            ScoreTrackerGameView()
        case .fingerRoulette:
            FingerRouletteSetupView()
        case .ticTacToe:
            TicTacToeSetupView()
        case .trivia:
            TriviaSetupView()
        case .songBlitz:
            SongBlitzSetupView()
        case .colorGame:
            ColorGameSetupView()
        case .dotsAndBoxes:
            DotsAndBoxesSetupView()
        case .reactionTime:
            ReactionTimeSetupView()
        case .categories:
            CategoriesSetupView()
        case .famileyGame:
            FamilySetupView()
        case .memoryGame:
            MemorySetupView()
        case .pokerChip:
            PokerSetupView()
        case .verbalMem:
            VerbalMemSetupView()
        @unknown default:
            Text("Game not implemented yet")
        }
    }
}
