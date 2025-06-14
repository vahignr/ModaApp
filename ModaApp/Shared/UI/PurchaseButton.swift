//
//  PurchaseButton.swift
//  ModaApp
//
//  Premium purchase button with luxury animations
//

import SwiftUI

struct PurchaseButton: View {
    let title: String
    let subtitle: String?
    let price: String
    let isLoading: Bool
    let action: () -> Void
    
    @State private var isPressed = false
    @State private var pulseAnimation = false
    @State private var shimmerOffset: CGFloat = -200
    
    init(
        title: String,
        subtitle: String? = nil,
        price: String,
        isLoading: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.subtitle = subtitle
        self.price = price
        self.isLoading = isLoading
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            ZStack {
                // Background with gradient
                RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.large)
                    .fill(ModernTheme.primaryGradient)
                    .overlay(
                        RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.large)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.3),
                                        Color.white.opacity(0.1)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                
                // Shimmer effect
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
                    RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.large)
                )
                .allowsHitTesting(false)
                
                // Pulse animation background
                if !isLoading {
                    RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.large)
                        .stroke(ModernTheme.primary.opacity(0.5), lineWidth: 2)
                        .scaleEffect(pulseAnimation ? 1.05 : 1.0)
                        .opacity(pulseAnimation ? 0 : 0.5)
                        .animation(
                            .easeOut(duration: 1.5)
                            .repeatForever(autoreverses: false),
                            value: pulseAnimation
                        )
                }
                
                // Content
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(title.uppercased())
                            .font(ModernTheme.Typography.headline)
                            .tracking(1.2)
                            .foregroundColor(.white)
                        
                        if let subtitle = subtitle {
                            Text(subtitle)
                                .font(ModernTheme.Typography.caption)
                                .tracking(0.5)
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                    
                    Spacer()
                    
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.2)
                    } else {
                        VStack(alignment: .trailing, spacing: 2) {
                            Text(price)
                                .font(ModernTheme.Typography.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            // Add "tap to buy" hint
                            Text("TAP TO BUY")
                                .font(ModernTheme.Typography.finePrint)
                                .tracking(1.0)
                                .foregroundColor(.white.opacity(0.6))
                        }
                    }
                }
                .padding(.horizontal, ModernTheme.Spacing.lg)
                .padding(.vertical, ModernTheme.Spacing.md)
            }
            .frame(height: 80)
            .shadow(
                color: ModernTheme.primary.opacity(0.4),
                radius: isPressed ? 10 : 20,
                x: 0,
                y: isPressed ? 5 : 10
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
        }
        .disabled(isLoading)
        .onAppear {
            pulseAnimation = true
            withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                shimmerOffset = 300
            }
        }
        .onLongPressGesture(minimumDuration: .infinity, maximumDistance: .infinity,
            pressing: { pressing in
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = pressing
                }
            },
            perform: {}
        )
    }
}

// MARK: - Compact Purchase Button with Floating Design
struct CompactPurchaseButton: View {
    let creditsNeeded: Int
    let action: () -> Void
    @EnvironmentObject var localizationManager: LocalizationManager
    @State private var isAnimating = false
    @State private var rotationAngle: Double = 0
    
    var body: some View {
        Button(action: action) {
            ZStack {
                // Glow effect
                Circle()
                    .fill(ModernTheme.primary.opacity(0.3))
                    .frame(width: 140, height: 140)
                    .blur(radius: 30)
                    .scaleEffect(isAnimating ? 1.3 : 0.8)
                    .animation(
                        .easeInOut(duration: 2)
                        .repeatForever(autoreverses: true),
                        value: isAnimating
                    )
                
                // Main button with glass morphism
                HStack(spacing: ModernTheme.Spacing.sm) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 22, weight: .medium))
                        .rotationEffect(.degrees(rotationAngle))
                    
                    Text(localized(.buyCredits).uppercased())
                        .font(ModernTheme.Typography.buttonText)
                        .fontWeight(.semibold)
                        .tracking(1.5)
                }
                .foregroundColor(.white)
                .padding(.horizontal, ModernTheme.Spacing.lg)
                .padding(.vertical, ModernTheme.Spacing.sm)
                .background(
                    Capsule()
                        .fill(ModernTheme.primaryGradient)
                        .overlay(
                            Capsule()
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(0.3),
                                            Color.white.opacity(0.1)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        )
                )
                .shadow(
                    color: ModernTheme.primary.opacity(0.5),
                    radius: 15,
                    x: 0,
                    y: 8
                )
            }
        }
        .onAppear {
            isAnimating = true
            withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                rotationAngle = 360
            }
        }
    }
}

// MARK: - Premium Credit Display
struct CreditDisplay: View {
    let credits: Int
    let onTap: () -> Void
    @State private var isAnimating = false
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: ModernTheme.Spacing.xs) {
                // Animated coin icon
                ZStack {
                    Circle()
                        .fill(ModernTheme.secondary.opacity(0.2))
                        .frame(width: 28, height: 28)
                    
                    Image(systemName: "leaf.circle.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [ModernTheme.secondary, ModernTheme.primary],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .scaleEffect(isAnimating ? 1.1 : 1.0)
                        .animation(
                            .spring(response: 0.5, dampingFraction: 0.7)
                            .repeatForever(autoreverses: true),
                            value: isAnimating
                        )
                }
                
                Text("\(credits)")
                    .font(ModernTheme.Typography.headline)
                    .fontWeight(.bold)
                    .foregroundColor(ModernTheme.textPrimary)
                
                if credits == 0 {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(ModernTheme.error)
                }
            }
            .padding(.horizontal, ModernTheme.Spacing.md)
            .padding(.vertical, ModernTheme.Spacing.xs)
            .background(
                Capsule()
                    .fill(
                        credits > 0 ?
                        ModernTheme.surface.opacity(0.8) :
                        ModernTheme.error.opacity(0.1)
                    )
                    .background(
                        .ultraThinMaterial.opacity(0.3)
                    )
                    .overlay(
                        Capsule()
                            .stroke(
                                credits > 0 ?
                                ModernTheme.secondary.opacity(0.3) :
                                ModernTheme.error.opacity(0.3),
                                lineWidth: 1
                            )
                    )
            )
        }
        .onAppear {
            isAnimating = true
        }
    }
}

#Preview {
    VStack(spacing: ModernTheme.Spacing.xl) {
        PurchaseButton(
            title: "10 Credits",
            subtitle: "Most popular",
            price: "$1.99",
            action: {}
        )
        
        PurchaseButton(
            title: "50 Credits",
            subtitle: "Best value",
            price: "$9.99",
            isLoading: true,
            action: {}
        )
        
        CompactPurchaseButton(creditsNeeded: 1, action: {})
            .environmentObject(LocalizationManager.shared)
        
        HStack {
            CreditDisplay(credits: 5, onTap: {})
            CreditDisplay(credits: 0, onTap: {})
        }
    }
    .padding()
    .background(ModernTheme.background)
}
