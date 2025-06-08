import Foundation

/// Central access point for compile-time secrets (e.g., API keys).
enum SecretsManager {
    
    /// Default/demo keys for when the actual keys are missing
    private static let defaultOpenAIKey = "demo-key-replace-with-actual"
    private static let defaultSerpAPIKey = "demo-key-replace-with-actual"
    
    /// Flag to track if we've shown the warning
    private static var hasShownWarning = false

    /// Reads the OpenAI key from **Secrets.plist**.
    static var openAIKey: String {
        if let key = readKey("OPENAI_API_KEY"), !key.isEmpty {
            return key
        }
        
        showWarningOnce()
        return defaultOpenAIKey
    }
    
    /// Reads the SerpAPI key from **Secrets.plist**.
    static var serpAPIKey: String {
        if let key = readKey("SERP_API_KEY"), !key.isEmpty {
            return key
        }
        
        showWarningOnce()
        return defaultSerpAPIKey
    }
    
    /// Check if we're using demo keys
    static var isUsingDemoKeys: Bool {
        return openAIKey == defaultOpenAIKey || serpAPIKey == defaultSerpAPIKey
    }
    
    // MARK: - Private Helpers
    
    private static func readKey(_ keyName: String) -> String? {
        guard let url = Bundle.main.url(forResource: "Secrets", withExtension: "plist"),
              let dict = NSDictionary(contentsOf: url),
              let key = dict[keyName] as? String else {
            return nil
        }
        return key
    }
    
    private static func showWarningOnce() {
        #if DEBUG
        if !hasShownWarning {
            hasShownWarning = true
            print("""
                ⚠️ WARNING: API keys are missing from Secrets.plist
                • Create Secrets.plist in the app target
                • Add OPENAI_API_KEY and SERP_API_KEY entries
                • The app will run with limited functionality
                """)
        }
        #endif
    }
}
