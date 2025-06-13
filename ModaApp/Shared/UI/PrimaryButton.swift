//
//  PrimaryButton.swift
//  ModaApp
//
//  Luxury button with animations and haptic feedback
//

import SwiftUI

struct PrimaryButton: View {
    
    // MARK: - Properties
    let title: String
    let systemImage: String?
    let enabled: Bool
    let style: ButtonVariant
    let action: () -> Void
    
    @State private var isPressed = false
    @State private var shimmerPhase: CGFloat = 0
    
    enum ButtonVariant {
        case primary
        case secondary
        case text
        case floating
    }
    
    // MARK: - Initializers
    init(title: String,
         systemImage: String? = nil,
         enabled: Bool = true,
         style: ButtonVariant = .primary,
         action: @escaping () -> Void = {}) {
        self.title = title
        self.systemImage = systemImage
        self.enabled = enabled
        self.style = style
        self.action = action
    }
    
    // MARK: - Body
    var body: some View {
        Button(action: {
            if enabled {
                // Haptic feedback
                let impact = UIImpactFeedbackGenerator(style: .medium)
                impact.impactOccurred()
                
                action()
            }
        }) {
            buttonContent
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(!enabled)
    }
    
    @ViewBuilder
    private var buttonContent: some View {
        switch style {
        case .primary:
            primaryStyle
        case .secondary:
            secondaryStyle
        case .text:
            textStyle
        case .floating:
            floatingStyle
        }
    }
    
    // MARK: - Primary Style
    private var primaryStyle: some View {
        HStack(spacing: ModernTheme.Spacing.sm) {
            if let systemImage {
                Image(systemName: systemImage)
                    .font(.system(size: 18, weight: .semibold))
                    .rotationEffect(.degrees(isPressed ? 360 : 0))
                    .animation(.easeInOut(duration: 0.4), value: isPressed)
            }
            
            Text(title)
                .fontWeight(.semibold)
                .tracking(0.5)
        }
        .font(ModernTheme.Typography.headline)
        .foregroundColor(.white)
        .frame(height: 56)
        .frame(maxWidth: .infinity)
        .background(
            ZStack {
                // Gradient background
                ModernTheme.primaryGradient
                    .opacity(enabled ? 1 : 0.5)
                
                // Shimmer overlay
                if enabled {
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0),
                            Color.white.opacity(0.3),
                            Color.white.opacity(0)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: 60)
                    .offset(x: shimmerPhase)
                    .mask(
                        RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.full)
                    )
                }
            }
        )
        .cornerRadius(ModernTheme.CornerRadius.full)
        .shadow(
            color: enabled ? ModernTheme.Shadow.colored.color : Color.clear,
            radius: isPressed ? 8 : ModernTheme.Shadow.colored.radius,
            x: 0,
            y: isPressed ? 4 : ModernTheme.Shadow.colored.y
        )
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .onLongPressGesture(
            minimumDuration: .infinity,
            maximumDistance: .infinity,
            pressing: { pressing in
                withAnimation(ModernTheme.springAnimation) {
                    isPressed = pressing
                }
            },
            perform: {}
        )
        .onAppear {
            withAnimation(
                .linear(duration: 2)
                .repeatForever(autoreverses: false)
            ) {
                shimmerPhase = 300
            }
        }
    }
    
    // MARK: - Secondary Style
    private var secondaryStyle: some View {
        HStack(spacing: ModernTheme.Spacing.sm) {
            if let systemImage {
                Image(systemName: systemImage)
                    .font(.system(size: 16, weight: .medium))
            }
            
            Text(title)
                .fontWeight(.medium)
        }
        .font(ModernTheme.Typography.callout)
        .foregroundColor(enabled ? ModernTheme.primary : ModernTheme.textTertiary)
        .padding(.horizontal, ModernTheme.Spacing.lg)
        .padding(.vertical, ModernTheme.Spacing.md)
        .background(
            ZStack {
                // Glass morphism background
                RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.full)
                    .fill(ModernTheme.glassWhite)
                    .background(
                        .ultraThinMaterial,
                        in: RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.full)
                    )
                
                // Gradient border
                RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.full)
                    .stroke(
                        LinearGradient(
                            colors: enabled ? [ModernTheme.primary, ModernTheme.secondary] : [ModernTheme.platinum],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        lineWidth: 2
                    )
            }
        )
        .shadow(
            color: ModernTheme.Shadow.small.color,
            radius: ModernTheme.Shadow.small.radius,
            x: 0,
            y: ModernTheme.Shadow.small.y
        )
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .onLongPressGesture(
            minimumDuration: .infinity,
            maximumDistance: .infinity,
            pressing: { pressing in
                withAnimation(ModernTheme.springAnimation) {
                    isPressed = pressing
                }
            },
            perform: {}
        )
    }
    
    // MARK: - Text Style
    private var textStyle: some View {
        HStack(spacing: ModernTheme.Spacing.xs) {
            if let systemImage {
                Image(systemName: systemImage)
                    .font(.system(size: 16))
            }
            
            Text(title)
                .fontWeight(.medium)
                .underline(isPressed, color: ModernTheme.secondary)
        }
        .font(ModernTheme.Typography.body)
        .foregroundColor(enabled ? ModernTheme.primary : ModernTheme.textTertiary)
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(ModernTheme.springAnimation, value: isPressed)
        .onLongPressGesture(
            minimumDuration: .infinity,
            maximumDistance: .infinity,
            pressing: { pressing in
                isPressed = pressing
            },
            perform: {}
        )
    }
    
    // MARK: - Floating Style
    private var floatingStyle: some View {
        ZStack {
            // Shadow circle
            Circle()
                .fill(ModernTheme.secondary.opacity(0.3))
                .blur(radius: 10)
                .offset(y: 4)
                .scaleEffect(isPressed ? 0.9 : 1.0)
            
            Circle()
                .fill(
                    LinearGradient(
                        colors: [ModernTheme.secondary, ModernTheme.tertiary],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(
                    color: ModernTheme.Shadow.colored.color,
                    radius: ModernTheme.Shadow.colored.radius,
                    x: 0,
                    y: ModernTheme.Shadow.colored.y
                )
            
            if let systemImage {
                Image(systemName: systemImage)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.white)
                    .rotationEffect(.degrees(isPressed ? 90 : 0))
                    .scaleEffect(isPressed ? 1.2 : 1.0)
            } else {
                Text(title)
                    .font(ModernTheme.Typography.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
        }
        .frame(width: 64, height: 64)
        .scaleEffect(isPressed ? 0.9 : 1.0)
        .animation(ModernTheme.bounceSpring, value: isPressed)
        .onLongPressGesture(
            minimumDuration: .infinity,
            maximumDistance: .infinity,
            pressing: { pressing in
                isPressed = pressing
            },
            perform: {}
        )
    }
}

// MARK: - Interactive Button Style for Other Uses
struct InteractiveButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(ModernTheme.springAnimation, value: configuration.isPressed)
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: ModernTheme.Spacing.lg) {
        PrimaryButton(
            title: "Analyze Outfit",
            systemImage: "sparkles",
            action: { print("Primary tapped") }
        )
        
        PrimaryButton(
            title: "Disabled Button",
            systemImage: "xmark",
            enabled: false
        )
        
        PrimaryButton(
            title: "Change Photo",
            systemImage: "camera",
            style: .secondary
        )
        
        PrimaryButton(
            title: "Skip for now",
            style: .text
        )
        
        HStack {
            PrimaryButton(
                title: "",  // Fixed: Added empty title for floating buttons
                systemImage: "camera.fill",
                style: .floating
            )
            
            PrimaryButton(
                title: "",  // Fixed: Added empty title for floating buttons
                systemImage: "heart.fill",
                style: .floating
            )
            
            PrimaryButton(
                title: "",  // Fixed: Added empty title for floating buttons
                systemImage: "sparkles",
                style: .floating
            )
        }
    }
    .padding()
    .background(ModernTheme.background)
}
