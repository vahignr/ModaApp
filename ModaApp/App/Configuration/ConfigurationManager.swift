import Foundation

struct ConfigurationManager {
    
    // MARK: - API Endpoints
    static let openAIBaseURL = "https://api.openai.com"
    static let openAIChatEndpoint = "\(openAIBaseURL)/v1/chat/completions"
    static let openAISpeechEndpoint = "\(openAIBaseURL)/v1/audio/speech"
    static let serpAPIBaseURL = "https://serpapi.com/search.json"
    
    // MARK: - Voice Settings
    static let availableVoices = ["nova", "shimmer", "echo", "alloy", "fable", "sage"]
    static let defaultVoice = "sage"
    
    // Voice by tone persona
    static func voiceForPersona(_ persona: TonePersona) -> String {
        switch persona.name {
        case "Best Friend":
            return "sage"
        case "Fashion Police":
            return "sage"
        case "Style Expert":
            return "sage"
        case "Trendsetter":
            return "sage"
        case "Eco Warrior":
            return "sage"
        default:
            return defaultVoice
        }
    }
    
    // Voice instructions based on tone and language
    static func voiceInstructions(for persona: TonePersona, language: Language) -> String {
        switch (persona.name, language) {
        case ("Best Friend", .english):
            return "Speak as a supportive best friend with warmth and enthusiasm. Be encouraging and use casual, friendly language."
        case ("Best Friend", .turkish):
            return "Destekleyici bir en iyi arkadaş gibi sıcak ve coşkulu konuş. Cesaretlendirici ol ve samimi, arkadaşça bir dil kullan."
            
        case ("Fashion Police", .english):
            return "Speak as a direct fashion critic with sass and confidence. Be honest but not mean, witty and sharp."
        case ("Fashion Police", .turkish):
            return "Doğrudan bir moda eleştirmeni gibi özgüvenli ve keskin konuş. Dürüst ama kırıcı değil, zeki ve sivri dilli ol."
            
        case ("Style Expert", .english):
            return "Speak as a professional fashion consultant with authority and expertise. Be informative and balanced."
        case ("Style Expert", .turkish):
            return "Profesyonel bir moda danışmanı gibi otorite ve uzmanlıkla konuş. Bilgilendirici ve dengeli ol."
            
        case ("Trendsetter", .english):
            return "Speak as a bold fashion influencer with energy and inspiration. Be cutting-edge and motivational."
        case ("Trendsetter", .turkish):
            return "Cesur bir moda etkileyicisi gibi enerjik ve ilham verici konuş. Yenilikçi ve motive edici ol."
            
        case ("Eco Warrior", .english):
            return "Speak as a passionate sustainability advocate with knowledge and care. Focus on eco-conscious choices."
        case ("Eco Warrior", .turkish):
            return "Tutkulu bir sürdürülebilirlik savunucusu gibi bilgili ve özenli konuş. Çevre dostu seçimlere odaklan."
            
        default:
            return "Speak in a warm, natural, and conversational style."
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
    
    // MARK: - Fashion Analysis Prompt with Tone (JSON Response)
    static func fashionAnalysisPrompt(for occasion: String, tone: TonePersona, language: Language) -> String {
        switch language {
        case .english:
            return englishFashionAnalysisPrompt(for: occasion, tone: tone)
        case .turkish:
            return turkishFashionAnalysisPrompt(for: occasion, tone: tone)
        }
    }
    
    private static func toneInstructions(for tone: TonePersona, in language: Language) -> String {
        switch (tone.name, language) {
        case ("Best Friend", .english):
            return "Write as a supportive best friend who wants them to feel amazing. Be warm, enthusiastic, and encouraging. Use casual language and exclamation points! Celebrate their style choices while gently suggesting improvements."
            
        case ("Fashion Police", .english):
            return "Write as a sassy fashion critic who tells it like it is. Be direct, witty, and honest without being mean. Use fashion terminology and clever observations. Point out what works and what definitely doesn't."
            
        case ("Style Expert", .english):
            return "Write as a professional fashion consultant with deep expertise. Be informative, balanced, and sophisticated. Use industry knowledge to explain why certain choices work or don't. Provide educated guidance."
            
        case ("Trendsetter", .english):
            return "Write as a bold fashion influencer who pushes boundaries. Be inspiring, cutting-edge, and confident. Encourage taking risks and trying new trends. Focus on making a statement and standing out."
            
        case ("Eco Warrior", .english):
            return "Write as a passionate sustainability advocate. Focus heavily on eco-friendly materials, ethical brands, and sustainable fashion choices. Praise conscious choices and suggest environmentally responsible alternatives."
            
        case ("Best Friend", .turkish):
            return "Onların harika hissetmesini isteyen destekleyici bir en iyi arkadaş gibi yaz. Sıcak, coşkulu ve cesaretlendirici ol. Günlük dil kullan ve ünlem işaretleri ekle! Stil seçimlerini kutlarken nazikçe iyileştirmeler öner."
            
        case ("Fashion Police", .turkish):
            return "Doğruları söyleyen sivri dilli bir moda eleştirmeni gibi yaz. Doğrudan, esprili ve dürüst ol ama kırıcı olma. Moda terminolojisi ve zekice gözlemler kullan. Neyin işe yaradığını ve kesinlikle yaramadığını belirt."
            
        case ("Style Expert", .turkish):
            return "Derin uzmanlığa sahip profesyonel bir moda danışmanı gibi yaz. Bilgilendirici, dengeli ve sofistike ol. Belirli seçimlerin neden işe yaradığını veya yaramadığını açıklamak için sektör bilgisini kullan."
            
        case ("Trendsetter", .turkish):
            return "Sınırları zorlayan cesur bir moda etkileyicisi gibi yaz. İlham verici, yenilikçi ve özgüvenli ol. Risk almayı ve yeni trendleri denemeyi teşvik et. Dikkat çekmeye ve öne çıkmaya odaklan."
            
        case ("Eco Warrior", .turkish):
            return "Tutkulu bir sürdürülebilirlik savunucusu gibi yaz. Çevre dostu malzemelere, etik markalara ve sürdürülebilir moda seçimlerine yoğun odaklan. Bilinçli seçimleri öv ve çevreye duyarlı alternatifler öner."
            
        default:
            return ""
        }
    }
    
    private static func englishFashionAnalysisPrompt(for occasion: String, tone: TonePersona) -> String {
        return """
        You are an expert fashion stylist analyzing an outfit for a specific occasion.
        
        Persona: \(tone.name) - \(toneInstructions(for: tone, in: .english))
        
        Occasion: \(occasion)
        
        Analyze the outfit in the image and provide a detailed response in JSON format.
        
        You MUST return a valid JSON object with this EXACT structure (no markdown, just JSON):
        {
          "overallComment": "A paragraph (100-150 words) in the tone of \(tone.name) about how well the outfit suits the occasion. Be specific about what works and what could be improved, maintaining the persona throughout.",
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
        - Maintain the \(tone.name) persona consistently in the overallComment
        - List ALL visible clothing items in currentItems array
        - Category must be one of: top/bottom/dress/shoes/outerwear/accessory/bag/jewelry/hat/sunglasses
        - Provide EXACTLY 3 suggestions that align with the persona's values
        - Each suggestion must have: item (specific name), reason (why it helps for \(occasion)), searchQuery (3-5 words)
        - Make search queries specific and Google-friendly
        - Return ONLY valid JSON, no additional text or markdown
        """
    }
    
    private static func turkishFashionAnalysisPrompt(for occasion: String, tone: TonePersona) -> String {
        return """
        Belirli bir etkinlik için kıyafet analiz eden uzman bir moda stilistisiniz.
        
        Kişilik: \(tone.name) - \(toneInstructions(for: tone, in: .turkish))
        
        Etkinlik: \(occasion)
        
        Görseldeki kıyafeti analiz edin ve JSON formatında detaylı bir yanıt verin.
        
        SADECE geçerli JSON objesi döndürmelisiniz (markdown yok, sadece JSON):
        {
          "overallComment": "\(tone.name) tonunda kıyafetin etkinliğe ne kadar uygun olduğu hakkında bir paragraf (100-150 kelime). Neyin işe yaradığı ve nelerin geliştirilebileceği konusunda spesifik olun, kişiliği koruyun.",
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
        - overallComment'te \(tone.name) kişiliğini tutarlı şekilde koruyun
        - currentItems dizisinde görünen TÜM giysi öğelerini listeleyin
        - Kategori şunlardan biri olmalı: top/bottom/dress/shoes/outerwear/accessory/bag/jewelry/hat/sunglasses
        - Kişiliğin değerleriyle uyumlu TAM OLARAK 3 öneri verin
        - Her öneri şunları içermeli: item (spesifik isim), reason (\(occasion) için neden yardımcı olur), searchQuery (3-5 kelime)
        - Arama sorgularını spesifik ve Google dostu yapın
        - SADECE geçerli JSON döndürün, ek metin veya markdown yok
        """
    }
    
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
