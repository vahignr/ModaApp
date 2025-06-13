//
//  PurchaseView.swift
//  ModaApp
//
//  Luxury purchase screen with animations and confetti
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
    @State private var confettiCounter = 0
    @State private var headerScale: CGFloat = 1.0
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Animated Background
                PurchaseBackground()
                
                ScrollView {
                    VStack(spacing: ModernTheme.Spacing.xl) {
                        // Animated Header
                        LuxuryPurchaseHeader(
                            currentCredits: creditsManager.remainingCredits,
                            scale: headerScale
                        )
                        .padding(.top, ModernTheme.Spacing.lg)
                        .onAppear {
                            withAnimation(
                                .spring(response: 2, dampingFraction: 0.6)
                                .repeatForever(autoreverses: true)
                            ) {
                                headerScale = 1.05
                            }
                        }
                        
                        // Products Section
                        if storeManager.isLoading && storeManager.products.isEmpty {
                            LuxuryLoadingView()
                        } else if storeManager.products.isEmpty {
                            EmptyProductsView(onRetry: {
                                Task {
                                    await storeManager.loadProducts()
                                }
                            })
                        } else {
                            LuxuryProductsGrid(
                                products: storeManager.products,
                                selectedProduct: $selectedProduct,
                                storeManager: storeManager
                            )
                        }
                        
                        // Purchase Button
                        if let selected = selectedProduct {
                            LuxuryPurchaseButton(
                                product: selected,
                                isLoading: storeManager.isLoading,
                                onPurchase: { purchase(selected) }
                            )
                            .padding(.horizontal)
                        }
                        
                        // Features List
                        PurchaseFeaturesView()
                            .padding(.horizontal)
                        
                        // Restore Button
                        LuxuryRestoreButton(
                            isLoading: storeManager.isLoading,
                            onRestore: restorePurchases
                        )
                        
                        // Footer
                        PurchaseFooterView()
                            .padding(.bottom, ModernTheme.Spacing.xxl)
                    }
                    .padding(.horizontal)
                }
                
                // Success Overlay with Confetti
                if showSuccessAnimation {
                    SuccessOverlay(
                        creditsAdded: purchasedCredits,
                        confettiCounter: confettiCounter
                    )
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .navigationTitle(localized(.buyCredits))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    CloseButton { dismiss() }
                }
            }
            .alert(localized(.error), isPresented: $showPurchaseError) {
                Button(localized(.ok)) { }
            } message: {
                Text(storeManager.error?.errorDescription ?? localized(.purchaseFailed))
            }
            .onChange(of: storeManager.products) { _ in
                selectDefaultProduct()
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
                confettiCounter += 1
                
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    showSuccessAnimation = true
                }
                
                // Haptic feedback
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
                
                // Dismiss after animation
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    dismiss()
                }
                
            case .failed:
                showPurchaseError = true
                
                // Haptic feedback
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.error)
                
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
                    confettiCounter += 1
                    withAnimation {
                        showSuccessAnimation = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
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
    
    private func selectDefaultProduct() {
        if selectedProduct == nil,
           let popular = storeManager.products.first(where: {
               storeManager.creditProduct(for: $0)?.isPopular == true
           }) {
            selectedProduct = popular
        }
    }
}

// MARK: - Purchase Background
struct PurchaseBackground: View {
    @State private var animateGradient = false
    @State private var sparklePositions: [CGPoint] = []
    
    var body: some View {
        ZStack {
            // Base gradient
            LinearGradient(
                colors: [
                    ModernTheme.background,
                    ModernTheme.secondary.opacity(0.05),
                    ModernTheme.tertiary.opacity(0.03)
                ],
                startPoint: animateGradient ? .topLeading : .bottomTrailing,
                endPoint: animateGradient ? .bottomTrailing : .topLeading
            )
            .ignoresSafeArea()
            .onAppear {
                withAnimation(.linear(duration: 20).repeatForever(autoreverses: true)) {
                    animateGradient.toggle()
                }
                generateSparkles()
            }
            
            // Floating sparkles
            ForEach(sparklePositions.indices, id: \.self) { index in
                Image(systemName: "sparkle")
                    .font(.system(size: CGFloat.random(in: 8...20)))
                    .foregroundColor(ModernTheme.tertiary.opacity(0.3))
                    .position(sparklePositions[index])
                    .animation(
                        .linear(duration: Double.random(in: 10...20))
                        .repeatForever(autoreverses: false),
                        value: sparklePositions
                    )
            }
        }
    }
    
    private func generateSparkles() {
        sparklePositions = (0..<10).map { _ in
            CGPoint(
                x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
            )
        }
    }
}

// MARK: - Luxury Purchase Header
struct LuxuryPurchaseHeader: View {
    let currentCredits: Int
    let scale: CGFloat
    @EnvironmentObject var localizationManager: LocalizationManager
    @State private var iconRotation: Double = 0
    
    var body: some View {
        VStack(spacing: ModernTheme.Spacing.lg) {
            // Animated Icon
            ZStack {
                // Glow effect
                Circle()
                    .fill(ModernTheme.secondaryGradient)
                    .frame(width: 120, height: 120)
                    .blur(radius: 30)
                    .opacity(0.5)
                    .scaleEffect(scale)
                
                // Main icon container
                Circle()
                    .fill(ModernTheme.primaryGradient)
                    .frame(width: 100, height: 100)
                    .overlay(
                        Image(systemName: "leaf.circle.fill")
                            .font(.system(size: 60, weight: .medium))
                            .foregroundColor(.white)
                            .rotationEffect(.degrees(iconRotation))
                    )
                    .shadow(
                        color: ModernTheme.Shadow.glow.color,
                        radius: ModernTheme.Shadow.glow.radius
                    )
            }
            .onAppear {
                withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                    iconRotation = 360
                }
            }
            
            // Credits Display
            VStack(spacing: ModernTheme.Spacing.sm) {
                Text(localized(.credits))
                    .font(ModernTheme.Typography.headline)
                    .foregroundColor(ModernTheme.textSecondary)
                
                HStack(alignment: .top, spacing: 4) {
                    Text("\(LocalizationHelpers.formatNumber(currentCredits))")
                        .font(.system(size: 56, weight: .bold, design: .rounded))
                        .foregroundStyle(ModernTheme.primaryGradient)
                        .contentTransition(.numericText())
                    
                    if currentCredits == 0 {
                        Image(systemName: "exclamationmark.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(ModernTheme.error)
                            .offset(y: 8)
                    }
                }
                
                Text(localizationManager.currentLanguage == .turkish ?
                     "Her analiz 1 kredi harcar" :
                     "Each analysis uses 1 credit")
                    .font(ModernTheme.Typography.caption)
                    .foregroundColor(ModernTheme.textTertiary)
            }
        }
    }
}

// MARK: - Luxury Products Grid
struct LuxuryProductsGrid: View {
    let products: [Product]
    @Binding var selectedProduct: Product?
    let storeManager: StoreKitManager
    
    var body: some View {
        VStack(spacing: ModernTheme.Spacing.md) {
            ForEach(Array(products.enumerated()), id: \.element.id) { index, product in
                LuxuryProductCard(
                    product: product,
                    isSelected: selectedProduct?.id == product.id,
                    creditProduct: storeManager.creditProduct(for: product),
                    animationDelay: Double(index) * 0.1,
                    onTap: { selectedProduct = product }
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
    let animationDelay: Double
    let onTap: () -> Void
    
    @EnvironmentObject var localizationManager: LocalizationManager
    @State private var isPressed = false
    @State private var appeared = false
    @State private var badgeScale: CGFloat = 1.0
    
    var body: some View {
        Button(action: {
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
            onTap()
        }) {
            HStack(spacing: ModernTheme.Spacing.lg) {
                // Credit Amount with animation
                ZStack {
                    Circle()
                        .fill(
                            isSelected ?
                            ModernTheme.secondaryGradient :
                            LinearGradient(
                                colors: [ModernTheme.lightBlush, ModernTheme.accent],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 80, height: 80)
                        .shadow(
                            color: isSelected ? ModernTheme.Shadow.colored.color : Color.clear,
                            radius: 12,
                            x: 0,
                            y: 6
                        )
                    
                    VStack(spacing: 2) {
                        Text("\(creditProduct?.creditAmount ?? 0)")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(isSelected ? .white : ModernTheme.primary)
                        
                        Text(localized(.credits))
                            .font(ModernTheme.Typography.caption2)
                            .foregroundColor(isSelected ? .white.opacity(0.9) : ModernTheme.textSecondary)
                    }
                }
                .scaleEffect(isSelected ? 1.05 : 1.0)
                
                // Product Details
                VStack(alignment: .leading, spacing: ModernTheme.Spacing.xs) {
                    HStack {
                        Text(product.displayName)
                            .font(ModernTheme.Typography.headline)
                            .foregroundColor(ModernTheme.textPrimary)
                        
                        if let creditProduct = creditProduct {
                            if creditProduct.isPopular {
                                PremiumBadge(
                                    text: localized(.mostPopular),
                                    color: ModernTheme.secondary,
                                    scale: badgeScale
                                )
                            } else if creditProduct.isBestValue {
                                PremiumBadge(
                                    text: localized(.bestValue),
                                    color: ModernTheme.success,
                                    scale: badgeScale
                                )
                            }
                        }
                    }
                    
                    Text(creditProduct?.localizedDescription(for: localizationManager.currentLanguage) ?? "")
                        .font(ModernTheme.Typography.caption)
                        .foregroundColor(ModernTheme.textSecondary)
                }
                
                Spacer()
                
                // Price with animation
                VStack(alignment: .trailing, spacing: 2) {
                    Text(product.displayPrice)
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            isSelected ?
                            ModernTheme.primaryGradient :
                            LinearGradient(colors: [ModernTheme.textPrimary], startPoint: .leading, endPoint: .trailing)
                        )
                    
                    if let creditProduct = creditProduct, creditProduct.creditAmount > 0 {
                        let pricePerCredit = product.price / Decimal(creditProduct.creditAmount)
                        Text(localizationManager.currentLanguage == .turkish ?
                             "kredi başı \(pricePerCredit.formatted(.currency(code: product.priceFormatStyle.currencyCode)))" :
                             "\(pricePerCredit.formatted(.currency(code: product.priceFormatStyle.currencyCode)))/credit")
                            .font(ModernTheme.Typography.caption2)
                            .foregroundColor(ModernTheme.textTertiary)
                    }
                }
            }
            .padding(ModernTheme.Spacing.lg)
            .background(
                RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.xl)
                    .fill(
                        isSelected ?
                        ModernTheme.glassWhite :
                        ModernTheme.surface
                    )
                    .background(
                        isSelected ? AnyView(
                            RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.xl)
                                .fill(.ultraThinMaterial)
                        ) : AnyView(Color.clear)
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.xl)
                    .stroke(
                        isSelected ?
                        ModernTheme.secondaryGradient :
                        LinearGradient(colors: [ModernTheme.glassBorder], startPoint: .leading, endPoint: .trailing),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
            .shadow(
                color: isSelected ? ModernTheme.Shadow.colored.color : ModernTheme.Shadow.small.color,
                radius: isSelected ? 16 : ModernTheme.Shadow.small.radius,
                x: 0,
                y: isSelected ? 8 : ModernTheme.Shadow.small.y
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .offset(x: appeared ? 0 : -50)
            .opacity(appeared ? 1 : 0)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(
            minimumDuration: .infinity,
            maximumDistance: .infinity,
            pressing: { pressing in
                withAnimation(ModernTheme.springAnimation) {
                    isPressed = pressing
                }
            },
            perform: {}
        )
        .onAppear {
            withAnimation(
                .spring(response: 0.6, dampingFraction: 0.7)
                .delay(animationDelay)
            ) {
                appeared = true
            }
            
            if creditProduct?.isPopular == true || creditProduct?.isBestValue == true {
                withAnimation(
                    .easeInOut(duration: 1.5)
                    .repeatForever(autoreverses: true)
                ) {
                    badgeScale = 1.1
                }
            }
        }
    }
}

// MARK: - Premium Badge
struct PremiumBadge: View {
    let text: String
    let color: Color
    let scale: CGFloat
    
    var body: some View {
        Text(text)
            .font(.system(size: 10, weight: .bold))
            .foregroundColor(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [color, color.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            )
            .scaleEffect(scale)
            .shadow(
                color: color.opacity(0.3),
                radius: 4,
                x: 0,
                y: 2
            )
    }
}

// MARK: - Luxury Purchase Button
struct LuxuryPurchaseButton: View {
    let product: Product
    let isLoading: Bool
    let onPurchase: () -> Void
    
    @State private var isPressed = false
    @State private var shimmerOffset: CGFloat = -200
    
    var body: some View {
        Button(action: onPurchase) {
            ZStack {
                // Background with shimmer
                RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.full)
                    .fill(ModernTheme.primaryGradient)
                    .overlay(
                        LinearGradient(
                            colors: [
                                Color.clear,
                                Color.white.opacity(0.3),
                                Color.clear
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .frame(width: 100)
                        .offset(x: shimmerOffset)
                        .mask(
                            RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.full)
                        )
                    )
                
                // Content
                if isLoading {
                    HStack(spacing: ModernTheme.Spacing.sm) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        Text(localized(.loading))
                            .font(ModernTheme.Typography.headline)
                            .foregroundColor(.white)
                    }
                } else {
                    HStack(spacing: ModernTheme.Spacing.sm) {
                        Image(systemName: "creditcard.fill")
                            .font(.system(size: 20))
                        Text("\(localized(.buy)) \(product.displayName)")
                            .font(ModernTheme.Typography.headline)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                }
            }
            .frame(height: 60)
            .frame(maxWidth: .infinity)
            .shadow(
                color: ModernTheme.Shadow.colored.color,
                radius: isPressed ? 8 : ModernTheme.Shadow.colored.radius,
                x: 0,
                y: isPressed ? 4 : ModernTheme.Shadow.colored.y
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isLoading)
        .onLongPressGesture(
            minimumDuration: .infinity,
            maximumDistance: .infinity,
            pressing: { pressing in
                withAnimation(ModernTheme.springAnimation) {
                    isPressed = pressing
                }
            },
            perform: {}
        )
        .onAppear {
            withAnimation(
                .linear(duration: 2)
                .repeatForever(autoreverses: false)
            ) {
                shimmerOffset = 400
            }
        }
    }
}

// MARK: - Purchase Features View
struct PurchaseFeaturesView: View {
    @State private var animatedFeatures: Set<Int> = []
    
    private let features = [
        (icon: "bolt.fill", text: LocalizedStringKey.instantDelivery, color: ModernTheme.tertiary),
        (icon: "lock.fill", text: LocalizedStringKey.securePayment, color: ModernTheme.success),
        (icon: "arrow.triangle.2.circlepath", text: LocalizedStringKey.restorePurchases, color: ModernTheme.info)
    ]
    
    var body: some View {
        VStack(spacing: ModernTheme.Spacing.sm) {
            ForEach(Array(features.enumerated()), id: \.offset) { index, feature in
                HStack(spacing: ModernTheme.Spacing.md) {
                    ZStack {
                        Circle()
                            .fill(feature.color.opacity(0.1))
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: feature.icon)
                            .font(.system(size: 20))
                            .foregroundColor(feature.color)
                            .scaleEffect(animatedFeatures.contains(index) ? 1.1 : 1.0)
                    }
                    
                    Text(LocalizationManager.shared.string(for: feature.text))
                        .font(ModernTheme.Typography.callout)
                        .foregroundColor(ModernTheme.textPrimary)
                    
                    Spacer()
                }
                .opacity(animatedFeatures.contains(index) ? 1 : 0)
                .offset(x: animatedFeatures.contains(index) ? 0 : -30)
                .onAppear {
                    withAnimation(
                        .spring(response: 0.5, dampingFraction: 0.7)
                        .delay(Double(index) * 0.1)
                    ) {
                        animatedFeatures.insert(index)
                    }
                }
            }
        }
        .padding(ModernTheme.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.large)
                .fill(ModernTheme.primary.opacity(0.05))
        )
    }
}

// MARK: - Luxury Restore Button
struct LuxuryRestoreButton: View {
    let isLoading: Bool
    let onRestore: () -> Void
    
    var body: some View {
        Button(action: onRestore) {
            HStack(spacing: ModernTheme.Spacing.sm) {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .font(.system(size: 16))
                Text(LocalizationManager.shared.string(for: .restorePurchases))
                    .font(ModernTheme.Typography.callout)
            }
            .foregroundColor(ModernTheme.primary)
            .padding(.vertical, ModernTheme.Spacing.sm)
            .padding(.horizontal, ModernTheme.Spacing.lg)
            .background(
                Capsule()
                    .stroke(ModernTheme.primary, lineWidth: 1)
            )
        }
        .disabled(isLoading)
    }
}

// MARK: - Luxury Loading View
struct LuxuryLoadingView: View {
    @State private var rotationAngle: Double = 0
    
    var body: some View {
        VStack(spacing: ModernTheme.Spacing.lg) {
            ZStack {
                ForEach(0..<3) { index in
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [
                                    ModernTheme.secondary.opacity(0.3),
                                    ModernTheme.tertiary.opacity(0.1)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            lineWidth: 3
                        )
                        .frame(
                            width: 60 + CGFloat(index * 20),
                            height: 60 + CGFloat(index * 20)
                        )
                        .rotationEffect(.degrees(rotationAngle + Double(index * 120)))
                }
            }
            .onAppear {
                withAnimation(
                    .linear(duration: 3)
                    .repeatForever(autoreverses: false)
                ) {
                    rotationAngle = 360
                }
            }
            
            Text(localized(.loading))
                .font(ModernTheme.Typography.body)
                .foregroundColor(ModernTheme.textSecondary)
        }
        .frame(height: 300)
    }
}

// MARK: - Empty Products View
struct EmptyProductsView: View {
    let onRetry: () -> Void
    @EnvironmentObject var localizationManager: LocalizationManager
    @State private var iconScale: CGFloat = 1.0
    
    var body: some View {
        VStack(spacing: ModernTheme.Spacing.lg) {
            Image(systemName: "wifi.exclamationmark")
                .font(.system(size: 60))
                .foregroundStyle(ModernTheme.primaryGradient)
                .scaleEffect(iconScale)
                .onAppear {
                    withAnimation(
                        .easeInOut(duration: 1.5)
                        .repeatForever(autoreverses: true)
                    ) {
                        iconScale = 1.1
                    }
                }
            
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
                    .background(ModernTheme.primaryGradient)
                    .cornerRadius(ModernTheme.CornerRadius.full)
                    .shadow(
                        color: ModernTheme.Shadow.colored.color,
                        radius: ModernTheme.Shadow.colored.radius,
                        x: 0,
                        y: ModernTheme.Shadow.colored.y
                    )
            }
        }
        .frame(height: 300)
    }
}

// MARK: - Success Overlay
struct SuccessOverlay: View {
    let creditsAdded: Int
    let confettiCounter: Int
    @EnvironmentObject var localizationManager: LocalizationManager
    @State private var scale = 0.5
    @State private var viewOpacity = 0.0
    @State private var checkmarkScale = 0.0
    
    var body: some View {
        ZStack {
            // Background blur
            Color.black.opacity(0.7)
                .ignoresSafeArea()
                .opacity(viewOpacity)
            
            // Success Card
            VStack(spacing: ModernTheme.Spacing.xl) {
                // Animated Checkmark
                ZStack {
                    Circle()
                        .fill(ModernTheme.success.opacity(0.1))
                        .frame(width: 140, height: 140)
                        .scaleEffect(scale)
                    
                    Circle()
                        .fill(ModernTheme.success)
                        .frame(width: 120, height: 120)
                        .overlay(
                            Image(systemName: "checkmark")
                                .font(.system(size: 60, weight: .bold))
                                .foregroundColor(.white)
                                .scaleEffect(checkmarkScale)
                        )
                        .shadow(
                            color: ModernTheme.success.opacity(0.5),
                            radius: 20,
                            x: 0,
                            y: 10
                        )
                }
                
                // Success Text
                VStack(spacing: ModernTheme.Spacing.sm) {
                    Text(localized(.purchaseSuccess))
                        .font(ModernTheme.Typography.title)
                        .foregroundColor(.white)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "plus")
                            .font(.system(size: 24, weight: .bold))
                        Text("\(creditsAdded)")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .contentTransition(.numericText())
                        Text(localized(.credits))
                            .font(ModernTheme.Typography.headline)
                    }
                    .foregroundStyle(ModernTheme.secondaryGradient)
                }
            }
            .scaleEffect(scale)
            .opacity(viewOpacity)
            
            // Confetti
            ConfettiView(counter: confettiCounter)
                .allowsHitTesting(false)
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                scale = 1.0
                viewOpacity = 1.0
            }
            
            withAnimation(
                .spring(response: 0.5, dampingFraction: 0.6)
                .delay(0.3)
            ) {
                checkmarkScale = 1.0
            }
        }
    }
}

// MARK: - Confetti View
struct ConfettiView: View {
    let counter: Int
    @State private var confettiPieces: [ConfettiPiece] = []
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(confettiPieces) { piece in
                    ConfettiPieceView(piece: piece)
                }
            }
            .onAppear {
                createConfetti(in: geometry.size)
            }
            .onChange(of: counter) { _ in
                createConfetti(in: geometry.size)
            }
        }
    }
    
    private func createConfetti(in size: CGSize) {
        confettiPieces = (0..<50).map { _ in
            ConfettiPiece(
                position: CGPoint(
                    x: CGFloat.random(in: 0...size.width),
                    y: -50
                ),
                color: [
                    ModernTheme.primary,
                    ModernTheme.secondary,
                    ModernTheme.tertiary,
                    ModernTheme.success,
                    ModernTheme.info
                ].randomElement()!,
                size: CGFloat.random(in: 8...16),
                velocity: CGFloat.random(in: 100...300),
                angularVelocity: Double.random(in: -180...180)
            )
        }
    }
}

struct ConfettiPiece: Identifiable {
    let id = UUID()
    let position: CGPoint
    let color: Color
    let size: CGFloat
    let velocity: CGFloat
    let angularVelocity: Double
}

struct ConfettiPieceView: View {
    let piece: ConfettiPiece
    @State private var position: CGPoint
    @State private var rotation: Double = 0
    @State private var opacity: Double = 1
    
    init(piece: ConfettiPiece) {
        self.piece = piece
        _position = State(initialValue: piece.position)
    }
    
    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(piece.color)
            .frame(width: piece.size, height: piece.size * 1.5)
            .rotationEffect(.degrees(rotation))
            .position(position)
            .opacity(opacity)
            .onAppear {
                withAnimation(.linear(duration: 3)) {
                    position.y = UIScreen.main.bounds.height + 100
                    rotation = piece.angularVelocity * 3
                    opacity = 0
                }
            }
    }
}

// MARK: - Close Button
struct CloseButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(ModernTheme.glassWhite)
                    .frame(width: 32, height: 32)
                    .background(
                        .ultraThinMaterial,
                        in: Circle()
                    )
                
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(ModernTheme.textSecondary)
            }
        }
    }
}

// MARK: - Footer View
struct PurchaseFooterView: View {
    @EnvironmentObject var localizationManager: LocalizationManager
    
    var body: some View {
        VStack(spacing: ModernTheme.Spacing.sm) {
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 24))
                .foregroundColor(ModernTheme.textTertiary)
            
            Text(localizationManager.currentLanguage == .turkish ?
                 "Tüm ödemeler Apple tarafından güvenle işlenir" :
                 "All payments are securely processed by Apple")
                .font(ModernTheme.Typography.caption)
                .foregroundColor(ModernTheme.textTertiary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, ModernTheme.Spacing.xl)
    }
}

// MARK: - Preview
#Preview {
    PurchaseView()
        .environmentObject(LocalizationManager.shared)
}
