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
    
    // MARK: - Fashion Prompt
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
