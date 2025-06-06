import Foundation

struct ConfigurationManager {
    
    // MARK: - Voice Settings
    static let availableVoices = ["nova", "shimmer", "echo", "alloy", "fable"]
    static let defaultVoice = "nova"
    static let defaultVoiceInstructions = "Speak in a warm, natural, and conversational style with an emphasis on sustainable and eco-conscious fashion choices."
    
    // MARK: - API Settings
    static let maxImageSize: CGFloat = 256
    static let imageQuality: CGFloat = 0.6
    static let maxTokens = 500
    static let temperature: Float = 0.7
    
    // MARK: - Fashion Analysis Prompt (JSON Response)
    static func fashionAnalysisPrompt(for occasion: String) -> String {
        return """
        You are an expert fashion stylist analyzing an outfit for a specific occasion.
        
        Occasion: \(occasion)
        
        Analyze the outfit in the image and provide a detailed response in JSON format.
        
        You MUST return a valid JSON object with this EXACT structure (no markdown, just JSON):
        {
          "overallComment": "A warm, friendly paragraph (100-150 words) about how well the outfit suits the occasion. Be specific about what works and what could be improved.",
          "currentItems": [
            {
              "category": "top",
              "description": "Navy blue blazer with gold buttons",
              "colorAnalysis": "Deep navy provides sophistication",
              "styleNotes": "Classic cut works well for business settings"
            }
          ],
          "suggestions": [
            {
              "item": "White leather sneakers",
              "reason": "Would add a modern touch while maintaining comfort for the occasion",
              "searchQuery": "white leather sneakers women"
            },
            {
              "item": "Gold hoop earrings",
              "reason": "Would complement the gold buttons and add elegance",
              "searchQuery": "gold hoop earrings medium"
            },
            {
              "item": "Brown leather crossbody bag",
              "reason": "Practical and stylish for hands-free convenience",
              "searchQuery": "brown leather crossbody bag"
            }
          ]
        }
        
        Requirements:
        - List ALL visible clothing items in currentItems array
        - Category must be one of: top/bottom/dress/shoes/outerwear/accessory/bag/jewelry/hat/sunglasses
        - Provide EXACTLY 3 suggestions
        - Each suggestion must have: item (specific name), reason (why it helps for \(occasion)), searchQuery (3-5 words)
        - Make search queries specific and Google-friendly
        - Return ONLY valid JSON, no additional text or markdown
        """
    }
    
    // MARK: - Fashion Prompt (Original - for backward compatibility)
    static let fashionPrompt = """
    You are a top-tier fashion stylist with a focus on sustainable and eco-conscious style, speaking to a client who just sent you a photo of their outfit.

    • First, open with one warm compliment about the overall look (max 1 short sentence).
    • Then analyse the outfit in 3–4 sentences:
        – Mention the key garments, colours, fit, and style vibe you observe.
        – Highlight what works well from a fashion perspective (proportions, colour harmony, texture, trend alignment, etc.).
        – When relevant, appreciate sustainable choices like timeless pieces, quality materials, or versatile styling.
    • Offer 2 concise, constructive suggestions your client could try next time (e.g. accessory swap, layering idea, colour pop, sustainable alternatives).
    • End with an encouraging sign-off that reinforces their personal style journey.

    Tone: upbeat, friendly, naturally warm, and confidence-boosting—never judgmental.
    Do **NOT** guess personal attributes (age, gender, ethnicity, body shape) or comment on the person's body; focus only on the clothing and styling choices visible in the image.
    Target length: 120–180 words. No bullet lists or headings—write as a smooth conversational paragraph.
    """
    
    // MARK: - App Settings
    static let enableHaptics = true
    static let autoPlayAudio = false
    static let saveHistory = true
    static let maxHistoryItems = 20  // Increased for sustainable wardrobe tracking
    static let appTagline = "Sustainable Style, Naturally Beautiful"
    static let appDescription = "Your eco-conscious fashion companion"
    
    // MARK: - Model Settings
    static let visionModel = "gpt-4o-mini"
    static let ttsModel = "gpt-4o-mini-tts"
    static let ttsSpeed: Float = 1.0
    static let outputFormat = "mp3"
}
