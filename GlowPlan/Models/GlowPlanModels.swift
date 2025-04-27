import SwiftUI

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
    
    // Private init to enforce singleton
    private init() {
        // Initialize with sample data
        self.routines = GlowPlanModels.sampleRoutines
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
} 