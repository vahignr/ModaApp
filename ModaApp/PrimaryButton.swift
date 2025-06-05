//
//  PrimaryButton.swift
//  ModaApp
//
//  Created by Vahi Guner on 6/3/25.
//
//  A stylised capsule-shaped view that you can use:
//
//  • Directly inside a `Button {}` or `PhotosPicker`
//  • As a plain visual component (no built-in tap handler)
//
//  Example:
//
//      Button {
//          // do something
//      } label: {
//          PrimaryButton(title: "Generate", systemImage: "sparkles")
//      }
//

import SwiftUI

struct PrimaryButton: View {
    
    // MARK: - Public properties ----------------------------------------------
    
    let title: String
    let systemImage: String?          // optional SF Symbol
    var enabled: Bool = true          // greyed-out appearance if false
    
    // MARK: - View ------------------------------------------------------------
    
    var body: some View {
        HStack(spacing: 8) {
            if let systemImage {
                Image(systemName: systemImage)
            }
            Text(title)
                .fontWeight(.semibold)
        }
        .font(.headline)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity)
        .background(
            Capsule()
                .fill(enabled ? Color.accentColor : Color.gray.opacity(0.4))
        )
        .foregroundStyle(Color.white)
        .opacity(enabled ? 1 : 0.6)
    }
}

#Preview {
    VStack(spacing: 16) {
        PrimaryButton(title: "Select Photo", systemImage: "photo")
        PrimaryButton(title: "Disabled", systemImage: "xmark", enabled: false)
    }
    .padding()
}
