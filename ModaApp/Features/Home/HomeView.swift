//
//  HomeView.swift
//  ModaApp
//
//  Main screen with enhanced animations and parallax effects
//

import SwiftUI

struct HomeView: View {
    @StateObject private var creditsManager = CreditsManager.shared
    @EnvironmentObject var localizationManager: LocalizationManager
    @State private var selectedFeature: AppFeature?
    @State private var animateElements = false
    @State private var showPurchaseView = false
    @State private var heroScale: CGFloat = 0.5
    @State private var particlesVisible = false
    @State private var previousCredits: Int = 0
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Animated gradient background
                AnimatedBackgroundView()
                
                // Floating orbs with parallax
                FloatingOrbsView()
                
                VStack(spacing: 0) {
                    ScrollView {
                        VStack(spacing: ModernTheme.Spacing.xl) {
                            // Welcome Section with hero animation
                            WelcomeSection()
                                .padding(.top, 20)
                                .scaleEffect(heroScale)
                                .opacity(heroScale)
                                .onAppear {
                                    withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.2)) {
                                        heroScale = 1.0
                                    }
                                }
                            
                            // Feature Section with staggered animations
                            VStack(alignment: .leading, spacing: ModernTheme.Spacing.lg) {
                                // Get Started and Credits Row
                                HStack(alignment: .center) {
                                    Text(localized(.getStarted))
                                        .font(ModernTheme.Typography.title2)
                                        .foregroundColor(ModernTheme.textPrimary)
                                        .shimmer()
                                    
                                    Spacer()
                                    
                                    // Animated Credits Display
                                    CreditDisplay(
                                        credits: creditsManager.remainingCredits,
                                        onTap: { showPurchaseView = true }
                                    )
                                    .transition(.scale.combined(with: .opacity))
                                }
                                .padding(.horizontal)
                                .opacity(animateElements ? 1 : 0)
                                .offset(y: animateElements ? 0 : 20)
                                
                                // No Credits Banner with elastic animation
                                if creditsManager.remainingCredits == 0 {
                                    NoCreditsCard(onPurchase: { showPurchaseView = true })
                                        .padding(.horizontal)
                                        .transition(.glassReveal)
                                        .elasticDrag()
                                }
                                
                                // Feature Cards with parallax
                                ForEach(Array(AppFeature.allCases.enumerated()), id: \.element) { index, feature in
                                    MinimalFeatureCard(
                                        feature: feature,
                                        action: {
                                            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                                selectedFeature = feature
                                            }
                                        }
                                    )
                                    .padding(.horizontal)
                                    .opacity(animateElements ? 1 : 0)
                                    .offset(y: animateElements ? 0 : 50)
                                    .animation(
                                        .spring(response: 0.6, dampingFraction: 0.8)
                                        .delay(Double(index) * 0.15),
                                        value: animateElements
                                    )
                                }
                            }
                            .padding(.top, ModernTheme.Spacing.lg)
                            
                            // Animated Footer
                            FooterView()
                                .opacity(animateElements ? 1 : 0)
                                .animation(.easeOut(duration: 1).delay(0.8), value: animateElements)
                        }
                        .padding(.bottom, 100)
                    }
                }
                
                // Floating Language Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        LanguageButton()
                            .floatingAnimation(delay: 0.5)
                            .padding(.trailing, ModernTheme.Spacing.lg)
                            .padding(.bottom, ModernTheme.Spacing.xl)
                    }
                }
                
                // Particle effects when credits are added
                if particlesVisible {
                    ParticleEffectView()
                        .allowsHitTesting(false)
                }
            }
            .navigationBarHidden(true)
            .fullScreenCover(item: $selectedFeature) { feature in
                switch feature {
                case .modaAnalyzer:
                    ContentView()
                        .environmentObject(localizationManager)
                        .transition(.luxurySlide)
                }
            }
            .fullScreenCover(isPresented: $showPurchaseView) {
                PurchaseView()
                    .environmentObject(localizationManager)
                    .transition(.hero)
            }
        }
        .onAppear {
            previousCredits = creditsManager.remainingCredits
            withAnimation(.easeOut(duration: 0.8).delay(0.3)) {
                animateElements = true
            }
        }
        .onChange(of: creditsManager.remainingCredits) { newValue in  // Fixed: iOS 16 compatible syntax
            if newValue > previousCredits {
                particlesVisible = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    particlesVisible = false
                }
            }
            previousCredits = newValue
        }
    }
}

// MARK: - Animated Background
struct AnimatedBackgroundView: View {
    @State private var gradientRotation: Double = 0
    
    var body: some View {
        ZStack {
            ModernTheme.background
                .ignoresSafeArea()
            
            // Animated gradient overlay
            LinearGradient(
                colors: [
                    ModernTheme.primary.opacity(0.1),
                    ModernTheme.secondary.opacity(0.05),
                    Color.clear,
                    ModernTheme.accent.opacity(0.05)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .rotationEffect(.degrees(gradientRotation))
            .ignoresSafeArea()
            .onAppear {
                withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                    gradientRotation = 360
                }
            }
        }
    }
}

// MARK: - Floating Orbs
struct FloatingOrbsView: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(0..<5) { index in
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    ModernTheme.primary.opacity(0.2),
                                    ModernTheme.secondary.opacity(0.1),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: 150
                            )
                        )
                        .frame(width: 300, height: 300)
                        .blur(radius: 40)
                        .offset(
                            x: CGFloat.random(in: -100...geometry.size.width),
                            y: CGFloat.random(in: -100...geometry.size.height)
                        )
                        .floatingAnimation(delay: Double(index) * 0.3)
                        .parallaxEffect(magnitude: CGFloat(index + 1) * 5)
                }
            }
        }
        .ignoresSafeArea()
    }
}

// MARK: - No Credits Card with Animation
struct NoCreditsCard: View {
    let onPurchase: () -> Void
    @EnvironmentObject var localizationManager: LocalizationManager
    @State private var isPressed = false
    
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
                            
                            // Pulse effect
                            if !isPressed {
                                Circle()
                                    .stroke(ModernTheme.secondary, lineWidth: 2)
                                    .scaleEffect(1.5)
                                    .opacity(0)
                                    .animation(
                                        .easeOut(duration: 1)
                                        .repeatForever(autoreverses: false),
                                        value: isPressed
                                    )
                            }
                        }
                    )
                    .cornerRadius(ModernTheme.CornerRadius.full)
            }
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .onLongPressGesture(minimumDuration: .infinity, maximumDistance: .infinity,
                pressing: { pressing in
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        isPressed = pressing
                    }
                },
                perform: {}
            )
        }
        .padding(ModernTheme.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.large)
                .fill(ModernTheme.secondary.opacity(0.1))
                .background(.ultraThinMaterial.opacity(0.5))
                .overlay(
                    RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.large)
                        .stroke(ModernTheme.secondary.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

// MARK: - Welcome Section with Animations
struct WelcomeSection: View {
    @EnvironmentObject var localizationManager: LocalizationManager
    @State private var titleScale: CGFloat = 0
    @State private var subtitleOffset: CGFloat = 50
    
    var body: some View {
        VStack(spacing: ModernTheme.Spacing.md) {
            // App Name with Icon
            HStack(spacing: ModernTheme.Spacing.xs) {
                Image(systemName: "leaf.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [ModernTheme.primary, ModernTheme.secondary],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .rotationEffect(.degrees(titleScale * 360))
                
                Text(localized(.appName))
                    .font(.system(size: 36, weight: .bold, design: .serif))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [ModernTheme.primary, ModernTheme.secondary],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            }
            .scaleEffect(titleScale)
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    titleScale = 1
                }
            }
            
            // Welcome Text
            VStack(spacing: ModernTheme.Spacing.xs) {
                Text(localized(.welcomeTo))
                    .font(ModernTheme.Typography.title2)
                    .foregroundColor(ModernTheme.textPrimary)
                
                Text(localized(.sustainableStyleJourney))
                    .font(ModernTheme.Typography.title)
                    .fontWeight(.bold)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [ModernTheme.primary, ModernTheme.secondary],
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
            .offset(y: subtitleOffset)
            .opacity(subtitleOffset == 0 ? 1 : 0)
            .onAppear {
                withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.3)) {
                    subtitleOffset = 0
                }
            }
        }
    }
}

// MARK: - Minimal Feature Card with Hover
struct MinimalFeatureCard: View {
    @EnvironmentObject var localizationManager: LocalizationManager
    let feature: AppFeature
    let action: () -> Void
    @State private var isPressed = false
    @State private var isHovered = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: ModernTheme.Spacing.md) {
                // Animated Icon
                ZStack {
                    Circle()
                        .fill(ModernTheme.primary.opacity(0.1))
                        .frame(width: 56, height: 56)
                        .overlay(
                            Circle()
                                .stroke(ModernTheme.primaryGradient.opacity(0.3), lineWidth: 1)
                                .scaleEffect(isHovered ? 1.2 : 1.0)
                                .opacity(isHovered ? 1 : 0)
                                .animation(.easeOut(duration: 0.3), value: isHovered)
                        )
                    
                    Image(systemName: feature.icon)
                        .font(.system(size: 24, weight: .medium))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [ModernTheme.primary, ModernTheme.secondary],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .rotationEffect(.degrees(isHovered ? 10 : 0))
                        .animation(.spring(response: 0.4, dampingFraction: 0.6), value: isHovered)
                }
                
                // Content
                VStack(alignment: .leading, spacing: 4) {
                    Text(localized(feature.titleKey))
                        .font(ModernTheme.Typography.headline)
                        .foregroundColor(ModernTheme.textPrimary)
                    
                    Text(localized(feature.descriptionKey))
                        .font(ModernTheme.Typography.callout)
                        .foregroundColor(ModernTheme.textSecondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                // Animated Arrow
                Image(systemName: "arrow.right.circle.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [ModernTheme.primary, ModernTheme.secondary],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .opacity(feature.isAvailable ? 1 : 0.5)
                    .offset(x: isHovered ? 5 : 0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isHovered)
            }
            .padding(ModernTheme.Spacing.lg)
            .background(
                RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.large)
                    .fill(ModernTheme.surface)
                    .background(.ultraThinMaterial.opacity(0.3))
                    .shadow(
                        color: isHovered ? ModernTheme.primary.opacity(0.2) : ModernTheme.primary.opacity(0.08),
                        radius: isHovered ? 12 : 8,
                        x: 0,
                        y: isHovered ? 6 : 4
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.large)
                    .stroke(ModernTheme.primaryGradient.opacity(isHovered ? 0.3 : 0.1), lineWidth: 1)
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(!feature.isAvailable)
        .onHover { hovering in
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isHovered = hovering
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

// MARK: - Animated Footer
struct FooterView: View {
    @State private var dotsScale: [CGFloat] = [1, 1, 1]
    
    var body: some View {
        VStack(spacing: ModernTheme.Spacing.xs) {
            HStack(spacing: 8) {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(ModernTheme.tertiary)
                        .frame(width: 6, height: 6)
                        .scaleEffect(dotsScale[index])
                        .animation(
                            .spring(response: 0.5, dampingFraction: 0.5)
                            .delay(Double(index) * 0.1)
                            .repeatForever(autoreverses: true),
                            value: dotsScale[index]
                        )
                }
            }
            .onAppear {
                for index in 0..<3 {
                    dotsScale[index] = 1.5
                }
            }
            
            Text(localized(.madeWithLove))
                .font(ModernTheme.Typography.caption)
                .foregroundColor(ModernTheme.textTertiary)
                .shimmer()
        }
        .padding(.top, ModernTheme.Spacing.xxl)
        .padding(.bottom, ModernTheme.Spacing.xxl)
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
