//
//  ViewExtensions.swift
//  ModaApp
//
//  Common view extensions for the app
//

import SwiftUI

// MARK: - Animation Extensions
extension View {
    /// Fade in animation
    func fadeIn(delay: Double = 0) -> some View {
        self
            .opacity(0)
            .onAppear {
                withAnimation(.easeOut(duration: 0.6).delay(delay)) {
                    // This will trigger the parent view to update
                }
            }
    }
    
    /// Scale animation
    func scaleIn(delay: Double = 0, from: CGFloat = 0.8) -> some View {
        self
            .scaleEffect(from)
            .onAppear {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(delay)) {
                    // This will trigger the parent view to update
                }
            }
    }
}

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
