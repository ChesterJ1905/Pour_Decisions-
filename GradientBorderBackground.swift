import SwiftUI

//UNUSED, originally used to appliy color borders to ever game page and homepage

struct GradientBorderBackground: View {
    @AppStorage("gradientColor1") private var gradientColor1Raw = AppColorOption.blue.rawValue
    @AppStorage("gradientColor2") private var gradientColor2Raw = AppColorOption.teal.rawValue

    private var color1: Color {
        AppColorOption(rawValue: gradientColor1Raw)?.color ?? .blue
    }

    private var color2: Color {
        AppColorOption(rawValue: gradientColor2Raw)?.color ?? .teal
    }

    var cornerRadius: CGFloat = 34
    var borderWidth: CGFloat = 28

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [color1, color2],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(Color(.systemBackground))
                .padding(borderWidth)
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }
}
