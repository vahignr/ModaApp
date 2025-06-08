//
//  LanguageButton.swift
//  ModaApp
//
//  Reusable language switcher button component
//

import SwiftUI

struct LanguageButton: View {
    @EnvironmentObject var localizationManager: LocalizationManager
    @State private var isPressed = false
    
    var body: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                localizationManager.toggleLanguage()
            }
        } label: {
            HStack(spacing: ModernTheme.Spacing.xs) {
                Image(systemName: "globe")
                    .font(.system(size: 16, weight: .medium))
                
                Text(localizationManager.currentLanguage.displayName)
                    .font(ModernTheme.Typography.caption)
                    .fontWeight(.medium)
            }
            .foregroundColor(ModernTheme.primary)
            .padding(.horizontal, ModernTheme.Spacing.sm)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(ModernTheme.primary.opacity(0.1))
            )
            .overlay(
                Capsule()
                    .stroke(ModernTheme.primary.opacity(0.2), lineWidth: 1)
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
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

// MARK: - Compact Language Toggle
struct CompactLanguageToggle: View {
    @EnvironmentObject var localizationManager: LocalizationManager
    
    var body: some View {
        Button {
            localizationManager.toggleLanguage()
        } label: {
            Text(localizationManager.currentLanguage == .english ? "TR" : "EN")
                .font(ModernTheme.Typography.caption)
                .fontWeight(.bold)
                .foregroundColor(ModernTheme.primary)
                .frame(width: 32, height: 32)
                .background(
                    Circle()
                        .fill(ModernTheme.lightSage)
                )
                .overlay(
                    Circle()
                        .stroke(ModernTheme.primary.opacity(0.3), lineWidth: 1)
                )
        }
    }
}

// MARK: - Language Menu
struct LanguageMenu: View {
    @EnvironmentObject var localizationManager: LocalizationManager
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text(localized(.language))
                    .font(ModernTheme.Typography.headline)
                    .foregroundColor(ModernTheme.textPrimary)
                
                Spacer()
                
                Button {
                    withAnimation {
                        isPresented = false
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(ModernTheme.textSecondary)
                }
            }
            .padding()
            
            Divider()
                .background(ModernTheme.lightSage)
            
            // Language Options
            VStack(spacing: ModernTheme.Spacing.xs) {
                ForEach(Language.allCases, id: \.self) { language in
                    LanguageRow(
                        language: language,
                        isSelected: localizationManager.currentLanguage == language,
                        action: {
                            localizationManager.switchLanguage(to: language)
                            withAnimation {
                                isPresented = false
                            }
                        }
                    )
                }
            }
            .padding()
        }
        .background(ModernTheme.surface)
        .cornerRadius(ModernTheme.CornerRadius.large)
        .shadow(
            color: ModernTheme.Shadow.large.color,
            radius: ModernTheme.Shadow.large.radius,
            x: ModernTheme.Shadow.large.x,
            y: ModernTheme.Shadow.large.y
        )
        .frame(maxWidth: 300)
    }
}

// MARK: - Language Row
struct LanguageRow: View {
    let language: Language
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(language.displayName)
                        .font(ModernTheme.Typography.body)
                        .fontWeight(isSelected ? .semibold : .regular)
                        .foregroundColor(isSelected ? ModernTheme.primary : ModernTheme.textPrimary)
                    
                    Text(language == .english ? "English" : "Turkish")
                        .font(ModernTheme.Typography.caption)
                        .foregroundColor(ModernTheme.textSecondary)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(ModernTheme.primary)
                }
            }
            .padding(ModernTheme.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.medium)
                    .fill(isSelected ? ModernTheme.primary.opacity(0.1) : Color.clear)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 40) {
        // Regular Button
        LanguageButton()
            .environmentObject(LocalizationManager.shared)
        
        // Compact Toggle
        CompactLanguageToggle()
            .environmentObject(LocalizationManager.shared)
        
        // Language Menu
        LanguageMenu(isPresented: .constant(true))
            .environmentObject(LocalizationManager.shared)
            .padding()
    }
    .padding()
    .background(ModernTheme.background)
}
