//
//  ModaAppApp.swift
//  ModaApp
//
//  Created by Vahi Guner on 6/3/25.
//  Updated to include CreditsManager, LocalizationManager and HomeView as root
//

import SwiftUI

@main
struct ModaAppApp: App {
    @StateObject private var creditsManager = CreditsManager.shared
    @StateObject private var localizationManager = LocalizationManager.shared
    
    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(creditsManager)
                .environmentObject(localizationManager)
        }
    }
}
