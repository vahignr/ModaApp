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

// MARK: - Preview
#Preview {
    NavigationStack {
        Text("Sample View")
            .navigationTitle("App Title")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    LanguageButton()
                        .environmentObject(LocalizationManager.shared)
                }
            }
    }
}
