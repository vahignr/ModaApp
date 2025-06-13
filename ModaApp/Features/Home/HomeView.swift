//
//  HomeView.swift
//  ModaApp
//
//  Luxury home screen with animations and parallax effects
//

import SwiftUI

struct HomeView: View {
    @StateObject private var creditsManager = CreditsManager.shared
    @EnvironmentObject var localizationManager: LocalizationManager
    @State private var selectedFeature: AppFeature?
    @State private var animateElements = false
    @State private var showPurchaseView = false
    @State private var scrollOffset: CGFloat = 0
    @State private var heroScale: CGFloat = 1.0
    @State private var sparklePositions: [CGPoint] = []
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Animated gradient background
                AnimatedBackground()
                
                // Sparkle effects
                SparkleOverlay(positions: $sparklePositions)
                
                // Main content
                GeometryReader { geometry in
                    ScrollView {
                        VStack(spacing: 0) {
                            // Hero Section with parallax
                            HeroSection(scrollOffset: scrollOffset, scale: heroScale)
                                .frame(height: geometry.size.height * 0.5)
                                .opacity(animateElements ? 1 : 0)
                                .offset(y: animateElements ? 0 : 50)
                            
                            // Features Section
                            VStack(spacing: ModernTheme.Spacing.xl) {
                                // Credits and Get Started
                                HStack(alignment: .center) {
                                    Text(localized(.getStarted))
                                        .font(ModernTheme.Typography.title2)
                                        .foregroundColor(ModernTheme.textPrimary)
                                    
                                    Spacer()
                                    
                                    CreditsButton(
                                        credits: creditsManager.remainingCredits,
                                        action: { showPurchaseView = true }
                                    )
                                }
                                .padding(.horizontal)
                                .padding(.top, ModernTheme.Spacing.xl)
                                
                                // No Credits Card
                                if creditsManager.remainingCredits == 0 {
                                    NoCreditsCard(onPurchase: { showPurchaseView = true })
                                        .padding(.horizontal)
                                        .transition(.asymmetric(
                                            insertion: .scale(scale: 0.9).combined(with: .opacity),
                                            removal: .scale(scale: 0.9).combined(with: .opacity)
                                        ))
                                }
                                
                                // Feature Cards with staggered animation
                                ForEach(Array(AppFeature.allCases.enumerated()), id: \.element.id) { index, feature in
                                    LuxuryFeatureCard(
                                        feature: feature,
                                        action: { selectedFeature = feature },
                                        animationDelay: Double(index) * 0.15
                                    )
                                    .padding(.horizontal)
                                    .opacity(animateElements ? 1 : 0)
                                    .offset(y: animateElements ? 0 : 50)
                                }
                                
                                // Footer
                                FooterView()
                                    .padding(.top, ModernTheme.Spacing.xxxl)
                                    .padding(.bottom, 120)
                            }
                            .background(
                                GeometryReader { geo in
                                    Color.clear
                                        .preference(
                                            key: ScrollOffsetPreferenceKey.self,
                                            value: geo.frame(in: .named("scroll")).minY
                                        )
                                }
                            )
                        }
                    }
                    .coordinateSpace(name: "scroll")
                    .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                        scrollOffset = value
                        heroScale = 1 + (max(0, value) / 500)
                    }
                }
                
                // Language Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        LanguageButton()
                            .padding(.trailing, ModernTheme.Spacing.lg)
                            .padding(.bottom, ModernTheme.Spacing.xl)
                    }
                }
            }
            .navigationBarHidden(true)
            .fullScreenCover(item: $selectedFeature) { feature in
                switch feature {
                case .modaAnalyzer:
                    ContentView()
                        .environmentObject(localizationManager)
                }
            }
            .fullScreenCover(isPresented: $showPurchaseView) {
                PurchaseView()
                    .environmentObject(localizationManager)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.0)) {
                animateElements = true
            }
            generateSparklePositions()
        }
    }
    
    private func generateSparklePositions() {
        sparklePositions = (0..<15).map { _ in
            CGPoint(
                x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
            )
        }
    }
}

// MARK: - Animated Background
struct AnimatedBackground: View {
    @State private var animateGradient = false
    
    var body: some View {
        ZStack {
            // Base gradient
            LinearGradient(
                colors: [
                    ModernTheme.background,
                    ModernTheme.lightBlush,
                    ModernTheme.background
                ],
                startPoint: animateGradient ? .topLeading : .bottomTrailing,
                endPoint: animateGradient ? .bottomTrailing : .topLeading
            )
            .ignoresSafeArea()
            .onAppear {
                withAnimation(.linear(duration: 10).repeatForever(autoreverses: true)) {
                    animateGradient.toggle()
                }
            }
            
            // Radial overlay
            ModernTheme.radialBlushGradient
                .ignoresSafeArea()
                .opacity(0.5)
        }
    }
}

// MARK: - Sparkle Overlay
struct SparkleOverlay: View {
    @Binding var positions: [CGPoint]
    
    var body: some View {
        ZStack {
            ForEach(positions.indices, id: \.self) { index in
                SparkleView()
                    .position(positions[index])
                    .animation(
                        Animation.easeInOut(duration: Double.random(in: 2...4))
                            .repeatForever(autoreverses: true)
                            .delay(Double.random(in: 0...2)),
                        value: positions
                    )
            }
        }
        .ignoresSafeArea()
    }
}

struct SparkleView: View {
    @State private var opacity: Double = Double.random(in: 0.3...0.7)
    @State private var scale: CGFloat = CGFloat.random(in: 0.5...1.2)
    
    var body: some View {
        Image(systemName: "sparkle")
            .font(.system(size: CGFloat.random(in: 8...16)))
            .foregroundColor(ModernTheme.secondary)
            .opacity(opacity)
            .scaleEffect(scale)
            .onAppear {
                withAnimation(.easeInOut(duration: Double.random(in: 1...3)).repeatForever(autoreverses: true)) {
                    opacity = opacity == 0.3 ? 0.7 : 0.3
                    scale = scale == 0.5 ? 1.2 : 0.5
                }
            }
    }
}

// MARK: - Hero Section
struct HeroSection: View {
    let scrollOffset: CGFloat
    let scale: CGFloat
    @EnvironmentObject var localizationManager: LocalizationManager
    @State private var logoRotation: Double = 0
    
    var body: some View {
        ZStack {
            // Parallax background shapes
            Circle()
                .fill(ModernTheme.secondary.opacity(0.1))
                .frame(width: 300, height: 300)
                .blur(radius: 30)
                .offset(x: -100, y: -50 + scrollOffset * 0.3)
            
            Circle()
                .fill(ModernTheme.tertiary.opacity(0.1))
                .frame(width: 200, height: 200)
                .blur(radius: 20)
                .offset(x: 120, y: 100 + scrollOffset * 0.2)
            
            // Main content
            VStack(spacing: ModernTheme.Spacing.lg) {
                // Animated Logo
                ZStack {
                    Circle()
                        .fill(ModernTheme.primaryGradient)
                        .frame(width: 120, height: 120)
                        .blur(radius: 20)
                        .scaleEffect(scale)
                    
                    Circle()
                        .fill(ModernTheme.primary)
                        .frame(width: 100, height: 100)
                        .overlay(
                            Image(systemName: "leaf.fill")
                                .font(.system(size: 50, weight: .medium))
                                .foregroundColor(.white)
                                .rotationEffect(.degrees(logoRotation))
                        )
                        .shadow(
                            color: ModernTheme.Shadow.glow.color,
                            radius: ModernTheme.Shadow.glow.radius
                        )
                }
                .scaleEffect(scale)
                .onAppear {
                    withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                        logoRotation = 360
                    }
                }
                
                // App Name
                Text(localized(.appName))
                    .font(ModernTheme.Typography.largeTitle)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [ModernTheme.primary, ModernTheme.secondary],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .scaleEffect(scale)
                
                // Welcome Text
                VStack(spacing: ModernTheme.Spacing.xs) {
                    Text(localized(.welcomeTo))
                        .font(ModernTheme.Typography.title2)
                        .foregroundColor(ModernTheme.textSecondary)
                    
                    Text(localized(.sustainableStyleJourney))
                        .font(ModernTheme.Typography.title)
                        .fontWeight(.bold)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [ModernTheme.primary, ModernTheme.secondary, ModernTheme.tertiary],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .multilineTextAlignment(.center)
                    
                    Text(localized(.ecoDescription))
                        .font(ModernTheme.Typography.body)
                        .foregroundColor(ModernTheme.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, ModernTheme.Spacing.xl)
                        .padding(.top, ModernTheme.Spacing.xs)
                }
                .offset(y: scrollOffset * 0.1)
            }
        }
    }
}

// MARK: - Credits Button
struct CreditsButton: View {
    let credits: Int
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: ModernTheme.Spacing.xs) {
                ZStack {
                    Circle()
                        .fill(ModernTheme.secondaryGradient)
                        .frame(width: 24, height: 24)
                    
                    Image(systemName: "leaf.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                }
                
                Text("\(LocalizationHelpers.formatNumber(credits))")
                    .font(ModernTheme.Typography.headline)
                    .fontWeight(.bold)
                    .foregroundColor(ModernTheme.primary)
                
                Text(LocalizationManager.shared.string(for: .credits))
                    .font(ModernTheme.Typography.caption)
                    .foregroundColor(ModernTheme.textSecondary)
                
                if credits == 0 {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(ModernTheme.secondary)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(.horizontal, ModernTheme.Spacing.md)
            .padding(.vertical, ModernTheme.Spacing.sm)
            .background(
                Capsule()
                    .fill(credits > 0 ? ModernTheme.glassWhite : ModernTheme.secondary.opacity(0.1))
                    .background(
                        .ultraThinMaterial,
                        in: Capsule()
                    )
            )
            .overlay(
                Capsule()
                    .stroke(
                        credits > 0 ? ModernTheme.glassBorder : ModernTheme.secondary.opacity(0.3),
                        lineWidth: 1
                    )
            )
            .shadow(
                color: ModernTheme.Shadow.small.color,
                radius: ModernTheme.Shadow.small.radius,
                x: 0,
                y: ModernTheme.Shadow.small.y
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
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
}

// MARK: - Luxury Feature Card
struct LuxuryFeatureCard: View {
    @EnvironmentObject var localizationManager: LocalizationManager
    let feature: AppFeature
    let action: () -> Void
    let animationDelay: Double
    
    @State private var isPressed = false
    @State private var isHovered = false
    @State private var appeared = false
    
    var body: some View {
        Button(action: {
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
            action()
        }) {
            HStack(spacing: ModernTheme.Spacing.lg) {
                // Icon with glow effect
                ZStack {
                    Circle()
                        .fill(ModernTheme.primaryGradient)
                        .frame(width: 64, height: 64)
                        .blur(radius: isHovered ? 15 : 10)
                        .opacity(0.5)
                    
                    Circle()
                        .fill(ModernTheme.primaryGradient)
                        .frame(width: 56, height: 56)
                        .overlay(
                            Image(systemName: feature.icon)
                                .font(.system(size: 26, weight: .medium))
                                .foregroundColor(.white)
                                .rotationEffect(.degrees(isHovered ? 10 : 0))
                        )
                        .shadow(
                            color: ModernTheme.Shadow.colored.color,
                            radius: ModernTheme.Shadow.colored.radius,
                            x: 0,
                            y: ModernTheme.Shadow.colored.y
                        )
                }
                
                // Content
                VStack(alignment: .leading, spacing: 6) {
                    Text(localized(feature.titleKey))
                        .font(ModernTheme.Typography.headline)
                        .foregroundColor(ModernTheme.textPrimary)
                    
                    Text(localized(feature.descriptionKey))
                        .font(ModernTheme.Typography.callout)
                        .foregroundColor(ModernTheme.textSecondary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                Spacer()
                
                // Arrow with animation
                Image(systemName: "arrow.right.circle.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [ModernTheme.secondary, ModernTheme.tertiary],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .rotationEffect(.degrees(isHovered ? 45 : 0))
                    .offset(x: isHovered ? 5 : 0)
            }
            .padding(ModernTheme.Spacing.lg)
            .background(
                RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.xl)
                    .fill(ModernTheme.glassWhite)
                    .background(
                        .ultraThinMaterial,
                        in: RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.xl)
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.xl)
                    .stroke(ModernTheme.glassBorder, lineWidth: 1)
            )
            .shadow(
                color: isHovered ? ModernTheme.Shadow.medium.color : ModernTheme.Shadow.small.color,
                radius: isHovered ? ModernTheme.Shadow.medium.radius : ModernTheme.Shadow.small.radius,
                x: 0,
                y: isHovered ? ModernTheme.Shadow.medium.y : ModernTheme.Shadow.small.y
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .offset(x: appeared ? 0 : -50)
            .opacity(appeared ? 1 : 0)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(!feature.isAvailable)
        .onHover { hovering in
            withAnimation(ModernTheme.springAnimation) {
                isHovered = hovering
            }
        }
        .onLongPressGesture(
            minimumDuration: .infinity,
            maximumDistance: .infinity,
            pressing: { pressing in
                withAnimation(ModernTheme.springAnimation) {
                    isPressed = pressing
                    if pressing { isHovered = true }
                }
            },
            perform: {}
        )
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(animationDelay)) {
                appeared = true
            }
        }
    }
}

// MARK: - No Credits Card
struct NoCreditsCard: View {
    let onPurchase: () -> Void
    @EnvironmentObject var localizationManager: LocalizationManager
    @State private var shimmerPhase: CGFloat = -100
    
    var body: some View {
        HStack(spacing: ModernTheme.Spacing.md) {
            VStack(alignment: .leading, spacing: ModernTheme.Spacing.xs) {
                Text(localized(.noCredits))
                    .font(ModernTheme.Typography.headline)
                    .foregroundColor(ModernTheme.textPrimary)
                
                Text(localizationManager.currentLanguage == .turkish ?
                     "Stil analizi için kredi alın" :
                     "Get credits to analyze your style")
                    .font(ModernTheme.Typography.caption)
                    .foregroundColor(ModernTheme.textSecondary)
            }
            
            Spacer()
            
            Button(action: onPurchase) {
                Text(localized(.getMoreCredits))
                    .font(ModernTheme.Typography.callout)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, ModernTheme.Spacing.md)
                    .padding(.vertical, ModernTheme.Spacing.sm)
                    .background(
                        ZStack {
                            ModernTheme.secondaryGradient
                            
                            // Shimmer effect
                            LinearGradient(
                                colors: [
                                    Color.clear,
                                    Color.white.opacity(0.3),
                                    Color.clear
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                            .frame(width: 30)
                            .offset(x: shimmerPhase)
                            .mask(
                                Capsule()
                            )
                        }
                    )
                    .cornerRadius(ModernTheme.CornerRadius.full)
                    .shadow(
                        color: ModernTheme.Shadow.colored.color,
                        radius: 8,
                        x: 0,
                        y: 4
                    )
            }
        }
        .padding(ModernTheme.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.large)
                .fill(ModernTheme.secondary.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.large)
                        .stroke(ModernTheme.secondary.opacity(0.2), lineWidth: 1)
                )
        )
        .onAppear {
            withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                shimmerPhase = 200
            }
        }
    }
}

// MARK: - Footer View
struct FooterView: View {
    var body: some View {
        VStack(spacing: ModernTheme.Spacing.xs) {
            HStack(spacing: 4) {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(ModernTheme.secondary.opacity(0.3))
                        .frame(width: 4, height: 4)
                        .scaleEffect(1.5)
                        .animation(
                            Animation.easeInOut(duration: 1.5)
                                .repeatForever()
                                .delay(Double(index) * 0.3),
                            value: true
                        )
                }
            }
            
            Text(LocalizationManager.shared.string(for: .madeWithLove))
                .font(ModernTheme.Typography.caption)
                .foregroundColor(ModernTheme.textTertiary)
        }
    }
}

// MARK: - Supporting Types
struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: - App Feature Enum
enum AppFeature: String, CaseIterable, Identifiable {
    case modaAnalyzer = "moda_analyzer"
    
    var id: String { rawValue }
    
    var titleKey: LocalizedStringKey {
        switch self {
        case .modaAnalyzer:
            return .modaAnalyzer
        }
    }
    
    var descriptionKey: LocalizedStringKey {
        switch self {
        case .modaAnalyzer:
            return .modaAnalyzerDesc
        }
    }
    
    var icon: String {
        switch self {
        case .modaAnalyzer:
            return "camera.viewfinder"
        }
    }
    
    var isAvailable: Bool {
        switch self {
        case .modaAnalyzer:
            return true
        }
    }
}

// MARK: - Preview
#Preview {
    HomeView()
        .environmentObject(CreditsManager.shared)
        .environmentObject(LocalizationManager.shared)
}
