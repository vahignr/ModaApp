//
//  SerpAPIService.swift
//  ModaApp
//
//  Service for searching fashion item images using SerpAPI
//

import Foundation

enum SerpAPIError: Error, LocalizedError {
    case invalidURL
    case noResults
    case apiError(String)
    case invalidAPIKey
    case quotaExceeded
    case networkError(String)
    
    var errorDescription: String? {
        let language = LocalizationManager.shared.currentLanguage
        switch self {
        case .invalidURL:
            return language == .turkish ?
                "Geçersiz arama URL'si" :
                "Invalid search URL"
        case .noResults:
            return language == .turkish ?
                "Görsel bulunamadı" :
                "No images found"
        case .apiError(let message):
            return language == .turkish ?
                "Arama hatası: \(message)" :
                "Search error: \(message)"
        case .invalidAPIKey:
            return language == .turkish ?
                "Geçersiz API anahtarı" :
                "Invalid API key"
        case .quotaExceeded:
            return language == .turkish ?
                "Arama limiti aşıldı" :
                "Search quota exceeded"
        case .networkError(let message):
            return language == .turkish ?
                "Ağ hatası: \(message)" :
                "Network error: \(message)"
        }
    }
}

struct SerpAPIService {
    
    // MARK: - Main Search Function
    static func searchImages(query: String, count: Int = 5, language: Language = LocalizationManager.shared.currentLanguage) async throws -> [SearchResult] {
        // Check for demo keys
        if SecretsManager.isUsingDemoKeys {
            print("⚠️ SerpAPI: Using demo key, returning empty results")
            return []
        }
        
        print("🔍 SerpAPI: Searching for '\(query)' (count: \(count), language: \(language.rawValue))")
        
        var allResults: [SearchResult] = []
        var page = 0
        
        // Keep searching until we have enough results
        while allResults.count < count && page < ConfigurationManager.maxSearchPages {
            do {
                let pageResults = try await searchPage(query: query, page: page, language: language)
                print("📄 SerpAPI: Page \(page) returned \(pageResults.count) results")
                
                // Filter results
                let filteredResults = pageResults.filter { result in
                    // Check if domain is blocked
                    if let url = URL(string: result.imageUrl),
                       let host = url.host,
                       ConfigurationManager.blockedImageDomains.contains(where: { host.contains($0) }) {
                        return false
                    }
                    
                    // Check minimum width if available
                    if let width = result.width, width < ConfigurationManager.minImageWidth {
                        return false
                    }
                    
                    return true
                }
                
                print("✅ SerpAPI: After filtering, \(filteredResults.count) results remain")
                allResults.append(contentsOf: filteredResults)
                
                // If no results on first page, throw error
                if page == 0 && pageResults.isEmpty {
                    print("❌ SerpAPI: No results found for query '\(query)'")
                    throw SerpAPIError.noResults
                }
                
                page += 1
            } catch {
                // If it's the first page and we get an error, throw it
                if page == 0 {
                    throw error
                }
                // Otherwise, just break the loop and return what we have
                break
            }
        }
        
        // Return only the requested count
        let finalResults = Array(allResults.prefix(count))
        print("✅ SerpAPI: Returning \(finalResults.count) results for '\(query)'")
        return finalResults
    }
    
    // MARK: - Search Single Page
    private static func searchPage(query: String, page: Int, language: Language = .english) async throws -> [SearchResult] {
        // Build URL with parameters
        var components = URLComponents(string: ConfigurationManager.serpAPIBaseURL)
        components?.queryItems = [
            URLQueryItem(name: "engine", value: "google_images"),
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "ijn", value: String(page)),
            URLQueryItem(name: "num", value: String(ConfigurationManager.imagesPerPage)),
            URLQueryItem(name: "hl", value: language == .turkish ? "tr" : "en"),
            URLQueryItem(name: "gl", value: language == .turkish ? "tr" : "us"),
            URLQueryItem(name: "api_key", value: SecretsManager.serpAPIKey)
        ]
        
        guard let url = components?.url else {
            print("❌ SerpAPI: Invalid URL for query '\(query)'")
            throw SerpAPIError.invalidURL
        }
        
        print("🌐 SerpAPI: Requesting \(url.absoluteString)")
        
        do {
            // Make request
            let (data, response) = try await URLSession.shared.data(from: url)
            
            // Check response
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ SerpAPI: Invalid response type")
                throw SerpAPIError.networkError("Invalid response type")
            }
            
            print("📡 SerpAPI: HTTP Status \(httpResponse.statusCode)")
            
            // Handle specific error codes
            switch httpResponse.statusCode {
            case 200..<300:
                break // Success
            case 401:
                throw SerpAPIError.invalidAPIKey
            case 429:
                throw SerpAPIError.quotaExceeded
            default:
                let errorBody = String(data: data, encoding: .utf8) ?? "No error body"
                print("❌ SerpAPI: HTTP Error \(httpResponse.statusCode): \(errorBody)")
                throw SerpAPIError.apiError("HTTP \(httpResponse.statusCode)")
            }
            
            // Parse JSON
            guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                print("❌ SerpAPI: Failed to parse JSON response")
                return []
            }
            
            // Check for error in response
            if let error = json["error"] as? String {
                print("❌ SerpAPI: API Error: \(error)")
                if error.contains("Invalid API key") {
                    throw SerpAPIError.invalidAPIKey
                }
                throw SerpAPIError.apiError(error)
            }
            
            guard let imagesResults = json["images_results"] as? [[String: Any]] else {
                print("⚠️ SerpAPI: No 'images_results' in response")
                return []
            }
            
            print("📸 SerpAPI: Found \(imagesResults.count) raw results")
            
            // Convert to SearchResult objects
            let results = imagesResults.compactMap { imageData -> SearchResult? in
                guard let originalUrl = imageData["original"] as? String,
                      let title = imageData["title"] as? String else {
                    return nil
                }
                
                return SearchResult(
                    imageUrl: originalUrl,
                    thumbnailUrl: imageData["thumbnail"] as? String,
                    title: title,
                    source: imageData["source"] as? String ?? "",
                    link: imageData["link"] as? String,
                    width: imageData["original_width"] as? Int,
                    height: imageData["original_height"] as? Int
                )
            }
            
            print("✅ SerpAPI: Converted to \(results.count) SearchResult objects")
            return results
            
        } catch {
            if error is SerpAPIError {
                throw error
            }
            throw SerpAPIError.networkError(error.localizedDescription)
        }
    }
    
    // MARK: - Test Function
    #if DEBUG
    static func testSearch() async {
        do {
            // First check if API key exists
            let apiKey = SecretsManager.serpAPIKey
            print("🔑 SerpAPI Key: \(apiKey.prefix(10))...")
            
            if SecretsManager.isUsingDemoKeys {
                print("⚠️ Using demo keys - search will return empty results")
            }
            
            // Test English search
            print("🔍 Testing SerpAPI with English query: 'leather jacket women'")
            let englishResults = try await searchImages(query: "leather jacket women", count: 3, language: .english)
            print("✅ Found \(englishResults.count) English results:")
            for (index, result) in englishResults.enumerated() {
                print("\(index + 1). \(result.title)")
                print("   URL: \(result.imageUrl)")
                print("   Size: \(result.width ?? 0)x\(result.height ?? 0)")
            }
            
            // Test Turkish search
            print("\n🔍 Testing SerpAPI with Turkish query: 'deri ceket kadın'")
            let turkishResults = try await searchImages(query: "deri ceket kadın", count: 3, language: .turkish)
            print("✅ Found \(turkishResults.count) Turkish results:")
            for (index, result) in turkishResults.enumerated() {
                print("\(index + 1). \(result.title)")
                print("   URL: \(result.imageUrl)")
                print("   Size: \(result.width ?? 0)x\(result.height ?? 0)")
            }
        } catch {
            print("❌ Search failed: \(error.localizedDescription)")
        }
    }
    #endif
}
