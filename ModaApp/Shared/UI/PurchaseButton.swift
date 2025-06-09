//
//  PurchaseButton.swift
//  ModaApp
//
//  Reusable purchase button component
//

import SwiftUI

struct PurchaseButton: View {
    let title: String
    let subtitle: String?
    let price: String
    let isLoading: Bool
    let action: () -> Void
    
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
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(ModernTheme.Typography.headline)
                        .foregroundColor(.white)
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(ModernTheme.Typography.caption)
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                
                Spacer()
                
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text(price)
                        .font(ModernTheme.Typography.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal, ModernTheme.Spacing.lg)
            .padding(.vertical, ModernTheme.Spacing.md)
            .background(ModernTheme.primaryGradient)
            .cornerRadius(ModernTheme.CornerRadius.large)
            .shadow(
                color: ModernTheme.primary.opacity(0.3),
                radius: 12,
                x: 0,
                y: 6
            )
        }
        .disabled(isLoading)
    }
}

// MARK: - Compact Purchase Button
struct CompactPurchaseButton: View {
    let creditsNeeded: Int
    let action: () -> Void
    @EnvironmentObject var localizationManager: LocalizationManager
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: ModernTheme.Spacing.sm) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 20))
                
                Text(localized(.buyCredits))
                    .font(ModernTheme.Typography.body)
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .padding(.horizontal, ModernTheme.Spacing.lg)
            .padding(.vertical, ModernTheme.Spacing.sm)
            .background(ModernTheme.primaryGradient)
            .cornerRadius(ModernTheme.CornerRadius.full)
            .shadow(
                color: ModernTheme.primary.opacity(0.3),
                radius: 8,
                x: 0,
                y: 4
            )
        }
    }
}

#Preview {
    VStack(spacing: ModernTheme.Spacing.lg) {
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
    }
    .padding()
    .background(ModernTheme.background)
}
