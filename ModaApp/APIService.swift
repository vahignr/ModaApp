//
//  APIService.swift
//  ModaApp
//
//  Updated 6 Jun 2025
//  • Vision call now uses a dedicated “fashion-stylist” prompt.
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
    
    // MARK: Static prompt -----------------------------------------------------
    
    /// One-shot system prompt for fashion feedback.
    private static let fashionPrompt = """
    You are a top-tier fashion stylist speaking to a client who just sent you a photo of their outfit.

    • First, open with one warm compliment about the overall look (max 1 short sentence).
    • Then analyse the outfit in 3–4 sentences:
        – Mention the key garments, colours, fit, and style vibe you observe.
        – Highlight what works well from a fashion perspective (proportions, colour harmony, texture, trend alignment, etc.).
    • Offer 2 concise, constructive suggestions your client could try next time (e.g. accessory swap, layering idea, colour pop).
    • End with an encouraging sign-off that reinforces their personal style journey.

    Tone: upbeat, friendly, and confidence-boosting—never judgmental.
    Do **NOT** guess personal attributes (age, gender, ethnicity, body shape) or comment on the person’s body; focus only on the clothing and styling choices visible in the image.
    Target length: 120–180 words. No bullet lists or headings—write as a smooth conversational paragraph.
    """

    // MARK: Vision ------------------------------------------------------------
    
    /// Sends the outfit photo to GPT-4o Vision and returns the stylist comment.
    static func generateCaption(for image: UIImage) async throws -> String {
        let base64 = try await resizeAndEncode(image,
                                               maxEdge: 256,
                                               quality: 0.6)
        
        // Messages in official multi-modal array-of-parts format
        let messages: [[String: Any]] = [
            [
                "role": "system",
                "content": fashionPrompt
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
            "model": "gpt-4o-mini",
            "messages": messages,
            "max_tokens": 500,
            "temperature": 0.7
        ]
        
        let data = try await postJSON(
            to: "https://api.openai.com/v1/chat/completions",
            payload: body
        )
        return try parseChatResponse(data)
    }

    // MARK: TTS ---------------------------------------------------------------
    
    static func textToSpeech(_ text: String,
                             voice: String = "nova",
                             instructions: String = "Speak in a warm, conversational style.") async throws -> URL {
        let body: [String: Any] = [
            "model": "gpt-4o-mini-tts",
            "voice": voice,
            "input": text,
            "instructions": instructions,
            "speed": 1.0,
            "output_format": "mp3"
        ]

        let data = try await postJSON(
            to: "https://api.openai.com/v1/audio/speech",
            payload: body
        )

        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("tts-\(UUID().uuidString).mp3")
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
