//
//  LanguageButton.swift
//  ModaApp
//
//  Luxury floating language switcher with animations
//

import SwiftUI

struct LanguageButton: View {
    @EnvironmentObject var localizationManager: LocalizationManager
    @State private var showLanguageSheet = false
    @State private var isPressed = false
    @State private var rotation: Double = 0
    
    var body: some View {
        Button {
            showLanguageSheet = true
            
            // Haptic feedback
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
        } label: {
            ZStack {
                // Glow effect
                Circle()
                    .fill(ModernTheme.secondary.opacity(0.3))
                    .frame(width: 72, height: 72)
                    .blur(radius: 20)
                    .offset(y: 4)
                
                // Main button
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                ModernTheme.primary,
                                ModernTheme.primary.opacity(0.8),
                                ModernTheme.secondary.opacity(0.5)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 56, height: 56)
                    .shadow(
                        color: ModernTheme.Shadow.colored.color,
                        radius: ModernTheme.Shadow.colored.radius,
                        x: 0,
                        y: ModernTheme.Shadow.colored.y
                    )
                
                // Icon with rotation
                Image(systemName: "globe")
                    .font(.system(size: 26, weight: .medium))
                    .foregroundColor(.white)
                    .rotationEffect(.degrees(rotation))
                    .scaleEffect(isPressed ? 1.2 : 1.0)
            }
        }
        .scaleEffect(isPressed ? 0.9 : 1.0)
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
                .linear(duration: 20)
                .repeatForever(autoreverses: false)
            ) {
                rotation = 360
            }
        }
        .sheet(isPresented: $showLanguageSheet) {
            LanguageSelectionSheet(isPresented: $showLanguageSheet)
                .environmentObject(localizationManager)
        }
    }
}

// MARK: - Language Selection Sheet
struct LanguageSelectionSheet: View {
    @Binding var isPresented: Bool
    @EnvironmentObject var localizationManager: LocalizationManager
    @State private var selectedLanguage: Language?
    @State private var iconScale: CGFloat = 1.0
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                ModernTheme.background
                    .ignoresSafeArea()
                
                LinearGradient(
                    colors: [
                        ModernTheme.secondary.opacity(0.05),
                        ModernTheme.background
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header with animation
                    VStack(spacing: ModernTheme.Spacing.md) {
                        ZStack {
                            Circle()
                                .fill(ModernTheme.radialBlushGradient)
                                .frame(width: 100, height: 100)
                                .blur(radius: 20)
                            
                            Image(systemName: "globe")
                                .font(.system(size: 50, weight: .light))
                                .foregroundColor(ModernTheme.primary)
                                .scaleEffect(iconScale)
                                .onAppear {
                                    withAnimation(
                                        .easeInOut(duration: 1.5)
                                        .repeatForever(autoreverses: true)
                                    ) {
                                        iconScale = 1.1
                                    }
                                }
                        }
                        .padding(.top, ModernTheme.Spacing.xl)
                        
                        Text(localized(.language))
                            .font(ModernTheme.Typography.title2)
                            .foregroundColor(ModernTheme.textPrimary)
                            .padding(.bottom, ModernTheme.Spacing.lg)
                    }
                    
                    // Language Options with staggered animation
                    VStack(spacing: ModernTheme.Spacing.md) {
                        ForEach(Array(Language.allCases.enumerated()), id: \.element) { index, language in
                            LanguageOptionRow(
                                language: language,
                                isSelected: language == localizationManager.currentLanguage,
                                action: {
                                    selectedLanguage = language
                                    
                                    withAnimation(ModernTheme.springAnimation) {
                                        localizationManager.switchLanguage(to: language)
                                    }
                                    
                                    // Haptic feedback
                                    let impact = UIImpactFeedbackGenerator(style: .light)
                                    impact.impactOccurred()
                                    
                                    // Close sheet after selection
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                        isPresented = false
                                    }
                                },
                                animationDelay: Double(index) * 0.1
                            )
                        }
                    }
                    .padding(.horizontal, ModernTheme.Spacing.xl)
                    .padding(.top, ModernTheme.Spacing.lg)
                    
                    Spacer()
                    
                    // Close button
                    Button {
                        isPresented = false
                    } label: {
                        Text(localized(.close))
                            .font(ModernTheme.Typography.body)
                            .foregroundColor(ModernTheme.textSecondary)
                            .padding(.vertical, ModernTheme.Spacing.sm)
                            .padding(.horizontal, ModernTheme.Spacing.xl)
                            .background(
                                Capsule()
                                    .stroke(ModernTheme.textTertiary.opacity(0.3), lineWidth: 1)
                            )
                    }
                    .padding(.bottom, ModernTheme.Spacing.xxl)
                }
            }
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Language Option Row
struct LanguageOptionRow: View {
    let language: Language
    let isSelected: Bool
    let action: () -> Void
    let animationDelay: Double
    
    @State private var appeared = false
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: ModernTheme.Spacing.md) {
                // Language icon
                ZStack {
                    Circle()
                        .fill(
                            isSelected ?
                            ModernTheme.primaryGradient :
                            LinearGradient(
                                colors: [ModernTheme.lightBlush, ModernTheme.accent.opacity(0.5)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 56, height: 56)
                    
                    Text(flagEmoji(for: language))
                        .font(.system(size: 28))
                }
                
                // Language name
                VStack(alignment: .leading, spacing: 4) {
                    Text(language.displayName)
                        .font(ModernTheme.Typography.headline)
                        .foregroundColor(isSelected ? ModernTheme.primary : ModernTheme.textPrimary)
                    
                    Text(nativeName(for: language))
                        .font(ModernTheme.Typography.caption)
                        .foregroundColor(ModernTheme.textSecondary)
                }
                
                Spacer()
                
                // Selection indicator
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(ModernTheme.primaryGradient)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(ModernTheme.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.large)
                    .fill(
                        isSelected ?
                        ModernTheme.primary.opacity(0.08) :
                        ModernTheme.surface
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.large)
                    .stroke(
                        isSelected ?
                        ModernTheme.primary.opacity(0.3) :
                        ModernTheme.glassBorder,
                        lineWidth: isSelected ? 2 : 1
                    )
            )
            .shadow(
                color: isSelected ? ModernTheme.Shadow.colored.color : ModernTheme.Shadow.small.color,
                radius: isSelected ? 8 : ModernTheme.Shadow.small.radius,
                x: 0,
                y: isSelected ? 4 : ModernTheme.Shadow.small.y
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .offset(x: appeared ? 0 : -50)
            .opacity(appeared ? 1 : 0)
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
        .onAppear {
            withAnimation(
                .spring(response: 0.6, dampingFraction: 0.7)
                .delay(animationDelay)
            ) {
                appeared = true
            }
        }
    }
    
    private func flagEmoji(for language: Language) -> String {
        switch language {
        case .english: return "🇺🇸"
        case .turkish: return "🇹🇷"
        }
    }
    
    private func nativeName(for language: Language) -> String {
        switch language {
        case .english: return "English (US)"
        case .turkish: return "Türkçe"
        }
    }
}

// MARK: - Preview
#Preview {
    VStack {
        Spacer()
        HStack {
            Spacer()
            LanguageButton()
                .environmentObject(LocalizationManager.shared)
        }
        .padding()
    }
    .background(ModernTheme.background)
}
