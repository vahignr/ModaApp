import Foundation

struct ConfigurationManager {
    
    // MARK: - API Endpoints
    static let openAIBaseURL = "https://api.openai.com"
    static let openAIChatEndpoint = "\(openAIBaseURL)/v1/chat/completions"
    static let openAISpeechEndpoint = "\(openAIBaseURL)/v1/audio/speech"
    static let serpAPIBaseURL = "https://serpapi.com/search.json"
    
    // MARK: - Voice Settings
    static let availableVoices = ["nova", "shimmer", "echo", "alloy", "fable"]
    static let defaultVoice = "nova"
    
    // Voice instructions based on language
    static func voiceInstructions(for language: Language) -> String {
        switch language {
        case .english:
            return "Speak in a warm, natural, and conversational style with an emphasis on sustainable and eco-conscious fashion choices."
        case .turkish:
            return "Samimi, doğal ve konuşma tarzında konuş. Sürdürülebilir ve çevre dostu moda seçimlerine vurgu yap."
        }
    }
    
    // MARK: - API Settings
    static let maxImageSize: CGFloat = 256
    static let imageQuality: CGFloat = 0.6
    static let maxTokens = 500
    static let maxAnalysisTokens = 1500
    static let temperature: Float = 0.7
    static let analysisTemperature: Float = 0.3
    
    // MARK: - Image Search Settings
    static let minImageWidth = 200
    static let maxSearchPages = 3
    static let imagesPerPage = 40
    static let maxImagesPerSuggestion = 5
    
    // Blocklist of domains to avoid
    static let blockedImageDomains = [
        "lookaside.instagram.com",
        "lookaside.fbsbx.com",
        "img.uefa.com"
    ]
    
    // MARK: - Credits Configuration
    static let initialFreeCredits = 3
    static let creditCostPerAnalysis = 1
    
    // MARK: - UI Configuration
    static let stepIndicatorSize: CGFloat = 32
    static let animationDuration: Double = 0.3
    static let loadingAnimationDuration: Double = 2.0
    static let toastDisplayDuration: Double = 3.0
    
    // MARK: - Fashion Analysis Prompt (JSON Response)
    static func fashionAnalysisPrompt(for occasion: String, language: Language) -> String {
        switch language {
        case .english:
            return englishFashionAnalysisPrompt(for: occasion)
        case .turkish:
            return turkishFashionAnalysisPrompt(for: occasion)
        }
    }
    
    private static func englishFashionAnalysisPrompt(for occasion: String) -> String {
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
    
    private static func turkishFashionAnalysisPrompt(for occasion: String) -> String {
        return """
        Belirli bir etkinlik için kıyafet analiz eden uzman bir moda stilistisiniz.
        
        Etkinlik: \(occasion)
        
        Görseldeki kıyafeti analiz edin ve JSON formatında detaylı bir yanıt verin.
        
        SADECE geçerli JSON objesi döndürmelisiniz (markdown yok, sadece JSON):
        {
          "overallComment": "Kıyafetin etkinliğe ne kadar uygun olduğu hakkında sıcak, samimi bir paragraf (100-150 kelime). Neyin işe yaradığı ve nelerin geliştirilebileceği konusunda spesifik olun.",
          "currentItems": [
            {
              "category": "top",
              "description": "Altın düğmeli lacivert blazer ceket",
              "colorAnalysis": "Derin lacivert sofistike bir hava katıyor",
              "styleNotes": "Klasik kesim iş ortamları için çok uygun"
            }
          ],
          "suggestions": [
            {
              "item": "Beyaz deri spor ayakkabı",
              "reason": "Etkinlik için rahat kalırken modern bir dokunuş katacaktır",
              "searchQuery": "beyaz deri spor ayakkabı kadın"
            },
            {
              "item": "Altın halka küpe",
              "reason": "Altın düğmeleri tamamlayacak ve zarafet katacaktır",
              "searchQuery": "altın halka küpe orta boy"
            },
            {
              "item": "Kahverengi deri çapraz çanta",
              "reason": "Eller serbest rahatlık için pratik ve şık",
              "searchQuery": "kahverengi deri çapraz çanta"
            }
          ]
        }
        
        Gereksinimler:
        - currentItems dizisinde görünen TÜM giysi öğelerini listeleyin
        - Kategori şunlardan biri olmalı: top/bottom/dress/shoes/outerwear/accessory/bag/jewelry/hat/sunglasses
        - TAM OLARAK 3 öneri verin
        - Her öneri şunları içermeli: item (spesifik isim), reason (\(occasion) için neden yardımcı olur), searchQuery (3-5 kelime)
        - Arama sorgularını spesifik ve Google dostu yapın
        - SADECE geçerli JSON döndürün, ek metin veya markdown yok
        """
    }
    
    // MARK: - Fashion Prompt (Original - for backward compatibility)
    static func fashionPrompt(for language: Language) -> String {
        switch language {
        case .english:
            return englishFashionPrompt
        case .turkish:
            return turkishFashionPrompt
        }
    }
    
    private static let englishFashionPrompt = """
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
    
    private static let turkishFashionPrompt = """
    Sürdürülebilir ve çevre dostu stile odaklanan üst düzey bir moda stilistisiniz, size kıyafet fotoğrafı gönderen bir müşterinizle konuşuyorsunuz.

    • İlk olarak, genel görünüm hakkında sıcak bir iltifatla başlayın (maksimum 1 kısa cümle).
    • Sonra kıyafeti 3-4 cümlede analiz edin:
        – Gördüğünüz ana giysileri, renkleri, uyumu ve stil havasını belirtin.
        – Moda açısından neyin iyi çalıştığını vurgulayın (orantılar, renk uyumu, doku, trend uyumu vb.).
        – İlgili olduğunda, zamansız parçalar, kaliteli malzemeler veya çok yönlü stil gibi sürdürülebilir seçimleri takdir edin.
    • Müşterinizin bir dahaki sefere deneyebileceği 2 özlü, yapıcı öneri sunun (örn. aksesuar değişimi, katmanlama fikri, renk patlaması, sürdürülebilir alternatifler).
    • Kişisel stil yolculuklarını pekiştiren cesaretlendirici bir kapanışla bitirin.

    Ton: neşeli, samimi, doğal sıcak ve güven artırıcı—asla yargılayıcı değil.
    Kişisel özellikleri (yaş, cinsiyet, etnik köken, vücut şekli) tahmin ETMEYİN veya kişinin vücudu hakkında yorum yapmayın; sadece görselde görünen giyim ve stil seçimlerine odaklanın.
    Hedef uzunluk: 120-180 kelime. Madde işaretleri veya başlık yok—akıcı konuşma paragrafı olarak yazın.
    """
    
    // MARK: - App Settings
    static let enableHaptics = true
    static let autoPlayAudio = false
    static let saveHistory = true
    static let maxHistoryItems = 20
    
    // Dynamic app tagline and description based on language
    static func appTagline(for language: Language) -> String {
        LocalizedStrings.get(.tagline, for: language)
    }
    
    static func appDescription(for language: Language) -> String {
        switch language {
        case .english:
            return "Your eco-conscious fashion companion"
        case .turkish:
            return "Çevre dostu moda arkadaşınız"
        }
    }
    
    // MARK: - Model Settings
    static let visionModel = "gpt-4o-mini"
    static let ttsModel = "gpt-4o-mini-tts"
    static let ttsSpeed: Float = 1.0
    static let outputFormat = "mp3"
}
