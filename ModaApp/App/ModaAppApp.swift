//
//  ModaAppApp.swift
//  ModaApp
//
//  Created by Vahi Guner on 6/3/25.
//  Updated to include CreditsManager
//

import SwiftUI

@main
struct ModaAppApp: App {
    @StateObject private var creditsManager = CreditsManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(creditsManager)
        }
    }
}
