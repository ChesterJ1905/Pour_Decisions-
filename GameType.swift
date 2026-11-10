import SwiftUI

enum GameType: String, CaseIterable, Identifiable {//Assigns names to the game cards on the homepage
    case imposter = "Imposter"
    case mafia = "Mafia"
    case rideTheBus = "Ride The Bus"
    case scoreTracker = "Score Tracker"
    case fingerRoulette = "Finger Roulette"
    case ticTacToe = "Tic Tac Toe"
    case trivia = "Trivia"
    case songBlitz = "Song Blitz"
    case colorGame = "Color Game"
    case dotsAndBoxes = "Dots and Boxes"
    case reactionTime = "Reaction Time"
    case categories = "Categories"
    case famileyGame = "Family Game"
    case memoryGame = "Memory Game"
    case pokerChip = "Poker Chip Tracker"
    case verbalMem = "Verbal Memory"

    var id: String { rawValue }

    var icon: String {//assigns string attribute to display game symbol for each game's game card on the homepage
        switch self {
        case .imposter:
            return "person.2.slash"
        case .mafia:
            return "moon.stars"
        case .rideTheBus:
            return "car.fill"
        case .scoreTracker:
            return "list.number"
        case .fingerRoulette:
            return "hand.draw.fill"
        case .ticTacToe:
            return "xmark.square"
        case .trivia:
            return "brain.head.profile"
        case .songBlitz:
            return "mic.fill"
        case .colorGame:
            return "eyedropper"
        case .dotsAndBoxes:
            return "square.grid.3x3"
            
        case .reactionTime:
            return "hand.tap"
            
        case .categories:
            return "textformat.abc"
            
        case .famileyGame:
            return "person.3.fill"
            
        case .memoryGame:
            return "arrow.2.circlepath.circle"
            
        case .pokerChip:
            return "suit.spade.fill"
            
        case .verbalMem:
            return "rectangle.stack"
        }
    }
}
