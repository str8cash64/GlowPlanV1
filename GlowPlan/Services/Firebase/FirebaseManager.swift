import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore
import Foundation

class FirebaseManager: ObservableObject {
    // MARK: - Properties
    
    // Singleton instance
    static let shared = FirebaseManager()
    
    // Firestore reference
    private let db = Firestore.firestore()
    
    // Authentication status
    @Published var isLoggedIn = false
    @Published var hasCompletedOnboarding = false
    @Published var userId: String?
    @Published var isLoading = false
    
    // MARK: - Initialization
    
    private init() {
        // Listen for auth state changes
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                self?.isLoggedIn = user != nil
                self?.userId = user?.uid
                
                if let uid = user?.uid {
                    self?.checkOnboardingStatus(userId: uid)
                }
            }
        }
    }
    
    // MARK: - Private Helper Methods
    
    private func checkOnboardingStatus(userId: String) {
        db.collection("users").document(userId).getDocument { [weak self] document, error in
            if let document = document, document.exists, let data = document.data() {
                DispatchQueue.main.async {
                    self?.hasCompletedOnboarding = data["quizCompleted"] as? Bool ?? false
                }
            }
        }
    }
    
    // MARK: - Authentication Methods
    
    /// Sign up with email and password
    func signUp(email: String, password: String, fullName: String) async throws -> Bool {
        do {
            // Create the user account
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            let user = result.user
            
            // Save the user's name to Firestore
            let userData: [String: Any] = [
                "fullName": fullName,
                "email": email,
                "createdAt": Date().timeIntervalSince1970,
                // If onboarding is in progress, mark the quiz as completed
                "quizCompleted": NavigationManager.shared.onboardingInProgress,
                "onboardingComplete": NavigationManager.shared.onboardingInProgress
            ]
            
            try await Firestore.firestore().collection("users").document(user.uid).setData(userData)
            
            // Update auth state
            DispatchQueue.main.async {
                self.isLoggedIn = true
                // If onboarding is already in progress, skip showing it again
                if NavigationManager.shared.onboardingInProgress {
                    NavigationManager.shared.shouldShowHome = true
                    self.hasCompletedOnboarding = true
                } else {
                    self.hasCompletedOnboarding = false
                }
            }
            
            print("User signed up successfully: \(user.uid)")
            return true
        } catch {
            print("Error signing up: \(error.localizedDescription)")
            throw error
        }
    }
    
    /// Sign in with email and password
    func signIn(email: String, password: String, completion: @escaping (Bool, String?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                completion(false, error.localizedDescription)
                return
            }
            
            if let user = authResult?.user {
                completion(true, nil)
            } else {
                completion(false, "Failed to sign in")
            }
        }
    }
    
    /// Sign out the current user
    func signOut() {
        do {
            try Auth.auth().signOut()
            // Clear cached user data directly to avoid calling clearUserCache method
            UserDefaults.standard.removeObject(forKey: "cached_user_name")
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Data Storage Methods
    
    /// Save user skin profile to Firestore
    func saveUserProfile(skinProfile: UserSkinProfile, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            let error = NSError(domain: "FirebaseManager", code: 1003, 
                               userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
            completion(.failure(error))
            return
        }
        
        // Create a simple dictionary with skin profile data
        var profileData: [String: Any] = [:]
        
        // Add each field manually
        profileData["skinType"] = skinProfile.skinType
        profileData["skinGoals"] = skinProfile.skinGoals
        profileData["sensitivityLevel"] = skinProfile.sensitivityLevel
        profileData["experienceLevel"] = skinProfile.experienceLevel
        profileData["routineFrequency"] = skinProfile.routineFrequency
        profileData["primaryConcern"] = skinProfile.primaryConcern
        profileData["preferredIngredients"] = skinProfile.preferredIngredients
        profileData["allergies"] = skinProfile.allergies
        profileData["usesSPF"] = skinProfile.usesSPF
        profileData["fragrancePreference"] = skinProfile.fragrancePreference
        profileData["climate"] = skinProfile.climate
        profileData["desiredRoutineTime"] = skinProfile.desiredRoutineTime
        profileData["doubleCleanses"] = skinProfile.doubleCleanses
        profileData["wantsProductRecommendations"] = skinProfile.wantsProductRecommendations
        profileData["usingPrescription"] = skinProfile.usingPrescription
        
        // Save profile data to Firestore
        db.collection("users").document(userId).collection("profile").document("info")
            .setData(profileData, merge: true) { error in
                if let error = error {
                    print("Error saving profile: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }
                
                // Set quizCompleted flag in user document
                self.db.collection("users").document(userId)
                    .setData(["quizCompleted": true], merge: true) { error in
                        if let error = error {
                            print("Error setting quizCompleted flag: \(error.localizedDescription)")
                            completion(.failure(error))
                        } else {
                            completion(.success(()))
                        }
                    }
            }
    }
    
    /// Save routine steps to Firestore
    func saveRoutine(steps: [RoutineStep], completion: @escaping (Result<Void, Error>) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            let error = NSError(domain: "FirebaseManager", code: 1003, 
                               userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
            completion(.failure(error))
            return
        }
        
        // Create a simple array of dictionaries for routine steps
        var stepsArray: [[String: Any]] = []
        
        // Add each step manually
        for step in steps {
            var stepDict: [String: Any] = [:]
            stepDict["id"] = step.id.uuidString
            stepDict["name"] = step.name
            stepDict["product"] = step.product
            stepDict["description"] = step.description
            stepsArray.append(stepDict)
        }
        
        // Create the routine document data
        let routineData: [String: Any] = [
            "steps": stepsArray,
            "createdAt": FieldValue.serverTimestamp(),
            "name": "My Personalized Routine",
            "isActive": true
        ]
        
        // Save routine data to Firestore
        db.collection("users").document(userId).collection("routines").document("initial")
            .setData(routineData, merge: true) { error in
                if let error = error {
                    print("Error saving routine: \(error.localizedDescription)")
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
    }
    
    /// Save both profile and routine in one operation
    func saveOnboardingData(skinProfile: UserSkinProfile, routineSteps: [RoutineStep], completion: @escaping (Bool) -> Void) {
        // Make sure user is authenticated
        guard let userId = Auth.auth().currentUser?.uid else {
            print("Error: No authenticated user when trying to save onboarding data")
            completion(false)
            return
        }
        
        // First save the profile
        saveUserProfile(skinProfile: skinProfile) { result in
            switch result {
            case .success():
                // Then save the routine
                self.saveRoutine(steps: routineSteps) { routineResult in
                    switch routineResult {
                    case .success():
                        // Both saved successfully
                        completion(true)
                    case .failure(let error):
                        print("Error saving routine during onboarding: \(error.localizedDescription)")
                        completion(false)
                    }
                }
            case .failure(let error):
                print("Error saving profile during onboarding: \(error.localizedDescription)")
                completion(false)
            }
        }
    }
    
    /// Save routine for a specific user
    func saveRoutine(userId: String, skinProfile: UserSkinProfile, routineSteps: [RoutineStep], completion: @escaping (Bool) -> Void) {
        // First save the profile under the user's document
        saveUserProfile(skinProfile: skinProfile) { result in
            switch result {
            case .success():
                // Then save the routine
                self.saveRoutine(steps: routineSteps) { routineResult in
                    switch routineResult {
                    case .success():
                        // Both saved successfully
                        completion(true)
                    case .failure(let error):
                        print("Error saving routine: \(error.localizedDescription)")
                        completion(false)
                    }
                }
            case .failure(let error):
                print("Error saving profile: \(error.localizedDescription)")
                completion(false)
            }
        }
    }
    
    // Add a method to start the onboarding process
    func startOnboardingProcess() {
        NavigationManager.shared.startOnboarding()
    }
    
    func checkAuthenticationStatus() {
        self.isLoading = true
        
        // Check if user is logged in
        if let currentUser = Auth.auth().currentUser {
            print("User is authenticated: \(currentUser.uid)")
            self.isLoggedIn = true
            self.userId = currentUser.uid
            
            // Check if the user needs to complete the quiz/onboarding
            NavigationManager.shared.checkOnboardingStatus { onboardingComplete in
                DispatchQueue.main.async {
                    // If onboarding is complete or in progress, don't show quiz
                    if onboardingComplete || NavigationManager.shared.onboardingInProgress {
                        NavigationManager.shared.shouldShowHome = true
                        self.hasCompletedOnboarding = true
                    } else {
                        // User needs to complete onboarding
                        self.hasCompletedOnboarding = false
                    }
                    self.isLoading = false
                }
            }
        } else {
            print("User is not authenticated")
            DispatchQueue.main.async {
                self.isLoggedIn = false
                self.hasCompletedOnboarding = false
                self.userId = nil
                self.isLoading = false
            }
        }
    }
} 