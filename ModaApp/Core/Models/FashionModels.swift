//
//  FashionModels.swift
//  ModaApp
//
//  Fashion analysis models including tone personas
//

import Foundation
import SwiftUI

// MARK: - Tone Persona Model
struct TonePersona: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let icon: String
    let description: String
    let localizationKey: LocalizedStringKey
    let descriptionKey: LocalizedStringKey
    
    static func == (lhs: TonePersona, rhs: TonePersona) -> Bool {
        lhs.id == rhs.id
    }
    
    static let personas = [
        TonePersona(
            name: "Best Friend",
            icon: "heart.fill",
            description: "Supportive and encouraging",
            localizationKey: .toneBestFriend,
            descriptionKey: .toneBestFriendDesc
        ),
        TonePersona(
            name: "Fashion Police",
            icon: "shield.fill",
            description: "Direct and honest critique",
            localizationKey: .toneFashionPolice,
            descriptionKey: .toneFashionPoliceDesc
        ),
        TonePersona(
            name: "Style Expert",
            icon: "star.fill",
            description: "Professional guidance",
            localizationKey: .toneStyleExpert,
            descriptionKey: .toneStyleExpertDesc
        ),
        TonePersona(
            name: "Trendsetter",
            icon: "sparkles",
            description: "Bold and inspiring",
            localizationKey: .toneTrendsetter,
            descriptionKey: .toneTrendsetterDesc
        ),
        TonePersona(
            name: "Eco Warrior",
            icon: "leaf.fill",
            description: "Sustainability focused",
            localizationKey: .toneEcoWarrior,
            descriptionKey: .toneEcoWarriorDesc
        )
    ]
    
    static let defaultPersona = personas.first!
}

// MARK: - Main Fashion Analysis Model
struct FashionAnalysis: Codable {
    let overallComment: String
    let currentItems: [FashionItem]
    let suggestions: [FashionSuggestion]
    
    enum CodingKeys: String, CodingKey {
        case overallComment = "overallComment"
        case currentItems = "currentItems"
        case suggestions = "suggestions"
    }
}

// MARK: - Fashion Item (Current Outfit Items)
struct FashionItem: Codable, Identifiable {
    let id: UUID
    let category: String // "top", "bottom", "shoes", "accessory", "outerwear", "bag", etc.
    let description: String
    let colorAnalysis: String
    let styleNotes: String
    
    enum CodingKeys: String, CodingKey {
        case category
        case description
        case colorAnalysis
        case styleNotes
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = UUID()
        self.category = try container.decode(String.self, forKey: .category)
        self.description = try container.decode(String.self, forKey: .description)
        self.colorAnalysis = try container.decode(String.self, forKey: .colorAnalysis)
        self.styleNotes = try container.decode(String.self, forKey: .styleNotes)
    }
    
    init(category: String, description: String, colorAnalysis: String, styleNotes: String) {
        self.id = UUID()
        self.category = category
        self.description = description
        self.colorAnalysis = colorAnalysis
        self.styleNotes = styleNotes
    }
}

// MARK: - Fashion Suggestion (Recommended Items)
struct FashionSuggestion: Codable, Identifiable {
    let id: UUID
    let item: String
    let reason: String
    let searchQuery: String
    var searchResults: [SearchResult]?
    
    enum CodingKeys: String, CodingKey {
        case item
        case reason
        case searchQuery
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = UUID()
        self.item = try container.decode(String.self, forKey: .item)
        self.reason = try container.decode(String.self, forKey: .reason)
        self.searchQuery = try container.decode(String.self, forKey: .searchQuery)
        self.searchResults = nil
    }
    
    init(item: String, reason: String, searchQuery: String, searchResults: [SearchResult]? = nil) {
        self.id = UUID()
        self.item = item
        self.reason = reason
        self.searchQuery = searchQuery
        self.searchResults = searchResults
    }
}

// MARK: - Search Result (From SerpAPI)
struct SearchResult: Identifiable, Equatable {
    let id = UUID()
    let imageUrl: String
    let thumbnailUrl: String?
    let title: String
    let source: String
    let link: String?
    let width: Int?
    let height: Int?
    
    static func == (lhs: SearchResult, rhs: SearchResult) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Occasion Model
struct Occasion: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let icon: String
    let description: String
    let localizationKey: LocalizedStringKey
    let descriptionKey: LocalizedStringKey
    
    static func == (lhs: Occasion, rhs: Occasion) -> Bool {
        lhs.id == rhs.id
    }
    
    static let presets = [
        Occasion(
            name: "Casual Day Out",
            icon: "sun.max.fill",
            description: "Relaxed everyday style",
            localizationKey: .casualDayOut,
            descriptionKey: .casualDayOutDesc
        ),
        Occasion(
            name: "Work/Office",
            icon: "briefcase.fill",
            description: "Professional business attire",
            localizationKey: .workOffice,
            descriptionKey: .workOfficeDesc
        ),
        Occasion(
            name: "First Date",
            icon: "heart.fill",
            description: "Impressive yet comfortable",
            localizationKey: .firstDate,
            descriptionKey: .firstDateDesc
        ),
        Occasion(
            name: "Graduation",
            icon: "graduationcap.fill",
            description: "Formal celebration attire",
            localizationKey: .graduation,
            descriptionKey: .graduationDesc
        ),
        Occasion(
            name: "Wedding Guest",
            icon: "sparkles",
            description: "Elegant formal wear",
            localizationKey: .weddingGuest,
            descriptionKey: .weddingGuestDesc
        ),
        Occasion(
            name: "Night Out",
            icon: "moon.stars.fill",
            description: "Party and club ready",
            localizationKey: .nightOut,
            descriptionKey: .nightOutDesc
        ),
        Occasion(
            name: "Picnic",
            icon: "leaf.fill",
            description: "Outdoor casual comfort",
            localizationKey: .picnic,
            descriptionKey: .picnicDesc
        ),
        Occasion(
            name: "Business Meeting",
            icon: "person.2.fill",
            description: "Executive professional",
            localizationKey: .businessMeeting,
            descriptionKey: .businessMeetingDesc
        ),
        Occasion(
            name: "Concert",
            icon: "music.note",
            description: "Music event style",
            localizationKey: .concert,
            descriptionKey: .concertDesc
        ),
        Occasion(
            name: "Gym/Workout",
            icon: "figure.run",
            description: "Athletic and sporty",
            localizationKey: .gymWorkout,
            descriptionKey: .gymWorkoutDesc
        ),
        Occasion(
            name: "Beach/Pool",
            icon: "sun.and.horizon.fill",
            description: "Summer water activities",
            localizationKey: .beachPool,
            descriptionKey: .beachPoolDesc
        ),
        Occasion(
            name: "Custom",
            icon: "pencil.circle.fill",
            description: "Describe your occasion",
            localizationKey: .custom,
            descriptionKey: .customDesc
        )
    ]
    
    static let custom = presets.last!
}

// MARK: - Category Helpers
extension FashionItem {
    var categoryIcon: String {
        switch category.lowercased() {
        case "top", "shirt", "blouse", "t-shirt":
            return "tshirt.fill"
        case "bottom", "pants", "jeans", "skirt", "shorts":
            return "figure.dress.line.vertical.figure"
        case "dress":
            return "figure.dress"
        case "shoes", "footwear", "sneakers", "heels", "boots":
            return "shoe.fill"
        case "accessory", "jewelry", "watch":
            return "sparkles"
        case "bag", "purse", "backpack":
            return "bag.fill"
        case "outerwear", "jacket", "coat":
            return "cloud.fill"
        case "hat", "cap":
            return "baseball.cap.fill"
        case "sunglasses", "glasses":
            return "eyeglasses"
        default:
            return "circle.fill"
        }
    }
    
    var categoryColor: Color {
        switch category.lowercased() {
        case "top", "shirt", "blouse", "t-shirt":
            return ModernTheme.primary
        case "bottom", "pants", "jeans", "skirt", "shorts":
            return ModernTheme.secondary
        case "dress":
            return ModernTheme.tertiary
        case "shoes", "footwear", "sneakers", "heels", "boots":
            return ModernTheme.darkSage
        case "accessory", "jewelry", "watch":
            return ModernTheme.accent
        case "bag", "purse", "backpack":
            return ModernTheme.sand
        case "outerwear", "jacket", "coat":
            return ModernTheme.textSecondary
        default:
            return ModernTheme.textTertiary
        }
    }
    
    func localizedCategoryName(for language: Language) -> String {
        return LocalizedStrings.categoryName(category, for: language)
    }
}
