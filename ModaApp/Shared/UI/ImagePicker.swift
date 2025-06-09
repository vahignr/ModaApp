//
//  ImagePicker.swift
//  ModaApp
//
//  Created by Vahi Guner on 6/3/25.
//  Updated with ModernTheme styling and localization
//

import SwiftUI
import PhotosUI

struct ImagePicker: View {
    
    /// The selected image returned to the parent view.
    @Binding var selectedImage: UIImage?
    
    /// Internally tracks the PhotosPicker item (photo library reference).
    @State private var pickerItem: PhotosPickerItem?
    @State private var isLoading = false
    
    /// Optional prompt shown on the button.  If you don't pass one, it toggles
    /// between "Select Photo" and "Change Photo".
    var title: String? = nil
    
    var body: some View {
        PhotosPicker(
            selection: $pickerItem,
            matching: .images,
            photoLibrary: .shared()
        ) {
            if isLoading {
                // Loading state
                HStack(spacing: ModernTheme.Spacing.sm) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                    
                    Text(LocalizationManager.shared.string(for: .loading))
                        .font(ModernTheme.Typography.body)
                        .fontWeight(.medium)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, ModernTheme.Spacing.md)
                .foregroundColor(.white)
                .background(ModernTheme.primary.opacity(0.8))
                .cornerRadius(ModernTheme.CornerRadius.full)
            } else {
                PrimaryButton(
                    title: title ?? (selectedImage == nil ? LocalizationManager.shared.string(for: .selectPhoto) : LocalizationManager.shared.string(for: .changePhoto)),
                    systemImage: "photo.fill",
                    style: selectedImage == nil ? .primary : .secondary
                )
            }
        }
        .disabled(isLoading)
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
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
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
