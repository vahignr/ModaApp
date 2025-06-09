//
//  APIService.swift
//  ModaApp
//
//  Updated to use ConfigurationManager and include Fashion Analysis with Tone
//

import Foundation
import UIKit

// MARK: - Domain errors -------------------------------------------------------

enum APIServiceError: Error, LocalizedError {
    case imageEncodingFailed
    case unexpectedResponse
    case http(status: Int, body: String)
    case invalidAPIKey
    case networkError(String)
    case jsonParsingError(String)
    case quotaExceeded

    var errorDescription: String? {
        switch self {
        case .imageEncodingFailed:
            return LocalizationManager.shared.currentLanguage == .turkish ?
                "Görüntü kodlaması başarısız oldu." :
                "Failed to encode image data."
        case .unexpectedResponse:
            return LocalizationManager.shared.currentLanguage == .turkish ?
                "Sunucudan beklenmeyen yanıt formatı." :
                "Unexpected response format from the server."
        case .http(let status, _):
            return LocalizationManager.shared.currentLanguage == .turkish ?
                "Sunucu hatası (kod: \(status))" :
                "Server error (code: \(status))"
        case .invalidAPIKey:
            return LocalizationManager.shared.currentLanguage == .turkish ?
                "API anahtarı geçersiz. Lütfen ayarları kontrol edin." :
                "Invalid API key. Please check your settings."
        case .networkError(let message):
            return LocalizationManager.shared.currentLanguage == .turkish ?
                "Ağ hatası: \(message)" :
                "Network error: \(message)"
        case .jsonParsingError:
            return LocalizationManager.shared.currentLanguage == .turkish ?
                "Veri işleme hatası." :
                "Failed to process response data."
        case .quotaExceeded:
            return LocalizationManager.shared.currentLanguage == .turkish ?
                "API kullanım limiti aşıldı. Lütfen daha sonra tekrar deneyin." :
                "API quota exceeded. Please try again later."
        }
    }
}

// MARK: - Service -------------------------------------------------------------

struct APIService {
    
    // MARK: - Fashion Analysis with Tone (JSON Response) --------------------------------
    
    /// Analyzes outfit for a specific occasion with a specific tone and returns structured data
    static func analyzeFashion(for image: UIImage, occasion: String, tone: TonePersona? = nil, language: Language = LocalizationManager.shared.currentLanguage) async throws -> FashionAnalysis {
        // Check for demo keys
        if SecretsManager.isUsingDemoKeys {
            throw APIServiceError.invalidAPIKey
        }
        
        let base64 = try await resizeAndEncode(image,
                                               maxEdge: ConfigurationManager.maxImageSize,
                                               quality: ConfigurationManager.imageQuality)
        
        // Use provided tone or default to Style Expert
        let selectedTone = tone ?? TonePersona.personas[2]
        
        // Messages for fashion analysis with tone
        let messages: [[String: Any]] = [
            [
                "role": "system",
                "content": ConfigurationManager.fashionAnalysisPrompt(for: occasion, tone: selectedTone, language: language)
            ],
            [
                "role": "user",
                "content": [
                    [
                        "type": "image_url",
                        "image_url": [
                            "url": "data:image/jpeg;base64,\(base64)",
                            "detail": "high"  // Use high detail for better analysis
                        ]
                    ]
                ]
            ]
        ]
        
        let body: [String: Any] = [
            "model": ConfigurationManager.visionModel,
            "messages": messages,
            "max_tokens": ConfigurationManager.maxAnalysisTokens,
            "temperature": ConfigurationManager.analysisTemperature
        ]
        
        let data = try await postJSON(
            to: ConfigurationManager.openAIChatEndpoint,
            payload: body
        )
        
        // Parse JSON response
        let jsonString = try parseChatResponse(data)
        
        print("🔍 API Response JSON:")
        print(jsonString.prefix(500))
        
        // Convert to FashionAnalysis object
        guard let jsonData = jsonString.data(using: .utf8) else {
            print("❌ Failed to convert string to data")
            throw APIServiceError.jsonParsingError("Failed to convert response to data")
        }
        
        do {
            let analysis = try JSONDecoder().decode(FashionAnalysis.self, from: jsonData)
            print("✅ Successfully decoded FashionAnalysis")
            return analysis
        } catch {
            print("❌ JSON Parsing Error: \(error)")
            if let decodingError = error as? DecodingError {
                switch decodingError {
                case .dataCorrupted(let context):
                    print("   Data corrupted: \(context)")
                case .keyNotFound(let key, let context):
                    print("   Key not found: \(key.stringValue) - \(context.debugDescription)")
                case .typeMismatch(let type, let context):
                    print("   Type mismatch: \(type) - \(context.debugDescription)")
                case .valueNotFound(let type, let context):
                    print("   Value not found: \(type) - \(context.debugDescription)")
                @unknown default:
                    print("   Unknown decoding error")
                }
            }
            print("📝 Raw JSON: \(jsonString)")
            throw APIServiceError.jsonParsingError("Invalid response format")
        }
    }
    
    // MARK: - Vision (Original) -----------------------------------------------
    
    /// Sends the outfit photo to GPT-4o Vision and returns the stylist comment.
    static func generateCaption(for image: UIImage, language: Language = LocalizationManager.shared.currentLanguage) async throws -> String {
        // Check for demo keys
        if SecretsManager.isUsingDemoKeys {
            throw APIServiceError.invalidAPIKey
        }
        
        let base64 = try await resizeAndEncode(image,
                                               maxEdge: ConfigurationManager.maxImageSize,
                                               quality: ConfigurationManager.imageQuality)
        
        // Messages in official multi-modal array-of-parts format
        let messages: [[String: Any]] = [
            [
                "role": "system",
                "content": ConfigurationManager.fashionPrompt(for: language)
            ],
            [
                "role": "user",
                "content": [
                    [
                        "type": "image_url",
                        "image_url": [
                            "url": "data:image/jpeg;base64,\(base64)",
                            "detail": "low"
                        ]
                    ]
                ]
            ]
        ]
        
        let body: [String: Any] = [
            "model": ConfigurationManager.visionModel,
            "messages": messages,
            "max_tokens": ConfigurationManager.maxTokens,
            "temperature": ConfigurationManager.temperature
        ]
        
        let data = try await postJSON(
            to: ConfigurationManager.openAIChatEndpoint,
            payload: body
        )
        return try parseChatResponse(data)
    }

    // MARK: TTS ---------------------------------------------------------------
    
    static func textToSpeech(_ text: String,
                             voice: String? = nil,
                             instructions: String? = nil,
                             language: Language = LocalizationManager.shared.currentLanguage) async throws -> URL {
        // Check for demo keys
        if SecretsManager.isUsingDemoKeys {
            throw APIServiceError.invalidAPIKey
        }
        
        let body: [String: Any] = [
            "model": ConfigurationManager.ttsModel,
            "voice": voice ?? ConfigurationManager.defaultVoice,
            "input": text,
            "instructions": instructions ?? ConfigurationManager.voiceInstructions(for: language),
            "speed": ConfigurationManager.ttsSpeed,
            "output_format": ConfigurationManager.outputFormat
        ]

        let data = try await postJSON(
            to: ConfigurationManager.openAISpeechEndpoint,
            payload: body
        )

        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("tts-\(UUID().uuidString).\(ConfigurationManager.outputFormat)")
        try data.write(to: url)
        return url
    }

    // MARK: Helpers -----------------------------------------------------------
    
    private static func resizeAndEncode(_ image: UIImage,
                                        maxEdge: CGFloat,
                                        quality: CGFloat) async throws -> String {
        let size   = image.size
        let ratio  = min(maxEdge / max(size.width, size.height), 1)
        let target = CGSize(width: size.width * ratio,
                            height: size.height * ratio)

        return try await MainActor.run {
            let renderer = UIGraphicsImageRenderer(size: target)
            let resized  = renderer.image { _ in
                image.draw(in: CGRect(origin: .zero, size: target))
            }
            guard let jpeg = resized.jpegData(compressionQuality: quality) else {
                throw APIServiceError.imageEncodingFailed
            }
            return jpeg.base64EncodedString()
        }
    }

    private static func postJSON(to urlString: String,
                                 payload: [String: Any]) async throws -> Data {
        let url = URL(string: urlString)!
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("Bearer \(SecretsManager.openAIKey)", forHTTPHeaderField: "Authorization")
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try JSONSerialization.data(withJSONObject: payload)

        do {
            let (data, resp) = try await URLSession.shared.data(for: req)
            
            guard let http = resp as? HTTPURLResponse else {
                throw APIServiceError.networkError("Invalid response type")
            }
            
            // Handle specific error codes
            switch http.statusCode {
            case 200..<300:
                return data
            case 401:
                throw APIServiceError.invalidAPIKey
            case 429:
                throw APIServiceError.quotaExceeded
            default:
                let body = String(data: data, encoding: .utf8) ?? "-"
                throw APIServiceError.http(status: http.statusCode, body: body)
            }
        } catch {
            if error is APIServiceError {
                throw error
            }
            throw APIServiceError.networkError(error.localizedDescription)
        }
    }

    private static func parseChatResponse(_ data: Data) throws -> String {
        guard
            let root    = try JSONSerialization.jsonObject(with: data) as? [String: Any],
            let choices = root["choices"] as? [[String: Any]],
            let first   = choices.first,
            let message = first["message"] as? [String: Any],
            let content = message["content"] as? String
        else {
            throw APIServiceError.unexpectedResponse
        }
        return content.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
