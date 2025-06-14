//
//  ContentView.swift
//  ModaApp
//
//  Updated with luxury animations and enhanced UI polish
//

import SwiftUI

struct ContentView: View {
    
    @StateObject private var vm = ImageCaptureViewModel()
    @StateObject private var creditsManager = CreditsManager.shared
    @EnvironmentObject var localizationManager: LocalizationManager
    @State private var showCreditsAnimation = false
    @State private var currentStep: Step = .selectImage
    @State private var showPurchaseView = false
    @State private var stepProgress: CGFloat = 0.25
    @Environment(\.dismiss) private var dismiss
    
    enum Step {
        case selectImage
        case selectOccasion
        case analyzing
        case results
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Animated gradient background
                LuxuryBackgroundView()
                
                ScrollView {
                    VStack(spacing: ModernTheme.Spacing.lg) {
                        
                        // Enhanced Step Indicator
                        LuxuryStepIndicator(
                            currentStep: currentStep,
                            progress: stepProgress
                        )
                        .padding(.horizontal)
                        .padding(.top, ModernTheme.Spacing.xs)
                        
                        // Main Content with transitions
                        Group {
                            switch currentStep {
                            case .selectImage:
                                ImageSelectionView(vm: vm, currentStep: $currentStep)
                                    .transition(.luxurySlide)
                                
                            case .selectOccasion:
                                OccasionSelector(vm: vm, currentStep: $currentStep)
                                    .transition(.luxurySlide)
                                
                            case .analyzing:
                                LuxuryAnalyzingView()
                                    .transition(.hero)
                                
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
                                                stepProgress = 0.25
                                            }
                                        }
                                    )
                                    .transition(.glassReveal)
                                }
                            }
                        }
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
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    CreditDisplay(
                        credits: creditsManager.remainingCredits,
                        onTap: { showPurchaseView = true }
                    )
                    .scaleEffect(showCreditsAnimation ? 1.1 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: showCreditsAnimation)
                }
            }
        }
        .onChange(of: vm.processingState) { newState in
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                switch newState {
                case .idle:
                    break
                case .analyzing:
                    if currentStep == .selectOccasion {
                        currentStep = .analyzing
                        stepProgress = 0.75
                    }
                case .searchingImages:
                    break
                case .complete:
                    currentStep = .results
                    stepProgress = 1.0
                }
            }
        }
        .onChange(of: currentStep) { _ in
            updateStepProgress()
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
    
    private func updateStepProgress() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            switch currentStep {
            case .selectImage:
                stepProgress = 0.25
            case .selectOccasion:
                stepProgress = 0.5
            case .analyzing:
                stepProgress = 0.75
            case .results:
                stepProgress = 1.0
            }
        }
    }
}

// MARK: - Luxury Background
struct LuxuryBackgroundView: View {
    @State private var shimmerOffset: CGFloat = -500
    
    var body: some View {
        ZStack {
            ModernTheme.background
                .ignoresSafeArea()
            
            // Subtle gradient
            LinearGradient(
                colors: [
                    ModernTheme.primary.opacity(0.05),
                    Color.clear,
                    ModernTheme.secondary.opacity(0.03)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // Moving shimmer
            LinearGradient(
                colors: [
                    Color.clear,
                    Color.white.opacity(0.03),
                    Color.clear
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(width: 200)
            .rotationEffect(.degrees(30))
            .offset(x: shimmerOffset)
            .ignoresSafeArea()
            .onAppear {
                withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) {
                    shimmerOffset = 500
                }
            }
        }
    }
}

// MARK: - Luxury Step Indicator
struct LuxuryStepIndicator: View {
    let currentStep: ContentView.Step
    let progress: CGFloat
    @State private var animatedProgress: CGFloat = 0
    @EnvironmentObject var localizationManager: LocalizationManager
    
    private var steps: [(ContentView.Step, String, LocalizedStringKey)] {
        [
            (.selectImage, "camera.fill", .photo),
            (.selectOccasion, "calendar", .occasion),
            (.analyzing, "sparkles", .style),
            (.results, "checkmark.circle", .results)
        ]
    }
    
    var body: some View {
        VStack(spacing: ModernTheme.Spacing.sm) {
            // Progress bar background
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background track
                    RoundedRectangle(cornerRadius: 10)
                        .fill(ModernTheme.surface.opacity(0.3))
                        .frame(height: 4)
                    
                    // Progress track with gradient
                    RoundedRectangle(cornerRadius: 10)
                        .fill(ModernTheme.primaryGradient)
                        .frame(width: geometry.size.width * animatedProgress, height: 4)
                        .shadow(color: ModernTheme.primary.opacity(0.5), radius: 10, x: 0, y: 0)
                }
            }
            .frame(height: 4)
            .padding(.horizontal, ModernTheme.Spacing.lg)
            .onAppear {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    animatedProgress = progress
                }
            }
            .onChange(of: progress) { newValue in
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    animatedProgress = newValue
                }
            }
            
            // Step circles
            HStack(spacing: 0) {
                ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                    VStack(spacing: 8) {
                        // Step Circle with animation
                        ZStack {
                            Circle()
                                .fill(isStepCompleted(step.0) ? ModernTheme.primaryGradient : ModernTheme.surface)
                                .frame(width: 44, height: 44)
                                .overlay(
                                    Circle()
                                        .stroke(
                                            isStepCompleted(step.0) ?
                                            ModernTheme.primaryGradient :
                                            LinearGradient(colors: [ModernTheme.surface], startPoint: .top, endPoint: .bottom),
                                            lineWidth: 2
                                        )
                                )
                                .shadow(
                                    color: isStepCompleted(step.0) ? ModernTheme.primary.opacity(0.3) : Color.clear,
                                    radius: 10,
                                    x: 0,
                                    y: 5
                                )
                            
                            Image(systemName: step.1)
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(isStepCompleted(step.0) ? .white : ModernTheme.textSecondary)
                                .rotationEffect(.degrees(currentStep == step.0 ? 360 : 0))
                                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: currentStep)
                        }
                        .scaleEffect(currentStep == step.0 ? 1.1 : 1.0)
                        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: currentStep)
                        
                        // Step Label
                        Text(localized(step.2))
                            .font(ModernTheme.Typography.caption2)
                            .fontWeight(currentStep == step.0 ? .semibold : .regular)
                            .foregroundColor(isStepCompleted(step.0) ? ModernTheme.primary : ModernTheme.textTertiary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(.vertical, ModernTheme.Spacing.sm)
    }
    
    private func isStepCompleted(_ step: ContentView.Step) -> Bool {
        switch currentStep {
        case .selectImage:
            return step == .selectImage
        case .selectOccasion:
            return step == .selectImage || step == .selectOccasion
        case .analyzing:
            return step != .results
        case .results:
            return true
        }
    }
}

// MARK: - Enhanced Image Selection View
struct ImageSelectionView: View {
    @ObservedObject var vm: ImageCaptureViewModel
    @Binding var currentStep: ContentView.Step
    @State private var imageScale: CGFloat = 0.8
    @State private var buttonOffset: CGFloat = 50
    
    var body: some View {
        VStack(spacing: ModernTheme.Spacing.lg) {
            // Title with fade-in
            VStack(spacing: ModernTheme.Spacing.xs) {
                Text(localized(.uploadYourOutfit))
                    .font(ModernTheme.Typography.headline)
                    .foregroundColor(ModernTheme.textPrimary)
                    .shimmer()
                
                Text(localized(.takePhotoOrSelect))
                    .font(ModernTheme.Typography.callout)
                    .foregroundColor(ModernTheme.textSecondary)
            }
            .opacity(imageScale > 0.9 ? 1 : 0)
            .animation(.easeOut(duration: 0.5), value: imageScale)
            
            // Enhanced Image Selection
            LuxuryImageSelectionSection(selectedImage: $vm.selectedImage)
                .scaleEffect(imageScale)
                .onAppear {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        imageScale = 1.0
                    }
                }
            
            // Continue Button with slide-in
            if vm.selectedImage != nil {
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        currentStep = .selectOccasion
                    }
                } label: {
                    PrimaryButton(
                        title: localized(.continueToOccasion),
                        systemImage: "arrow.right",
                        style: .primary
                    )
                }
                .padding(.horizontal, ModernTheme.Spacing.xl)
                .offset(y: buttonOffset)
                .onAppear {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        buttonOffset = 0
                    }
                }
            }
        }
    }
}

// MARK: - Luxury Image Selection Section
struct LuxuryImageSelectionSection: View {
    @Binding var selectedImage: UIImage?
    @State private var isHovered = false
    @State private var rotationAngle: Double = 0
    
    var body: some View {
        VStack(spacing: ModernTheme.Spacing.md) {
            if let image = selectedImage {
                // Image preview with luxury frame
                ZStack {
                    // Glow effect
                    RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.xl)
                        .fill(ModernTheme.primaryGradient.opacity(0.3))
                        .frame(maxHeight: 320)
                        .blur(radius: 30)
                        .scaleEffect(isHovered ? 1.1 : 1.0)
                    
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 300)
                        .cornerRadius(ModernTheme.CornerRadius.large)
                        .overlay(
                            RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.large)
                                .stroke(ModernTheme.primaryGradient, lineWidth: 2)
                        )
                        .shadow(
                            color: ModernTheme.Shadow.large.color,
                            radius: ModernTheme.Shadow.large.radius,
                            x: ModernTheme.Shadow.large.x,
                            y: ModernTheme.Shadow.large.y
                        )
                        .scaleEffect(isHovered ? 1.02 : 1.0)
                        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isHovered)
                }
                .padding(.horizontal)
                .onHover { hovering in
                    isHovered = hovering
                }
                
                // Change photo button
                ImagePicker(selectedImage: $selectedImage)
                    .padding(.horizontal)
            } else {
                // Empty state with animation
                VStack(spacing: ModernTheme.Spacing.lg) {
                    ZStack {
                        // Animated background circles
                        Circle()
                            .fill(ModernTheme.primary.opacity(0.1))
                            .frame(width: 150, height: 150)
                            .scaleEffect(isHovered ? 1.2 : 1.0)
                            .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: isHovered)
                        
                        Circle()
                            .fill(ModernTheme.secondary.opacity(0.1))
                            .frame(width: 120, height: 120)
                            .scaleEffect(isHovered ? 1.0 : 1.2)
                            .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true).delay(0.5), value: isHovered)
                        
                        Image(systemName: "camera.macro")
                            .font(.system(size: 60))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [ModernTheme.primary, ModernTheme.secondary],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .rotationEffect(.degrees(rotationAngle))
                    }
                    .onAppear {
                        isHovered = true
                        withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                            rotationAngle = 360
                        }
                    }
                    
                    Text(localized(.selectYourOutfitPhoto))
                        .font(ModernTheme.Typography.headline)
                        .foregroundColor(ModernTheme.textSecondary)
                    
                    ImagePicker(selectedImage: $selectedImage)
                }
                .frame(height: 300)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.large)
                        .fill(ModernTheme.surface.opacity(0.5))
                        .background(.ultraThinMaterial.opacity(0.3))
                        .overlay(
                            RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.large)
                                .stroke(
                                    style: StrokeStyle(lineWidth: 2, dash: [8])
                                )
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [ModernTheme.primary.opacity(0.5), ModernTheme.secondary.opacity(0.3)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        )
                )
                .padding(.horizontal)
            }
        }
    }
}

// MARK: - Luxury Analyzing View
struct LuxuryAnalyzingView: View {
    @State private var dots = 0
    @State private var rotations: [Double] = [0, 0, 0]
    @State private var scales: [CGFloat] = [1, 1, 1]
    
    var body: some View {
        VStack(spacing: ModernTheme.Spacing.xl) {
            // Multiple animated icons
            HStack(spacing: ModernTheme.Spacing.lg) {
                ForEach(0..<3) { index in
                    ZStack {
                        Circle()
                            .fill(ModernTheme.primaryGradient.opacity(0.2))
                            .frame(width: 80, height: 80)
                            .blur(radius: 10)
                            .scaleEffect(scales[index])
                        
                        Image(systemName: ["sparkles", "wand.and.stars", "star.fill"][index])
                            .font(.system(size: 40))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [ModernTheme.primary, ModernTheme.secondary],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .rotationEffect(.degrees(rotations[index]))
                    }
                }
            }
            .onAppear {
                for index in 0..<3 {
                    withAnimation(.linear(duration: 2).repeatForever(autoreverses: false).delay(Double(index) * 0.3)) {
                        rotations[index] = 360
                    }
                    withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true).delay(Double(index) * 0.2)) {
                        scales[index] = 1.3
                    }
                }
            }
            
            // Loading Text
            Text(localized(.analyzingYourStyle) + String(repeating: ".", count: dots))
                .font(ModernTheme.Typography.headline)
                .foregroundColor(ModernTheme.textPrimary)
                .onAppear {
                    Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
                        dots = (dots + 1) % 4
                    }
                }
            
            Text(localized(.aiStylistReviewing))
                .font(ModernTheme.Typography.body)
                .foregroundColor(ModernTheme.textSecondary)
                .shimmer()
        }
        .padding(.vertical, ModernTheme.Spacing.xxl)
    }
}

// MARK: - Preview
#Preview {
    ContentView()
        .environmentObject(CreditsManager.shared)
        .environmentObject(LocalizationManager.shared)
}
