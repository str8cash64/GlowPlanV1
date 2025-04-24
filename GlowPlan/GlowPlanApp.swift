//
//  GlowPlanApp.swift
//  GlowPlan
//
//  Created by Abdel Fekih on 2025-04-21.
//

import SwiftUI

@main
struct GlowPlanApp: App {
    // Create app state for authentication and onboarding
    @StateObject var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            if appState.isAuthenticated {
                if appState.hasCompletedOnboarding {
                    MainTabView()
                        .environmentObject(appState)
                } else {
                    OnboardingView()
                        .environmentObject(appState)
                }
            } else {
                // For now, just start with onboarding
                OnboardingView()
                    .environmentObject(appState)
            }
        }
    }
}

// App State
class AppState: ObservableObject {
    @Published var isAuthenticated = false
    @Published var hasCompletedOnboarding = false
    
    init() {
        // For development, set default values
        self.isAuthenticated = true
        self.hasCompletedOnboarding = true
    }
}
