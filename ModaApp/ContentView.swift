//
//  ContentView.swift
//  ModaApp
//
//  Updated 6/3/25 – integrates AudioProgressView so the timeline moves
//  in real time while audio is playing.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject private var vm = ImageCaptureViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    
                    // ── 1. Pick / change photo ─────────────────────────────
                    ImagePicker(selectedImage: $vm.selectedImage)
                    
                    // ── 2. Thumbnail preview ───────────────────────────────
                    if let img = vm.selectedImage {
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 250)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    
                    // ── 3. Generate caption + audio ───────────────────────
                    Button {
                        vm.generate()
                    } label: {
                        PrimaryButton(
                            title: "Generate Caption + Audio",
                            systemImage: "sparkles",
                            enabled: vm.selectedImage != nil && !vm.isBusy
                        )
                    }
                    
                    // ── 4. Spinner while busy ─────────────────────────────
                    if vm.isBusy {
                        ProgressView("Working…")
                            .progressViewStyle(.circular)
                            .padding()
                    }
                    
                    // ── 5. Caption text ───────────────────────────────────
                    if !vm.caption.isEmpty {
                        Text(vm.caption)
                            .padding()
                            .background(.ultraThinMaterial,
                                        in: RoundedRectangle(cornerRadius: 12))
                    }
                    
                    // ── 6. Audio controls (slider + play/pause) ───────────
                    if vm.audioURL != nil {
                        AudioProgressView(audio: vm.audio)
                        
                        Button {
                            vm.audio.toggle()
                        } label: {
                            Image(systemName: vm.audio.isPlaying
                                               ? "pause.circle.fill"
                                               : "play.circle.fill")
                                .font(.system(size: 44))
                        }
                        .padding(.top, 6)
                    }
                    
                    // ── 7. Error message ─────────────────────────────────
                    if let err = vm.error {
                        Text(err)
                            .foregroundColor(.red)
                    }
                }
                .padding()
            }
            .navigationTitle("ModaApp")
        }
    }
}

#Preview {
    ContentView()
}
