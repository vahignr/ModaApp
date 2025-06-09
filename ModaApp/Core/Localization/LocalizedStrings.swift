//
//  LocalizedStrings.swift
//  ModaApp
//
//  Contains all localized strings for the app
//

import Foundation

struct LocalizedStrings {
    
    // MARK: - String Definitions
    private static let strings: [Language: [LocalizedStringKey: String]] = [
        
        // MARK: English
        .english: [
            // App General
            .appName: "EcoStyle AI",
            .tagline: "Sustainable Style, Naturally Beautiful",
            .credits: "Credits",
            .madeWithLove: "Made with care for sustainable fashion",
            
            // Home Screen
            .welcomeTo: "Welcome to Your",
            .sustainableStyleJourney: "Sustainable Style Journey",
            .ecoDescription: "Discover eco-conscious fashion that makes you look and feel amazing",
            .getStarted: "Get Started",
            .aiAnalysis: "AI Analysis",
            .aiAnalysisDesc: "Smart outfit recommendations",
            .ecoFriendly: "Eco-Friendly",
            .ecoFriendlyDesc: "Sustainable fashion focus",
            .personalized: "Personalized",
            .personalizedDesc: "Tailored to your style",
            .privateSecure: "Private",
            .privateSecureDesc: "Your data stays secure",
            
            // Moda Analyzer
            .modaAnalyzer: "Moda Analyzer",
            .modaAnalyzerDesc: "Get AI-powered outfit analysis and style recommendations",
            .back: "Back",
            .home: "Home",
            
            // Image Selection
            .uploadYourOutfit: "Upload Your Outfit",
            .takePhotoOrSelect: "Take a photo or select from gallery",
            .selectPhoto: "Select Photo",
            .changePhoto: "Change Photo",
            .continueToOccasion: "Continue to Occasion",
            .selectYourOutfitPhoto: "Select your outfit photo",
            
            // Occasion Selection
            .selectTheOccasion: "Select the Occasion",
            .helpUsStyle: "Help us style you perfectly for your event",
            .describeYourOccasion: "Describe your occasion",
            .occasionPlaceholder: "e.g., Blues concert at outdoor venue",
            .analyzeStyle: "Analyze Style",
            
            // Voice Tone Selection
            .selectVoiceTone: "Choose Your Style Advisor",
            .voiceToneDescription: "Select the personality for your fashion advice",
            
            // Tone Personas
            .toneBestFriend: "Best Friend",
            .toneBestFriendDesc: "Supportive and encouraging",
            .toneFashionPolice: "Fashion Police",
            .toneFashionPoliceDesc: "Direct and honest critique",
            .toneStyleExpert: "Style Expert",
            .toneStyleExpertDesc: "Professional guidance",
            .toneTrendsetter: "Trendsetter",
            .toneTrendsetterDesc: "Bold and inspiring",
            .toneEcoWarrior: "Eco Warrior",
            .toneEcoWarriorDesc: "Sustainability focused",
            
            // Occasions
            .casualDayOut: "Casual Day Out",
            .workOffice: "Work/Office",
            .firstDate: "First Date",
            .graduation: "Graduation",
            .weddingGuest: "Wedding Guest",
            .nightOut: "Night Out",
            .picnic: "Picnic",
            .businessMeeting: "Business Meeting",
            .concert: "Concert",
            .gymWorkout: "Gym/Workout",
            .beachPool: "Beach/Pool",
            .custom: "Custom",
            
            // Occasion Descriptions
            .casualDayOutDesc: "Relaxed everyday style",
            .workOfficeDesc: "Professional business attire",
            .firstDateDesc: "Impressive yet comfortable",
            .graduationDesc: "Formal celebration attire",
            .weddingGuestDesc: "Elegant formal wear",
            .nightOutDesc: "Party and club ready",
            .picnicDesc: "Outdoor casual comfort",
            .businessMeetingDesc: "Executive professional",
            .concertDesc: "Music event style",
            .gymWorkoutDesc: "Athletic and sporty",
            .beachPoolDesc: "Summer water activities",
            .customDesc: "Describe your occasion",
            
            // Analysis Process
            .analyzingYourStyle: "Analyzing your style",
            .aiStylistReviewing: "Our AI stylist is reviewing your outfit",
            .photo: "Photo",
            .occasion: "Occasion",
            .style: "Style",
            .results: "Results",
            
            // Results
            .aiStylistAnalysis: "AI Stylist Analysis",
            .currentOutfit: "Current Outfit",
            .styleSuggestions: "Style Suggestions",
            .noOutfitItemsDetected: "No outfit items detected",
            .noSuggestionsAvailable: "No suggestions available",
            .analyzeNewOutfit: "Analyze New Outfit",
            .category: "Category",
            .color: "Color",
            .styleNotes: "Style Notes",
            .playingAnalysis: "Playing Analysis",
            .listenToAnalysis: "Listen to Analysis",
            .aiStylistVoice: "AI Stylist Voice",
            
            // Credits
            .noCredits: "No Credits",
            .buyCredits: "Buy Credits",
            .later: "Later",
            .needCreditsMessage: "You need credits to analyze outfits. Each analysis costs 1 credit.",
            .buy: "Buy",
            .creditsAdded: "Credits Added!",
            .purchaseFailed: "Purchase Failed",
            .purchaseSuccess: "Purchase Successful",
            .creditsPackage: "Credits Package",
            .oneCredit: "1 Credit",
            .nCredits: "%d Credits",
            
            // Errors
            .error: "Error",
            .ok: "OK",
            .pleaseSelectOccasion: "Please select an occasion",
            .noCreditsRemaining: "No credits remaining. Purchase more to continue.",
            
            // Image Search
            .foundNImages: "Found %d images",
            .noImagesFound: "No images found for this suggestion",
            .searchingImages: "Searching images...",
            .done: "Done",
            
            // Language
            .language: "Language",
            .english: "English",
            .turkish: "Türkçe",
            
            // Common UI
            .loading: "Loading...",
            .cancel: "Cancel",
            .selectSource: "Select Source",
            .photoLibrary: "Photo Library",
            .camera: "Camera",
            .selectFromLibrary: "Select from Library",
            .failed: "Failed",
            .success: "Success",
            .warning: "Warning",
            .info: "Info",
            .tryAgain: "Try Again",
            .close: "Close"
        ],
        
        // MARK: Turkish
        .turkish: [
            // App General
            .appName: "EcoStyle AI",
            .tagline: "Sürdürülebilir Stil, Doğal Güzellik",
            .credits: "Kredi",
            .madeWithLove: "Sürdürülebilir moda için özenle yapıldı",
            
            // Home Screen
            .welcomeTo: "Hoş Geldiniz",
            .sustainableStyleJourney: "Sürdürülebilir Stil Yolculuğunuza",
            .ecoDescription: "Sizi harika gösterip hissettiren çevre dostu modayı keşfedin",
            .getStarted: "Başlayın",
            .aiAnalysis: "AI Analizi",
            .aiAnalysisDesc: "Akıllı kıyafet önerileri",
            .ecoFriendly: "Çevre Dostu",
            .ecoFriendlyDesc: "Sürdürülebilir moda odaklı",
            .personalized: "Kişiselleştirilmiş",
            .personalizedDesc: "Tarzınıza özel",
            .privateSecure: "Gizli",
            .privateSecureDesc: "Verileriniz güvende",
            
            // Moda Analyzer
            .modaAnalyzer: "Moda Analizci",
            .modaAnalyzerDesc: "AI destekli kıyafet analizi ve stil önerileri alın",
            .back: "Geri",
            .home: "Ana Sayfa",
            
            // Image Selection
            .uploadYourOutfit: "Kıyafetinizi Yükleyin",
            .takePhotoOrSelect: "Fotoğraf çekin veya galeriden seçin",
            .selectPhoto: "Fotoğraf Seç",
            .changePhoto: "Fotoğrafı Değiştir",
            .continueToOccasion: "Etkinliğe Devam Et",
            .selectYourOutfitPhoto: "Kıyafet fotoğrafınızı seçin",
            
            // Occasion Selection
            .selectTheOccasion: "Etkinliği Seçin",
            .helpUsStyle: "Etkinliğiniz için size mükemmel stili sunmamıza yardımcı olun",
            .describeYourOccasion: "Etkinliğinizi açıklayın",
            .occasionPlaceholder: "örn., Açık havada blues konseri",
            .analyzeStyle: "Stili Analiz Et",
            
            // Voice Tone Selection
            .selectVoiceTone: "Stil Danışmanınızı Seçin",
            .voiceToneDescription: "Moda tavsiyeleriniz için kişiliği seçin",
            
            // Tone Personas
            .toneBestFriend: "En İyi Arkadaş",
            .toneBestFriendDesc: "Destekleyici ve cesaretlendirici",
            .toneFashionPolice: "Moda Polisi",
            .toneFashionPoliceDesc: "Doğrudan ve dürüst eleştiri",
            .toneStyleExpert: "Stil Uzmanı",
            .toneStyleExpertDesc: "Profesyonel rehberlik",
            .toneTrendsetter: "Trend Belirleyici",
            .toneTrendsetterDesc: "Cesur ve ilham verici",
            .toneEcoWarrior: "Çevre Savaşçısı",
            .toneEcoWarriorDesc: "Sürdürülebilirlik odaklı",
            
            // Occasions
            .casualDayOut: "Günlük Gezinti",
            .workOffice: "İş/Ofis",
            .firstDate: "İlk Buluşma",
            .graduation: "Mezuniyet",
            .weddingGuest: "Düğün Konuğu",
            .nightOut: "Gece Eğlencesi",
            .picnic: "Piknik",
            .businessMeeting: "İş Toplantısı",
            .concert: "Konser",
            .gymWorkout: "Spor/Egzersiz",
            .beachPool: "Plaj/Havuz",
            .custom: "Özel",
            
            // Occasion Descriptions
            .casualDayOutDesc: "Rahat günlük stil",
            .workOfficeDesc: "Profesyonel iş kıyafeti",
            .firstDateDesc: "Etkileyici ama rahat",
            .graduationDesc: "Resmi kutlama kıyafeti",
            .weddingGuestDesc: "Zarif resmi giyim",
            .nightOutDesc: "Parti ve kulüp hazır",
            .picnicDesc: "Açık hava rahat konfor",
            .businessMeetingDesc: "Yönetici profesyonel",
            .concertDesc: "Müzik etkinliği stili",
            .gymWorkoutDesc: "Atletik ve sportif",
            .beachPoolDesc: "Yaz su aktiviteleri",
            .customDesc: "Etkinliğinizi açıklayın",
            
            // Analysis Process
            .analyzingYourStyle: "Stiliniz analiz ediliyor",
            .aiStylistReviewing: "AI stilistimiz kıyafetinizi inceliyor",
            .photo: "Fotoğraf",
            .occasion: "Etkinlik",
            .style: "Stil",
            .results: "Sonuçlar",
            
            // Results
            .aiStylistAnalysis: "AI Stilist Analizi",
            .currentOutfit: "Mevcut Kıyafet",
            .styleSuggestions: "Stil Önerileri",
            .noOutfitItemsDetected: "Kıyafet öğesi tespit edilmedi",
            .noSuggestionsAvailable: "Öneri bulunmuyor",
            .analyzeNewOutfit: "Yeni Kıyafet Analiz Et",
            .category: "Kategori",
            .color: "Renk",
            .styleNotes: "Stil Notları",
            .playingAnalysis: "Analiz Oynatılıyor",
            .listenToAnalysis: "Analizi Dinle",
            .aiStylistVoice: "AI Stilist Sesi",
            
            // Credits
            .noCredits: "Kredi Yok",
            .buyCredits: "Kredi Satın Al",
            .later: "Sonra",
            .needCreditsMessage: "Kıyafetleri analiz etmek için krediye ihtiyacınız var. Her analiz 1 kredi harcar.",
            .buy: "Satın Al",
            .creditsAdded: "Kredi Eklendi!",
            .purchaseFailed: "Satın Alma Başarısız",
            .purchaseSuccess: "Satın Alma Başarılı",
            .creditsPackage: "Kredi Paketi",
            .oneCredit: "1 Kredi",
            .nCredits: "%d Kredi",
            
            // Errors
            .error: "Hata",
            .ok: "Tamam",
            .pleaseSelectOccasion: "Lütfen bir etkinlik seçin",
            .noCreditsRemaining: "Kredi kalmadı. Devam etmek için daha fazla satın alın.",
            
            // Image Search
            .foundNImages: "%d görsel bulundu",
            .noImagesFound: "Bu öneri için görsel bulunamadı",
            .searchingImages: "Görseller aranıyor...",
            .done: "Bitti",
            
            // Language
            .language: "Dil",
            .english: "English",
            .turkish: "Türkçe",
            
            // Common UI
            .loading: "Yükleniyor...",
            .cancel: "İptal",
            .selectSource: "Kaynak Seç",
            .photoLibrary: "Fotoğraf Kütüphanesi",
            .camera: "Kamera",
            .selectFromLibrary: "Kütüphaneden Seç",
            .failed: "Başarısız",
            .success: "Başarılı",
            .warning: "Uyarı",
            .info: "Bilgi",
            .tryAgain: "Tekrar Dene",
            .close: "Kapat"
        ]
    ]
    
    // MARK: - Get String Method
    static func get(_ key: LocalizedStringKey, for language: Language) -> String {
        return strings[language]?[key] ?? strings[.english]?[key] ?? key.rawValue
    }
    
    // MARK: - Formatted String Methods
    static func getFormatted(_ key: LocalizedStringKey, for language: Language, args: CVarArg...) -> String {
        let format = get(key, for: language)
        return String(format: format, arguments: args)
    }
}

// MARK: - Category Translations
extension LocalizedStrings {
    static func categoryName(_ category: String, for language: Language) -> String {
        let categoryTranslations: [Language: [String: String]] = [
            .english: [
                "top": "Top",
                "bottom": "Bottom",
                "dress": "Dress",
                "shoes": "Shoes",
                "accessory": "Accessory",
                "bag": "Bag",
                "outerwear": "Outerwear",
                "jewelry": "Jewelry",
                "hat": "Hat",
                "sunglasses": "Sunglasses"
            ],
            .turkish: [
                "top": "Üst",
                "bottom": "Alt",
                "dress": "Elbise",
                "shoes": "Ayakkabı",
                "accessory": "Aksesuar",
                "bag": "Çanta",
                "outerwear": "Dış Giyim",
                "jewelry": "Takı",
                "hat": "Şapka",
                "sunglasses": "Güneş Gözlüğü"
            ]
        ]
        
        return categoryTranslations[language]?[category.lowercased()] ??
               categoryTranslations[.english]?[category.lowercased()] ??
               category.capitalized
    }
}

// MARK: - Credits Formatting
extension LocalizedStrings {
    static func formatCredits(_ count: Int, for language: Language) -> String {
        if count == 1 {
            return get(.oneCredit, for: language)
        } else {
            return getFormatted(.nCredits, for: language, args: count)
        }
    }
}
