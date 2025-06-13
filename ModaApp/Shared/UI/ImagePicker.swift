//
//  ImagePicker.swift
//  ModaApp
//
//  Luxury image picker with loading animations
//

import SwiftUI
import PhotosUI

struct ImagePicker: View {
    @Binding var selectedImage: UIImage?
    @State private var pickerItem: PhotosPickerItem?
    @State private var isLoading = false
    @State private var loadingProgress: CGFloat = 0
    
    var title: String? = nil
    
    var body: some View {
        PhotosPicker(
            selection: $pickerItem,
            matching: .images,
            photoLibrary: .shared()
        ) {
            if isLoading {
                loadingButton
            } else {
                selectButton
            }
        }
        .disabled(isLoading)
        .onChange(of: pickerItem) { _ in
            loadImage()
        }
    }
    
    // MARK: - Loading Button
    private var loadingButton: some View {
        ZStack {
            // Background with gradient
            RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.full)
                .fill(ModernTheme.primaryGradient.opacity(0.8))
                .frame(height: 56)
            
            // Loading progress overlay
            GeometryReader { geometry in
                RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.full)
                    .fill(
                        LinearGradient(
                            colors: [
                                ModernTheme.secondary.opacity(0.5),
                                ModernTheme.tertiary.opacity(0.3)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geometry.size.width * loadingProgress)
                    .animation(ModernTheme.smoothSpring, value: loadingProgress)
            }
            .frame(height: 56)
            .mask(RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.full))
            
            // Loading content
            HStack(spacing: ModernTheme.Spacing.sm) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(0.8)
                
                Text(LocalizationManager.shared.string(for: .loading))
                    .font(ModernTheme.Typography.body)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                
                // Animated dots
                HStack(spacing: 4) {
                    ForEach(0..<3) { index in
                        Circle()
                            .fill(Color.white)
                            .frame(width: 4, height: 4)
                            .opacity(loadingProgress > CGFloat(index) * 0.33 ? 1 : 0.3)
                            .animation(
                                Animation.easeInOut(duration: 0.6)
                                    .repeatForever()
                                    .delay(Double(index) * 0.2),
                                value: loadingProgress
                            )
                    }
                }
            }
        }
        .shadow(
            color: ModernTheme.Shadow.colored.color,
            radius: ModernTheme.Shadow.colored.radius,
            x: 0,
            y: ModernTheme.Shadow.colored.y
        )
    }
    
    // MARK: - Select Button
    private var selectButton: some View {
        PrimaryButton(
            title: title ?? buttonTitle,
            systemImage: "photo.fill",
            style: selectedImage == nil ? .primary : .secondary,
            action: {}
        )
    }
    
    private var buttonTitle: String {
        selectedImage == nil ?
        LocalizationManager.shared.string(for: .selectPhoto) :
        LocalizationManager.shared.string(for: .changePhoto)
    }
    
    // MARK: - Load Image
    private func loadImage() {
        guard let item = pickerItem else { return }
        
        isLoading = true
        loadingProgress = 0
        
        // Animate loading progress
        withAnimation(.linear(duration: 1.5)) {
            loadingProgress = 0.8
        }
        
        Task {
            do {
                if let data = try await item.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    
                    // Complete the progress
                    await MainActor.run {
                        withAnimation(ModernTheme.springAnimation) {
                            loadingProgress = 1.0
                        }
                    }
                    
                    // Small delay to show completion
                    try await Task.sleep(nanoseconds: 200_000_000)
                    
                    await MainActor.run {
                        withAnimation(ModernTheme.springAnimation) {
                            selectedImage = uiImage
                            isLoading = false
                            loadingProgress = 0
                        }
                    }
                } else {
                    await MainActor.run {
                        isLoading = false
                        loadingProgress = 0
                    }
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    loadingProgress = 0
                }
                print("Error loading image: \(error)")
            }
        }
    }
}

// MARK: - Preview
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
