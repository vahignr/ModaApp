//
//  StoreKitProducts.swift
//  ModaApp
//
//  Product definitions for In-App Purchases
//

import Foundation
import StoreKit

// MARK: - Product Identifiers
enum StoreKitProducts {
    static let productIDPrefix = "com.vahiguner.ModaApp"
    
    enum Credits: String, CaseIterable {
        case credits5 = "credits_5"
        case credits10 = "credits_10"
        case credits25 = "credits_25"
        case credits50 = "credits_50"
        
        var productID: String {
            "\(productIDPrefix).\(rawValue)"
        }
        
        var creditAmount: Int {
            switch self {
            case .credits5: return 5
            case .credits10: return 10
            case .credits25: return 25
            case .credits50: return 50
            }
        }
        
        // Suggested pricing (you'll set actual prices in App Store Connect)
        var displayPrice: String {
            switch self {
            case .credits5: return "$0.99"
            case .credits10: return "$1.99"
            case .credits25: return "$4.99"
            case .credits50: return "$9.99"
            }
        }
        
        var isPopular: Bool {
            self == .credits10
        }
        
        var isBestValue: Bool {
            self == .credits50
        }
        
        func localizedName(for language: Language) -> String {
            switch language {
            case .english:
                return "\(creditAmount) Credits"
            case .turkish:
                return "\(creditAmount) Kredi"
            }
        }
        
        func localizedDescription(for language: Language) -> String {
            switch language {
            case .english:
                switch self {
                case .credits5:
                    return "Analyze 5 outfits"
                case .credits10:
                    return "Most popular choice"
                case .credits25:
                    return "Great for regular users"
                case .credits50:
                    return "Best value - Save 20%"
                }
            case .turkish:
                switch self {
                case .credits5:
                    return "5 kıyafet analizi"
                case .credits10:
                    return "En popüler seçim"
                case .credits25:
                    return "Düzenli kullanıcılar için"
                case .credits50:
                    return "En iyi değer - %20 tasarruf"
                }
            }
        }
    }
    
    // All product IDs for fetching from StoreKit
    static var allProductIDs: Set<String> {
        Set(Credits.allCases.map { $0.productID })
    }
}

// MARK: - Purchase Result
enum PurchaseResult {
    case success(credits: Int)
    case pending
    case cancelled
    case failed(error: Error)
    case restored(totalCredits: Int)
}

// MARK: - StoreKit Error
enum StoreKitError: LocalizedError {
    case productNotFound
    case purchaseFailed
    case restoreFailed
    case networkError
    case invalidReceipt
    case unknown
    
    var errorDescription: String? {
        let language = LocalizationManager.shared.currentLanguage
        switch self {
        case .productNotFound:
            return language == .turkish ?
                "Ürün bulunamadı. Lütfen daha sonra tekrar deneyin." :
                "Product not found. Please try again later."
        case .purchaseFailed:
            return language == .turkish ?
                "Satın alma başarısız. Lütfen tekrar deneyin." :
                "Purchase failed. Please try again."
        case .restoreFailed:
            return language == .turkish ?
                "Satın almaları geri yükleme başarısız." :
                "Failed to restore purchases."
        case .networkError:
            return language == .turkish ?
                "Ağ bağlantısı hatası. İnternet bağlantınızı kontrol edin." :
                "Network connection error. Please check your internet."
        case .invalidReceipt:
            return language == .turkish ?
                "Geçersiz satın alma fişi." :
                "Invalid purchase receipt."
        case .unknown:
            return language == .turkish ?
                "Bilinmeyen bir hata oluştu." :
                "An unknown error occurred."
        }
    }
}
