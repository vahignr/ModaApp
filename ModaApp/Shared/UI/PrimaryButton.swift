//
//  PrimaryButton.swift
//  ModaApp
//
//  Created by Vahi Guner on 6/3/25.
//  Updated to use ModernTheme
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
        HStack(spacing: ModernTheme.Spacing.xs) {
            if let systemImage {
                Image(systemName: systemImage)
                    .font(.system(size: 18, weight: .medium))
            }
            Text(title)
                .fontWeight(.semibold)
        }
        .font(ModernTheme.Typography.headline)
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
        .scaleEffect(enabled ? 1.0 : 0.98)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: enabled)
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
                ModernTheme.primaryGradient
            } else {
                ModernTheme.textTertiary.opacity(0.3)
            }
        case .secondary:
            Capsule()
                .stroke(enabled ? ModernTheme.primary : ModernTheme.textTertiary, lineWidth: 2)
                .background(Color.clear)
        case .text:
            Color.clear
        }
    }
    
    private var shadowColor: Color {
        guard enabled else { return .clear }
        
        switch style {
        case .primary:
            return ModernTheme.primary.opacity(0.3)
        case .secondary, .text:
            return .clear
        }
    }
    
    private var shadowRadius: CGFloat {
        switch style {
        case .primary:
            return enabled ? 12 : 0
        case .secondary, .text:
            return 0
        }
    }
    
    private var shadowY: CGFloat {
        switch style {
        case .primary:
            return enabled ? 6 : 0
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
