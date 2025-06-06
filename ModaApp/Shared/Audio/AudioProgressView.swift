//
//  AudioProgressView.swift
//  ModaApp
//
//  Created by Vahi Guner on 6/3/25.
//  Updated with ModernTheme styling
//

import SwiftUI

struct AudioProgressView: View {
    
    /// The audio manager we observe for time updates.
    @ObservedObject var audio: AudioPlayerManager
    @State private var isDragging = false
    @State private var dragValue: Float = 0
    
    var body: some View {
        VStack(spacing: ModernTheme.Spacing.sm) {
            // Seekable slider (0 … 1)
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background track
                    RoundedRectangle(cornerRadius: 4)
                        .fill(ModernTheme.tertiary.opacity(0.3))
                        .frame(height: 6)
                    
                    // Progress track
                    RoundedRectangle(cornerRadius: 4)
                        .fill(ModernTheme.sageGradient)
                        .frame(
                            width: geometry.size.width * CGFloat(isDragging ? dragValue : currentProgress),
                            height: 6
                        )
                    
                    // Draggable thumb
                    Circle()
                        .fill(ModernTheme.surface)
                        .frame(width: 20, height: 20)
                        .shadow(
                            color: ModernTheme.Shadow.medium.color,
                            radius: ModernTheme.Shadow.medium.radius,
                            x: ModernTheme.Shadow.medium.x,
                            y: ModernTheme.Shadow.medium.y
                        )
                        .overlay(
                            Circle()
                                .fill(ModernTheme.primary)
                                .frame(width: 12, height: 12)
                        )
                        .offset(x: thumbPosition(in: geometry.size.width))
                        .scaleEffect(isDragging ? 1.2 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isDragging)
                }
                .frame(height: 20)
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            isDragging = true
                            let progress = min(max(0, value.location.x / geometry.size.width), 1)
                            dragValue = Float(progress)
                        }
                        .onEnded { value in
                            let progress = min(max(0, value.location.x / geometry.size.width), 1)
                            audio.seek(to: Double(progress))
                            isDragging = false
                        }
                )
            }
            .frame(height: 20)
            
            // Time labels
            HStack {
                Text(format(audio.currentTime))
                    .font(ModernTheme.Typography.caption)
                    .fontWeight(.medium)
                    .foregroundColor(ModernTheme.textSecondary)
                    .monospacedDigit()
                
                Spacer()
                
                Text(format(audio.duration))
                    .font(ModernTheme.Typography.caption)
                    .fontWeight(.medium)
                    .foregroundColor(ModernTheme.textSecondary)
                    .monospacedDigit()
            }
        }
        .padding(.horizontal, ModernTheme.Spacing.md)
    }
    
    // MARK: - Helpers
    
    private var currentProgress: Float {
        guard audio.duration > 0 else { return 0 }
        return Float(audio.currentTime / audio.duration)
    }
    
    private func thumbPosition(in width: CGFloat) -> CGFloat {
        let progress = isDragging ? dragValue : currentProgress
        let position = width * CGFloat(progress)
        // Constrain thumb to track bounds
        return min(max(0, position - 10), width - 20)
    }
    
    private func format(_ t: TimeInterval) -> String {
        let m = Int(t) / 60
        let s = Int(t) % 60
        return String(format: "%02d:%02d", m, s)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 40) {
        // Example 1: Empty state
        VStack {
            Text("Empty State")
                .font(ModernTheme.Typography.caption)
                .foregroundColor(ModernTheme.textTertiary)
            AudioProgressView(audio: AudioPlayerManager())
        }
        
        // Example 2: With mock progress
        VStack {
            Text("With Progress")
                .font(ModernTheme.Typography.caption)
                .foregroundColor(ModernTheme.textTertiary)
            AudioProgressView(audio: {
                let manager = AudioPlayerManager()
                // Note: In preview, we can't actually set these values
                // but this shows the intent
                return manager
            }())
        }
    }
    .padding(ModernTheme.Spacing.xl)
    .background(ModernTheme.background)
}
