//
//  APIService.swift
//  ModaApp
//
//  Updated to use ConfigurationManager and include Fashion Analysis
//

import Foundation
import UIKit

// MARK: - Domain errors -------------------------------------------------------

enum APIServiceError: Error, LocalizedError {
    case imageEncodingFailed
    case unexpectedResponse
    case http(status: Int, body: String)

    var errorDescription: String? {
        switch self {
        case .imageEncodingFailed:
            return "Failed to encode image data."
        case .unexpectedResponse:
            return "Unexpected response format from the server."
        case .http(let status, let body):
            return "HTTP \(status): \(body)"
        }
    }
}

// MARK: - Service -------------------------------------------------------------

struct APIService {
    
    // MARK: - Fashion Analysis (JSON Response) --------------------------------
    
    /// Analyzes outfit for a specific occasion and returns structured data
    static func analyzeFashion(for image: UIImage, occasion: String) async throws -> FashionAnalysis {
        let base64 = try await resizeAndEncode(image,
                                               maxEdge: ConfigurationManager.maxImageSize,
                                               quality: ConfigurationManager.imageQuality)
        
        // Messages for fashion analysis
        let messages: [[String: Any]] = [
            [
                "role": "system",
                "content": ConfigurationManager.fashionAnalysisPrompt(for: occasion)
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
            "max_tokens": 1500,  // More tokens for detailed JSON
            "temperature": 0.3   // Lower temperature for consistent JSON
        ]
        
        let data = try await postJSON(
            to: "https://api.openai.com/v1/chat/completions",
            payload: body
        )
        
        // Parse JSON response
        let jsonString = try parseChatResponse(data)
        
        print("🔍 API Response JSON:")
        print(jsonString.prefix(500))
        
        // Convert to FashionAnalysis object
        guard let jsonData = jsonString.data(using: .utf8) else {
            print("❌ Failed to convert string to data")
            throw APIServiceError.unexpectedResponse
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
            throw APIServiceError.unexpectedResponse
        }
    }
    
    // MARK: - Vision (Original) -----------------------------------------------
    
    /// Sends the outfit photo to GPT-4o Vision and returns the stylist comment.
    static func generateCaption(for image: UIImage) async throws -> String {
        let base64 = try await resizeAndEncode(image,
                                               maxEdge: ConfigurationManager.maxImageSize,
                                               quality: ConfigurationManager.imageQuality)
        
        // Messages in official multi-modal array-of-parts format
        let messages: [[String: Any]] = [
            [
                "role": "system",
                "content": ConfigurationManager.fashionPrompt
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
            to: "https://api.openai.com/v1/chat/completions",
            payload: body
        )
        return try parseChatResponse(data)
    }

    // MARK: TTS ---------------------------------------------------------------
    
    static func textToSpeech(_ text: String,
                             voice: String? = nil,
                             instructions: String? = nil) async throws -> URL {
        let body: [String: Any] = [
            "model": ConfigurationManager.ttsModel,
            "voice": voice ?? ConfigurationManager.defaultVoice,
            "input": text,
            "instructions": instructions ?? ConfigurationManager.defaultVoiceInstructions,
            "speed": ConfigurationManager.ttsSpeed,
            "output_format": ConfigurationManager.outputFormat
        ]

        let data = try await postJSON(
            to: "https://api.openai.com/v1/audio/speech",
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

        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse, 200..<300 ~= http.statusCode else {
            let body = String(data: data, encoding: .utf8) ?? "-"
            throw APIServiceError.http(
                status: (resp as? HTTPURLResponse)?.statusCode ?? -1,
                body: body
            )
        }
        return data
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
