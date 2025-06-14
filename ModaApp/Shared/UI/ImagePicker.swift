//
//  ImagePicker.swift
//  ModaApp
//
//  Created by Vahi Guner on 6/3/25.
//  Updated with glass morphism and luxury animations
//

import SwiftUI
import PhotosUI

struct ImagePicker: View {
    
    /// The selected image returned to the parent view.
    @Binding var selectedImage: UIImage?
    
    /// Internally tracks the PhotosPicker item (photo library reference).
    @State private var pickerItem: PhotosPickerItem?
    @State private var isLoading = false
    @State private var isHovered = false
    @State private var shimmerOffset: CGFloat = -300
    
    /// Optional prompt shown on the button.  If you don't pass one, it toggles
    /// between "Select Photo" and "Change Photo".
    var title: String? = nil
    
    var body: some View {
        PhotosPicker(
            selection: $pickerItem,
            matching: .images,
            photoLibrary: .shared()
        ) {
            ZStack {
                // Glass morphism background
                RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.full)
                    .fill(
                        LinearGradient(
                            colors: [
                                ModernTheme.primary.opacity(0.2),
                                ModernTheme.secondary.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .background(
                        .ultraThinMaterial.opacity(0.5)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.full)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.3),
                                        Color.white.opacity(0.1)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                
                // Shimmer effect
                LinearGradient(
                    colors: [
                        Color.white.opacity(0),
                        Color.white.opacity(0.2),
                        Color.white.opacity(0)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(width: 150)
                .offset(x: shimmerOffset)
                .mask(
                    RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.full)
                )
                .allowsHitTesting(false)
                
                // Content
                if isLoading {
                    // Premium loading state
                    HStack(spacing: ModernTheme.Spacing.sm) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                        
                        Text(LocalizationManager.shared.string(for: .loading).uppercased())
                            .font(ModernTheme.Typography.buttonText)
                            .tracking(1.2)
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, ModernTheme.Spacing.md)
                } else {
                    HStack(spacing: ModernTheme.Spacing.sm) {
                        Image(systemName: "photo.fill")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.white)
                            .rotationEffect(.degrees(isHovered ? 5 : 0))
                            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isHovered)
                        
                        Text((title ?? (selectedImage == nil ?
                            LocalizationManager.shared.string(for: .selectPhoto) :
                            LocalizationManager.shared.string(for: .changePhoto))).uppercased())
                            .font(ModernTheme.Typography.buttonText)
                            .tracking(1.2)
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, ModernTheme.Spacing.md)
                }
            }
            .frame(height: 60)
            .scaleEffect(isHovered ? 1.02 : 1.0)
            .shadow(
                color: ModernTheme.primary.opacity(0.3),
                radius: isHovered ? 25 : 15,
                x: 0,
                y: isHovered ? 12 : 8
            )
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isHovered)
        }
        .disabled(isLoading)
        .onHover { hovering in
            isHovered = hovering
        }
        .onAppear {
            withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                shimmerOffset = 300
            }
        }
        // Load the UIImage when the user picks something
        .onChange(of: pickerItem) { _ in
            loadImage()
        }
    }
    
    // MARK: - Helpers ---------------------------------------------------------
    
    private func loadImage() {
        guard let item = pickerItem else { return }
        
        isLoading = true
        
        Task {
            do {
                if let data = try await item.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    await MainActor.run {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            selectedImage = uiImage
                            isLoading = false
                        }
                    }
                } else {
                    await MainActor.run {
                        isLoading = false
                    }
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                }
                print("Error loading image: \(error)")
            }
        }
    }
}

// MARK: - Preview -------------------------------------------------------------

#Preview {
    VStack(spacing: ModernTheme.Spacing.xl) {
        // Default state
        ImagePicker(selectedImage: .constant(nil))
        
        // With image selected
        ImagePicker(selectedImage: .constant(UIImage(systemName: "photo")))
        
        // Custom title
        ImagePicker(selectedImage: .constant(nil), title: "Upload Outfit")
    }
    .padding(ModernTheme.Spacing.xl)
    .background(ModernTheme.background)
    .environmentObject(LocalizationManager.shared)
}
