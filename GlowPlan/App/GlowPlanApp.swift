import SwiftUI
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore

@main
struct GlowPlanApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var authViewModel = AuthViewModel()
    
    var body: some Scene {
        WindowGroup {
            // For development, start with onboarding flow by default
            NavigationStack {
                OnboardingView()
            }
            
            // Uncomment this for the full Firebase-based flow
            /*
            ZStack {
                if !delegate.firebaseConfigured {
                    // Firebase is not configured yet
                    OnboardingView()
                        .overlay(
                            Text("Firebase Not Configured")
                                .font(.caption)
                                .foregroundColor(.red)
                                .padding(8)
                                .background(Color.white.opacity(0.8))
                                .cornerRadius(8)
                                .padding(),
                            alignment: .bottom
                        )
                } else if authViewModel.isCheckingAuth {
                    // Show loading screen while checking auth state
                    LoadingView()
                } else if authViewModel.isLoggedIn {
                    // User is logged in
                    if authViewModel.hasCompletedOnboarding {
                        // User has completed onboarding, show main app
                        MainTabView()
                    } else {
                        // User is logged in but hasn't completed onboarding, show quiz
                        OnboardingQuizView()
                    }
                } else {
                    // User is not logged in, show onboarding
                    NavigationStack {
                        OnboardingView()
                    }
                }
            }
            */
        }
    }
}

// AuthViewModel to handle authentication state
class AuthViewModel: ObservableObject {
    @Published var isLoggedIn = false
    @Published var hasCompletedOnboarding = false
    @Published var isCheckingAuth = true
    
    init() {
        checkAuthState()
    }
    
    private func checkAuthState() {
        Auth.auth().addStateDidChangeListener { [weak self] auth, user in
            guard let self = self else { return }
            
            if let user = user {
                // User is logged in, check if they've completed the onboarding
                self.isLoggedIn = true
                
                let db = Firestore.firestore()
                db.collection("users").document(user.uid).getDocument { [weak self] document, error in
                    guard let self = self else { return }
                    
                    DispatchQueue.main.async {
                        if let document = document, document.exists {
                            self.hasCompletedOnboarding = document.data()?["quizCompleted"] as? Bool ?? false
                        } else {
                            self.hasCompletedOnboarding = false
                        }
                        
                        self.isCheckingAuth = false
                    }
                }
            } else {
                // User is not logged in
                DispatchQueue.main.async {
                    self.isLoggedIn = false
                    self.hasCompletedOnboarding = false
                    self.isCheckingAuth = false
                }
            }
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
}

// Loading View
struct LoadingView: View {
    var body: some View {
        ZStack {
            Color("SoftWhite").ignoresSafeArea()
            
            VStack {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(2)
                    .padding(.bottom, 24)
                
                Text("Loading...")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(Color("CharcoalGray"))
            }
        }
    }
}

// AppDelegate for Firebase setup
class AppDelegate: NSObject, UIApplicationDelegate {
    var firebaseConfigured = false
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Check if GoogleService-Info.plist exists before initializing Firebase
        if Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil {
            FirebaseApp.configure()
            firebaseConfigured = true
        } else {
            print("⚠️ GoogleService-Info.plist not found. Firebase will not be initialized. Please add your Firebase configuration file.")
        }
        return true
    }
} 