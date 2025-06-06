//
//  ImagePicker.swift
//  ModaApp
//
//  Created by Vahi Guner on 6/3/25.
//  Updated with ModernTheme styling
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
                    
                    Text("Loading...")
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
                    title: title ?? (selectedImage == nil ? "Select Photo" : "Change Photo"),
                    systemImage: "photo.fill",
                    style: selectedImage == nil ? .primary : .secondary
                )
            }
        }
        .disabled(isLoading)
        // Load the UIImage when the user picks something
        .onChange(of: pickerItem) { _, _ in
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

// MARK: - Alternative Camera/Library Picker

struct ImageSourcePicker: View {
    @Binding var selectedImage: UIImage?
    @State private var showingImagePicker = false
    @State private var showingCamera = false
    @State private var pickerItem: PhotosPickerItem?
    @State private var showingActionSheet = false
    
    var body: some View {
        Button(action: {
            showingActionSheet = true
        }) {
            PrimaryButton(
                title: selectedImage == nil ? "Add Photo" : "Change Photo",
                systemImage: "leaf.camera.fill",
                style: .primary
            )
        }
        .confirmationDialog("Select Source", isPresented: $showingActionSheet) {
            Button("Photo Library") {
                showingImagePicker = true
            }
            
            Button("Camera") {
                showingCamera = true
            }
            
            Button("Cancel", role: .cancel) { }
        }
        .sheet(isPresented: $showingImagePicker) {
            PhotosPicker(
                selection: $pickerItem,
                matching: .images,
                photoLibrary: .shared()
            ) {
                Text("Select from Library")
            }
            .onChange(of: pickerItem) { _, _ in
                Task {
                    if let item = pickerItem,
                       let data = try? await item.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        await MainActor.run {
                            selectedImage = image
                            showingImagePicker = false
                        }
                    }
                }
            }
        }
        // Note: Camera functionality would require UIImagePickerController
        // which needs additional implementation
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
        
        // Alternative picker with source selection
        ImageSourcePicker(selectedImage: .constant(nil))
    }
    .padding(ModernTheme.Spacing.xl)
    .background(ModernTheme.background)
}
