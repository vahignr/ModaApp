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
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid search URL"
        case .noResults:
            return "No images found"
        case .apiError(let message):
            return "Search error: \(message)"
        }
    }
}

struct SerpAPIService {
    
    // MARK: - Configuration
    private static let baseURL = "https://serpapi.com/search.json"
    private static let minImageWidth = 200  // Lowered from 400 for more results
    
    // Blocklist of domains to avoid
    private static let blockedDomains = [
        "lookaside.instagram.com",
        "lookaside.fbsbx.com",
        "img.uefa.com"
    ]
    
    // MARK: - Main Search Function
    static func searchImages(query: String, count: Int = 5) async throws -> [SearchResult] {
        print("🔍 SerpAPI: Searching for '\(query)' (count: \(count))")
        
        var allResults: [SearchResult] = []
        var page = 0
        
        // Keep searching until we have enough results
        while allResults.count < count && page < 3 { // Max 3 pages to avoid too many requests
            let pageResults = try await searchPage(query: query, page: page)
            print("📄 SerpAPI: Page \(page) returned \(pageResults.count) results")
            
            // Filter results
            let filteredResults = pageResults.filter { result in
                // Check if domain is blocked
                if let url = URL(string: result.imageUrl),
                   let host = url.host,
                   blockedDomains.contains(where: { host.contains($0) }) {
                    return false
                }
                
                // Check minimum width if available
                if let width = result.width, width < minImageWidth {
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
        }
        
        // Return only the requested count
        let finalResults = Array(allResults.prefix(count))
        print("✅ SerpAPI: Returning \(finalResults.count) results for '\(query)'")
        return finalResults
    }
    
    // MARK: - Search Single Page
    private static func searchPage(query: String, page: Int) async throws -> [SearchResult] {
        // Build URL with parameters
        var components = URLComponents(string: baseURL)
        components?.queryItems = [
            URLQueryItem(name: "engine", value: "google_images"),
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "ijn", value: String(page)),
            URLQueryItem(name: "num", value: "40"),  // Reduced from 100
            URLQueryItem(name: "api_key", value: SecretsManager.serpAPIKey)
        ]
        
        guard let url = components?.url else {
            print("❌ SerpAPI: Invalid URL for query '\(query)'")
            throw SerpAPIError.invalidURL
        }
        
        print("🌐 SerpAPI: Requesting \(url.absoluteString)")
        
        // Make request
        let (data, response) = try await URLSession.shared.data(from: url)
        
        // Check response
        guard let httpResponse = response as? HTTPURLResponse else {
            print("❌ SerpAPI: Invalid response type")
            throw SerpAPIError.apiError("Invalid response")
        }
        
        print("📡 SerpAPI: HTTP Status \(httpResponse.statusCode)")
        
        guard 200..<300 ~= httpResponse.statusCode else {
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
    }
    
    // MARK: - Test Function
    #if DEBUG
    static func testSearch() async {
        do {
            // First check if API key exists
            let apiKey = SecretsManager.serpAPIKey
            print("🔑 SerpAPI Key: \(apiKey.prefix(10))...")
            
            print("🔍 Testing SerpAPI with query: 'leather jacket women'")
            let results = try await searchImages(query: "leather jacket women", count: 3)
            print("✅ Found \(results.count) results:")
            for (index, result) in results.enumerated() {
                print("\(index + 1). \(result.title)")
                print("   URL: \(result.imageUrl)")
                print("   Size: \(result.width ?? 0)x\(result.height ?? 0)")
            }
        } catch {
            print("❌ Search failed: \(error)")
        }
    }
    #endif
}
