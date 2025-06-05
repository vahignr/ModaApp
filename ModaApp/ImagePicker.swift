//
//  ImagePicker.swift
//  ModaApp
//
//  Created by Vahi Guner on 6/3/25.
//
//  A lightweight SwiftUI wrapper around `PhotosPicker` (iOS 17+).  It lets the
//  user choose a single image from their photo library and returns it as
//  `UIImage` via a binding.
//

import SwiftUI
import PhotosUI

struct ImagePicker: View {
    
    /// The selected image returned to the parent view.
    @Binding var selectedImage: UIImage?
    
    /// Internally tracks the PhotosPicker item (photo library reference).
    @State private var pickerItem: PhotosPickerItem?
    
    /// Optional prompt shown on the button.  If you don’t pass one, it toggles
    /// between “Select Photo” and “Change Photo”.
    var title: String? = nil
    
    var body: some View {
        PhotosPicker(
            selection: $pickerItem,
            matching: .images,
            photoLibrary: .shared()
        ) {
            PrimaryButton(
                title: title ?? (selectedImage == nil ? "Select Photo" : "Change Photo"),
                systemImage: "photo"
            )
        }
        // Load the UIImage when the user picks something
        .onChange(of: pickerItem) { _ in
            loadImage()
        }
    }
    
    // MARK: - Helpers ---------------------------------------------------------
    
    private func loadImage() {
        guard let item = pickerItem else { return }
        Task {
            if let data = try? await item.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                await MainActor.run {
                    selectedImage = uiImage
                }
            }
        }
    }
}


// MARK: - Preview -------------------------------------------------------------

#Preview {
    ImagePicker(selectedImage: .constant(nil))
        .padding()
}
