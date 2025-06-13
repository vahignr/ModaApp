//
//  ContentView.swift
//  ModaApp
//
//  Luxury fashion analysis flow with animated steps
//

import SwiftUI

struct ContentView: View {
    
    @StateObject private var vm = ImageCaptureViewModel()
    @StateObject private var creditsManager = CreditsManager.shared
    @EnvironmentObject var localizationManager: LocalizationManager
    @State private var showCreditsAnimation = false
    @State private var currentStep: Step = .selectImage
    @State private var showPurchaseView = false
    @Environment(\.dismiss) private var dismiss
    
    enum Step: Int, CaseIterable {
        case selectImage = 0
        case selectOccasion = 1
        case analyzing = 2
        case results = 3
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Animated background
                LuxuryBackground()
                
                ScrollView {
                    VStack(spacing: 0) {
                        // Animated Step Indicator
                        AnimatedStepIndicator(currentStep: currentStep)
                            .padding(.horizontal)
                            .padding(.top, ModernTheme.Spacing.md)
                            .padding(.bottom, ModernTheme.Spacing.lg)
                        
                        // Main Content with transitions
                        ZStack {
                            ForEach(Step.allCases, id: \.self) { step in
                                Group {
                                    switch step {
                                    case .selectImage:
                                        ImageSelectionView(vm: vm, currentStep: $currentStep)
                                    case .selectOccasion:
                                        OccasionSelectionView(vm: vm, currentStep: $currentStep)
                                    case .analyzing:
                                        AnalyzingView()
                                    case .results:
                                        if let analysis = vm.fashionAnalysis {
                                            FashionResultsView(
                                                analysis: analysis,
                                                audioManager: vm.audio,
                                                audioURL: vm.audioURL,
                                                isSearchingImages: vm.isSearchingImages,
                                                onNewAnalysis: {
                                                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                                        vm.resetAll()
                                                        currentStep = .selectImage
                                                    }
                                                }
                                            )
                                        }
                                    }
                                }
                                .opacity(currentStep == step ? 1 : 0)
                                .offset(x: offsetForStep(step))
                                .scaleEffect(currentStep == step ? 1 : 0.9)
                            }
                        }
                        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: currentStep)
                        .padding(.bottom, ModernTheme.Spacing.xxl)
                    }
                }
            }
            .navigationTitle(localized(.modaAnalyzer))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .medium))
                            Text(localized(.home))
                                .font(.system(size: 16, weight: .medium))
                        }
                        .foregroundColor(ModernTheme.primary)
                    }
                }
            }
        }
        .onChange(of: vm.processingState) { newState in
            switch newState {
            case .idle:
                break
            case .analyzing:
                if currentStep == .selectOccasion {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        currentStep = .analyzing
                    }
                }
            case .searchingImages:
                break
            case .complete:
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    currentStep = .results
                }
            }
        }
        .alert(localized(.noCredits), isPresented: $vm.showPurchaseView) {
            Button(localized(.buyCredits)) {
                showPurchaseView = true
            }
            Button(localized(.later), role: .cancel) { }
        } message: {
            Text(localized(.needCreditsMessage))
        }
        .alert(localized(.error), isPresented: .constant(vm.error != nil)) {
            Button(localized(.ok)) { vm.error = nil }
        } message: {
            Text(vm.error ?? "")
        }
        .fullScreenCover(isPresented: $showPurchaseView) {
            PurchaseView()
                .environmentObject(localizationManager)
        }
    }
    
    private func offsetForStep(_ step: Step) -> CGFloat {
        let diff = step.rawValue - currentStep.rawValue
        return CGFloat(diff) * UIScreen.main.bounds.width * 0.3
    }
}

// MARK: - Luxury Background
struct LuxuryBackground: View {
    @State private var animateGradient = false
    
    var body: some View {
        ZStack {
            ModernTheme.background
                .ignoresSafeArea()
            
            // Animated gradient overlay
            LinearGradient(
                colors: [
                    ModernTheme.secondary.opacity(0.03),
                    ModernTheme.tertiary.opacity(0.05),
                    ModernTheme.primary.opacity(0.02)
                ],
                startPoint: animateGradient ? .topLeading : .bottomTrailing,
                endPoint: animateGradient ? .bottomTrailing : .topLeading
            )
            .ignoresSafeArea()
            .onAppear {
                withAnimation(.linear(duration: 15).repeatForever(autoreverses: true)) {
                    animateGradient.toggle()
                }
            }
        }
    }
}

// MARK: - Animated Step Indicator
struct AnimatedStepIndicator: View {
    let currentStep: ContentView.Step
    @EnvironmentObject var localizationManager: LocalizationManager
    @State private var animatedProgress: CGFloat = 0
    
    private var steps: [(ContentView.Step, String, LocalizedStringKey)] {
        [
            (.selectImage, "camera.fill", .photo),
            (.selectOccasion, "calendar", .occasion),
            (.analyzing, "sparkles", .style),
            (.results, "checkmark.circle", .results)
        ]
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background track
                RoundedRectangle(cornerRadius: 2)
                    .fill(ModernTheme.platinum.opacity(0.3))
                    .frame(height: 4)
                    .frame(width: geometry.size.width - 40)
                    .position(x: geometry.size.width / 2, y: 25)
                
                // Animated progress track
                RoundedRectangle(cornerRadius: 2)
                    .fill(ModernTheme.primaryGradient)
                    .frame(height: 4)
                    .frame(width: max(0, (geometry.size.width - 40) * animatedProgress))
                    .position(x: 20 + (geometry.size.width - 40) * animatedProgress / 2, y: 25)
                    .animation(.spring(response: 0.5, dampingFraction: 0.8), value: animatedProgress)
                
                // Step indicators
                HStack(spacing: 0) {
                    ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                        StepCircle(
                            step: step,
                            isActive: currentStep.rawValue >= step.0.rawValue,
                            isCurrent: currentStep == step.0,
                            geometry: geometry
                        )
                        
                        if index < steps.count - 1 {
                            Spacer()
                        }
                    }
                }
            }
        }
        .frame(height: 80)
        .onChange(of: currentStep) { _ in
            updateProgress()
        }
        .onAppear {
            updateProgress()
        }
    }
    
    private func updateProgress() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            animatedProgress = CGFloat(currentStep.rawValue) / CGFloat(steps.count - 1)
        }
    }
}

// MARK: - Step Circle Component
struct StepCircle: View {
    let step: (ContentView.Step, String, LocalizedStringKey)
    let isActive: Bool
    let isCurrent: Bool
    let geometry: GeometryProxy
    @EnvironmentObject var localizationManager: LocalizationManager
    @State private var pulseAnimation = false
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                // Pulse effect for current step
                if isCurrent {
                    Circle()
                        .fill(ModernTheme.primary.opacity(0.2))
                        .frame(width: 50, height: 50)
                        .scaleEffect(pulseAnimation ? 1.2 : 1.0)
                        .opacity(pulseAnimation ? 0 : 1)
                        .animation(
                            .easeOut(duration: 1.5)
                            .repeatForever(autoreverses: false),
                            value: pulseAnimation
                        )
                }
                
                // Main circle
                Circle()
                    .fill(isActive ? ModernTheme.primaryGradient : Color(ModernTheme.platinum))
                    .frame(width: 40, height: 40)
                    .shadow(
                        color: isActive ? ModernTheme.Shadow.colored.color : Color.clear,
                        radius: 8,
                        x: 0,
                        y: 4
                    )
                
                // Icon
                Image(systemName: step.1)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(isActive ? .white : ModernTheme.textTertiary)
                    .scaleEffect(isCurrent ? 1.1 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isCurrent)
            }
            
            // Label
            Text(localized(step.2))
                .font(ModernTheme.Typography.caption2)
                .fontWeight(isCurrent ? .semibold : .regular)
                .foregroundColor(isActive ? ModernTheme.primary : ModernTheme.textTertiary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: geometry.size.width / CGFloat(4))
        .onAppear {
            if isCurrent {
                pulseAnimation = true
            }
        }
        .onChange(of: isCurrent) { newValue in
            pulseAnimation = newValue
        }
    }
}

// MARK: - Image Selection View
struct ImageSelectionView: View {
    @ObservedObject var vm: ImageCaptureViewModel
    @Binding var currentStep: ContentView.Step
    @State private var imageScale: CGFloat = 1.0
    @State private var imageRotation: Double = 0
    
    var body: some View {
        VStack(spacing: ModernTheme.Spacing.xl) {
            // Title Section
            VStack(spacing: ModernTheme.Spacing.sm) {
                Text(localized(.uploadYourOutfit))
                    .font(ModernTheme.Typography.title2)
                    .foregroundColor(ModernTheme.textPrimary)
                
                Text(localized(.takePhotoOrSelect))
                    .font(ModernTheme.Typography.body)
                    .foregroundColor(ModernTheme.textSecondary)
            }
            .padding(.top, ModernTheme.Spacing.lg)
            
            // Image Selection Area
            ZStack {
                if let image = vm.selectedImage {
                    // Selected Image with effects
                    VStack(spacing: ModernTheme.Spacing.lg) {
                        ZStack {
                            // Glow background
                            RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.xl)
                                .fill(ModernTheme.secondary.opacity(0.1))
                                .frame(width: 280, height: 380)
                                .blur(radius: 30)
                            
                            // Image container
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: 260, maxHeight: 360)
                                .clipShape(RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.large))
                                .overlay(
                                    RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.large)
                                        .stroke(ModernTheme.glassBorder, lineWidth: 1)
                                )
                                .shadow(
                                    color: ModernTheme.Shadow.large.color,
                                    radius: ModernTheme.Shadow.large.radius,
                                    x: 0,
                                    y: ModernTheme.Shadow.large.y
                                )
                                .scaleEffect(imageScale)
                                .rotationEffect(.degrees(imageRotation))
                                .onAppear {
                                    withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                                        imageScale = 1.05
                                        imageRotation = -2
                                    }
                                }
                        }
                        
                        // Change photo button
                        ImagePicker(selectedImage: $vm.selectedImage)
                            .padding(.horizontal, ModernTheme.Spacing.xl)
                    }
                } else {
                    // Empty state with animation
                    EmptyImageState(selectedImage: $vm.selectedImage)
                }
            }
            
            // Continue Button
            if vm.selectedImage != nil {
                PrimaryButton(
                    title: localized(.continueToOccasion),
                    systemImage: "arrow.right",
                    style: .primary,
                    action: {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            currentStep = .selectOccasion
                        }
                    }
                )
                .padding(.horizontal, ModernTheme.Spacing.xl)
                .transition(.scale.combined(with: .opacity))
            }
            
            Spacer()
        }
    }
}

// MARK: - Empty Image State
struct EmptyImageState: View {
    @Binding var selectedImage: UIImage?
    @State private var iconBounce = false
    
    var body: some View {
        VStack(spacing: ModernTheme.Spacing.xl) {
            // Animated icon container
            ZStack {
                // Ripple effect
                ForEach(0..<3) { index in
                    Circle()
                        .stroke(ModernTheme.secondary.opacity(0.3 - Double(index) * 0.1), lineWidth: 2)
                        .frame(width: 100 + CGFloat(index * 30), height: 100 + CGFloat(index * 30))
                        .scaleEffect(iconBounce ? 1.2 : 1.0)
                        .opacity(iconBounce ? 0 : 1)
                        .animation(
                            .easeOut(duration: 2)
                            .repeatForever(autoreverses: false)
                            .delay(Double(index) * 0.4),
                            value: iconBounce
                        )
                }
                
                // Main icon
                Circle()
                    .fill(ModernTheme.primaryGradient.opacity(0.1))
                    .frame(width: 100, height: 100)
                    .overlay(
                        Image(systemName: "camera.macro")
                            .font(.system(size: 50))
                            .foregroundStyle(ModernTheme.primaryGradient)
                            .symbolEffect(.bounce, value: iconBounce)
                    )
            }
            .onAppear {
                iconBounce = true
            }
            
            Text(localized(.selectYourOutfitPhoto))
                .font(ModernTheme.Typography.headline)
                .foregroundColor(ModernTheme.textPrimary)
            
            ImagePicker(selectedImage: $selectedImage)
                .padding(.horizontal, ModernTheme.Spacing.xl)
        }
        .padding(.vertical, ModernTheme.Spacing.xxl)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.xl)
                .fill(ModernTheme.glassWhite)
                .background(
                    .ultraThinMaterial,
                    in: RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.xl)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.xl)
                        .stroke(style: StrokeStyle(lineWidth: 2, dash: [10, 5]))
                        .foregroundColor(ModernTheme.secondary.opacity(0.3))
                )
        )
        .padding(.horizontal)
    }
}

// MARK: - Occasion Selection View (Enhanced)
struct OccasionSelectionView: View {
    @ObservedObject var vm: ImageCaptureViewModel
    @Binding var currentStep: ContentView.Step
    @State private var showPurchaseView = false
    @EnvironmentObject var creditsManager: CreditsManager
    @EnvironmentObject var localizationManager: LocalizationManager
    
    var body: some View {
        VStack(spacing: ModernTheme.Spacing.lg) {
            // Action Bar with glass morphism
            HStack(spacing: ModernTheme.Spacing.md) {
                Button {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        currentStep = .selectImage
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                        Text(localized(.back))
                    }
                    .font(ModernTheme.Typography.body)
                    .foregroundColor(ModernTheme.primary)
                    .padding(.horizontal, ModernTheme.Spacing.md)
                    .padding(.vertical, ModernTheme.Spacing.sm)
                    .background(
                        Capsule()
                            .fill(ModernTheme.glassWhite)
                            .background(.ultraThinMaterial, in: Capsule())
                    )
                }
                
                Spacer()
                
                // Credits Display
                CreditsButton(
                    credits: creditsManager.remainingCredits,
                    action: { showPurchaseView = true }
                )
                
                // Analyze Button
                Button {
                    vm.analyzeOutfit()
                } label: {
                    HStack(spacing: ModernTheme.Spacing.xs) {
                        Text(localized(.analyzeStyle))
                            .fontWeight(.semibold)
                        Image(systemName: "sparkles")
                            .symbolEffect(.variableColor.iterative, value: vm.canAnalyze)
                    }
                    .font(ModernTheme.Typography.body)
                    .foregroundColor(.white)
                    .padding(.horizontal, ModernTheme.Spacing.lg)
                    .padding(.vertical, ModernTheme.Spacing.sm)
                    .background(
                        Capsule()
                            .fill(vm.canAnalyze && vm.hasCredits ?
                                ModernTheme.primaryGradient :
                                LinearGradient(colors: [Color.gray], startPoint: .leading, endPoint: .trailing))
                    )
                    .shadow(
                        color: vm.canAnalyze && vm.hasCredits ? ModernTheme.Shadow.colored.color : Color.clear,
                        radius: 8,
                        x: 0,
                        y: 4
                    )
                }
                .disabled(!vm.canAnalyze || !vm.hasCredits)
            }
            .padding(.horizontal, ModernTheme.Spacing.lg)
            
            // Enhanced Occasion Selector
            OccasionSelector(
                selectedOccasion: $vm.selectedOccasion,
                customOccasion: $vm.customOccasion,
                selectedTone: $vm.selectedTone
            )
            .padding(.horizontal)
        }
        .fullScreenCover(isPresented: $showPurchaseView) {
            PurchaseView()
                .environmentObject(localizationManager)
        }
    }
}

// MARK: - Analyzing View (Enhanced)
struct AnalyzingView: View {
    @State private var dots = 0
    @State private var rotation = 0.0
    @State private var particlePositions: [CGPoint] = []
    
    var body: some View {
        VStack(spacing: ModernTheme.Spacing.xl) {
            // Animated particles around icon
            ZStack {
                // Background glow
                Circle()
                    .fill(ModernTheme.radialBlushGradient)
                    .frame(width: 200, height: 200)
                    .blur(radius: 40)
                    .scaleEffect(1.2)
                
                // Orbiting particles
                ForEach(0..<6) { index in
                    Circle()
                        .fill(ModernTheme.secondaryGradient)
                        .frame(width: 8, height: 8)
                        .offset(x: 60, y: 0)
                        .rotationEffect(.degrees(Double(index) * 60 + rotation))
                        .blur(radius: 0.5)
                }
                
                // Main icon
                ZStack {
                    Circle()
                        .fill(ModernTheme.glassWhite)
                        .frame(width: 120, height: 120)
                        .background(.ultraThinMaterial, in: Circle())
                        .overlay(
                            Circle()
                                .stroke(ModernTheme.glassBorder, lineWidth: 1)
                        )
                    
                    Image(systemName: "sparkles")
                        .font(.system(size: 50))
                        .foregroundStyle(ModernTheme.primaryGradient)
                        .symbolEffect(.variableColor.iterative.dimInactiveLayers, value: rotation)
                }
                .shadow(
                    color: ModernTheme.Shadow.large.color,
                    radius: ModernTheme.Shadow.large.radius,
                    x: 0,
                    y: ModernTheme.Shadow.large.y
                )
            }
            .onAppear {
                withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                    rotation = 360
                }
            }
            
            // Loading Text
            Text(localized(.analyzingYourStyle) + String(repeating: ".", count: dots))
                .font(ModernTheme.Typography.title2)
                .foregroundColor(ModernTheme.textPrimary)
                .onAppear {
                    Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
                        dots = (dots + 1) % 4
                    }
                }
            
            Text(localized(.aiStylistReviewing))
                .font(ModernTheme.Typography.body)
                .foregroundColor(ModernTheme.textSecondary)
        }
        .padding(.vertical, ModernTheme.Spacing.xxxl)
    }
}

// MARK: - Preview
#Preview {
    ContentView()
        .environmentObject(CreditsManager.shared)
        .environmentObject(LocalizationManager.shared)
}
