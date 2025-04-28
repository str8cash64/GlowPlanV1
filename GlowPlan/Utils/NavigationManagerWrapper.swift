import SwiftUI

// Helper class to capture and provide access to a NavigationManager from the environment
class NavigationManagerWrapper: ObservableObject {
    static let shared = NavigationManagerWrapper()
    
    @Published var manager: NavigationManager?
    
    private var didCapture = false
    
    // Call this in onAppear to try to capture the environment object if it exists
    func captureIfPresent() {
        if manager == nil && !didCapture {
            // This is a workaround since we can't check if an @EnvironmentObject exists
            // Instead, we'll use the shared instance as a fallback
            didCapture = true
            let currentView = UIApplication.shared.windows.first?.rootViewController?.view
            
            // Attempt to find a NavigationManager in the environment
            // If not found, we'll continue to use the nil value and fall back to the local instance
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                if self.manager == nil {
                    self.manager = NavigationManager.shared
                }
            }
        }
    }
    
    // Reset the captured manager
    func reset() {
        didCapture = false
        manager = nil
    }
} 