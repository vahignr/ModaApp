//
//  ViewExtensions.swift
//  ModaApp
//
//  Common view extensions for the app
//

import SwiftUI

// MARK: - Haptic Feedback
extension View {
    /// Add haptic feedback to any view interaction
    func hapticFeedback(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .light) -> some View {
        self.onTapGesture {
            if ConfigurationManager.enableHaptics {
                let impactFeedback = UIImpactFeedbackGenerator(style: style)
                impactFeedback.impactOccurred()
            }
        }
    }
}
