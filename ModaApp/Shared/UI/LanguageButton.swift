//
//  LanguageButton.swift
//  ModaApp
//
//  Reusable language switcher button component
//

import SwiftUI

struct LanguageButton: View {
    @EnvironmentObject var localizationManager: LocalizationManager
    @State private var showLanguageSheet = false
    
    var body: some View {
        Button {
            showLanguageSheet = true
        } label: {
            ZStack {
                Circle()
                    .fill(ModernTheme.primary)
                    .shadow(
                        color: ModernTheme.primary.opacity(0.3),
                        radius: 8,
                        x: 0,
                        y: 4
                    )
                
                Image(systemName: "globe")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(.white)
            }
            .frame(width: 56, height: 56)
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
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: ModernTheme.Spacing.xs) {
                    Image(systemName: "globe")
                        .font(.system(size: 40))
                        .foregroundColor(ModernTheme.primary)
                        .padding(.top, ModernTheme.Spacing.xl)
                    
                    Text(localized(.language))
                        .font(ModernTheme.Typography.title2)
                        .foregroundColor(ModernTheme.textPrimary)
                        .padding(.bottom, ModernTheme.Spacing.lg)
                }
                
                // Language Options
                VStack(spacing: ModernTheme.Spacing.md) {
                    ForEach(Language.allCases, id: \.self) { language in
                        LanguageOptionRow(
                            language: language,
                            isSelected: language == localizationManager.currentLanguage,
                            action: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                    localizationManager.switchLanguage(to: language)
                                    // Small delay to show the selection animation
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                        isPresented = false
                                    }
                                }
                            }
                        )
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .background(ModernTheme.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        isPresented = false
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(ModernTheme.textTertiary)
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
                // Flag or Language Icon
                ZStack {
                    Circle()
                        .fill(isSelected ? ModernTheme.primary.opacity(0.2) : ModernTheme.lightSage)
                        .frame(width: 50, height: 50)
                    
                    Text(language == .english ? "EN" : "TR")
                        .font(ModernTheme.Typography.headline)
                        .fontWeight(.bold)
                        .foregroundColor(isSelected ? ModernTheme.primary : ModernTheme.textSecondary)
                }
                
                // Language Name
                VStack(alignment: .leading, spacing: 4) {
                    Text(language.displayName)
                        .font(ModernTheme.Typography.headline)
                        .foregroundColor(ModernTheme.textPrimary)
                    
                    Text(language == .english ? "English Language" : "Türk Dili")
                        .font(ModernTheme.Typography.caption)
                        .foregroundColor(ModernTheme.textSecondary)
                }
                
                Spacer()
                
                // Checkmark
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(ModernTheme.primary)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(ModernTheme.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.large)
                    .fill(isSelected ? ModernTheme.primary.opacity(0.1) : ModernTheme.surface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.large)
                    .stroke(isSelected ? ModernTheme.primary : Color.clear, lineWidth: 2)
            )
            .shadow(
                color: isSelected ? ModernTheme.primary.opacity(0.1) : ModernTheme.Shadow.small.color,
                radius: isSelected ? 8 : ModernTheme.Shadow.small.radius,
                x: 0,
                y: isSelected ? 4 : ModernTheme.Shadow.small.y
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
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

// MARK: - Alternative Compact Menu (if you prefer a smaller presentation)
struct LanguageCompactMenu: View {
    @EnvironmentObject var localizationManager: LocalizationManager
    @State private var showMenu = false
    
    var body: some View {
        VStack(alignment: .trailing, spacing: ModernTheme.Spacing.sm) {
            // Language Options (shown when menu is expanded)
            if showMenu {
                VStack(alignment: .trailing, spacing: ModernTheme.Spacing.xs) {
                    ForEach(Language.allCases, id: \.self) { language in
                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                localizationManager.switchLanguage(to: language)
                                showMenu = false
                            }
                        } label: {
                            HStack(spacing: ModernTheme.Spacing.sm) {
                                Text(language.displayName)
                                    .font(ModernTheme.Typography.body)
                                    .fontWeight(language == localizationManager.currentLanguage ? .semibold : .regular)
                                
                                if language == localizationManager.currentLanguage {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 14, weight: .bold))
                                }
                            }
                            .foregroundColor(ModernTheme.textPrimary)
                            .padding(.horizontal, ModernTheme.Spacing.md)
                            .padding(.vertical, ModernTheme.Spacing.sm)
                            .background(
                                Capsule()
                                    .fill(language == localizationManager.currentLanguage ?
                                         ModernTheme.primary.opacity(0.2) : ModernTheme.surface)
                                    .shadow(
                                        color: ModernTheme.Shadow.small.color,
                                        radius: ModernTheme.Shadow.small.radius,
                                        x: ModernTheme.Shadow.small.x,
                                        y: ModernTheme.Shadow.small.y
                                    )
                            )
                        }
                        .transition(.asymmetric(
                            insertion: .scale(scale: 0.8, anchor: .bottomTrailing).combined(with: .opacity),
                            removal: .scale(scale: 0.8, anchor: .bottomTrailing).combined(with: .opacity)
                        ))
                    }
                }
            }
            
            // Main Globe Button
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    showMenu.toggle()
                }
            } label: {
                ZStack {
                    Circle()
                        .fill(ModernTheme.primary)
                        .shadow(
                            color: ModernTheme.primary.opacity(0.3),
                            radius: 8,
                            x: 0,
                            y: 4
                        )
                    
                    Image(systemName: showMenu ? "xmark" : "globe")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(.white)
                        .rotationEffect(.degrees(showMenu ? 90 : 0))
                }
                .frame(width: 56, height: 56)
            }
        }
        .onTapGesture {
            // Dismiss menu when tapping outside
            if showMenu {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    showMenu = false
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        ModernTheme.background
            .ignoresSafeArea()
        
        VStack {
            Spacer()
            
            Text("Sheet Style")
                .font(ModernTheme.Typography.caption)
                .foregroundColor(ModernTheme.textTertiary)
            
            LanguageButton()
            
            Spacer()
                .frame(height: 100)
            
            Text("Compact Menu Style")
                .font(ModernTheme.Typography.caption)
                .foregroundColor(ModernTheme.textTertiary)
            
            HStack {
                Spacer()
                LanguageCompactMenu()
                    .padding()
            }
        }
    }
    .environmentObject(LocalizationManager.shared)
}
