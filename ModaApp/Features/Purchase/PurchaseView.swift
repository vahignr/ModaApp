//
//  PurchaseView.swift
//  ModaApp
//
//  Enhanced purchase screen with luxury animations
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
    @State private var heroScale: CGFloat = 0
    @State private var cardsVisible = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Animated background
                LuxuryPurchaseBackground()
                
                ScrollView {
                    VStack(spacing: ModernTheme.Spacing.xl) {
                        // Enhanced Header Section
                        LuxuryPurchaseHeader(
                            currentCredits: creditsManager.remainingCredits,
                            heroScale: $heroScale
                        )
                        .padding(.top, ModernTheme.Spacing.lg)
                        
                        // Products Grid with staggered animation
                        if storeManager.isLoading && storeManager.products.isEmpty {
                            LuxuryLoadingView()
                        } else if storeManager.products.isEmpty {
                            NoProductsView(onRetry: {
                                Task {
                                    await storeManager.loadProducts()
                                }
                            })
                        } else {
                            LuxuryProductsGrid(
                                products: storeManager.products,
                                selectedProduct: $selectedProduct,
                                storeManager: storeManager,
                                cardsVisible: $cardsVisible
                            )
                        }
                        
                        // Enhanced Purchase Button
                        if let selected = selectedProduct {
                            LuxuryPurchaseButton(
                                product: selected,
                                storeManager: storeManager,
                                onPurchase: { purchase(selected) }
                            )
                            .transition(.scale.combined(with: .opacity))
                        }
                        
                        // Restore Purchases with animation
                        RestorePurchasesButton(
                            isLoading: storeManager.isLoading,
                            onRestore: restorePurchases
                        )
                        .opacity(cardsVisible ? 1 : 0)
                        .animation(.easeOut(duration: 0.5).delay(0.8), value: cardsVisible)
                        
                        // Enhanced Footer
                        LuxuryPurchaseFooter()
                            .padding(.bottom, ModernTheme.Spacing.xxl)
                            .opacity(cardsVisible ? 1 : 0)
                            .animation(.easeOut(duration: 0.5).delay(1.0), value: cardsVisible)
                    }
                    .padding(.horizontal)
                }
                
                // Success Animation Overlay
                if showSuccessAnimation {
                    LuxurySuccessView(creditsAdded: purchasedCredits)
                        .transition(.hero)
                }
            }
            .navigationTitle(localized(.buyCredits))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        ZStack {
                            Circle()
                                .fill(ModernTheme.surface.opacity(0.8))
                                .frame(width: 32, height: 32)
                            
                            Image(systemName: "xmark")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(ModernTheme.textPrimary)
                        }
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
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        selectedProduct = popular
                    }
                }
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                heroScale = 1
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    cardsVisible = true
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
                
                // Add haptic feedback
                let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
                impactFeedback.impactOccurred()
                
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

// MARK: - Luxury Purchase Background
struct LuxuryPurchaseBackground: View {
    @State private var gradientRotation: Double = 0
    
    var body: some View {
        ZStack {
            ModernTheme.background
                .ignoresSafeArea()
            
            // Animated gradient
            RadialGradient(
                colors: [
                    ModernTheme.secondary.opacity(0.1),
                    ModernTheme.primary.opacity(0.05),
                    Color.clear
                ],
                center: .top,
                startRadius: 100,
                endRadius: 400
            )
            .rotationEffect(.degrees(gradientRotation))
            .ignoresSafeArea()
            .onAppear {
                withAnimation(.linear(duration: 15).repeatForever(autoreverses: false)) {
                    gradientRotation = 360
                }
            }
            
            // Floating particles
            GeometryReader { geometry in
                ForEach(0..<20) { index in
                    Circle()
                        .fill(ModernTheme.secondary.opacity(0.1))
                        .frame(width: CGFloat.random(in: 10...30))
                        .position(
                            x: CGFloat.random(in: 0...geometry.size.width),
                            y: CGFloat.random(in: 0...geometry.size.height)
                        )
                        .floatingAnimation(delay: Double(index) * 0.1)
                }
            }
            .ignoresSafeArea()
        }
    }
}

// MARK: - Luxury Purchase Header
struct LuxuryPurchaseHeader: View {
    let currentCredits: Int
    @Binding var heroScale: CGFloat
    @State private var coinRotation: Double = 0
    @EnvironmentObject var localizationManager: LocalizationManager
    
    var body: some View {
        VStack(spacing: ModernTheme.Spacing.md) {
            // Animated Credits Icon
            ZStack {
                // Glow effect
                Circle()
                    .fill(ModernTheme.primaryGradient.opacity(0.3))
                    .frame(width: 120, height: 120)
                    .blur(radius: 30)
                    .scaleEffect(heroScale * 1.5)
                
                Circle()
                    .fill(ModernTheme.primaryGradient)
                    .frame(width: 80, height: 80)
                    .overlay(
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.3), Color.white.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                    )
                    .shadow(
                        color: ModernTheme.primary.opacity(0.5),
                        radius: 20,
                        x: 0,
                        y: 10
                    )
                
                Image(systemName: "leaf.circle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.white)
                    .rotationEffect(.degrees(coinRotation))
            }
            .scaleEffect(heroScale)
            .onAppear {
                withAnimation(.linear(duration: 10).repeatForever(autoreverses: false)) {
                    coinRotation = 360
                }
            }
            
            // Current Credits with animation
            VStack(spacing: ModernTheme.Spacing.xs) {
                Text(localized(.credits).uppercased())
                    .font(ModernTheme.Typography.headline)
                    .tracking(2.0)
                    .foregroundColor(ModernTheme.textPrimary)
                
                Text("\(LocalizationHelpers.formatNumber(currentCredits))")
                    .font(.system(size: 56, weight: .bold, design: .serif))
                    .foregroundStyle(ModernTheme.primaryGradient)
                    .scaleEffect(heroScale)
                
                Text(localizationManager.currentLanguage == .turkish ?
                     "Her analiz 1 kredi harcar" :
                     "Each analysis uses 1 credit")
                    .font(ModernTheme.Typography.caption)
                    .foregroundColor(ModernTheme.textSecondary)
                    .opacity(heroScale)
            }
        }
    }
}

// MARK: - Luxury Products Grid
struct LuxuryProductsGrid: View {
    let products: [Product]
    @Binding var selectedProduct: Product?
    let storeManager: StoreKitManager
    @Binding var cardsVisible: Bool
    @EnvironmentObject var localizationManager: LocalizationManager
    
    var body: some View {
        VStack(spacing: ModernTheme.Spacing.md) {
            ForEach(Array(products.enumerated()), id: \.element.id) { index, product in
                LuxuryProductCard(
                    product: product,
                    isSelected: selectedProduct?.id == product.id,
                    creditProduct: storeManager.creditProduct(for: product),
                    onTap: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            selectedProduct = product
                        }
                    }
                )
                .opacity(cardsVisible ? 1 : 0)
                .offset(y: cardsVisible ? 0 : 50)
                .animation(
                    .spring(response: 0.6, dampingFraction: 0.8)
                    .delay(Double(index) * 0.1),
                    value: cardsVisible
                )
            }
        }
    }
}

// MARK: - Luxury Product Card
struct LuxuryProductCard: View {
    let product: Product
    let isSelected: Bool
    let creditProduct: StoreKitProducts.Credits?
    let onTap: () -> Void
    @EnvironmentObject var localizationManager: LocalizationManager
    @State private var isPressed = false
    @State private var shimmerOffset: CGFloat = -200
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                // Background with gradient
                RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.large)
                    .fill(
                        isSelected ?
                        ModernTheme.primary.opacity(0.1) :
                        ModernTheme.surface.opacity(0.7)
                    )
                    .background(.ultraThinMaterial.opacity(0.5))
                
                // Shimmer effect for selected
                if isSelected {
                    LinearGradient(
                        colors: [
                            Color.clear,
                            Color.white.opacity(0.1),
                            Color.clear
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: 100)
                    .offset(x: shimmerOffset)
                    .mask(
                        RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.large)
                    )
                    .onAppear {
                        withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                            shimmerOffset = 300
                        }
                    }
                }
                
                HStack(spacing: ModernTheme.Spacing.md) {
                    // Animated Credit Amount
                    VStack(spacing: 4) {
                        Text("\(creditProduct?.creditAmount ?? 0)")
                            .font(.system(size: 42, weight: .bold, design: .serif))
                            .foregroundStyle(
                                isSelected ?
                                ModernTheme.primaryGradient :
                                LinearGradient(colors: [ModernTheme.textPrimary], startPoint: .top, endPoint: .bottom)
                            )
                        
                        Text(localized(.credits).uppercased())
                            .font(ModernTheme.Typography.caption)
                            .tracking(1.0)
                            .foregroundColor(ModernTheme.textSecondary)
                    }
                    .frame(width: 90)
                    .scaleEffect(isSelected ? 1.1 : 1.0)
                    .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isSelected)
                    
                    // Product Details
                    VStack(alignment: .leading, spacing: ModernTheme.Spacing.xs) {
                        HStack {
                            Text(product.displayName.uppercased())
                                .font(ModernTheme.Typography.headline)
                                .tracking(1.2)
                                .foregroundColor(ModernTheme.textPrimary)
                            
                            if creditProduct?.isPopular == true {
                                PopularBadge()
                                    .scaleEffect(isSelected ? 1.1 : 1.0)
                                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
                            } else if creditProduct?.isBestValue == true {
                                BestValueBadge()
                                    .scaleEffect(isSelected ? 1.1 : 1.0)
                                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
                            }
                        }
                        
                        Text(creditProduct?.localizedDescription(for: localizationManager.currentLanguage) ?? "")
                            .font(ModernTheme.Typography.caption)
                            .foregroundColor(ModernTheme.textSecondary)
                    }
                    
                    Spacer()
                    
                    // Animated Price
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(product.displayPrice)
                            .font(ModernTheme.Typography.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(
                                isSelected ?
                                ModernTheme.primaryGradient :
                                LinearGradient(colors: [ModernTheme.textPrimary], startPoint: .top, endPoint: .bottom)
                            )
                        
                        if isSelected {
                            Text("TAP TO BUY")
                                .font(ModernTheme.Typography.finePrint)
                                .tracking(1.0)
                                .foregroundColor(ModernTheme.primary)
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                }
                .padding(ModernTheme.Spacing.lg)
            }
            .overlay(
                RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.large)
                    .stroke(
                        isSelected ? ModernTheme.primaryGradient : Color.clear,
                        lineWidth: 2
                    )
            )
            .shadow(
                color: isSelected ? ModernTheme.primary.opacity(0.3) : ModernTheme.Shadow.small.color,
                radius: isSelected ? 15 : ModernTheme.Shadow.small.radius,
                x: 0,
                y: isSelected ? 8 : ModernTheme.Shadow.small.y
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
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

// MARK: - Badges (Missing Components)
struct PopularBadge: View {
    @EnvironmentObject var localizationManager: LocalizationManager
    @State private var isAnimating = false
    
    var body: some View {
        Text(localizationManager.currentLanguage == .turkish ? "POPÜLER" : "POPULAR")
            .font(.system(size: 10, weight: .bold))
            .tracking(0.8)
            .foregroundColor(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.small)
                    .fill(ModernTheme.secondaryGradient)
                    .shadow(
                        color: ModernTheme.secondary.opacity(0.3),
                        radius: 5,
                        x: 0,
                        y: 2
                    )
            )
            .scaleEffect(isAnimating ? 1.05 : 1.0)
            .onAppear {
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    isAnimating = true
                }
            }
    }
}

struct BestValueBadge: View {
    @EnvironmentObject var localizationManager: LocalizationManager
    @State private var shimmerOffset: CGFloat = -50
    
    var body: some View {
        ZStack {
            Text(localizationManager.currentLanguage == .turkish ? "EN İYİ DEĞER" : "BEST VALUE")
                .font(.system(size: 10, weight: .bold))
                .tracking(0.8)
                .foregroundColor(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.small)
                        .fill(
                            LinearGradient(
                                colors: [ModernTheme.success, ModernTheme.success.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(
                            color: ModernTheme.success.opacity(0.3),
                            radius: 5,
                            x: 0,
                            y: 2
                        )
                )
            
            // Shimmer overlay
            LinearGradient(
                colors: [
                    Color.clear,
                    Color.white.opacity(0.3),
                    Color.clear
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(width: 30)
            .offset(x: shimmerOffset)
            .mask(
                RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.small)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
            )
        }
        .onAppear {
            withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                shimmerOffset = 50
            }
        }
    }
}

// MARK: - Restore Purchases Button (Missing Component)
struct RestorePurchasesButton: View {
    let isLoading: Bool
    let onRestore: () -> Void
    @EnvironmentObject var localizationManager: LocalizationManager
    @State private var isPressed = false
    
    var body: some View {
        Button(action: onRestore) {
            HStack(spacing: ModernTheme.Spacing.xs) {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 14, weight: .medium))
                    .rotationEffect(.degrees(isPressed ? 360 : 0))
                    .animation(.easeInOut(duration: 0.5), value: isPressed)
                
                Text(localizationManager.currentLanguage == .turkish ?
                     "Satın Almaları Geri Yükle" :
                     "Restore Purchases")
                    .font(ModernTheme.Typography.callout)
                    .tracking(0.5)
            }
            .foregroundColor(ModernTheme.primary)
            .opacity(isLoading ? 0.5 : 1.0)
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
        }
        .disabled(isLoading)
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

// MARK: - No Products View (Missing Component)
struct NoProductsView: View {
    let onRetry: () -> Void
    @EnvironmentObject var localizationManager: LocalizationManager
    @State private var iconRotation: Double = 0
    
    var body: some View {
        VStack(spacing: ModernTheme.Spacing.lg) {
            // Animated icon
            ZStack {
                Circle()
                    .fill(ModernTheme.error.opacity(0.1))
                    .frame(width: 100, height: 100)
                
                Image(systemName: "wifi.exclamationmark")
                    .font(.system(size: 50))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [ModernTheme.error, ModernTheme.error.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .rotationEffect(.degrees(iconRotation))
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                    iconRotation = 10
                }
            }
            
            Text(localizationManager.currentLanguage == .turkish ?
                 "Ürünler yüklenemedi" :
                 "Could not load products")
                .font(ModernTheme.Typography.headline)
                .foregroundColor(ModernTheme.textPrimary)
            
            Button(action: onRetry) {
                Text(localized(.tryAgain).uppercased())
                    .font(ModernTheme.Typography.body)
                    .tracking(1.0)
                    .foregroundColor(.white)
                    .padding(.horizontal, ModernTheme.Spacing.xl)
                    .padding(.vertical, ModernTheme.Spacing.sm)
                    .background(ModernTheme.primaryGradient)
                    .cornerRadius(ModernTheme.CornerRadius.full)
                    .shadow(
                        color: ModernTheme.primary.opacity(0.3),
                        radius: 10,
                        x: 0,
                        y: 5
                    )
            }
        }
        .frame(height: 300)
    }
}

// MARK: - Luxury Purchase Button
struct LuxuryPurchaseButton: View {
    let product: Product
    let storeManager: StoreKitManager
    let onPurchase: () -> Void
    @State private var isPressed = false
    @State private var pulseScale: CGFloat = 1.0
    @EnvironmentObject var localizationManager: LocalizationManager
    
    var body: some View {
        VStack(spacing: ModernTheme.Spacing.md) {
            Button(action: onPurchase) {
                ZStack {
                    // Pulse effect background
                    RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.full)
                        .stroke(ModernTheme.primary, lineWidth: 2)
                        .frame(height: 64)
                        .scaleEffect(pulseScale)
                        .opacity(2 - pulseScale)
                        .animation(
                            .easeOut(duration: 1.5)
                            .repeatForever(autoreverses: false),
                            value: pulseScale
                        )
                    
                    // Main button
                    Group {
                        if storeManager.isLoading {
                            HStack(spacing: ModernTheme.Spacing.sm) {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                Text(localized(.loading).uppercased())
                                    .font(ModernTheme.Typography.headline)
                                    .tracking(1.5)
                            }
                        } else {
                            HStack(spacing: ModernTheme.Spacing.sm) {
                                Image(systemName: "creditcard.fill")
                                    .font(.system(size: 20))
                                Text("\(localized(.buy).uppercased()) \(product.displayName.uppercased())")
                                    .font(ModernTheme.Typography.headline)
                                    .tracking(1.5)
                            }
                        }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 64)
                    .background(ModernTheme.primaryGradient)
                    .cornerRadius(ModernTheme.CornerRadius.full)
                    .shadow(
                        color: ModernTheme.primary.opacity(0.5),
                        radius: isPressed ? 10 : 20,
                        x: 0,
                        y: isPressed ? 5 : 10
                    )
                }
            }
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
            .disabled(storeManager.isLoading || !storeManager.canMakePayments)
            .onAppear {
                pulseScale = 1.2
            }
            .onLongPressGesture(minimumDuration: .infinity, maximumDistance: .infinity,
                pressing: { pressing in
                    withAnimation(.easeInOut(duration: 0.1)) {
                        isPressed = pressing
                    }
                },
                perform: {}
            )
            
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

// MARK: - Luxury Loading View
struct LuxuryLoadingView: View {
    @State private var rotations: [Double] = [0, 0, 0]
    
    var body: some View {
        VStack(spacing: ModernTheme.Spacing.lg) {
            HStack(spacing: ModernTheme.Spacing.md) {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(ModernTheme.primaryGradient.opacity(0.3))
                        .frame(width: 20, height: 20)
                        .rotationEffect(.degrees(rotations[index]))
                        .onAppear {
                            withAnimation(.linear(duration: 1).repeatForever(autoreverses: false).delay(Double(index) * 0.2)) {
                                rotations[index] = 360
                            }
                        }
                }
            }
            
            Text(localized(.loading))
                .font(ModernTheme.Typography.body)
                .foregroundColor(ModernTheme.textSecondary)
                .shimmer()
        }
        .frame(height: 300)
    }
}

// MARK: - Luxury Success View
struct LuxurySuccessView: View {
    let creditsAdded: Int
    @State private var scale = 0.1
    @State private var opacity = 0.0
    @State private var rotationAngle = -90.0
    @State private var particlesVisible = false
    @EnvironmentObject var localizationManager: LocalizationManager
    
    var body: some View {
        ZStack {
            // Background
            Color.black.opacity(0.8)
                .ignoresSafeArea()
                .onTapGesture { } // Prevent dismissal
            
            // Particles
            if particlesVisible {
                ParticleEffectView()
            }
            
            VStack(spacing: ModernTheme.Spacing.lg) {
                // Success Icon with rotation
                ZStack {
                    // Glow effect
                    Circle()
                        .fill(ModernTheme.success.opacity(0.3))
                        .frame(width: 160, height: 160)
                        .blur(radius: 30)
                        .scaleEffect(scale * 1.5)
                    
                    Circle()
                        .fill(ModernTheme.success)
                        .frame(width: 120, height: 120)
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.3), lineWidth: 2)
                        )
                    
                    Image(systemName: "checkmark")
                        .font(.system(size: 60, weight: .bold))
                        .foregroundColor(.white)
                        .rotationEffect(.degrees(rotationAngle))
                }
                
                // Success Text
                VStack(spacing: ModernTheme.Spacing.sm) {
                    Text(localized(.purchaseSuccess).uppercased())
                        .font(ModernTheme.Typography.title)
                        .tracking(2.0)
                        .foregroundColor(.white)
                    
                    Text(localizationManager.currentLanguage == .turkish ?
                         "\(creditsAdded) KREDİ EKLENDİ!" :
                         "\(creditsAdded) CREDITS ADDED!")
                        .font(ModernTheme.Typography.headline)
                        .tracking(1.5)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [ModernTheme.primary, ModernTheme.secondary],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                }
            }
            .scaleEffect(scale)
            .opacity(opacity)
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                scale = 1.0
                opacity = 1.0
                rotationAngle = 0
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                particlesVisible = true
            }
            
            // Haptic feedback
            let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
            impactFeedback.impactOccurred()
        }
    }
}

// MARK: - Luxury Footer View
struct LuxuryPurchaseFooter: View {
    @EnvironmentObject var localizationManager: LocalizationManager
    @State private var iconScale: CGFloat = 1.0
    
    var body: some View {
        VStack(spacing: ModernTheme.Spacing.sm) {
            // Security icons
            HStack(spacing: ModernTheme.Spacing.lg) {
                ForEach(["lock.shield.fill", "creditcard.fill", "checkmark.shield.fill"], id: \.self) { icon in
                    Image(systemName: icon)
                        .font(.system(size: 24))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [ModernTheme.primary, ModernTheme.secondary],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .scaleEffect(iconScale)
                }
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    iconScale = 1.1
                }
            }
            
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
        .padding(.vertical, ModernTheme.Spacing.md)
    }
}

// MARK: - Preview
#Preview {
    PurchaseView()
        .environmentObject(LocalizationManager.shared)
}
