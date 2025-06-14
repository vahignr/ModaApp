//
//  LanguageButton.swift
//  ModaApp
//
//  Reusable language switcher with luxury floating design
//

import SwiftUI

struct LanguageButton: View {
    @EnvironmentObject var localizationManager: LocalizationManager
    @State private var showLanguageSheet = false
    @State private var isAnimating = false
    @State private var rotationAngle: Double = 0
    
    var body: some View {
        Button {
            showLanguageSheet = true
        } label: {
            ZStack {
                // Outer glow effect
                Circle()
                    .fill(ModernTheme.primary.opacity(0.3))
                    .frame(width: 72, height: 72)
                    .blur(radius: 20)
                    .scaleEffect(isAnimating ? 1.2 : 0.9)
                    .animation(
                        .easeInOut(duration: 2)
                        .repeatForever(autoreverses: true),
                        value: isAnimating
                    )
                
                // Glass morphism circle
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                ModernTheme.primary.opacity(0.3),
                                ModernTheme.secondary.opacity(0.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .background(
                        .ultraThinMaterial.opacity(0.7)
                    )
                    .overlay(
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.5),
                                        Color.white.opacity(0.2)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                    .shadow(
                        color: ModernTheme.primary.opacity(0.4),
                        radius: 15,
                        x: 0,
                        y: 8
                    )
                
                Image(systemName: "globe")
                    .font(.system(size: 26, weight: .medium))
                    .foregroundColor(.white)
                    .rotationEffect(.degrees(rotationAngle))
            }
            .frame(width: 60, height: 60)
            .scaleEffect(showLanguageSheet ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: showLanguageSheet)
        }
        .onAppear {
            isAnimating = true
            withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                rotationAngle = 360
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
                // Luxury background
                ModernTheme.background
                    .ignoresSafeArea()
                
                // Subtle gradient overlay
                LinearGradient(
                    colors: [
                        ModernTheme.primary.opacity(0.05),
                        ModernTheme.secondary.opacity(0.05),
                        Color.clear
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header with animation
                    VStack(spacing: ModernTheme.Spacing.sm) {
                        ZStack {
                            // Animated background circle
                            Circle()
                                .fill(ModernTheme.primaryGradient.opacity(0.2))
                                .frame(width: 100, height: 100)
                                .blur(radius: 30)
                                .scaleEffect(selectedLanguage != nil ? 1.5 : 1.0)
                                .animation(.spring(response: 0.5, dampingFraction: 0.7), value: selectedLanguage)
                            
                            Image(systemName: "globe")
                                .font(.system(size: 44))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [ModernTheme.primary, ModernTheme.secondary],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .rotationEffect(.degrees(selectedLanguage != nil ? 180 : 0))
                                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: selectedLanguage)
                        }
                        .padding(.top, ModernTheme.Spacing.xl)
                        
                        Text(localized(.language).uppercased())
                            .font(ModernTheme.Typography.title2)
                            .tracking(2.0)
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
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                        localizationManager.switchLanguage(to: language)
                                    }
                                    // Haptic feedback
                                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                                    impactFeedback.impactOccurred()
                                    
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        isPresented = false
                                    }
                                }
                            )
                            .transition(.asymmetric(
                                insertion: .scale(scale: 0.8).combined(with: .opacity),
                                removal: .scale(scale: 1.1).combined(with: .opacity)
                            ))
                            .animation(
                                .spring(response: 0.5, dampingFraction: 0.8)
                                .delay(Double(index) * 0.1),
                                value: selectedLanguage
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
                                .fill(ModernTheme.surface.opacity(0.8))
                                .frame(width: 32, height: 32)
                            
                            Image(systemName: "xmark")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(ModernTheme.textPrimary)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Language Option Row with Glass Morphism
struct LanguageOptionRow: View {
    let language: Language
    let isSelected: Bool
    let action: () -> Void
    @State private var isPressed = false
    @State private var isHovered = false
    
    // Extract complex background to computed property
    private var rowBackground: some View {
        RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.large)
            .fill(backgroundFillColor)
            .background(backgroundMaterial)
    }
    
    private var backgroundFillColor: Color {
        isSelected ? ModernTheme.primary.opacity(0.1) : ModernTheme.surface.opacity(0.5)
    }
    
    private var backgroundMaterial: some View {
        Color.clear
            .background(.ultraThinMaterial.opacity(0.3))
            .cornerRadius(ModernTheme.CornerRadius.large)
    }
    
    private var strokeGradient: LinearGradient {
        if isSelected {
            return ModernTheme.primaryGradient
        } else {
            return LinearGradient(
                colors: [Color.clear],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: ModernTheme.Spacing.md) {
                // Flag or Language Icon with glass effect
                LanguageIconCircle(
                    language: language,
                    isSelected: isSelected,
                    isHovered: isHovered
                )
                
                // Language Name with elegant typography
                VStack(alignment: .leading, spacing: 4) {
                    Text(language.displayName.uppercased())
                        .font(ModernTheme.Typography.headline)
                        .tracking(1.5)
                        .foregroundColor(ModernTheme.textPrimary)
                    
                    Text(language == .english ? "English Language" : "Türk Dili")
                        .font(ModernTheme.Typography.caption)
                        .foregroundColor(ModernTheme.textSecondary)
                }
                
                Spacer()
                
                // Animated checkmark
                if isSelected {
                    SelectedCheckmark()
                }
            }
            .padding(ModernTheme.Spacing.md)
            .background(rowBackground)
            .overlay(
                RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.large)
                    .stroke(strokeGradient, lineWidth: isSelected ? 2 : 0)
            )
            .shadow(
                color: isSelected ? ModernTheme.primary.opacity(0.2) : ModernTheme.Shadow.small.color,
                radius: isSelected ? 12 : ModernTheme.Shadow.small.radius,
                x: 0,
                y: isSelected ? 6 : ModernTheme.Shadow.small.y
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .onHover { hovering in
            isHovered = hovering
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

// MARK: - Extracted Components

struct LanguageIconCircle: View {
    let language: Language
    let isSelected: Bool
    let isHovered: Bool
    
    var body: some View {
        ZStack {
            // Background circle with material
            Circle()
                .fill(Color.clear)
                .frame(width: 56, height: 56)
                .background(
                    ZStack {
                        // Material layer
                        Circle()
                            .fill(Color.clear)
                            .background(.ultraThinMaterial.opacity(0.3))
                        
                        // Color layer
                        Circle()
                            .fill(
                                isSelected ?
                                ModernTheme.primary.opacity(0.3) :
                                Color.white.opacity(0.05)
                            )
                    }
                    .clipShape(Circle())
                )
                .overlay(
                    Circle()
                        .stroke(
                            isSelected ?
                            LinearGradient(
                                colors: [ModernTheme.primary, ModernTheme.secondary],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ) :
                            LinearGradient(
                                colors: [Color.white.opacity(0.2), Color.white.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: isSelected ? 2 : 1
                        )
                )
                .shadow(
                    color: isSelected ? ModernTheme.primary.opacity(0.3) : Color.clear,
                    radius: 10,
                    x: 0,
                    y: 5
                )
            
            Text(language == .english ? "EN" : "TR")
                .font(ModernTheme.Typography.headline)
                .fontWeight(.bold)
                .tracking(1.0)
                .foregroundColor(isSelected ? ModernTheme.primary : ModernTheme.textPrimary)
                .scaleEffect(isHovered ? 1.1 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isHovered)
        }
    }
}

struct SelectedCheckmark: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(ModernTheme.primaryGradient)
                .frame(width: 32, height: 32)
            
            Image(systemName: "checkmark")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
        }
        .transition(.asymmetric(
            insertion: .scale(scale: 0.1).combined(with: .opacity),
            removal: .scale(scale: 1.5).combined(with: .opacity)
        ))
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
