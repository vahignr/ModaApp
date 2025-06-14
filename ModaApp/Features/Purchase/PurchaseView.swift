//
//  PurchaseView.swift
//  ModaApp
//
//  Luxury purchase screen with animations and confetti
//

import SwiftUI
import StoreKit

struct PurchaseView: View {
    @StateObject private var storeManager  = StoreKitManager.shared
    @StateObject private var creditsManager = CreditsManager.shared
    @EnvironmentObject private var localizationManager: LocalizationManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedProduct: Product?
    @State private var showPurchaseError = false
    @State private var showSuccessAnimation = false
    @State private var purchasedCredits = 0
    @State private var confettiCounter   = 0
    @State private var headerScale: CGFloat = 1
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Animated background
                PurchaseBackground()
                
                ScrollView {
                    VStack(spacing: ModernTheme.Spacing.xl) {
                        // Header
                        LuxuryPurchaseHeader(
                            currentCredits: creditsManager.remainingCredits,
                            scale: headerScale
                        )
                        .padding(.top, ModernTheme.Spacing.lg)
                        .onAppear {
                            withAnimation(
                                .spring(response: 2, dampingFraction: 0.6)
                                    .repeatForever(autoreverses: true)
                            ) { headerScale = 1.05 }
                        }
                        
                        // Products
                        if storeManager.isLoading && storeManager.products.isEmpty {
                            LuxuryLoadingView()
                        } else if storeManager.products.isEmpty {
                            EmptyProductsView {
                                Task { await storeManager.loadProducts() }
                            }
                        } else {
                            LuxuryProductsGrid(
                                products: storeManager.products,
                                selectedProduct: $selectedProduct,
                                storeManager: storeManager
                            )
                        }
                        
                        // Purchase button
                        if let selected = selectedProduct {
                            LuxuryPurchaseButton(
                                product: selected,
                                isLoading: storeManager.isLoading,
                                onPurchase: { purchase(selected) }
                            )
                            .padding(.horizontal)
                        }
                        
                        // Feature list
                        PurchaseFeaturesView()
                            .padding(.horizontal)
                        
                        // Restore
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
                
                // Success overlay
                if showSuccessAnimation {
                    SuccessOverlay(
                        creditsAdded: purchasedCredits,
                        confettiCounter: confettiCounter
                    )
                    .transition(.scale.combined(with: AnyTransition.opacity)) // disambiguated
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
            .onChange(of: storeManager.products) { _ in selectDefaultProduct() }
        }
    }
    
    // MARK: - Purchase helpers
    private func purchase(_ product: Product) {
        Task {
            switch await storeManager.purchase(product) {
            case .success(let credits):
                purchasedCredits = credits
                confettiCounter += 1
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    showSuccessAnimation = true
                }
                UINotificationFeedbackGenerator().notificationOccurred(.success)
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) { dismiss() }
                
            case .failed:
                showPurchaseError = true
                UINotificationFeedbackGenerator().notificationOccurred(.error)
                
            case .cancelled, .pending, .restored:
                break
            }
        }
    }
    
    private func restorePurchases() {
        Task {
            switch await storeManager.restorePurchases() {
            case .restored(let totalCredits):
                if totalCredits > 0 {
                    purchasedCredits = totalCredits
                    confettiCounter += 1
                    withAnimation { showSuccessAnimation = true }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) { dismiss() }
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
        guard selectedProduct == nil,
              let popular = storeManager.products.first(where: {
                  storeManager.creditProduct(for: $0)?.isPopular == true
              })
        else { return }
        selectedProduct = popular
    }
}

// MARK: - Background
struct PurchaseBackground: View {
    @State private var animateGradient = false
    @State private var sparklePositions: [CGPoint] = []
    
    var body: some View {
        ZStack {
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
            
            ForEach(sparklePositions.indices, id: \.self) { i in
                Image(systemName: "sparkle")
                    .font(.system(size: CGFloat.random(in: 8...20)))
                    .foregroundColor(ModernTheme.tertiary.opacity(0.3))
                    .position(sparklePositions[i])
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

// MARK: - Header
struct LuxuryPurchaseHeader: View {
    let currentCredits: Int
    let scale: CGFloat
    @EnvironmentObject private var localizationManager: LocalizationManager
    @State private var iconRotation = 0.0
    
    var body: some View {
        VStack(spacing: ModernTheme.Spacing.lg) {
            ZStack {
                Circle()
                    .fill(ModernTheme.secondaryGradient)
                    .frame(width: 120, height: 120)
                    .blur(radius: 30)
                    .opacity(0.5)
                    .scaleEffect(scale)
                
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
                
                Text(localizationManager.currentLanguage == .turkish
                     ? "Her analiz 1 kredi harcar"
                     : "Each analysis uses 1 credit")
                    .font(ModernTheme.Typography.caption)
                    .foregroundColor(ModernTheme.textTertiary)
            }
        }
    }
}

// MARK: - Products grid
struct LuxuryProductsGrid: View {
    let products: [Product]
    @Binding var selectedProduct: Product?
    let storeManager: StoreKitManager
    
    var body: some View {
        VStack(spacing: ModernTheme.Spacing.md) {
            ForEach(Array(products.enumerated()), id: \.element.id) { i, product in
                LuxuryProductCard(
                    product: product,
                    isSelected: selectedProduct?.id == product.id,
                    creditProduct: storeManager.creditProduct(for: product),
                    animationDelay: Double(i) * 0.1
                ) { selectedProduct = product }
            }
        }
    }
}

// MARK: - Product card
struct LuxuryProductCard: View {
    let product: Product
    let isSelected: Bool
    let creditProduct: StoreKitProducts.Credits?
    let animationDelay: Double
    let onTap: () -> Void
    
    @EnvironmentObject private var localizationManager: LocalizationManager
    @State private var isPressed = false
    @State private var appeared  = false
    @State private var badgeScale: CGFloat = 1
    
    var body: some View {
        Button(action: {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            onTap()
        }) {
            HStack(spacing: ModernTheme.Spacing.lg) {
                ZStack {
                    Circle()
                        .fill(
                            isSelected
                            ? ModernTheme.secondaryGradient
                            : LinearGradient(
                                colors: [ModernTheme.lightBlush, ModernTheme.accent],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 80, height: 80)
                        .shadow(
                            color: isSelected ? ModernTheme.Shadow.colored.color : .clear,
                            radius: 12, x: 0, y: 6
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
                .scaleEffect(isSelected ? 1.05 : 1)
                
                VStack(alignment: .leading, spacing: ModernTheme.Spacing.xs) {
                    HStack {
                        Text(product.displayName)
                            .font(ModernTheme.Typography.headline)
                            .foregroundColor(ModernTheme.textPrimary)
                        
                        if let creditProduct {
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
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text(product.displayPrice)
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            isSelected
                            ? ModernTheme.primaryGradient
                            : LinearGradient(colors: [ModernTheme.textPrimary], startPoint: .leading, endPoint: .trailing)
                        )
                    
                    if let creditProduct, creditProduct.creditAmount > 0 {
                        let pricePer = product.price / Decimal(creditProduct.creditAmount)
                        Text(localizationManager.currentLanguage == .turkish
                             ? "kredi başı \(pricePer.formatted(.currency(code: product.priceFormatStyle.currencyCode)))"
                             : "\(pricePer.formatted(.currency(code: product.priceFormatStyle.currencyCode)))/credit")
                            .font(ModernTheme.Typography.caption2)
                            .foregroundColor(ModernTheme.textTertiary)
                    }
                }
            }
            .padding(ModernTheme.Spacing.lg)
            .background(
                RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.xl)
                    .fill(isSelected ? ModernTheme.glassWhite : ModernTheme.surface)
                    .background(
                        isSelected
                        ? AnyView(RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.xl).fill(.ultraThinMaterial))
                        : AnyView(Color.clear)
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.xl)
                    .stroke(
                        isSelected
                        ? ModernTheme.secondaryGradient
                        : LinearGradient(colors: [ModernTheme.glassBorder], startPoint: .leading, endPoint: .trailing),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
            .shadow(
                color: isSelected ? ModernTheme.Shadow.colored.color : ModernTheme.Shadow.small.color,
                radius: isSelected ? 16 : ModernTheme.Shadow.small.radius,
                x: 0,
                y: isSelected ? 8 : ModernTheme.Shadow.small.y
            )
            .scaleEffect(isPressed ? 0.98 : 1)
            .offset(x: appeared ? 0 : -50)
            .opacity(appeared ? 1 : 0)
        }
        .buttonStyle(.plain)
        .onLongPressGesture(
            minimumDuration: .infinity,
            maximumDistance: .infinity,
            pressing: { p in
                withAnimation(ModernTheme.springAnimation) { isPressed = p }
            }, perform: { }
        )
        .onAppear {
            withAnimation(
                .spring(response: 0.6, dampingFraction: 0.7).delay(animationDelay)
            ) { appeared = true }
            
            if creditProduct?.isPopular == true || creditProduct?.isBestValue == true {
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    badgeScale = 1.1
                }
            }
        }
    }
}

// MARK: - Premium badge
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
            .shadow(color: color.opacity(0.3), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Purchase button
struct LuxuryPurchaseButton: View {
    let product: Product
    let isLoading: Bool
    let onPurchase: () -> Void
    
    @State private var isPressed = false
    @State private var shimmerOffset: CGFloat = -200
    
    var body: some View {
        Button(action: onPurchase) {
            ZStack {
                RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.full)
                    .fill(ModernTheme.primaryGradient)
                    .overlay(
                        LinearGradient(
                            colors: [.clear, .white.opacity(0.3), .clear],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .frame(width: 100)
                        .offset(x: shimmerOffset)
                        .mask(RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.full))
                    )
                
                if isLoading {
                    HStack(spacing: ModernTheme.Spacing.sm) {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .tint(.white)
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
            .scaleEffect(isPressed ? 0.98 : 1)
        }
        .buttonStyle(.plain)
        .disabled(isLoading)
        .onLongPressGesture(
            minimumDuration: .infinity,
            maximumDistance: .infinity,
            pressing: { p in
                withAnimation(ModernTheme.springAnimation) { isPressed = p }
            }, perform: { }
        )
        .onAppear {
            withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                shimmerOffset = 400
            }
        }
    }
}

// MARK: - Feature list
struct PurchaseFeaturesView: View {
    @State private var animatedFeatures: Set<Int> = []
    
    private let features = [
        (icon: "bolt.fill",  text: LocalizedStringKey.instantDelivery,  color: ModernTheme.tertiary),
        (icon: "lock.fill",  text: LocalizedStringKey.securePayment,    color: ModernTheme.success),
        (icon: "arrow.triangle.2.circlepath", text: LocalizedStringKey.restorePurchases, color: ModernTheme.info)
    ]
    
    var body: some View {
        VStack(spacing: ModernTheme.Spacing.sm) {
            ForEach(Array(features.enumerated()), id: \.offset) { index, feature in
                HStack(spacing: ModernTheme.Spacing.md) {
                    ZStack {
                        Circle()
                            .fill(feature.color)           // disambiguated
                            .opacity(0.1)
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: feature.icon)
                            .font(.system(size: 20))
                            .foregroundColor(feature.color)
                            .scaleEffect(animatedFeatures.contains(index) ? 1.1 : 1)
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
                        _ = animatedFeatures.insert(index) // discard tuple to keep Void
                    }
                }
            }
        }
        .padding(ModernTheme.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.large)
                .fill(ModernTheme.primary)          // disambiguated
                .opacity(0.05)
        )
    }
}

// MARK: - Restore button
struct LuxuryRestoreButton: View {
    let isLoading: Bool
    let onRestore: () -> Void
    
    var body: some View {
        Button(action: onRestore) {
            HStack(spacing: ModernTheme.Spacing.sm) {
                Image(systemName: "arrow.triangle.2.circlepath").font(.system(size: 16))
                Text(LocalizationManager.shared.string(for: .restorePurchases))
                    .font(ModernTheme.Typography.callout)
            }
            .foregroundColor(ModernTheme.primary)
            .padding(.vertical, ModernTheme.Spacing.sm)
            .padding(.horizontal, ModernTheme.Spacing.lg)
            .background(
                Capsule().stroke(ModernTheme.primary, lineWidth: 1)
            )
        }
        .disabled(isLoading)
    }
}

// MARK: - Loading view
struct LuxuryLoadingView: View {
    @State private var rotationAngle = 0.0
    
    var body: some View {
        VStack(spacing: ModernTheme.Spacing.lg) {
            ZStack {
                ForEach(0..<3) { i in
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [ModernTheme.secondary.opacity(0.3), ModernTheme.tertiary.opacity(0.1)],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            lineWidth: 3
                        )
                        .frame(width: 60 + CGFloat(i * 20), height: 60 + CGFloat(i * 20))
                        .rotationEffect(.degrees(rotationAngle + Double(i * 120)))
                }
            }
            .onAppear {
                withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
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

// MARK: - Empty products
struct EmptyProductsView: View {
    let onRetry: () -> Void
    @EnvironmentObject private var localizationManager: LocalizationManager
    @State private var iconScale: CGFloat = 1
    
    var body: some View {
        VStack(spacing: ModernTheme.Spacing.lg) {
            Image(systemName: "wifi.exclamationmark")
                .font(.system(size: 60))
                .foregroundStyle(ModernTheme.primaryGradient)
                .scaleEffect(iconScale)
                .onAppear {
                    withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                        iconScale = 1.1
                    }
                }
            
            Text(localizationManager.currentLanguage == .turkish
                 ? "Ürünler yüklenemedi"
                 : "Could not load products")
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

// MARK: - Success overlay
struct SuccessOverlay: View {
    let creditsAdded: Int
    let confettiCounter: Int
    @EnvironmentObject private var localizationManager: LocalizationManager
    @State private var scale        = 0.5
    @State private var viewOpacity  = 0.0
    @State private var checkmarkScale = 0.0
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.7).ignoresSafeArea().opacity(viewOpacity)
            
            VStack(spacing: ModernTheme.Spacing.xl) {
                ZStack {
                    Circle()
                        .fill(ModernTheme.success) // disambiguated
                        .opacity(0.1)
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
                        .shadow(color: ModernTheme.success.opacity(0.5), radius: 20, x: 0, y: 10)
                }
                
                VStack(spacing: ModernTheme.Spacing.sm) {
                    Text(localized(.purchaseSuccess))
                        .font(ModernTheme.Typography.title)
                        .foregroundColor(.white)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "plus").font(.system(size: 24, weight: .bold))
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
            
            ConfettiView(counter: confettiCounter).allowsHitTesting(false)
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                scale = 1
                viewOpacity = 1
            }
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.3)) {
                checkmarkScale = 1
            }
        }
    }
}

// MARK: - Confetti
struct ConfettiPiece: Identifiable {
    let id = UUID()
    var position: CGPoint
    let color: Color
    let size: CGFloat
    let velocity: CGFloat
    let angularVelocity: Double
}

struct ConfettiView: View {
    let counter: Int
    @State private var pieces: [ConfettiPiece] = []
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(pieces) { piece in
                    ConfettiPieceView(piece: piece)
                }
            }
            .onAppear { spawn(in: geo.size) }
            .onChange(of: counter) { _ in spawn(in: geo.size) }
        }
    }
    
    private func spawn(in size: CGSize) {
        pieces = (0..<50).map { _ in
            ConfettiPiece(
                position: CGPoint(x: CGFloat.random(in: 0...size.width), y: -50),
                color: [
                    ModernTheme.primary, ModernTheme.secondary, ModernTheme.tertiary,
                    ModernTheme.success, ModernTheme.info
                ].randomElement()!,
                size: CGFloat.random(in: 8...16),
                velocity: CGFloat.random(in: 100...300),
                angularVelocity: Double.random(in: -180...180)
            )
        }
    }
}

struct ConfettiPieceView: View {
    let piece: ConfettiPiece
    @State private var position: CGPoint
    @State private var rotation = 0.0
    @State private var opacity  = 1.0
    
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

// MARK: - Close button
struct CloseButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(ModernTheme.glassWhite)
                    .frame(width: 32, height: 32)
                    .background(.ultraThinMaterial, in: Circle())
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(ModernTheme.textSecondary)
            }
        }
    }
}

// MARK: - Footer
struct PurchaseFooterView: View {
    @EnvironmentObject private var localizationManager: LocalizationManager
    
    var body: some View {
        VStack(spacing: ModernTheme.Spacing.sm) {
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 24))
                .foregroundColor(ModernTheme.textTertiary)
            
            Text(localizationManager.currentLanguage == .turkish
                 ? "Tüm ödemeler Apple tarafından güvenle işlenir"
                 : "All payments are securely processed by Apple")
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
