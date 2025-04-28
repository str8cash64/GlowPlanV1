import SwiftUI
import FirebaseFirestore
import FirebaseAuth

// Simplified navigation manager to handle the quiz->signup->home flow
class NavigationManager: ObservableObject {
    static let shared = NavigationManager()
    
    @Published var shouldShowHome = false
    @Published var comingFromOnboardingFlow = false
    @Published var onboardingInProgress = false
    
    // Mark a user as having completed onboarding
    func markUserAsOnboarded() {
        if let userId = Auth.auth().currentUser?.uid {
            let db = Firestore.firestore()
            let userData: [String: Any] = [
                "quizCompleted": true,
                "onboardingComplete": true,
                "lastLoginAt": Date().timeIntervalSince1970
            ]
            
            db.collection("users").document(userId).setData(userData, merge: true) { error in
                if let error = error {
                    print("Error updating user data: \(error.localizedDescription)")
                }
            }
        }
        
        // Set the local navigation state to go to home
        DispatchQueue.main.async {
            self.onboardingInProgress = false
            self.shouldShowHome = true
        }
    }
    
    // Simple method to force navigation to home
    func forceNavigateToHome() {
        // Update user data if logged in
        if let userId = Auth.auth().currentUser?.uid {
            let db = Firestore.firestore()
            db.collection("users").document(userId).setData([
                "quizCompleted": true,
                "onboardingComplete": true
            ], merge: true)
        }
        
        // Set the navigation flag and broadcast notification
        DispatchQueue.main.async {
            self.onboardingInProgress = false
            self.shouldShowHome = true
            NotificationCenter.default.post(
                name: Notification.Name("ForceNavigateToHome"),
                object: nil
            )
        }
    }
    
    // Start the onboarding process - call this when starting the quiz
    func startOnboarding() {
        DispatchQueue.main.async {
            self.onboardingInProgress = true
        }
    }
    
    // Check if a user has completed onboarding
    func checkOnboardingStatus(completion: @escaping (Bool) -> Void) {
        // If onboarding is currently in progress, return false to prevent showing the quiz again
        if onboardingInProgress {
            completion(false)
            return
        }
        
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(false)
            return
        }
        
        let db = Firestore.firestore()
        db.collection("users").document(userId).getDocument { document, error in
            if let document = document, document.exists {
                let quizCompleted = document.data()?["quizCompleted"] as? Bool ?? false
                let onboardingComplete = document.data()?["onboardingComplete"] as? Bool ?? false
                
                completion(quizCompleted || onboardingComplete)
            } else {
                completion(false)
            }
        }
    }
    
    // Alias for backward compatibility
    func forceSkipQuiz() {
        forceNavigateToHome()
    }
    
    // Alias for backward compatibility
    func navigateToHomeAfterAuth() {
        markUserAsOnboarded()
    }
    
    // For backward compatibility
    func directJumpToHome() {
        forceNavigateToHome()
    }
    
    // Reset navigation state (for testing)
    func resetNavigationState() {
        DispatchQueue.main.async {
            self.shouldShowHome = false
            self.comingFromOnboardingFlow = false
            self.onboardingInProgress = false
        }
    }
} 