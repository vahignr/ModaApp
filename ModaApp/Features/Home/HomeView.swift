//
//  HomeView.swift
//  ModaApp
//
//  Main screen showing app features and navigation
//

import SwiftUI

struct HomeView: View {
    @StateObject private var creditsManager = CreditsManager.shared
    @EnvironmentObject var localizationManager: LocalizationManager
    @State private var selectedFeature: AppFeature?
    @State private var animateElements = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Clean background
                ModernTheme.background
                    .ignoresSafeArea()
                
                // Subtle pattern overlay
                GeometryReader { geometry in
                    ForEach(0..<5) { index in
                        Circle()
                            .fill(ModernTheme.lightSage.opacity(0.05))
                            .frame(width: 300, height: 300)
                            .offset(
                                x: CGFloat.random(in: -100...geometry.size.width),
                                y: CGFloat.random(in: -100...geometry.size.height)
                            )
                            .blur(radius: 40)
                    }
                }
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    ScrollView {
                        VStack(spacing: ModernTheme.Spacing.xl) {
                            // Welcome Section
                            WelcomeSection()
                                .padding(.top, 80) // Space from top
                                .opacity(animateElements ? 1 : 0)
                                .offset(y: animateElements ? 0 : 20)
                            
                            // Feature Section with Credits
                            VStack(alignment: .leading, spacing: ModernTheme.Spacing.lg) {
                                // Get Started and Credits Row
                                HStack(alignment: .center) {
                                    Text(localized(.getStarted))
                                        .font(ModernTheme.Typography.title2)
                                        .foregroundColor(ModernTheme.textPrimary)
                                    
                                    Spacer()
                                    
                                    // Credits Display
                                    HStack(spacing: ModernTheme.Spacing.xs) {
                                        Image(systemName: "leaf.circle.fill")
                                            .font(.system(size: 20))
                                            .foregroundColor(ModernTheme.primary)
                                        
                                        Text("\(LocalizationHelpers.formatNumber(creditsManager.remainingCredits))")
                                            .font(ModernTheme.Typography.body)
                                            .fontWeight(.semibold)
                                            .foregroundColor(ModernTheme.textPrimary)
                                        
                                        Text(localized(.credits))
                                            .font(ModernTheme.Typography.caption)
                                            .foregroundColor(ModernTheme.textSecondary)
                                    }
                                    .padding(.horizontal, ModernTheme.Spacing.md)
                                    .padding(.vertical, ModernTheme.Spacing.xs)
                                    .background(
                                        Capsule()
                                            .fill(ModernTheme.lightSage)
                                    )
                                }
                                .padding(.horizontal)
                                
                                // Feature Cards
                                ForEach(AppFeature.allCases) { feature in
                                    MinimalFeatureCard(
                                        feature: feature,
                                        action: { selectedFeature = feature }
                                    )
                                    .padding(.horizontal)
                                    .opacity(animateElements ? 1 : 0)
                                    .offset(y: animateElements ? 0 : 30)
                                }
                            }
                            .padding(.top, ModernTheme.Spacing.lg)
                            
                            // Footer
                            VStack(spacing: ModernTheme.Spacing.xs) {
                                HStack(spacing: 4) {
                                    ForEach(0..<3) { _ in
                                        Circle()
                                            .fill(ModernTheme.tertiary)
                                            .frame(width: 4, height: 4)
                                    }
                                }
                                
                                Text(localized(.madeWithLove))
                                    .font(ModernTheme.Typography.caption)
                                    .foregroundColor(ModernTheme.textTertiary)
                            }
                            .padding(.top, ModernTheme.Spacing.xxl)
                            .padding(.bottom, ModernTheme.Spacing.xxl)
                        }
                        .padding(.bottom, 100) // Space for language button
                    }
                }
                
                // Language Button at Bottom Right
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
            .navigationBarHidden(true) // Hide the navigation bar completely
            .fullScreenCover(item: $selectedFeature) { feature in
                switch feature {
                case .modaAnalyzer:
                    ContentView()
                        .environmentObject(localizationManager)
                }
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                animateElements = true
            }
        }
    }
}

// MARK: - Welcome Section
struct WelcomeSection: View {
    @EnvironmentObject var localizationManager: LocalizationManager
    
    var body: some View {
        VStack(spacing: ModernTheme.Spacing.md) {
            // App Name with Icon
            HStack(spacing: ModernTheme.Spacing.xs) {
                Image(systemName: "leaf.fill")
                    .font(.system(size: 36))
                    .foregroundColor(ModernTheme.primary)
                
                Text(localized(.appName))
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [ModernTheme.primary, ModernTheme.secondary],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
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
        }
    }
}

// MARK: - Minimal Feature Card
struct MinimalFeatureCard: View {
    @EnvironmentObject var localizationManager: LocalizationManager
    let feature: AppFeature
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: ModernTheme.Spacing.md) {
                // Icon
                ZStack {
                    Circle()
                        .fill(ModernTheme.primary.opacity(0.1))
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: feature.icon)
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(ModernTheme.primary)
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
                
                // Arrow
                Image(systemName: "arrow.right.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(ModernTheme.primary)
                    .opacity(feature.isAvailable ? 1 : 0.5)
            }
            .padding(ModernTheme.Spacing.lg)
            .background(
                RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.large)
                    .fill(ModernTheme.surface)
                    .shadow(
                        color: ModernTheme.primary.opacity(0.08),
                        radius: 8,
                        x: 0,
                        y: 4
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.large)
                    .stroke(ModernTheme.primary.opacity(0.1), lineWidth: 1)
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(!feature.isAvailable)
        .scaleEffect(isPressed ? 0.98 : 1.0)
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
