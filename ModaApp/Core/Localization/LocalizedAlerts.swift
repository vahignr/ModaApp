//
//  LocalizedAlerts.swift
//  ModaApp
//
//  Reusable alert configurations with localization
//

import SwiftUI

// MARK: - Toast View for Non-Blocking Notifications

struct LocalizedToast: View {
    let message: String
    let type: ToastType
    @Binding var isShowing: Bool
    
    enum ToastType {
        case success
        case error
        case warning
        case info
        
        var icon: String {
            switch self {
            case .success: return "checkmark.circle.fill"
            case .error: return "xmark.circle.fill"
            case .warning: return "exclamationmark.triangle.fill"
            case .info: return "info.circle.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .success: return ModernTheme.success
            case .error: return ModernTheme.error
            case .warning: return ModernTheme.warning
            case .info: return ModernTheme.info
            }
        }
    }
    
    var body: some View {
        HStack(spacing: ModernTheme.Spacing.sm) {
            Image(systemName: type.icon)
                .font(.system(size: 20))
                .foregroundColor(type.color)
            
            Text(message)
                .font(ModernTheme.Typography.body)
                .foregroundColor(ModernTheme.textPrimary)
                .lineLimit(2)
            
            Spacer()
            
            Button {
                withAnimation {
                    isShowing = false
                }
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 14))
                    .foregroundColor(ModernTheme.textSecondary)
            }
        }
        .padding(ModernTheme.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.medium)
                .fill(ModernTheme.surface)
                .shadow(
                    color: ModernTheme.Shadow.medium.color,
                    radius: ModernTheme.Shadow.medium.radius,
                    x: ModernTheme.Shadow.medium.x,
                    y: ModernTheme.Shadow.medium.y
                )
        )
        .padding(.horizontal)
        .transition(.move(edge: .top).combined(with: .opacity))
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation {
                    isShowing = false
                }
            }
        }
    }
}

// MARK: - Toast Modifier

struct ToastModifier: ViewModifier {
    @Binding var isShowing: Bool
    let message: String
    let type: LocalizedToast.ToastType
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            VStack {
                if isShowing {
                    LocalizedToast(
                        message: message,
                        type: type,
                        isShowing: $isShowing
                    )
                    .padding(.top, 50)
                }
                
                Spacer()
            }
        }
    }
}

extension View {
    func toast(
        isShowing: Binding<Bool>,
        message: String,
        type: LocalizedToast.ToastType = .info
    ) -> some View {
        modifier(ToastModifier(
            isShowing: isShowing,
            message: message,
            type: type
        ))
    }
}

// MARK: - Alert Helpers

struct AlertHelper {
    
    static func showNoCreditsAlert(isPresented: Binding<Bool>, onBuyCredits: @escaping () -> Void) -> Alert {
        let localizationManager = LocalizationManager.shared
        return Alert(
            title: Text(localizationManager.string(for: .noCredits)),
            message: Text(localizationManager.string(for: .needCreditsMessage)),
            primaryButton: .default(
                Text(localizationManager.string(for: .buyCredits)),
                action: onBuyCredits
            ),
            secondaryButton: .cancel(
                Text(localizationManager.string(for: .later))
            )
        )
    }
    
    static func showErrorAlert(isPresented: Binding<Bool>, message: String, onRetry: (() -> Void)? = nil) -> Alert {
        let localizationManager = LocalizationManager.shared
        
        // Check if it's a specific error we want to handle differently
        let isAPIKeyError = message.contains("API key") || message.contains("API anahtarı")
        let isQuotaError = message.contains("quota") || message.contains("limit")
        
        let title = isAPIKeyError || isQuotaError ?
            localizationManager.string(for: .warning) :
            localizationManager.string(for: .error)
        
        if let onRetry = onRetry, !isAPIKeyError {
            return Alert(
                title: Text(title),
                message: Text(message),
                primaryButton: .default(
                    Text(localizationManager.string(for: .tryAgain)),
                    action: onRetry
                ),
                secondaryButton: .cancel(
                    Text(localizationManager.string(for: .ok))
                )
            )
        } else {
            return Alert(
                title: Text(title),
                message: Text(message),
                dismissButton: .default(
                    Text(localizationManager.string(for: .ok))
                )
            )
        }
    }
    
    static func showSuccessAlert(isPresented: Binding<Bool>, message: String) -> Alert {
        let localizationManager = LocalizationManager.shared
        return Alert(
            title: Text(localizationManager.string(for: .success)),
            message: Text(message),
            dismissButton: .default(
                Text(localizationManager.string(for: .ok))
            )
        )
    }
}
