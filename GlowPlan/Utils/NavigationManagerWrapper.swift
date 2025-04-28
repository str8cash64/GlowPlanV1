import SwiftUI
import Foundation
import FirebaseAuth

// A wrapper to help with environment object handling
// This is needed to handle cases where the view might be presented directly
// without an environment object
class NavigationManagerWrapper: ObservableObject {
    static let shared = NavigationManagerWrapper()
    
    // This will be set when the wrapper is used from a view that has access
    // to the environment object
    @Published var manager: NavigationManager?
    
    private init() {}
    
    // Call this method to capture an environment object if it exists
    func captureIfPresent() {
        if manager == nil {
            // Use the singleton instance if no environment object is set
            manager = NavigationManager.shared
        }
    }
    
    // Reset the captured manager
    func reset() {
        manager = nil
    }
} 