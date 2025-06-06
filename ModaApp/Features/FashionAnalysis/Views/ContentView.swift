//
//  ContentView.swift
//  ModaApp
//
//  Updated with ModernTheme styling
//

import SwiftUI

struct ContentView: View {
    
    @StateObject private var vm = ImageCaptureViewModel()
    @StateObject private var creditsManager = CreditsManager.shared
    @State private var showCreditsAnimation = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                ModernTheme.background
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: ModernTheme.Spacing.lg) {
                        
                        // ── Credits Display ────────────────────────────────
                        CreditsHeaderView(credits: creditsManager.remainingCredits)
                            .padding(.horizontal)
                        
                        // ── Main Content Card ──────────────────────────────
                        VStack(spacing: ModernTheme.Spacing.lg) {
                            
                            // ── 1. Image Selection Section ─────────────────
                            ImageSelectionSection(selectedImage: $vm.selectedImage)
                            
                            // ── 2. Generate Button ─────────────────────────
                            Button {
                                vm.generate()
                            } label: {
                                PrimaryButton(
                                    title: vm.hasCredits ? "Analyze Outfit" : "No Credits",
                                    systemImage: vm.hasCredits ? "leaf.circle" : "exclamationmark.circle",
                                    enabled: vm.selectedImage != nil && !vm.isBusy && vm.hasCredits
                                )
                            }
                            .buttonStyle(InteractiveButtonStyle())
                            .padding(.horizontal)
                            
                            // ── 3. Processing View ─────────────────────────
                            if vm.isBusy {
                                ProcessingView()
                                    .transition(.scale.combined(with: .opacity))
                            }
                            
                            // ── 4. Results Section ─────────────────────────
                            if !vm.caption.isEmpty {
                                ResultsSection(
                                    caption: vm.caption,
                                    audioURL: vm.audioURL,
                                    audioManager: vm.audio
                                )
                                .transition(.asymmetric(
                                    insertion: .scale.combined(with: .opacity),
                                    removal: .opacity
                                ))
                            }
                            
                            // ── 5. Error Display ───────────────────────────
                            if let error = vm.error {
                                ErrorView(message: error)
                                    .transition(.move(edge: .top).combined(with: .opacity))
                            }
                            
                            // ── 6. Debug Section ───────────────────────────
                            #if DEBUG
                            DebugSection(onAddCredits: vm.addDebugCredits)
                            #endif
                        }
                        .padding(.bottom, ModernTheme.Spacing.xxl)
                    }
                }
            }
            .navigationTitle("EcoStyle AI")
            .navigationBarTitleDisplayMode(.large)
        }
        .alert("No Credits", isPresented: $vm.showPurchaseView) {
            Button("Buy Credits") {
                // TODO: Navigate to purchase view
                print("Navigate to purchase view")
            }
            Button("Later", role: .cancel) { }
        } message: {
            Text("You need credits to analyze outfits. Each analysis costs 1 credit.")
        }
    }
}

// MARK: - Credits Header View

struct CreditsHeaderView: View {
    let credits: Int
    @State private var isAnimating = false
    
    var body: some View {
        HStack(spacing: ModernTheme.Spacing.md) {
            // Credits icon and count
            HStack(spacing: ModernTheme.Spacing.xs) {
                Image(systemName: "leaf.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(ModernTheme.secondary)
                    .rotationEffect(.degrees(isAnimating ? 360 : 0))
                    .animation(.linear(duration: 2).repeatForever(autoreverses: false), value: isAnimating)
                
                Text("\(credits)")
                    .font(ModernTheme.Typography.title2)
                    .fontWeight(.bold)
                    .foregroundColor(ModernTheme.textPrimary)
                
                Text("Credits")
                    .font(ModernTheme.Typography.body)
                    .foregroundColor(ModernTheme.textSecondary)
            }
            
            Spacer()
            
            // Buy more button
            Button(action: {
                // TODO: Navigate to purchase view
                print("Show purchase options")
            }) {
                HStack(spacing: ModernTheme.Spacing.xs) {
                    Image(systemName: "plus.circle.fill")
                    Text("Buy")
                }
                .font(ModernTheme.Typography.callout)
                .fontWeight(.medium)
                .foregroundColor(ModernTheme.primary)
                .padding(.horizontal, ModernTheme.Spacing.md)
                .padding(.vertical, ModernTheme.Spacing.xs)
                .background(
                    Capsule()
                        .fill(ModernTheme.primary.opacity(0.15))
                )
            }
        }
        .padding(ModernTheme.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.large)
                .fill(ModernTheme.surface)
                .shadow(
                    color: ModernTheme.Shadow.small.color,
                    radius: ModernTheme.Shadow.small.radius,
                    x: ModernTheme.Shadow.small.x,
                    y: ModernTheme.Shadow.small.y
                )
        )
        .onAppear {
            isAnimating = true
        }
    }
}

// MARK: - Image Selection Section

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
                    
                    Text("Select your outfit photo")
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

// MARK: - Processing View

struct ProcessingView: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: ModernTheme.Spacing.md) {
            // Animated dots
            HStack(spacing: ModernTheme.Spacing.xs) {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(ModernTheme.primary)
                        .frame(width: 12, height: 12)
                        .scaleEffect(isAnimating ? 1.0 : 0.5)
                        .animation(
                            .easeInOut(duration: 0.6)
                            .repeatForever()
                            .delay(Double(index) * 0.2),
                            value: isAnimating
                        )
                }
            }
            
            Text("Analyzing your sustainable style...")
                .font(ModernTheme.Typography.body)
                .foregroundColor(ModernTheme.textSecondary)
        }
        .padding(ModernTheme.Spacing.xl)
        .onAppear {
            isAnimating = true
        }
    }
}

// MARK: - Results Section

struct ResultsSection: View {
    let caption: String
    let audioURL: URL?
    let audioManager: AudioPlayerManager
    
    var body: some View {
        VStack(spacing: ModernTheme.Spacing.lg) {
            // Caption text
            Text(caption)
                .font(ModernTheme.Typography.body)
                .foregroundColor(ModernTheme.textPrimary)
                .padding(ModernTheme.Spacing.lg)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.large)
                        .fill(ModernTheme.surface)
                        .shadow(
                            color: ModernTheme.Shadow.small.color,
                            radius: ModernTheme.Shadow.small.radius,
                            x: ModernTheme.Shadow.small.x,
                            y: ModernTheme.Shadow.small.y
                        )
                )
                .padding(.horizontal)
            
            // Audio controls
            if audioURL != nil {
                VStack(spacing: ModernTheme.Spacing.md) {
                    AudioProgressView(audio: audioManager)
                        .padding(.horizontal)
                    
                    Button {
                        audioManager.toggle()
                    } label: {
                        Image(systemName: audioManager.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                            .font(.system(size: 56))
                            .foregroundStyle(ModernTheme.sageGradient)
                            .shadow(
                                color: ModernTheme.primary.opacity(0.3),
                                radius: 8,
                                x: 0,
                                y: 4
                            )
                    }
                }
            }
        }
    }
}

// MARK: - Error View

struct ErrorView: View {
    let message: String
    
    var body: some View {
        HStack(spacing: ModernTheme.Spacing.sm) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(ModernTheme.error)
            
            Text(message)
                .font(ModernTheme.Typography.callout)
                .foregroundColor(ModernTheme.error)
                .multilineTextAlignment(.leading)
            
            Spacer()
        }
        .padding(ModernTheme.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.medium)
                .fill(ModernTheme.error.opacity(0.1))
        )
        .padding(.horizontal)
    }
}

// MARK: - Debug Section

#if DEBUG
struct DebugSection: View {
    let onAddCredits: () -> Void
    
    var body: some View {
        VStack(spacing: ModernTheme.Spacing.sm) {
            Text("Debug Tools")
                .font(ModernTheme.Typography.caption)
                .foregroundColor(ModernTheme.textTertiary)
            
            Button("Add 5 Credits") {
                onAddCredits()
            }
            .font(ModernTheme.Typography.callout)
            .foregroundColor(ModernTheme.darkSage)
            .padding(.horizontal, ModernTheme.Spacing.md)
            .padding(.vertical, ModernTheme.Spacing.xs)
            .background(
                Capsule()
                    .stroke(ModernTheme.darkSage, lineWidth: 1)
            )
        }
        .padding()
    }
}
#endif

// MARK: - Preview

#Preview {
    ContentView()
}
