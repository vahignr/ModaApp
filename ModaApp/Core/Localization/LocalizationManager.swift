//
//  LocalizationManager.swift
//  ModaApp
//
//  Manages app localization and language switching
//

import Foundation
import SwiftUI

// MARK: - Language Enum
enum Language: String, CaseIterable {
    case english = "en"
    case turkish = "tr"
    
    var displayName: String {
        switch self {
        case .english:
            return "English"
        case .turkish:
            return "Türkçe"
        }
    }
    
    var locale: Locale {
        switch self {
        case .english:
            return Locale(identifier: "en_US")
        case .turkish:
            return Locale(identifier: "tr_TR")
        }
    }
}

// MARK: - Localization Manager
final class LocalizationManager: ObservableObject {
    static let shared = LocalizationManager()
    
    @Published var currentLanguage: Language {
        didSet {
            saveLanguagePreference()
        }
    }
    
    private let languageKey = "selectedLanguage"
    
    private init() {
        // Load saved language or default to English
        if let savedLanguage = UserDefaults.standard.string(forKey: languageKey),
           let language = Language(rawValue: savedLanguage) {
            self.currentLanguage = language
        } else {
            // Try to detect system language
            let systemLanguage = Locale.current.language.languageCode?.identifier ?? "en"
            self.currentLanguage = systemLanguage.hasPrefix("tr") ? .turkish : .english
            saveLanguagePreference()
        }
    }
    
    // MARK: - Public Methods
    
    /// Get localized string for a given key
    func string(for key: LocalizedStringKey) -> String {
        return LocalizedStrings.get(key, for: currentLanguage)
    }
    
    /// Switch to a different language
    func switchLanguage(to language: Language) {
        withAnimation(.easeInOut(duration: 0.3)) {
            currentLanguage = language
        }
    }
    
    /// Toggle between available languages
    func toggleLanguage() {
        let languages = Language.allCases
        if let currentIndex = languages.firstIndex(of: currentLanguage) {
            let nextIndex = (currentIndex + 1) % languages.count
            switchLanguage(to: languages[nextIndex])
        }
    }
    
    // MARK: - Private Methods
    
    private func saveLanguagePreference() {
        UserDefaults.standard.set(currentLanguage.rawValue, forKey: languageKey)
        UserDefaults.standard.synchronize()
    }
}

// MARK: - Localized String Key
enum LocalizedStringKey: String, CaseIterable {
    // App General
    case appName = "app_name"
    case tagline = "tagline"
    case credits = "credits"
    case madeWithLove = "made_with_love"
    
    // Home Screen
    case welcomeTo = "welcome_to"
    case sustainableStyleJourney = "sustainable_style_journey"
    case ecoDescription = "eco_description"
    case getStarted = "get_started"
    case aiAnalysis = "ai_analysis"
    case aiAnalysisDesc = "ai_analysis_desc"
    case ecoFriendly = "eco_friendly"
    case ecoFriendlyDesc = "eco_friendly_desc"
    case personalized = "personalized"
    case personalizedDesc = "personalized_desc"
    case privateSecure = "private"
    case privateSecureDesc = "private_desc"
    
    // Moda Analyzer
    case modaAnalyzer = "moda_analyzer"
    case modaAnalyzerDesc = "moda_analyzer_desc"
    case back = "back"
    case home = "home"
    
    // Image Selection
    case uploadYourOutfit = "upload_your_outfit"
    case takePhotoOrSelect = "take_photo_or_select"
    case selectPhoto = "select_photo"
    case changePhoto = "change_photo"
    case continueToOccasion = "continue_to_occasion"
    case selectYourOutfitPhoto = "select_your_outfit_photo"
    
    // Occasion Selection
    case selectTheOccasion = "select_the_occasion"
    case helpUsStyle = "help_us_style"
    case describeYourOccasion = "describe_your_occasion"
    case occasionPlaceholder = "occasion_placeholder"
    case analyzeStyle = "analyze_style"
    
    // Occasions
    case casualDayOut = "casual_day_out"
    case workOffice = "work_office"
    case firstDate = "first_date"
    case graduation = "graduation"
    case weddingGuest = "wedding_guest"
    case nightOut = "night_out"
    case picnic = "picnic"
    case businessMeeting = "business_meeting"
    case concert = "concert"
    case gymWorkout = "gym_workout"
    case beachPool = "beach_pool"
    case custom = "custom"
    
    // Occasion Descriptions
    case casualDayOutDesc = "casual_day_out_desc"
    case workOfficeDesc = "work_office_desc"
    case firstDateDesc = "first_date_desc"
    case graduationDesc = "graduation_desc"
    case weddingGuestDesc = "wedding_guest_desc"
    case nightOutDesc = "night_out_desc"
    case picnicDesc = "picnic_desc"
    case businessMeetingDesc = "business_meeting_desc"
    case concertDesc = "concert_desc"
    case gymWorkoutDesc = "gym_workout_desc"
    case beachPoolDesc = "beach_pool_desc"
    case customDesc = "custom_desc"
    
    // Analysis Process
    case analyzingYourStyle = "analyzing_your_style"
    case aiStylistReviewing = "ai_stylist_reviewing"
    case photo = "photo"
    case occasion = "occasion"
    case style = "style"
    case results = "results"
    
    // Results
    case aiStylistAnalysis = "ai_stylist_analysis"
    case currentOutfit = "current_outfit"
    case styleSuggestions = "style_suggestions"
    case noOutfitItemsDetected = "no_outfit_items_detected"
    case noSuggestionsAvailable = "no_suggestions_available"
    case analyzeNewOutfit = "analyze_new_outfit"
    case category = "category"
    case color = "color"
    case styleNotes = "style_notes"
    case playingAnalysis = "playing_analysis"
    case listenToAnalysis = "listen_to_analysis"
    case aiStylistVoice = "ai_stylist_voice"
    
    // Credits
    case noCredits = "no_credits"
    case buyCredits = "buy_credits"
    case later = "later"
    case needCreditsMessage = "need_credits_message"
    case buy = "buy"
    case creditsAdded = "credits_added"
    case purchaseFailed = "purchase_failed"
    case purchaseSuccess = "purchase_success"
    case creditsPackage = "credits_package"
    case oneCredit = "one_credit"
    case nCredits = "n_credits"
    
    // Errors
    case error = "error"
    case ok = "ok"
    case pleaseSelectOccasion = "please_select_occasion"
    case noCreditsRemaining = "no_credits_remaining"
    
    // Image Search
    case foundNImages = "found_n_images"
    case noImagesFound = "no_images_found"
    case searchingImages = "searching_images"
    case done = "done"
    
    // Language
    case language = "language"
    case english = "english"
    case turkish = "turkish"
    
    // Common UI
    case loading = "loading"
    case cancel = "cancel"
    case selectSource = "select_source"
    case photoLibrary = "photo_library"
    case camera = "camera"
    case selectFromLibrary = "select_from_library"
    case failed = "failed"
    case success = "success"
    case warning = "warning"
    case info = "info"
    case tryAgain = "try_again"
    case close = "close"
}

// MARK: - View Extension for Easy Access
extension View {
    /// Get localized string using the shared LocalizationManager
    func localized(_ key: LocalizedStringKey) -> String {
        LocalizationManager.shared.string(for: key)
    }
}
