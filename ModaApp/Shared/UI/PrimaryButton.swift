//
//  PrimaryButton.swift
//  ModaApp
//
//  Created by Vahi Guner on 6/3/25.
//  Updated to use Luxury Typography with elegant animations
//

import SwiftUI

struct PrimaryButton: View {
    
    // MARK: - Public properties ----------------------------------------------
    
    let title: String
    let systemImage: String?
    let enabled: Bool
    let style: ButtonVariant
    
    enum ButtonVariant {
        case primary
        case secondary
        case text
    }
    
    // MARK: - State for luxury animations
    @State private var isPressed = false
    @State private var shimmerOffset: CGFloat = -200
    
    // MARK: - Initializers ----------------------------------------------------
    
    init(title: String,
         systemImage: String? = nil,
         enabled: Bool = true,
         style: ButtonVariant = .primary) {
        self.title = title
        self.systemImage = systemImage
        self.enabled = enabled
        self.style = style
    }
    
    // MARK: - View ------------------------------------------------------------
    
    var body: some View {
        HStack(spacing: ModernTheme.Spacing.sm) {
            if let systemImage {
                Image(systemName: systemImage)
                    .font(.system(size: 20, weight: .medium))
                    .scaleEffect(isPressed ? 0.9 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
            }
            Text(title.uppercased()) // Uppercase for luxury feel
                .tracking(style == .primary ? 1.5 : 1.0) // Letter spacing
                .fontWeight(style == .primary ? .semibold : .medium)
        }
        .font(ModernTheme.Typography.buttonText)
        .padding(.vertical, ModernTheme.Spacing.md)
        .frame(maxWidth: .infinity)
        .foregroundStyle(foregroundColor)
        .background(backgroundView)
        .cornerRadius(ModernTheme.CornerRadius.full)
        .shadow(
            color: shadowColor,
            radius: shadowRadius,
            x: 0,
            y: shadowY
        )
        .opacity(enabled ? 1 : 0.6)
        .scaleEffect(enabled && !isPressed ? 1.0 : 0.98)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: enabled)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
        .onLongPressGesture(minimumDuration: .infinity, maximumDistance: .infinity,
            pressing: { pressing in
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = pressing
                }
            },
            perform: {}
        )
        .onAppear {
            if style == .primary && enabled {
                withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                    shimmerOffset = 200
                }
            }
        }
    }
    
    // MARK: - Computed Properties ---------------------------------------------
    
    private var foregroundColor: Color {
        switch style {
        case .primary:
            return .white
        case .secondary:
            return ModernTheme.primary
        case .text:
            return enabled ? ModernTheme.primary : ModernTheme.textTertiary
        }
    }
    
    @ViewBuilder
    private var backgroundView: some View {
        switch style {
        case .primary:
            if enabled {
                ZStack {
                    ModernTheme.primaryGradient
                    
                    // Shimmer effect for luxury feel
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0),
                            Color.white.opacity(0.3),
                            Color.white.opacity(0)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: 100)
                    .offset(x: shimmerOffset)
                    .mask(
                        RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.full)
                    )
                }
                .overlay(
                    RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.full)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.3),
                                    Color.white.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 0.5
                        )
                )
            } else {
                Color.white.opacity(0.1)
            }
        case .secondary:
            Capsule()
                .stroke(
                    enabled ?
                    LinearGradient(
                        colors: [ModernTheme.primary, ModernTheme.secondary],
                        startPoint: .leading,
                        endPoint: .trailing
                    ) :
                    LinearGradient(
                        colors: [ModernTheme.textTertiary],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    lineWidth: 2
                )
                .background(
                    Capsule()
                        .fill(enabled ? ModernTheme.primary.opacity(0.1) : Color.clear)
                )
        case .text:
            Color.clear
        }
    }
    
    private var shadowColor: Color {
        guard enabled else { return .clear }
        
        switch style {
        case .primary:
            return ModernTheme.primary.opacity(0.5)
        case .secondary, .text:
            return .clear
        }
    }
    
    private var shadowRadius: CGFloat {
        switch style {
        case .primary:
            return enabled ? 20 : 0
        case .secondary, .text:
            return 0
        }
    }
    
    private var shadowY: CGFloat {
        switch style {
        case .primary:
            return enabled ? 10 : 0
        case .secondary, .text:
            return 0
        }
    }
}

// MARK: - Interactive Button Style

struct InteractiveButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.8), value: configuration.isPressed)
    }
}

#Preview {
    VStack(spacing: ModernTheme.Spacing.lg) {
        PrimaryButton(title: "Analyze Outfit", systemImage: "sparkles")
        
        PrimaryButton(title: "Disabled", systemImage: "xmark", enabled: false)
        
        PrimaryButton(title: "Secondary Style", systemImage: "camera", style: .secondary)
        
        PrimaryButton(title: "Text Style", style: .text)
    }
    .padding()
    .background(ModernTheme.background)
}
