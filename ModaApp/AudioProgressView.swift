//
//  AudioProgressView.swift
//  ModaApp
//
//  Created by Vahi Guner on 6/3/25.
//
//  Two-row component:
//
//  ┌─────────── Slider (seekable) ────────────┐
//  | 00:12                     00:26         |
//  └──────────────────────────────────────────┘
//

import SwiftUI

struct AudioProgressView: View {
    
    /// The audio manager we observe for time updates.
    @ObservedObject var audio: AudioPlayerManager
    
    var body: some View {
        VStack(spacing: 8) {
            // Seekable slider (0 … 1)
            Slider(value: Binding(
                get: {
                    guard audio.duration > 0 else { return 0 }
                    return audio.currentTime / audio.duration
                },
                set: { audio.seek(to: $0) }
            ))
            
            // Time labels
            HStack {
                Text(format(audio.currentTime))
                Spacer()
                Text(format(audio.duration))
            }
            .font(.caption.monospacedDigit())
        }
        .padding(.horizontal)
    }
    
    // MARK: - helpers
    
    private func format(_ t: TimeInterval) -> String {
        let m = Int(t) / 60
        let s = Int(t) % 60
        return String(format: "%02d:%02d", m, s)
    }
}

#Preview {
    AudioProgressView(audio: .init())
        .environment(\.colorScheme, .dark)
        .padding()
}
