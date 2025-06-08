import Foundation
import SwiftUI

final class CreditsManager: ObservableObject {
    @Published private(set) var remainingCredits: Int
    
    static let shared = CreditsManager()
    
    private let userDefaults = UserDefaults.standard
    private let creditsKey = "remainingCredits"
    private let hasLaunchedKey = "hasLaunchedBefore"
    private let freeCreditsKey = "freeCreditsGiven"
    
    // Configuration - using values from ConfigurationManager directly
    private let initialFreeCredits = ConfigurationManager.initialFreeCredits
    private let creditCost = ConfigurationManager.creditCostPerAnalysis
    
    private init() {
        // Check if this is first launch
        let hasLaunchedBefore = userDefaults.bool(forKey: hasLaunchedKey)
        
        if !hasLaunchedBefore {
            // First launch: Give free credits
            remainingCredits = initialFreeCredits
            userDefaults.set(true, forKey: hasLaunchedKey)
            userDefaults.set(initialFreeCredits, forKey: creditsKey)
            userDefaults.set(true, forKey: freeCreditsKey)
            userDefaults.synchronize()
        } else {
            // Not first launch: Load saved credits
            remainingCredits = userDefaults.integer(forKey: creditsKey)
            
            // Ensure non-negative credits
            if remainingCredits < 0 {
                remainingCredits = 0
                saveCredits()
            }
        }
    }
    
    // MARK: - Public Methods
    
    /// Check if user has enough credits
    var hasCredits: Bool {
        return remainingCredits >= creditCost
    }
    
    /// Use credits for an analysis
    func useCredit() -> Bool {
        guard hasCredits else { return false }
        
        remainingCredits -= creditCost
        saveCredits()
        return true
    }
    
    /// Add credits (called after purchase)
    func addCredits(_ amount: Int) {
        remainingCredits += amount
        saveCredits()
    }
    
    /// Get the cost of one analysis
    var costPerAnalysis: Int {
        return creditCost
    }
    
    /// Check if user has received free credits
    var hasReceivedFreeCredits: Bool {
        return userDefaults.bool(forKey: freeCreditsKey)
    }
    
    // MARK: - Private Methods
    
    private func saveCredits() {
        userDefaults.set(remainingCredits, forKey: creditsKey)
        userDefaults.synchronize()
    }
    
    // MARK: - Debug Methods (remove in production)
    
    #if DEBUG
    func resetCredits() {
        remainingCredits = 0
        saveCredits()
    }
    
    func addDebugCredits(_ amount: Int = 10) {
        addCredits(amount)
    }
    #endif
}
