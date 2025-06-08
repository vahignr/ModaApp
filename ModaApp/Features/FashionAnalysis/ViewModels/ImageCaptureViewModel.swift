//
//  ImageCaptureViewModel.swift
//  ModaApp
//
//  Created by Vahi Guner on 6/3/25.
//  Updated to include fashion analysis and occasion selection
//

import SwiftUI
import UIKit

@MainActor
final class ImageCaptureViewModel: ObservableObject {
    
    // MARK: - Public, UI-observable state ------------------------------------
    
    // Image selection
    @Published var selectedImage: UIImage?       // the photo user picked
    
    // Occasion selection
    @Published var selectedOccasion: Occasion?   // selected occasion
    @Published var customOccasion: String = ""   // custom occasion text
    
    // Processing state
    enum ProcessingState {
        case idle
        case analyzing
        case searchingImages
        case complete
    }
    @Published var processingState: ProcessingState = .idle
    
    // Results
    @Published var fashionAnalysis: FashionAnalysis? // structured analysis result
    @Published var audioURL: URL?                // local MP3 file path
    
    // UI states
    @Published var error: String?                // non-nil on failure
    @Published var showPurchaseView: Bool = false // show purchase view when no credits
    
    // Computed properties for backwards compatibility
    var isBusy: Bool { processingState == .analyzing }
    var isSearchingImages: Bool { processingState == .searchingImages }
    var showResults: Bool { processingState == .complete && fashionAnalysis != nil }
    var caption: String { fashionAnalysis?.overallComment ?? "" }
    
    /// Separate helper that actually plays the MP3.
    let audio = AudioPlayerManager()
    
    /// Credits manager
    private let creditsManager = CreditsManager.shared
    
    // MARK: - Computed Properties ---------------------------------------------
    
    var hasCredits: Bool {
        creditsManager.hasCredits
    }
    
    var remainingCredits: Int {
        creditsManager.remainingCredits
    }
    
    var occasionText: String {
        if let occasion = selectedOccasion {
            if occasion.name == "Custom" && !customOccasion.isEmpty {
                return customOccasion
            } else {
                // Get localized occasion name
                let localizationManager = LocalizationManager.shared
                let localizedName = localizationManager.string(for: occasion.localizationKey)
                return localizedName
            }
        }
        return ""
    }
    
    var canAnalyze: Bool {
        selectedImage != nil && selectedOccasion != nil &&
        (selectedOccasion?.name != "Custom" || !customOccasion.isEmpty)
    }
    
    // MARK: - Primary workflow ------------------------------------------------
    
    /// Enhanced analysis with occasion context
    func analyzeOutfit() {
        guard let image = selectedImage else { return }
        
        // Get the occasion text in English for API (API expects English)
        let occasionForAPI: String
        if let occasion = selectedOccasion {
            if occasion.name == "Custom" && !customOccasion.isEmpty {
                occasionForAPI = customOccasion
            } else {
                // Use English name for API
                occasionForAPI = occasion.name
            }
        } else {
            error = LocalizationManager.shared.string(for: .pleaseSelectOccasion)
            return
        }
        
        guard !occasionForAPI.isEmpty else {
            error = LocalizationManager.shared.string(for: .pleaseSelectOccasion)
            return
        }
        
        // Check credits first
        guard creditsManager.useCredit() else {
            showPurchaseView = true
            error = LocalizationManager.shared.string(for: .noCreditsRemaining)
            return
        }
        
        Task {
            do {
                // Reset states
                processingState = .analyzing
                fashionAnalysis = nil
                audioURL = nil
                error = nil
                
                // 1️⃣ Get fashion analysis
                print("📤 Calling API for fashion analysis...")
                let analysis = try await APIService.analyzeFashion(
                    for: image,
                    occasion: occasionForAPI,
                    language: LocalizationManager.shared.currentLanguage
                )
                
                print("📥 Received analysis:")
                print("   - Overall comment: \(analysis.overallComment.prefix(100))...")
                print("   - Current items: \(analysis.currentItems.count)")
                print("   - Suggestions: \(analysis.suggestions.count)")
                for (index, suggestion) in analysis.suggestions.enumerated() {
                    print("     \(index + 1). \(suggestion.item) - Query: '\(suggestion.searchQuery)'")
                }
                
                fashionAnalysis = analysis
                
                // 2️⃣ Generate TTS for the overall comment
                let localizationManager = LocalizationManager.shared
                let localizedOccasion = occasionText // This is already localized for display
                let voiceInstructions = localizationManager.currentLanguage == .turkish ?
                    "Etkinlik için kıyafet seçimlerini tartışan samimi bir moda danışmanı olarak konuş: \(localizedOccasion)" :
                    "Speak as a friendly fashion advisor discussing outfit choices for \(localizedOccasion)"
                
                let url = try await APIService.textToSpeech(
                    analysis.overallComment,
                    voice: ConfigurationManager.defaultVoice,
                    instructions: voiceInstructions,
                    language: localizationManager.currentLanguage
                )
                audioURL = url
                try audio.load(fileURL: url)
                
                // Show results
                withAnimation {
                    processingState = .complete
                }
                
                // 3️⃣ Search for suggested items sequentially (don't block UI)
                Task {
                    await searchForSuggestions(analysis.suggestions)
                }
                
            } catch {
                // Surface user-friendly error to UI
                if let apiError = error as? APIServiceError {
                    self.error = apiError.errorDescription
                } else {
                    self.error = LocalizationManager.shared.currentLanguage == .turkish ?
                        "Bir hata oluştu. Lütfen tekrar deneyin." :
                        "An error occurred. Please try again."
                }
                
                // Refund the credit on error
                creditsManager.addCredits(1)
                processingState = .idle
            }
        }
    }
    
    // MARK: - Image Search ------------------------------------------------
    
    private func searchForSuggestions(_ suggestions: [FashionSuggestion]) async {
        print("🔎 Starting image search for \(suggestions.count) suggestions")
        processingState = .searchingImages
        
        let currentLanguage = LocalizationManager.shared.currentLanguage
        
        // Update each suggestion with search results sequentially
        for (index, suggestion) in suggestions.enumerated() {
            print("🔍 Searching for suggestion \(index + 1): \(suggestion.item) - Query: '\(suggestion.searchQuery)'")
            
            do {
                let results = try await SerpAPIService.searchImages(
                    query: suggestion.searchQuery,
                    count: ConfigurationManager.maxImagesPerSuggestion,
                    language: currentLanguage
                )
                
                print("✅ Found \(results.count) images for '\(suggestion.item)'")
                
                // Update the specific suggestion with results
                if let currentAnalysis = fashionAnalysis {
                    var updatedSuggestions = currentAnalysis.suggestions
                    updatedSuggestions[index] = FashionSuggestion(
                        item: suggestion.item,
                        reason: suggestion.reason,
                        searchQuery: suggestion.searchQuery,
                        searchResults: results
                    )
                    
                    fashionAnalysis = FashionAnalysis(
                        overallComment: currentAnalysis.overallComment,
                        currentItems: currentAnalysis.currentItems,
                        suggestions: updatedSuggestions
                    )
                    
                    print("✅ Updated fashionAnalysis with new search results")
                }
                
                // Small delay between searches to avoid rate limiting
                if index < suggestions.count - 1 {
                    try await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds
                }
            } catch {
                // Log error but don't show to user (non-critical feature)
                print("❌ Failed to search for \(suggestion.item): \(error)")
                
                // If it's a critical error like invalid API key, we might want to track it
                if let serpError = error as? SerpAPIError {
                    switch serpError {
                    case .invalidAPIKey, .quotaExceeded:
                        // These are critical - maybe set a flag to show warning
                        print("⚠️ Critical SerpAPI error: \(serpError.errorDescription ?? "")")
                    default:
                        break
                    }
                }
            }
        }
        
        processingState = .complete
        print("🔎 Completed all image searches")
    }
    
    // MARK: - Convenience helpers --------------------------------------------
    
    /// Clears everything except the selected photo.
    func resetOutputs() {
        audioURL = nil
        error    = nil
        fashionAnalysis = nil
        processingState = .idle
        audio.pause()
    }
    
    /// Reset everything including image and occasion
    func resetAll() {
        selectedImage = nil
        selectedOccasion = nil
        customOccasion = ""
        resetOutputs()
    }
    
    /// Add debug credits (only in debug mode)
    #if DEBUG
    func addDebugCredits() {
        creditsManager.addDebugCredits(5)
    }
    #endif
}
