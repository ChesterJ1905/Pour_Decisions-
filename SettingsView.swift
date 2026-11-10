import SwiftUI

struct SettingsView: View {
    // Feature toggles - Set to false (Off) by default
    @AppStorage("vibration") private var vibration = true
    
    // 1. Set drinking mode to false as default
    @AppStorage("drinkingMode") private var drinkingMode = false
    
    // State for disclaimer alert
    @State private var showDisclaimer = false

    // Gradient colors
    @AppStorage("gradientColor1") private var gradientColor1Raw = AppColorOption.blue.rawValue
    @AppStorage("gradientColor2") private var gradientColor2Raw = AppColorOption.teal.rawValue

    private let colorColumns = [
        GridItem(.adaptive(minimum: 52), spacing: 12)
    ]

    private var previewColor1: Color {
        AppColorOption(rawValue: gradientColor1Raw)?.color ?? .blue
    }

    private var previewColor2: Color {
        AppColorOption(rawValue: gradientColor2Raw)?.color ?? .teal
    }

    var body: some View {
        Form {
            Section("App Settings") {
                Toggle(isOn: $vibration) {
                    Label("Vibration", systemImage: "iphone.radiowaves.left.and.right")
                }

                // Custom binding to show alert before allowing the toggle to turn on
                Toggle(isOn: Binding(
                    get: { self.drinkingMode },
                    set: { newValue in
                        if newValue {
                            // If user attempts to switch ON, show alert first
                            self.showDisclaimer = true
                        } else {
                            // If user switches OFF, update immediately
                            self.drinkingMode = false
                        }
                    }
                )) {
                    Label("Drinking Mode", systemImage: "wineglass.fill")
                }
            }

            Section("Home Screen Gradient") {
                VStack(alignment: .leading, spacing: 16) {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                colors: [previewColor1, previewColor2],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(height: 140)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.white.opacity(0.25), lineWidth: 1)
                        )

                    VStack(alignment: .leading, spacing: 10) {
                        Text("First Color")
                            .font(.headline)

                        LazyVGrid(columns: colorColumns, spacing: 12) {
                            ForEach(AppColorOption.allCases) { option in
                                ColorChoiceCircle(
                                    option: option,
                                    isSelected: gradientColor1Raw == option.rawValue
                                ) {
                                    gradientColor1Raw = option.rawValue
                                }
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Second Color")
                            .font(.headline)

                        LazyVGrid(columns: colorColumns, spacing: 12) {
                            ForEach(AppColorOption.allCases) { option in
                                ColorChoiceCircle(
                                    option: option,
                                    isSelected: gradientColor2Raw == option.rawValue
                                ) {
                                    gradientColor2Raw = option.rawValue
                                }
                            }
                        }
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        // Disclaimer alert logic
        .alert("Drink Responsibly", isPresented: $showDisclaimer) {
            Button("Cancel", role: .cancel) {
                // Keep the state false if they cancel
                self.drinkingMode = false
            }
            Button("I Agree") {
                // Only set to true if they agree
                self.drinkingMode = true
            }
        } message: {
            Text("By enabling Drinking Mode, you agree to play responsibly. Ensure all players are of legal age and do not drink and drive.")
        }
    }
}

struct ColorChoiceCircle: View {
    let option: AppColorOption
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(option.color)
                    .frame(width: 38, height: 38)

                Circle()
                    .stroke(isSelected ? Color.primary : Color.clear, lineWidth: 3)
                    .frame(width: 46, height: 46)

                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(checkmarkColor)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(option.title)
    }

    private var checkmarkColor: Color {
        switch option {
        case .yellow, .mint:
            return .black
        default:
            return .white
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
