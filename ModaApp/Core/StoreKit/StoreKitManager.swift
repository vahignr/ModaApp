//
//  StoreKitManager.swift
//  ModaApp
//
//  Manages all StoreKit operations and purchases
//

import Foundation
import StoreKit

@MainActor
final class StoreKitManager: NSObject, ObservableObject {
    
    // MARK: - Published Properties
    @Published private(set) var products: [Product] = []
    @Published private(set) var purchasedProductIDs = Set<String>()
    @Published private(set) var isLoading = false
    @Published private(set) var error: StoreKitError?
    
    // MARK: - Private Properties
    private var updates: Task<Void, Never>?
    private let creditsManager = CreditsManager.shared
    
    // MARK: - Singleton
    static let shared = StoreKitManager()
    
    // MARK: - Initialization
    override init() {
        super.init()
        
        // Start listening for transactions
        updates = observeTransactionUpdates()
        
        // Load products on init
        Task {
            await loadProducts()
            await updatePurchasedProducts()
        }
    }
    
    deinit {
        updates?.cancel()
    }
    
    // MARK: - Public Methods
    
    /// Load products from StoreKit
    func loadProducts() async {
        isLoading = true
        error = nil
        
        do {
            // Fetch products from StoreKit
            let storeProducts = try await Product.products(for: StoreKitProducts.allProductIDs)
            
            // Sort by credit amount
            products = storeProducts.sorted { first, second in
                guard let firstCredit = StoreKitProducts.Credits.allCases.first(where: { $0.productID == first.id }),
                      let secondCredit = StoreKitProducts.Credits.allCases.first(where: { $0.productID == second.id }) else {
                    return false
                }
                return firstCredit.creditAmount < secondCredit.creditAmount
            }
            
            isLoading = false
            print("✅ Loaded \(products.count) products from StoreKit")
        } catch {
            print("❌ Failed to load products: \(error)")
            self.error = .productNotFound
            isLoading = false
        }
    }
    
    /// Purchase a product
    func purchase(_ product: Product) async -> PurchaseResult {
        isLoading = true
        error = nil
        
        do {
            // Initiate purchase
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                // Verify the transaction
                switch verification {
                case .verified(let transaction):
                    // Transaction is verified, grant credits
                    let credits = creditAmount(for: product)
                    creditsManager.addCredits(credits)
                    
                    // Always finish transactions
                    await transaction.finish()
                    
                    await updatePurchasedProducts()
                    isLoading = false
                    
                    print("✅ Purchase successful: \(credits) credits added")
                    return .success(credits: credits)
                    
                case .unverified(_, let error):
                    // Transaction failed verification
                    print("❌ Transaction verification failed: \(error)")
                    self.error = .purchaseFailed
                    isLoading = false
                    return .failed(error: StoreKitError.invalidReceipt)
                }
                
            case .userCancelled:
                // User cancelled
                isLoading = false
                return .cancelled
                
            case .pending:
                // Transaction is pending (e.g., waiting for parental approval)
                isLoading = false
                return .pending
                
            @unknown default:
                isLoading = false
                return .failed(error: StoreKitError.unknown)
            }
        } catch {
            print("❌ Purchase failed: \(error)")
            self.error = .purchaseFailed
            isLoading = false
            return .failed(error: error)
        }
    }
    
    /// Restore previous purchases
    func restorePurchases() async -> PurchaseResult {
        isLoading = true
        error = nil
        
        do {
            // Sync with App Store
            try await AppStore.sync()
            
            // Count total restored credits
            var totalRestoredCredits = 0
            
            // Check all current entitlements
            for await result in Transaction.currentEntitlements {
                switch result {
                case .verified(let transaction):
                    if let product = products.first(where: { $0.id == transaction.productID }) {
                        let credits = creditAmount(for: product)
                        totalRestoredCredits += credits
                    }
                case .unverified(_, _):
                    continue
                }
            }
            
            await updatePurchasedProducts()
            isLoading = false
            
            if totalRestoredCredits > 0 {
                print("✅ Restored \(totalRestoredCredits) credits")
                return .restored(totalCredits: totalRestoredCredits)
            } else {
                print("ℹ️ No purchases to restore")
                return .restored(totalCredits: 0)
            }
        } catch {
            print("❌ Restore failed: \(error)")
            self.error = .restoreFailed
            isLoading = false
            return .failed(error: error)
        }
    }
    
    /// Check if user can make payments
    var canMakePayments: Bool {
        SKPaymentQueue.canMakePayments()
    }
    
    // MARK: - Private Methods
    
    /// Get credit amount for a product
    private func creditAmount(for product: Product) -> Int {
        guard let creditProduct = StoreKitProducts.Credits.allCases.first(where: { $0.productID == product.id }) else {
            return 0
        }
        return creditProduct.creditAmount
    }
    
    /// Update purchased products set
    private func updatePurchasedProducts() async {
        var purchased = Set<String>()
        
        // Check all current entitlements
        for await result in Transaction.currentEntitlements {
            switch result {
            case .verified(let transaction):
                purchased.insert(transaction.productID)
            case .unverified(_, _):
                continue
            }
        }
        
        purchasedProductIDs = purchased
    }
    
    /// Observe transaction updates
    private func observeTransactionUpdates() -> Task<Void, Never> {
        Task(priority: .background) {
            for await result in Transaction.updates {
                switch result {
                case .verified(let transaction):
                    // Handle verified transaction update
                    if let product = products.first(where: { $0.id == transaction.productID }) {
                        let credits = creditAmount(for: product)
                        await MainActor.run {
                            creditsManager.addCredits(credits)
                        }
                    }
                    
                    await transaction.finish()
                    await updatePurchasedProducts()
                    
                case .unverified(_, _):
                    // Skip unverified transactions
                    continue
                }
            }
        }
    }
}

// MARK: - Helper Extensions
extension StoreKitManager {
    /// Get StoreKitProducts.Credits enum for a Product
    func creditProduct(for product: Product) -> StoreKitProducts.Credits? {
        StoreKitProducts.Credits.allCases.first { $0.productID == product.id }
    }
    
    /// Check if a product is purchased
    func isPurchased(_ product: Product) -> Bool {
        purchasedProductIDs.contains(product.id)
    }
}
