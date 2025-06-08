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
    
    // Processing states
    @Published var isBusy: Bool = false          // true while calling the API
    @Published var isSearchingImages = false     // true while searching images
    
    // Results
    @Published var fashionAnalysis: FashionAnalysis? // structured analysis result
    @Published var caption: String = ""          // Legacy: simple text output
    @Published var audioURL: URL?                // local MP3 file path
    
    // UI states
    @Published var error: String?                // non-nil on failure
    @Published var showPurchaseView: Bool = false // show purchase view when no credits
    @Published var showResults: Bool = false     // show results view
    
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
                isBusy = true
                fashionAnalysis = nil
                caption = ""
                audioURL = nil
                error = nil
                showResults = false
                
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
                
                // Set caption for backward compatibility
                caption = analysis.overallComment
                
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
                    showResults = true
                    isBusy = false
                }
                
                // 3️⃣ Search for suggested items (don't block UI)
                await searchForSuggestions(analysis.suggestions)
                
            } catch {
                // Surface any error to UI
                self.error = error.localizedDescription
                
                // Refund the credit on error
                creditsManager.addCredits(1)
                isBusy = false
            }
        }
    }
    
    // MARK: - Image Search ------------------------------------------------
    
    private func searchForSuggestions(_ suggestions: [FashionSuggestion]) async {
        print("🔎 Starting image search for \(suggestions.count) suggestions")
        isSearchingImages = true
        
        let currentLanguage = LocalizationManager.shared.currentLanguage
        
        // Update each suggestion with search results
        for (index, suggestion) in suggestions.enumerated() {
            print("🔍 Searching for suggestion \(index + 1): \(suggestion.item) - Query: '\(suggestion.searchQuery)'")
            
            do {
                let results = try await SerpAPIService.searchImages(
                    query: suggestion.searchQuery,
                    count: 5,
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
            } catch {
                print("❌ Failed to search for \(suggestion.item): \(error)")
            }
        }
        
        isSearchingImages = false
        print("🔎 Completed all image searches")
    }
    
    // MARK: - Legacy support for simple caption generation --------------------
    
    /// Original simple caption generation (kept for backward compatibility)
    func generate(voice: String? = nil, instructions: String? = nil) {
        guard let image = selectedImage else { return }
        
        // Check credits first
        guard creditsManager.useCredit() else {
            showPurchaseView = true
            error = LocalizationManager.shared.string(for: .noCreditsRemaining)
            return
        }
        
        Task {
            do {
                // Reset & show spinner
                isBusy   = true
                caption  = ""
                audioURL = nil
                error    = nil
                
                // 1️⃣  Vision
                let text = try await APIService.generateCaption(for: image)
                caption = text   // update UI immediately
                
                // 2️⃣  TTS
                let url = try await APIService.textToSpeech(
                    text,
                    voice: voice,
                    instructions: instructions
                )
                audioURL = url
                try audio.load(fileURL: url)
                
            } catch {
                // Surface any error to UI
                self.error = error.localizedDescription
                
                // Refund the credit on error
                creditsManager.addCredits(1)
            }
            isBusy = false
        }
    }
    
    // MARK: - Convenience helpers --------------------------------------------
    
    /// Clears everything except the selected photo.
    func resetOutputs() {
        caption  = ""
        audioURL = nil
        error    = nil
        fashionAnalysis = nil
        showResults = false
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
