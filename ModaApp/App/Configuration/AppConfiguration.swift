//
//  AppConfiguration.swift
//  ModaApp
//
//  Helper to check app configuration status
//

import Foundation

struct AppConfiguration {
    
    /// Check if the app is properly configured with API keys
    static var isProperlyConfigured: Bool {
        return !SecretsManager.isUsingDemoKeys
    }
    
    /// Get a user-friendly message about configuration status
    static func configurationMessage(for language: Language) -> String? {
        guard !isProperlyConfigured else { return nil }
        
        switch language {
        case .english:
            return "The app is running in demo mode. Some features may be limited. Please configure your API keys in Settings."
        case .turkish:
            return "Uygulama demo modunda çalışıyor. Bazı özellikler sınırlı olabilir. Lütfen API anahtarlarınızı Ayarlar'da yapılandırın."
        }
    }
    
    /// Check if a specific feature is available
    static func isFeatureAvailable(_ feature: Feature) -> Bool {
        switch feature {
        case .fashionAnalysis:
            return !SecretsManager.isUsingDemoKeys || isDemoModeAllowed
        case .imageSearch:
            return !SecretsManager.isUsingDemoKeys
        case .textToSpeech:
            return !SecretsManager.isUsingDemoKeys || isDemoModeAllowed
        }
    }
    
    /// Allow some features in demo mode for testing
    private static var isDemoModeAllowed: Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }
    
    enum Feature {
        case fashionAnalysis
        case imageSearch
        case textToSpeech
    }
}
