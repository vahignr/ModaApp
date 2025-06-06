//
//  SecretsManager.swift
//  ModaApp
//
//  Created by Vahi Guner on 6/3/25.
//
//  A tiny helper that loads values from Secrets.plist at runtime.
//  The file must be included in the main bundle (target membership checked)
//  but should be excluded from version control via .gitignore.
//

import Foundation

/// Central access point for compile-time secrets (e.g., API keys).
enum SecretsManager {

    /// Reads the OpenAI key from **Secrets.plist**.
    static var openAIKey: String {
        guard
            let url = Bundle.main.url(forResource: "Secrets", withExtension: "plist"),
            let dict = NSDictionary(contentsOf: url),
            let key = dict["OPENAI_API_KEY"] as? String,
            !key.isEmpty
        else {
            fatalError("""
                ❌ OPENAI_API_KEY is missing.
                • Ensure Secrets.plist exists in the app target.
                • Add a string entry OPENAI_API_KEY = <your key>.
                """)
        }
        return key
    }
}
