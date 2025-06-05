//
//  ImageCaptureViewModel.swift
//  ModaApp
//
//  Created by Vahi Guner on 6/3/25.
//
//  Holds all mutable state for the “select photo → caption → TTS” workflow.
//  UI views observe this object for updates.
//

import SwiftUI
import UIKit

@MainActor
final class ImageCaptureViewModel: ObservableObject {
    
    // MARK: - Public, UI-observable state ------------------------------------
    
    @Published var selectedImage: UIImage?       // the photo user picked
    @Published var isBusy: Bool        = false   // true while calling the API
    @Published var caption: String     = ""      // GPT-4o Vision output
    @Published var audioURL: URL?                // local MP3 file path
    @Published var error: String?                // non-nil on failure
    
    /// Separate helper that actually plays the MP3.
    let audio = AudioPlayerManager()
    
    
    // MARK: - Primary workflow ------------------------------------------------
    
    /// Calls Vision + TTS in sequence.  UI should disable buttons while busy.
    func generate(voice: String = "nova",
                  instructions: String = "Speak in a warm, conversational style.") {
        guard let image = selectedImage else { return }
        
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
        audio.pause()
    }
}
