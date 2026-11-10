/*
 Gradient background that mixes two chosen colors to display mixed background
 
 Auto defaults to blue and teal, changeable in settings
 */

import SwiftUI

struct AppGradientBackground: View {
    @AppStorage("gradientColor1") private var gradientColor1Raw = AppColorOption.blue.rawValue
    @AppStorage("gradientColor2") private var gradientColor2Raw = AppColorOption.teal.rawValue

    private var gradientColor1: Color {
        AppColorOption(rawValue: gradientColor1Raw)?.color ?? .blue
    }

    private var gradientColor2: Color {
        AppColorOption(rawValue: gradientColor2Raw)?.color ?? .teal
    }

    var body: some View {
        LinearGradient(
            colors: [gradientColor1, gradientColor2],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}
