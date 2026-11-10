/*
 Color Options for background of Homescreen
 
 */

import SwiftUI

enum AppColorOption: String, CaseIterable, Identifiable {
    case blue
    case teal
    case green
    case mint
    case orange
    case pink
    case purple
    case red
    case yellow
    case indigo
    case black
    case gray

    var id: String { rawValue }

    var color: Color {
        switch self {
        case .blue: return .blue
        case .teal: return .teal
        case .green: return .green
        case .mint: return .mint
        case .orange: return .orange
        case .pink: return .pink
        case .purple: return .purple
        case .red: return .red
        case .yellow: return .yellow
        case .indigo: return .indigo
        case .black: return .black
        case .gray: return .gray
        }
    }

    var title: String {
        rawValue.capitalized
    }
}
