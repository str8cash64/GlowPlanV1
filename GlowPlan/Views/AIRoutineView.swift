import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct AIRoutineView: View {
    @State private var morningRoutine: [RoutineStep] = []
    @State private var eveningRoutine: [RoutineStep] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var skinProfile: [String: String] = [:]
    
    private let db = Firestore.firestore()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                if isLoading {
                    loadingView
                } else if let error = errorMessage {
                    errorView(message: error)
                } else {
                    // Routine header
                    routineHeader
                    
                    // Skin profile summary
                    if !skinProfile.isEmpty {
                        skinProfileSummary
                    }
                    
                    // Morning routine
                    if !morningRoutine.isEmpty {
                        routineSection(
                            title: "Morning Routine",
                            steps: morningRoutine
                        )
                    }
                    
                    // Evening routine
                    if !eveningRoutine.isEmpty {
                        routineSection(
                            title: "Evening Routine",
                            steps: eveningRoutine
                        )
                    }
                    
                    // Regenerate button
                    regenerateButton
                }
            }
            .padding()
            .onAppear {
                loadRoutineFromFirebase()
            }
        }
        .background(Color("SoftWhite").edgesIgnoringSafeArea(.all))
        .navigationTitle("Your Skincare Routine")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Your Skincare Routine")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(Color.white)
            }
        }
        .toolbarBackground(Color("SalmonPink"), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
    
    // MARK: - View Components
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
                .padding()
            
            Text("Loading your personalized routine...")
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(Color("CharcoalGray"))
        }
        .frame(maxWidth: .infinity, minHeight: 200)
        .padding()
    }
    
    private func errorView(message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 40))
                .foregroundColor(Color("SalmonPink"))
            
            Text("Unable to load your routine")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(Color("CharcoalGray"))
            
            Text(message)
                .font(.system(size: 16, design: .rounded))
                .foregroundColor(Color("CharcoalGray").opacity(0.7))
                .multilineTextAlignment(.center)
            
            Button(action: {
                isLoading = true
                errorMessage = nil
                loadRoutineFromFirebase()
            }) {
                Text("Try Again")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(Color.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color("SalmonPink"))
                    .cornerRadius(12)
            }
            .padding(.top, 8)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
    }
    
    private var routineHeader: some View {
        VStack(spacing: 16) {
            // Checkmark circle
            ZStack {
                Circle()
                    .fill(Color("SalmonPink").opacity(0.2))
                    .frame(width: 80, height: 80)
                
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(Color("SalmonPink"))
            }
            
            Text("Your personalized routine is ready!")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(Color("CharcoalGray"))
                .multilineTextAlignment(.center)
            
            Text("Follow these steps for best results.")
                .font(.system(size: 16, design: .rounded))
                .foregroundColor(Color("CharcoalGray").opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
    }
    
    private var skinProfileSummary: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your Skin Profile")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(Color("CharcoalGray"))
            
            // Skin type
            if let skinType = skinProfile["skinType"], !skinType.isEmpty {
                HStack {
                    Text("Type:")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(Color("CharcoalGray"))
                    
                    Text(skinType)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(Color("SalmonPink"))
                    
                    Spacer()
                }
            }
            
            // Concern
            if let concern = skinProfile["primaryConcern"], !concern.isEmpty {
                HStack {
                    Text("Concern:")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(Color("CharcoalGray"))
                    
                    Text(concern)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(Color("SalmonPink"))
                    
                    Spacer()
                }
            }
            
            // Sensitivity
            if let sensitivity = skinProfile["sensitivityLevel"], !sensitivity.isEmpty {
                HStack {
                    Text("Sensitivity:")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(Color("CharcoalGray"))
                    
                    Text(sensitivity)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(Color("SalmonPink"))
                    
                    Spacer()
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
    }
    
    private func routineSection(title: String, steps: [RoutineStep]) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(Color("CharcoalGray"))
            
            // Routine steps
            ForEach(Array(steps.enumerated()), id: \.element.id) { index, step in
                routineStepCard(step: step, number: index + 1)
            }
        }
        .padding(.vertical)
    }
    
    private func routineStepCard(step: RoutineStep, number: Int) -> some View {
        HStack(alignment: .top, spacing: 16) {
            // Step number
            ZStack {
                Circle()
                    .fill(Color("SalmonPink").opacity(0.2))
                    .frame(width: 36, height: 36)
                
                Text("\(number)")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(Color("SalmonPink"))
            }
            
            // Step content
            VStack(alignment: .leading, spacing: 8) {
                // Step name and product
                HStack(alignment: .firstTextBaseline) {
                    Text(step.name)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(Color("CharcoalGray"))
                    
                    if !step.product.isEmpty {
                        Text("→")
                            .font(.system(size: 16, design: .rounded))
                            .foregroundColor(Color("CharcoalGray").opacity(0.7))
                        
                        Text(step.product)
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(Color("SalmonPink"))
                    }
                }
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
                
                // Description
                if !step.description.isEmpty {
                    Text(step.description)
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(Color("CharcoalGray").opacity(0.8))
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
    }
    
    private var regenerateButton: some View {
        Button(action: {
            regenerateRoutine()
        }) {
            HStack {
                Image(systemName: "arrow.triangle.2.circlepath")
                Text("Regenerate Routine")
            }
            .font(.system(size: 16, weight: .medium, design: .rounded))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color("SalmonPink"))
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            )
        }
        .padding(.top, 16)
    }
    
    // MARK: - Data Methods
    
    private func loadRoutineFromFirebase() {
        guard let userId = Auth.auth().currentUser?.uid else {
            isLoading = false
            errorMessage = "You need to be logged in to view your routine."
            return
        }
        
        // Load user skin profile
        db.collection("users").document(userId).collection("profile").document("info")
            .getDocument { document, error in
                if let error = error {
                    print("Error loading skin profile: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        self.isLoading = false
                        self.errorMessage = "Couldn't load your skin profile."
                    }
                    return
                }
                
                if let document = document, document.exists, let data = document.data() {
                    // Extract relevant skin profile data
                    var profile: [String: String] = [:]
                    
                    if let skinType = data["skinType"] as? String {
                        profile["skinType"] = skinType
                    }
                    
                    if let primaryConcern = data["primaryConcern"] as? String {
                        profile["primaryConcern"] = primaryConcern
                    }
                    
                    if let sensitivityLevel = data["sensitivityLevel"] as? String {
                        profile["sensitivityLevel"] = sensitivityLevel
                    }
                    
                    DispatchQueue.main.async {
                        self.skinProfile = profile
                    }
                }
                
                // Now load routine data
                self.loadRoutineSteps(userId: userId)
            }
    }
    
    private func loadRoutineSteps(userId: String) {
        // Try to get the active routine first
        db.collection("users").document(userId).collection("routines").document("activeRoutine")
            .getDocument { document, error in
                if let error = error {
                    print("Error loading routine: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        self.isLoading = false
                        self.errorMessage = "Couldn't load your routine data."
                    }
                    return
                }
                
                if let document = document, document.exists, let data = document.data(),
                   let stepsData = data["steps"] as? [[String: Any]] {
                    
                    // Process steps
                    var morningSteps: [RoutineStep] = []
                    var eveningSteps: [RoutineStep] = []
                    
                    for stepData in stepsData {
                        let id = UUID(uuidString: stepData["id"] as? String ?? "") ?? UUID()
                        let name = stepData["name"] as? String ?? "Step"
                        let product = stepData["product"] as? String ?? ""
                        let description = stepData["description"] as? String ?? ""
                        let timeOfDay = stepData["timeOfDay"] as? String ?? "morning"
                        
                        let step = RoutineStep(id, name: name, product: product, description: description)
                        
                        if timeOfDay.lowercased() == "morning" {
                            morningSteps.append(step)
                        } else {
                            eveningSteps.append(step)
                        }
                    }
                    
                    DispatchQueue.main.async {
                        self.morningRoutine = morningSteps
                        self.eveningRoutine = eveningSteps
                        self.isLoading = false
                    }
                } else {
                    // If no active routine, try to load initial routine
                    self.db.collection("users").document(userId).collection("routines").document("initial")
                        .getDocument { document, error in
                            if let document = document, document.exists, let data = document.data(),
                               let stepsData = data["steps"] as? [[String: Any]] {
                                
                                var allSteps: [RoutineStep] = []
                                
                                for stepData in stepsData {
                                    let id = UUID(uuidString: stepData["id"] as? String ?? "") ?? UUID()
                                    let name = stepData["name"] as? String ?? "Step"
                                    let product = stepData["product"] as? String ?? ""
                                    let description = stepData["description"] as? String ?? ""
                                    
                                    let step = RoutineStep(id, name: name, product: product, description: description)
                                    allSteps.append(step)
                                }
                                
                                // Split steps into morning and evening
                                let midpoint = allSteps.count / 2
                                
                                DispatchQueue.main.async {
                                    self.morningRoutine = Array(allSteps.prefix(midpoint))
                                    self.eveningRoutine = Array(allSteps.suffix(from: midpoint))
                                    self.isLoading = false
                                }
                            } else {
                                // No routine found at all
                                DispatchQueue.main.async {
                                    self.isLoading = false
                                    self.errorMessage = "No routine found. Generate a new one?"
                                }
                            }
                        }
                }
            }
    }
    
    private func regenerateRoutine() {
        // Start loading
        isLoading = true
        
        // Create skin profile from stored data
        let profile = UserSkinProfile()
        profile.skinType = skinProfile["skinType"] ?? "Normal"
        profile.primaryConcern = skinProfile["primaryConcern"] ?? "Hydration"
        profile.sensitivityLevel = skinProfile["sensitivityLevel"] ?? "Not sensitive"
        profile.desiredRoutineTime = "5-10 min"
        
        // Regenerate routine
        RoutineGenerator.shared.generateAndSaveRoutine(skinProfile: profile) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let steps):
                    // Split steps into morning and evening
                    var morning: [RoutineStep] = []
                    var evening: [RoutineStep] = []
                    var currentSection: RoutineSection?
                    
                    // Process steps to separate morning and evening
                    for step in steps {
                        if step.name.lowercased().contains("morning") {
                            currentSection = .morning
                            continue
                        } else if step.name.lowercased().contains("evening") {
                            currentSection = .evening
                            continue
                        }
                        
                        if let section = currentSection {
                            if section == .morning {
                                morning.append(step)
                            } else {
                                evening.append(step)
                            }
                        }
                    }
                    
                    // Update UI
                    self.morningRoutine = morning
                    self.eveningRoutine = evening
                    self.isLoading = false
                    
                case .failure(let error):
                    self.errorMessage = "Failed to generate routine: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }
    }
    
    private enum RoutineSection {
        case morning
        case evening
    }
}

struct AIRoutineView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            AIRoutineView()
        }
    }
} 