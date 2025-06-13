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
                                .symbolEffect(.pulse)
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
                                    
                                    // Dismiss after animation
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        isPresented = false
                                    }
                                }
                            )
                            .transition(.asymmetric(
                                insertion: .slide.combined(with: .opacity),
                                removal: .scale.combined(with: .opacity)
                            ))
                            .animation(
                                .spring(response: 0.5, dampingFraction: 0.8)
                                .delay(Double(index) * 0.1),
                                value: isPresented
                            )
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        isPresented = false
                    } label: {
                        ZStack {
                            Circle()
                                .fill(ModernTheme.glassWhite)
                                .frame(width: 32, height: 32)
                            
                            Image(systemName: "xmark")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(ModernTheme.textSecondary)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Language Option Row
struct LanguageOptionRow: View {
    let language: Language
    let isSelected: Bool
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: ModernTheme.Spacing.md) {
                // Language Icon with gradient
                ZStack {
                    Circle()
                        .fill(
                            isSelected ?
                            ModernTheme.secondaryGradient :
                            LinearGradient(
                                colors: [ModernTheme.lightBlush, ModernTheme.accent],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 56, height: 56)
                    
                    Text(language == .english ? "EN" : "TR")
                        .font(ModernTheme.Typography.headline)
                        .fontWeight(.bold)
                        .foregroundColor(isSelected ? .white : ModernTheme.primary)
                }
                
                // Language Details
                VStack(alignment: .leading, spacing: 4) {
                    Text(language.displayName)
                        .font(ModernTheme.Typography.headline)
                        .foregroundColor(ModernTheme.textPrimary)
                    
                    Text(language == .english ? "English Language" : "Türk Dili")
                        .font(ModernTheme.Typography.caption)
                        .foregroundColor(ModernTheme.textSecondary)
                }
                
                Spacer()
                
                // Animated Checkmark
                if isSelected {
                    ZStack {
                        Circle()
                            .fill(ModernTheme.success.opacity(0.1))
                            .frame(width: 32, height: 32)
                        
                        Image(systemName: "checkmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(ModernTheme.success)
                    }
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(ModernTheme.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.large)
                    .fill(isSelected ? ModernTheme.glassWhite : ModernTheme.surface)
                    .background(
                        isSelected ? AnyView(
                            RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.large)
                                .fill(.ultraThinMaterial)
                        ) : AnyView(Color.clear)
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.large)
                    .stroke(
                        isSelected ?
                        ModernTheme.secondaryGradient :
                        LinearGradient(colors: [Color.clear], startPoint: .leading, endPoint: .trailing),
                        lineWidth: 2
                    )
            )
            .shadow(
                color: isSelected ? ModernTheme.Shadow.medium.color : ModernTheme.Shadow.small.color,
                radius: isSelected ? ModernTheme.Shadow.medium.radius : ModernTheme.Shadow.small.radius,
                x: 0,
                y: isSelected ? ModernTheme.Shadow.medium.y : ModernTheme.Shadow.small.y
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
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

// MARK: - Preview
#Preview {
    ZStack {
        ModernTheme.background
            .ignoresSafeArea()
        
        VStack {
            Spacer()
            
            HStack {
                Spacer()
                LanguageButton()
                    .padding()
            }
        }
    }
    .environmentObject(LocalizationManager.shared)
}
