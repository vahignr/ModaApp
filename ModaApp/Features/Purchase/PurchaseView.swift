//
//  PurchaseView.swift
//  ModaApp
//
//  Main purchase screen for buying credits
//

import SwiftUI
import StoreKit

struct PurchaseView: View {
    @StateObject private var storeManager = StoreKitManager.shared
    @StateObject private var creditsManager = CreditsManager.shared
    @EnvironmentObject var localizationManager: LocalizationManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedProduct: Product?
    @State private var showPurchaseError = false
    @State private var showSuccessAnimation = false
    @State private var purchasedCredits = 0
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                ModernTheme.background
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: ModernTheme.Spacing.xl) {
                        // Header Section
                        PurchaseHeaderView(currentCredits: creditsManager.remainingCredits)
                            .padding(.top, ModernTheme.Spacing.lg)
                        
                        // Products Grid
                        if storeManager.isLoading && storeManager.products.isEmpty {
                            LoadingProductsView()
                        } else if storeManager.products.isEmpty {
                            NoProductsView(onRetry: {
                                Task {
                                    await storeManager.loadProducts()
                                }
                            })
                        } else {
                            ProductsGridView(
                                products: storeManager.products,
                                selectedProduct: $selectedProduct,
                                storeManager: storeManager
                            )
                        }
                        
                        // Purchase Button
                        if let selected = selectedProduct {
                            PurchaseButtonSection(
                                product: selected,
                                storeManager: storeManager,
                                onPurchase: { purchase(selected) }
                            )
                        }
                        
                        // Restore Purchases
                        RestorePurchasesButton(
                            isLoading: storeManager.isLoading,
                            onRestore: restorePurchases
                        )
                        
                        // Footer Info
                        PurchaseFooterView()
                            .padding(.bottom, ModernTheme.Spacing.xxl)
                    }
                    .padding(.horizontal)
                }
                
                // Success Animation Overlay
                if showSuccessAnimation {
                    SuccessCelebrationView(creditsAdded: purchasedCredits)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .navigationTitle(localized(.buyCredits))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(ModernTheme.textTertiary)
                    }
                }
            }
            .alert(localized(.error), isPresented: $showPurchaseError) {
                Button(localized(.ok)) { }
            } message: {
                Text(storeManager.error?.errorDescription ?? localized(.purchaseFailed))
            }
            .onChange(of: storeManager.products) { _ in
                // Auto-select popular product if none selected
                if selectedProduct == nil,
                   let popular = storeManager.products.first(where: {
                       storeManager.creditProduct(for: $0)?.isPopular == true
                   }) {
                    selectedProduct = popular
                }
            }
        }
    }
    
    // MARK: - Purchase Methods
    
    private func purchase(_ product: Product) {
        Task {
            let result = await storeManager.purchase(product)
            
            switch result {
            case .success(let credits):
                purchasedCredits = credits
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    showSuccessAnimation = true
                }
                
                // Dismiss after showing success
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    dismiss()
                }
                
            case .failed:
                showPurchaseError = true
                
            case .cancelled, .pending:
                break
                
            case .restored:
                break
            }
        }
    }
    
    private func restorePurchases() {
        Task {
            let result = await storeManager.restorePurchases()
            
            switch result {
            case .restored(let totalCredits):
                if totalCredits > 0 {
                    purchasedCredits = totalCredits
                    withAnimation {
                        showSuccessAnimation = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                        dismiss()
                    }
                } else {
                    // Show no purchases to restore message
                    showPurchaseError = true
                }
                
            case .failed:
                showPurchaseError = true
                
            default:
                break
            }
        }
    }
}

// MARK: - Purchase Header View
struct PurchaseHeaderView: View {
    let currentCredits: Int
    @EnvironmentObject var localizationManager: LocalizationManager
    
    var body: some View {
        VStack(spacing: ModernTheme.Spacing.md) {
            // Credits Icon
            ZStack {
                Circle()
                    .fill(ModernTheme.primaryGradient)
                    .frame(width: 80, height: 80)
                
                Image(systemName: "leaf.circle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.white)
            }
            .shadow(
                color: ModernTheme.primary.opacity(0.3),
                radius: 12,
                x: 0,
                y: 6
            )
            
            // Current Credits
            VStack(spacing: ModernTheme.Spacing.xs) {
                Text(localized(.credits))
                    .font(ModernTheme.Typography.headline)
                    .foregroundColor(ModernTheme.textPrimary)
                
                Text("\(LocalizationHelpers.formatNumber(currentCredits))")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(ModernTheme.primaryGradient)
                
                Text(localizationManager.currentLanguage == .turkish ?
                     "Her analiz 1 kredi harcar" :
                     "Each analysis uses 1 credit")
                    .font(ModernTheme.Typography.caption)
                    .foregroundColor(ModernTheme.textSecondary)
            }
        }
    }
}

// MARK: - Products Grid View
struct ProductsGridView: View {
    let products: [Product]
    @Binding var selectedProduct: Product?
    let storeManager: StoreKitManager
    @EnvironmentObject var localizationManager: LocalizationManager
    
    var body: some View {
        VStack(spacing: ModernTheme.Spacing.md) {
            ForEach(products, id: \.id) { product in
                ProductCard(
                    product: product,
                    isSelected: selectedProduct?.id == product.id,
                    creditProduct: storeManager.creditProduct(for: product),
                    onTap: { selectedProduct = product }
                )
            }
        }
    }
}

// MARK: - Product Card
struct ProductCard: View {
    let product: Product
    let isSelected: Bool
    let creditProduct: StoreKitProducts.Credits?
    let onTap: () -> Void
    @EnvironmentObject var localizationManager: LocalizationManager
    @State private var isPressed = false
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: ModernTheme.Spacing.md) {
                // Credit Amount
                VStack(spacing: 4) {
                    Text("\(creditProduct?.creditAmount ?? 0)")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(isSelected ? ModernTheme.primary : ModernTheme.textPrimary)
                    
                    Text(localized(.credits))
                        .font(ModernTheme.Typography.caption)
                        .foregroundColor(ModernTheme.textSecondary)
                }
                .frame(width: 80)
                
                // Product Details
                VStack(alignment: .leading, spacing: ModernTheme.Spacing.xs) {
                    HStack {
                        Text(product.displayName)
                            .font(ModernTheme.Typography.headline)
                            .foregroundColor(ModernTheme.textPrimary)
                        
                        if creditProduct?.isPopular == true {
                            PopularBadge()
                        } else if creditProduct?.isBestValue == true {
                            BestValueBadge()
                        }
                    }
                    
                    Text(creditProduct?.localizedDescription(for: localizationManager.currentLanguage) ?? "")
                        .font(ModernTheme.Typography.caption)
                        .foregroundColor(ModernTheme.textSecondary)
                }
                
                Spacer()
                
                // Price
                Text(product.displayPrice)
                    .font(ModernTheme.Typography.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(isSelected ? ModernTheme.primary : ModernTheme.textPrimary)
            }
            .padding(ModernTheme.Spacing.lg)
            .background(
                RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.large)
                    .fill(isSelected ? ModernTheme.primary.opacity(0.1) : ModernTheme.surface)
                    .shadow(
                        color: isSelected ? ModernTheme.primary.opacity(0.2) : ModernTheme.Shadow.small.color,
                        radius: isSelected ? 12 : ModernTheme.Shadow.small.radius,
                        x: 0,
                        y: isSelected ? 6 : ModernTheme.Shadow.small.y
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.large)
                    .stroke(isSelected ? ModernTheme.primary : Color.clear, lineWidth: 2)
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .onLongPressGesture(minimumDuration: .infinity, maximumDistance: .infinity,
            pressing: { pressing in
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = pressing
                }
            },
            perform: {}
        )
    }
}

// MARK: - Badges
struct PopularBadge: View {
    @EnvironmentObject var localizationManager: LocalizationManager
    
    var body: some View {
        Text(localizationManager.currentLanguage == .turkish ? "POPÜLER" : "POPULAR")
            .font(.system(size: 10, weight: .bold))
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(ModernTheme.secondary)
            .cornerRadius(ModernTheme.CornerRadius.small)
    }
}

struct BestValueBadge: View {
    @EnvironmentObject var localizationManager: LocalizationManager
    
    var body: some View {
        Text(localizationManager.currentLanguage == .turkish ? "EN İYİ DEĞER" : "BEST VALUE")
            .font(.system(size: 10, weight: .bold))
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(ModernTheme.success)
            .cornerRadius(ModernTheme.CornerRadius.small)
    }
}

// MARK: - Purchase Button Section (FIXED)
struct PurchaseButtonSection: View {
    let product: Product
    let storeManager: StoreKitManager
    let onPurchase: () -> Void
    @EnvironmentObject var localizationManager: LocalizationManager
    
    var body: some View {
        VStack(spacing: ModernTheme.Spacing.md) {
            Button(action: onPurchase) {
                Group {
                    if storeManager.isLoading {
                        HStack(spacing: ModernTheme.Spacing.sm) {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            Text(localized(.loading))
                                .font(ModernTheme.Typography.headline)
                        }
                    } else {
                        HStack(spacing: ModernTheme.Spacing.sm) {
                            Image(systemName: "creditcard.fill")
                            Text("\(localized(.buy)) \(product.displayName)")
                                .font(ModernTheme.Typography.headline)
                        }
                    }
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .contentShape(Rectangle()) // THIS IS THE KEY FIX - Makes entire area tappable
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(ModernTheme.primaryGradient)
            .cornerRadius(ModernTheme.CornerRadius.full)
            .shadow(
                color: ModernTheme.primary.opacity(0.3),
                radius: 12,
                x: 0,
                y: 6
            )
            .disabled(storeManager.isLoading || !storeManager.canMakePayments)
            
            if !storeManager.canMakePayments {
                Text(localizationManager.currentLanguage == .turkish ?
                     "Uygulama içi satın alma devre dışı" :
                     "In-app purchases are disabled")
                    .font(ModernTheme.Typography.caption)
                    .foregroundColor(ModernTheme.error)
            }
        }
    }
}

// MARK: - Restore Purchases Button
struct RestorePurchasesButton: View {
    let isLoading: Bool
    let onRestore: () -> Void
    @EnvironmentObject var localizationManager: LocalizationManager
    
    var body: some View {
        Button(action: onRestore) {
            Text(localizationManager.currentLanguage == .turkish ?
                 "Satın Almaları Geri Yükle" :
                 "Restore Purchases")
                .font(ModernTheme.Typography.callout)
                .foregroundColor(ModernTheme.primary)
        }
        .disabled(isLoading)
    }
}

// MARK: - Loading/Error States
struct LoadingProductsView: View {
    var body: some View {
        VStack(spacing: ModernTheme.Spacing.lg) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(ModernTheme.primary)
            
            Text(localized(.loading))
                .font(ModernTheme.Typography.body)
                .foregroundColor(ModernTheme.textSecondary)
        }
        .frame(height: 300)
    }
}

struct NoProductsView: View {
    let onRetry: () -> Void
    @EnvironmentObject var localizationManager: LocalizationManager
    
    var body: some View {
        VStack(spacing: ModernTheme.Spacing.lg) {
            Image(systemName: "wifi.exclamationmark")
                .font(.system(size: 60))
                .foregroundColor(ModernTheme.textTertiary)
            
            Text(localizationManager.currentLanguage == .turkish ?
                 "Ürünler yüklenemedi" :
                 "Could not load products")
                .font(ModernTheme.Typography.headline)
                .foregroundColor(ModernTheme.textPrimary)
            
            Button(action: onRetry) {
                Text(localized(.tryAgain))
                    .font(ModernTheme.Typography.body)
                    .foregroundColor(.white)
                    .padding(.horizontal, ModernTheme.Spacing.xl)
                    .padding(.vertical, ModernTheme.Spacing.sm)
                    .background(ModernTheme.primary)
                    .cornerRadius(ModernTheme.CornerRadius.full)
            }
        }
        .frame(height: 300)
    }
}

// MARK: - Success Animation
struct SuccessCelebrationView: View {
    let creditsAdded: Int
    @State private var scale = 0.5
    @State private var opacity = 0.0
    @EnvironmentObject var localizationManager: LocalizationManager
    
    var body: some View {
        ZStack {
            // Background
            Color.black.opacity(0.6)
                .ignoresSafeArea()
            
            VStack(spacing: ModernTheme.Spacing.lg) {
                // Success Icon
                ZStack {
                    Circle()
                        .fill(ModernTheme.success)
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: "checkmark")
                        .font(.system(size: 60, weight: .bold))
                        .foregroundColor(.white)
                }
                
                // Success Text
                VStack(spacing: ModernTheme.Spacing.sm) {
                    Text(localized(.purchaseSuccess))
                        .font(ModernTheme.Typography.title)
                        .foregroundColor(.white)
                    
                    // Fixed: Use proper string formatting
                    Text(localizationManager.currentLanguage == .turkish ?
                         "\(creditsAdded) kredi eklendi!" :
                         "\(creditsAdded) credits added!")
                        .font(ModernTheme.Typography.headline)
                        .foregroundColor(.white.opacity(0.9))
                }
            }
            .scaleEffect(scale)
            .opacity(opacity)
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                scale = 1.0
                opacity = 1.0
            }
        }
    }
}

// MARK: - Footer View
struct PurchaseFooterView: View {
    @EnvironmentObject var localizationManager: LocalizationManager
    
    var body: some View {
        VStack(spacing: ModernTheme.Spacing.sm) {
            Text(localizationManager.currentLanguage == .turkish ?
                 "Krediler hesabınıza anında eklenir" :
                 "Credits are added to your account instantly")
                .font(ModernTheme.Typography.caption)
                .foregroundColor(ModernTheme.textTertiary)
                .multilineTextAlignment(.center)
            
            Text(localizationManager.currentLanguage == .turkish ?
                 "Tüm satın almalar Apple tarafından güvenli şekilde işlenir" :
                 "All purchases are securely processed by Apple")
                .font(ModernTheme.Typography.caption2)
                .foregroundColor(ModernTheme.textTertiary)
                .multilineTextAlignment(.center)
        }
    }
}

// MARK: - Preview
#Preview {
    PurchaseView()
        .environmentObject(LocalizationManager.shared)
}
