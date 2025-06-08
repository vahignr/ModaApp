//
//  LocalizationHelpers.swift
//  ModaApp
//
//  Helper functions for locale-aware formatting
//

import Foundation
import SwiftUI

struct LocalizationHelpers {
    
    // MARK: - Number Formatting
    
    /// Format a number according to the current locale
    static func formatNumber(_ number: Int, for language: Language = LocalizationManager.shared.currentLanguage) -> String {
        let formatter = NumberFormatter()
        formatter.locale = language.locale
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }
    
    /// Format currency according to the current locale
    static func formatCurrency(_ amount: Double, for language: Language = LocalizationManager.shared.currentLanguage) -> String {
        let formatter = NumberFormatter()
        formatter.locale = language.locale
        formatter.numberStyle = .currency
        
        // Set currency symbol based on region
        switch language {
        case .turkish:
            formatter.currencyCode = "TRY"
            formatter.currencySymbol = "₺"
        case .english:
            formatter.currencyCode = "USD"
            formatter.currencySymbol = "$"
        }
        
        return formatter.string(from: NSNumber(value: amount)) ?? "\(amount)"
    }
    
    // MARK: - Date Formatting
    
    /// Format a date according to the current locale
    static func formatDate(_ date: Date, style: DateFormatter.Style = .medium, for language: Language = LocalizationManager.shared.currentLanguage) -> String {
        let formatter = DateFormatter()
        formatter.locale = language.locale
        formatter.dateStyle = style
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    /// Format time according to the current locale
    static func formatTime(_ date: Date, style: DateFormatter.Style = .short, for language: Language = LocalizationManager.shared.currentLanguage) -> String {
        let formatter = DateFormatter()
        formatter.locale = language.locale
        formatter.dateStyle = .none
        formatter.timeStyle = style
        return formatter.string(from: date)
    }
    
    // MARK: - Percentage Formatting
    
    /// Format a percentage according to the current locale
    static func formatPercentage(_ value: Double, for language: Language = LocalizationManager.shared.currentLanguage) -> String {
        let formatter = NumberFormatter()
        formatter.locale = language.locale
        formatter.numberStyle = .percent
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 1
        return formatter.string(from: NSNumber(value: value)) ?? "\(value * 100)%"
    }
    
    // MARK: - String Helpers
    
    /// Get the text direction for a language
    static func textDirection(for language: Language) -> NSLocale.LanguageDirection {
        return NSLocale.characterDirection(forLanguage: language.rawValue)
    }
    
    /// Check if language is RTL
    static func isRTL(for language: Language) -> Bool {
        return textDirection(for: language) == .rightToLeft
    }
}

// MARK: - View Extensions for Formatting

extension View {
    /// Format a number using the current locale
    func formatNumber(_ number: Int) -> String {
        LocalizationHelpers.formatNumber(number)
    }
    
    /// Format currency using the current locale
    func formatCurrency(_ amount: Double) -> String {
        LocalizationHelpers.formatCurrency(amount)
    }
    
    /// Format date using the current locale
    func formatDate(_ date: Date, style: DateFormatter.Style = .medium) -> String {
        LocalizationHelpers.formatDate(date, style: style)
    }
}
