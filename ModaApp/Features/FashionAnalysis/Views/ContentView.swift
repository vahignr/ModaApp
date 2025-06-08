//
//  ContentView.swift
//  ModaApp
//
//  Updated with Occasion Selection and Fashion Analysis
//

import SwiftUI

struct ContentView: View {
    
    @StateObject private var vm = ImageCaptureViewModel()
    @StateObject private var creditsManager = CreditsManager.shared
    @EnvironmentObject var localizationManager: LocalizationManager
    @State private var showCreditsAnimation = false
    @State private var currentStep: Step = .selectImage
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
                // Background
                ModernTheme.background
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: ModernTheme.Spacing.lg) {
                        
                        // ── Step Indicator ─────────────────────────────────
                        StepIndicator(currentStep: currentStep)
                            .padding(.horizontal)
                            .padding(.top, ModernTheme.Spacing.md)
                        
                        // ── Main Content Based on Step ─────────────────────
                        Group {
                            switch currentStep {
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
                                            withAnimation {
                                                vm.resetAll()
                                                currentStep = .selectImage
                                            }
                                        }
                                    )
                                }
                            }
                        }
                        .padding(.bottom, ModernTheme.Spacing.xxl)
                    }
                }
            }
            .navigationTitle(localized(.modaAnalyzer))
            .navigationBarTitleDisplayMode(.large)
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
        .onChange(of: vm.processingState) { _, newState in
            switch newState {
            case .idle:
                break
            case .analyzing:
                if currentStep == .selectOccasion {
                    withAnimation {
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
                // TODO: Navigate to purchase view
                print("Navigate to purchase view")
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
    }
}

// MARK: - Step Indicator
struct StepIndicator: View {
    let currentStep: ContentView.Step
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
        HStack(spacing: 0) {
            ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                HStack(spacing: 0) {
                    // Step Circle
                    ZStack {
                        Circle()
                            .fill(isStepCompleted(step.0) ? ModernTheme.primary : ModernTheme.lightSage)
                            .frame(width: 32, height: 32)
                        
                        Image(systemName: step.1)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(isStepCompleted(step.0) ? .white : ModernTheme.primary)
                    }
                    
                    // Step Label
                    Text(localized(step.2))
                        .font(ModernTheme.Typography.caption)
                        .foregroundColor(isStepCompleted(step.0) ? ModernTheme.primary : ModernTheme.textTertiary)
                        .padding(.leading, 4)
                    
                    // Connector Line
                    if index < steps.count - 1 {
                        Rectangle()
                            .fill(isStepCompleted(steps[index + 1].0) ? ModernTheme.primary : ModernTheme.lightSage)
                            .frame(height: 2)
                            .padding(.horizontal, 8)
                    }
                }
            }
        }
        .padding(.vertical, ModernTheme.Spacing.md)
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

// MARK: - Image Selection View
struct ImageSelectionView: View {
    @ObservedObject var vm: ImageCaptureViewModel
    @Binding var currentStep: ContentView.Step
    
    var body: some View {
        VStack(spacing: ModernTheme.Spacing.lg) {
            // Title
            VStack(spacing: ModernTheme.Spacing.xs) {
                Text(localized(.uploadYourOutfit))
                    .font(ModernTheme.Typography.headline)
                    .foregroundColor(ModernTheme.textPrimary)
                
                Text(localized(.takePhotoOrSelect))
                    .font(ModernTheme.Typography.callout)
                    .foregroundColor(ModernTheme.textSecondary)
            }
            
            // Image Selection
            ImageSelectionSection(selectedImage: $vm.selectedImage)
            
            // Continue Button
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
            }
        }
    }
}

// MARK: - Occasion Selection View
struct OccasionSelectionView: View {
    @ObservedObject var vm: ImageCaptureViewModel
    @Binding var currentStep: ContentView.Step
    
    var body: some View {
        VStack(spacing: ModernTheme.Spacing.lg) {
            // Occasion Selector
            OccasionSelector(
                selectedOccasion: $vm.selectedOccasion,
                customOccasion: $vm.customOccasion
            )
            .padding(.horizontal)
            
            // Action Buttons
            HStack(spacing: ModernTheme.Spacing.md) {
                Button {
                    withAnimation {
                        currentStep = .selectImage
                    }
                } label: {
                    PrimaryButton(
                        title: localized(.back),
                        systemImage: "chevron.left",
                        style: .secondary
                    )
                }
                
                Button {
                    vm.analyzeOutfit()
                } label: {
                    PrimaryButton(
                        title: localized(.analyzeStyle),
                        systemImage: "sparkles",
                        enabled: vm.canAnalyze && vm.hasCredits
                    )
                }
            }
            .padding(.horizontal, ModernTheme.Spacing.xl)
        }
    }
}

// MARK: - Analyzing View
struct AnalyzingView: View {
    @State private var dots = 0
    @State private var rotation = 0.0
    
    var body: some View {
        VStack(spacing: ModernTheme.Spacing.xl) {
            // Animated Icon
            ZStack {
                Circle()
                    .fill(ModernTheme.lightSage)
                    .frame(width: 120, height: 120)
                
                Image(systemName: "sparkles")
                    .font(.system(size: 50))
                    .foregroundColor(ModernTheme.primary)
                    .rotationEffect(.degrees(rotation))
            }
            .onAppear {
                withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                    rotation = 360
                }
            }
            
            // Loading Text
            Text(localized(.analyzingYourStyle) + String(repeating: ".", count: dots))
                .font(ModernTheme.Typography.headline)
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
        .padding(.vertical, ModernTheme.Spacing.xxl)
    }
}

// MARK: - Image Selection Section (from your existing code)
struct ImageSelectionSection: View {
    @Binding var selectedImage: UIImage?
    
    var body: some View {
        VStack(spacing: ModernTheme.Spacing.md) {
            if let image = selectedImage {
                // Image preview
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 300)
                    .cornerRadius(ModernTheme.CornerRadius.large)
                    .shadow(
                        color: ModernTheme.Shadow.medium.color,
                        radius: ModernTheme.Shadow.medium.radius,
                        x: ModernTheme.Shadow.medium.x,
                        y: ModernTheme.Shadow.medium.y
                    )
                    .padding(.horizontal)
                
                // Change photo button
                ImagePicker(selectedImage: $selectedImage)
                    .padding(.horizontal)
            } else {
                // Empty state
                VStack(spacing: ModernTheme.Spacing.lg) {
                    Image(systemName: "camera.macro")
                        .font(.system(size: 60))
                        .foregroundColor(ModernTheme.primary.opacity(0.3))
                    
                    Text(localized(.selectYourOutfitPhoto))
                        .font(ModernTheme.Typography.headline)
                        .foregroundColor(ModernTheme.textSecondary)
                    
                    ImagePicker(selectedImage: $selectedImage)
                }
                .frame(height: 300)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.large)
                        .fill(ModernTheme.surface)
                        .overlay(
                            RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.large)
                                .stroke(style: StrokeStyle(lineWidth: 2, dash: [8]))
                                .foregroundColor(ModernTheme.primary.opacity(0.3))
                        )
                )
                .padding(.horizontal)
            }
        }
    }
}

// MARK: - Preview
#Preview {
    ContentView()
        .environmentObject(CreditsManager.shared)
        .environmentObject(LocalizationManager.shared)
}
