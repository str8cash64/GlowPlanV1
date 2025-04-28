import SwiftUI
import FirebaseFirestore
import FirebaseAuth

// MARK: - Main namespaces to avoid conflicts
enum GlowPlanModels {
    // MARK: - Core Models
    struct RoutineStep: Identifiable {
        var id: UUID
        var name: String
        var isCompleted: Bool
        var icon: String
        
        init(id: UUID = UUID(), name: String, isCompleted: Bool, icon: String) {
            self.id = id
            self.name = name
            self.isCompleted = isCompleted
            self.icon = icon
        }
    }
    
    struct Routine: Identifiable {
        var id: UUID
        var name: String
        var timeOfDay: String
        var isActive: Bool
        var steps: [RoutineStep]
        
        init(id: UUID = UUID(), name: String, timeOfDay: String, isActive: Bool, steps: [RoutineStep]) {
            self.id = id
            self.name = name
            self.timeOfDay = timeOfDay
            self.isActive = isActive
            self.steps = steps
        }
    }
    
    // MARK: - Sample Data
    static let sampleRoutines = [
        Routine(
            name: "Morning Routine",
            timeOfDay: "Morning",
            isActive: true,
            steps: [
                RoutineStep(name: "Cleanse with CeraVe Hydrating Cleanser", isCompleted: true, icon: "drop.fill"),
                RoutineStep(name: "Apply Vitamin C Serum", isCompleted: true, icon: "sparkles"),
                RoutineStep(name: "Moisturize with Neutrogena Hydro Boost", isCompleted: false, icon: "humidity.fill"),
                RoutineStep(name: "Apply SPF 50 Sunscreen", isCompleted: false, icon: "sun.max.fill")
            ]
        ),
        Routine(
            name: "Evening Routine",
            timeOfDay: "Evening",
            isActive: true,
            steps: [
                RoutineStep(name: "Oil Cleanse with DHC Deep Cleansing Oil", isCompleted: false, icon: "drop.fill"),
                RoutineStep(name: "Second Cleanse with La Roche-Posay", isCompleted: false, icon: "drop.fill"),
                RoutineStep(name: "Apply Retinol", isCompleted: false, icon: "sparkles"),
                RoutineStep(name: "Apply Night Cream", isCompleted: false, icon: "moon.fill")
            ]
        ),
        Routine(
            name: "Weekly Treatment",
            timeOfDay: "Weekend",
            isActive: true,
            steps: [
                RoutineStep(name: "Exfoliate with AHA/BHA", isCompleted: false, icon: "sparkles"),
                RoutineStep(name: "Apply Sheet Mask", isCompleted: false, icon: "bandage.fill"),
                RoutineStep(name: "Apply Face Oil", isCompleted: false, icon: "drop.fill")
            ]
        )
    ]
}

// MARK: - Routine Manager
class RoutineManager: ObservableObject {
    // Singleton for app-wide state
    static let shared = RoutineManager()
    
    // Published properties for state management
    @Published var routines: [GlowPlanModels.Routine]
    @Published var isLoading = false
    
    // Private init to enforce singleton
    private init() {
        // Initialize with sample data
        self.routines = GlowPlanModels.sampleRoutines
        
        // Load routines from Firebase if user is logged in
        loadRoutinesFromFirebase()
    }
    
    // Function to toggle a step's completion status
    func toggleStepCompletion(routineId: UUID, stepId: UUID) {
        if let routineIndex = routines.firstIndex(where: { $0.id == routineId }),
           let stepIndex = routines[routineIndex].steps.firstIndex(where: { $0.id == stepId }) {
            // Toggle the step's completion status
            routines[routineIndex].steps[stepIndex].isCompleted.toggle()
        }
    }
    
    // Function to update a routine
    func updateRoutine(_ routine: GlowPlanModels.Routine) {
        if let index = routines.firstIndex(where: { $0.id == routine.id }) {
            routines[index] = routine
        }
    }
    
    // Function to get a specific routine by ID
    func getRoutine(id: UUID) -> GlowPlanModels.Routine? {
        return routines.first(where: { $0.id == id })
    }
    
    // Function to get a routine by time of day
    func getRoutineByTimeOfDay(_ timeOfDay: String) -> GlowPlanModels.Routine? {
        return routines.first(where: { $0.timeOfDay == timeOfDay })
    }
    
    // Function to load routines from Firebase
    func loadRoutinesFromFirebase() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("Not loading routines: User not logged in")
            return
        }
        
        isLoading = true
        let db = Firestore.firestore()
        
        // Create an array to hold the loaded routines
        var loadedRoutines: [GlowPlanModels.Routine] = []
        
        // Load morning routine
        db.collection("users").document(userId).collection("routines").document("morning")
            .getDocument { [weak self] document, error in
                if let error = error {
                    print("Error loading morning routine: \(error.localizedDescription)")
                    return
                }
                
                if let document = document, document.exists, let data = document.data() {
                    // Parse the routine data
                    let name = data["name"] as? String ?? "Morning Routine"
                    let timeOfDay = data["timeOfDay"] as? String ?? "Morning"
                    let isActive = data["isActive"] as? Bool ?? true
                    
                    // Parse steps
                    var routineSteps: [GlowPlanModels.RoutineStep] = []
                    if let stepsData = data["steps"] as? [[String: Any]] {
                        for stepData in stepsData {
                            let stepId = UUID(uuidString: stepData["id"] as? String ?? UUID().uuidString) ?? UUID()
                            let stepName = stepData["name"] as? String ?? ""
                            let stepDescription = stepData["description"] as? String ?? ""
                            
                            // Create a new step
                            let step = GlowPlanModels.RoutineStep(
                                id: stepId,
                                name: stepName,
                                isCompleted: false,
                                icon: self?.getIconForStep(stepName) ?? "sparkles"
                            )
                            routineSteps.append(step)
                        }
                    }
                    
                    // Create the routine
                    let morningRoutine = GlowPlanModels.Routine(
                        name: name,
                        timeOfDay: timeOfDay,
                        isActive: isActive,
                        steps: routineSteps
                    )
                    
                    // Add to loaded routines
                    loadedRoutines.append(morningRoutine)
                    
                    // Now load evening routine
                    db.collection("users").document(userId).collection("routines").document("evening")
                        .getDocument { document, error in
                            if let error = error {
                                print("Error loading evening routine: \(error.localizedDescription)")
                                return
                            }
                            
                            if let document = document, document.exists, let data = document.data() {
                                // Parse the routine data
                                let name = data["name"] as? String ?? "Evening Routine"
                                let timeOfDay = data["timeOfDay"] as? String ?? "Evening"
                                let isActive = data["isActive"] as? Bool ?? true
                                
                                // Parse steps
                                var routineSteps: [GlowPlanModels.RoutineStep] = []
                                if let stepsData = data["steps"] as? [[String: Any]] {
                                    for stepData in stepsData {
                                        let stepId = UUID(uuidString: stepData["id"] as? String ?? UUID().uuidString) ?? UUID()
                                        let stepName = stepData["name"] as? String ?? ""
                                        let stepDescription = stepData["description"] as? String ?? ""
                                        
                                        // Create a new step
                                        let step = GlowPlanModels.RoutineStep(
                                            id: stepId,
                                            name: stepName,
                                            isCompleted: false,
                                            icon: self?.getIconForStep(stepName) ?? "sparkles"
                                        )
                                        routineSteps.append(step)
                                    }
                                }
                                
                                // Create the routine
                                let eveningRoutine = GlowPlanModels.Routine(
                                    name: name,
                                    timeOfDay: timeOfDay,
                                    isActive: isActive,
                                    steps: routineSteps
                                )
                                
                                // Add to loaded routines
                                loadedRoutines.append(eveningRoutine)
                                
                                // Update the routines on the main thread
                                DispatchQueue.main.async {
                                    if loadedRoutines.isEmpty {
                                        print("No routines loaded from Firebase, using sample data")
                                    } else {
                                        print("Loaded \(loadedRoutines.count) routines from Firebase")
                                        self?.routines = loadedRoutines
                                    }
                                    self?.isLoading = false
                                }
                            } else {
                                // If evening routine doesn't exist, update with just morning routine
                                DispatchQueue.main.async {
                                    if !loadedRoutines.isEmpty {
                                        print("Loaded morning routine from Firebase")
                                        self?.routines = loadedRoutines
                                    }
                                    self?.isLoading = false
                                }
                            }
                        }
                } else {
                    // If morning routine doesn't exist, keep sample data
                    DispatchQueue.main.async {
                        print("No morning routine found in Firebase")
                        self?.isLoading = false
                    }
                }
            }
    }
    
    // Helper function to determine icon based on step name
    private func getIconForStep(_ stepName: String) -> String {
        let stepNameLower = stepName.lowercased()
        
        if stepNameLower.contains("cleanse") || stepNameLower.contains("clean") || stepNameLower.contains("wash") {
            return "drop.fill"
        } else if stepNameLower.contains("spf") || stepNameLower.contains("sunscreen") || stepNameLower.contains("sun") {
            return "sun.max.fill"
        } else if stepNameLower.contains("moisturize") || stepNameLower.contains("hydrat") {
            return "humidity.fill"
        } else if stepNameLower.contains("serum") || stepNameLower.contains("oil") {
            return "sparkles"
        } else if stepNameLower.contains("mask") {
            return "bandage.fill"
        } else if stepNameLower.contains("night") || stepNameLower.contains("evening") || stepNameLower.contains("sleep") {
            return "moon.fill"
        } else {
            return "sparkles"
        }
    }
} 