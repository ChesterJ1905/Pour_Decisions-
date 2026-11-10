//
//  HapticsManager.swift
//  Pour Decision
//
//  Created by CS3714 on 3/30/26.
//
// Responsible for vibration feedback (app on first bootup has vibrations defaulted to on)

import SwiftUI
import UIKit

enum HapticsManager {
    @AppStorage("vibration") private static var vibrationEnabled = true

    //Different vibration patterns to signify differnt actions/events
    
    static func light() {
        guard vibrationEnabled else { return }
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
    }

    static func medium() {
        guard vibrationEnabled else { return }
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
    }

    static func heavy() {
        guard vibrationEnabled else { return }
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.prepare()
        generator.impactOccurred()
    }

    static func success() {
        guard vibrationEnabled else { return }
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.success)
    }

    static func warning() {
        guard vibrationEnabled else { return }
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.warning)
    }

    static func error() {
        guard vibrationEnabled else { return }
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.error)
    }

    static func selection() {
        guard vibrationEnabled else { return }
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }
}
