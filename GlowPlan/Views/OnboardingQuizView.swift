import SwiftUI

struct OnboardingQuizView: View {
    @StateObject private var skinProfile = UserSkinProfile()
    @State private var currentQuestionIndex = 0
    @State private var showRoutinePreview = false
    
    // For text field questions
    @State private var textFieldValue = ""
    
    // Navigation manager
    @StateObject private var navigationManager = NavigationManager.shared
    
    private var questions = OnboardingQuizData.allQuestions
    private var currentQuestion: OnboardingQuizQuestion { questions[currentQuestionIndex] }
    private var progress: CGFloat {
        CGFloat(currentQuestionIndex) / CGFloat(questions.count - 1)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color("SoftWhite").edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 24) {
                    // Progress bar
                    OnboardingProgressBar(progress: progress)
                        .frame(height: 10)
                        .padding(.horizontal)
                    
                    // Question counter
                    Text("Question \(currentQuestionIndex + 1) of \(questions.count)")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(Color("CharcoalGray").opacity(0.7))
                    
                    ScrollView {
                        VStack(spacing: 24) {
                            // Question
                            Text(currentQuestion.question)
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundColor(Color("CharcoalGray"))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                                .padding(.top, 16)
                            
                            // Question instructions for multi-select
                            if currentQuestion.questionType == .multiSelect {
                                Text("Select all that apply")
                                    .font(.system(size: 16, design: .rounded))
                                    .foregroundColor(Color("CharcoalGray").opacity(0.7))
                            }
                            
                            Spacer(minLength: 20)
                            
                            // Different input controls based on question type
                            switch currentQuestion.questionType {
                            case .singleSelect:
                                SingleSelectOptions(
                                    options: currentQuestion.options,
                                    selectedOption: getSingleSelection(),
                                    onSelect: { option in
                                        skinProfile.saveResponse(for: currentQuestion.id, singleSelection: option)
                                    }
                                )
                            
                            case .multiSelect:
                                MultiSelectOptions(
                                    options: currentQuestion.options,
                                    selectedOptions: getMultiSelections(),
                                    onSelect: { options in
                                        skinProfile.saveResponse(for: currentQuestion.id, multiSelections: options)
                                    }
                                )
                            
                            case .toggle:
                                ToggleOption(
                                    isOn: getToggleValue(),
                                    onToggle: { value in
                                        skinProfile.saveResponse(for: currentQuestion.id, toggleValue: value)
                                    }
                                )
                            
                            case .textField:
                                CustomTextField(
                                    text: $textFieldValue,
                                    placeholder: currentQuestion.textFieldPlaceholder,
                                    onCommit: {
                                        skinProfile.saveResponse(for: currentQuestion.id, textValue: textFieldValue)
                                    }
                                )
                                .onAppear {
                                    // Set the text field value when the view appears
                                    switch currentQuestion.id {
                                    case 7: textFieldValue = skinProfile.allergies
                                    case 8: textFieldValue = skinProfile.preferredIngredients
                                    default: textFieldValue = ""
                                    }
                                }
                            }
                            
                            Spacer()
                        }
                        .padding(.bottom, 100) // Extra padding for the bottom buttons
                    }
                }
                
                // Navigation buttons
                VStack {
                    Spacer()
                    
                    HStack(spacing: 16) {
                        // Back button
                        if currentQuestionIndex > 0 {
                            Button(action: {
                                withAnimation {
                                    currentQuestionIndex -= 1
                                }
                            }) {
                                HStack {
                                    Image(systemName: "chevron.left")
                                    Text("Back")
                                }
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundColor(Color("CharcoalGray"))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.white)
                                .cornerRadius(16)
                                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                            }
                        }
                        
                        // Next/Finish button
                        Button(action: {
                            // If text field, save the value
                            if currentQuestion.questionType == .textField {
                                skinProfile.saveResponse(for: currentQuestion.id, textValue: textFieldValue)
                            }
                            
                            withAnimation {
                                if currentQuestionIndex < questions.count - 1 {
                                    currentQuestionIndex += 1
                                } else {
                                    showRoutinePreview = true
                                }
                            }
                        }) {
                            Text(currentQuestionIndex < questions.count - 1 ? "Next" : "Show My Routine")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color("SalmonPink"))
                                .cornerRadius(16)
                                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                        }
                        .disabled(!isCurrentQuestionAnswered())
                        .opacity(isCurrentQuestionAnswered() ? 1.0 : 0.5)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 40)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color("SoftWhite").opacity(0), Color("SoftWhite")]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: 100)
                        .edgesIgnoringSafeArea(.bottom)
                    )
                }
            }
            .navigationTitle("Skincare Quiz")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(Color("SalmonPink"), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .navigationDestination(isPresented: $showRoutinePreview) {
                RoutinePreviewView(skinProfile: skinProfile)
            }
            .onAppear {
                // Mark that onboarding is in progress to prevent duplicate quiz
                navigationManager.startOnboarding()
                // Also tell FirebaseManager
                FirebaseManager.shared.startOnboardingProcess()
            }
        }
    }
    
    // Helper methods to get the current value for different question types
    private func getSingleSelection() -> String {
        switch currentQuestion.id {
        case 1: return skinProfile.skinType
        case 3: return skinProfile.sensitivityLevel
        case 4: return skinProfile.routineFrequency
        case 5: return skinProfile.experienceLevel
        case 6: return skinProfile.primaryConcern
        case 10: return skinProfile.climate
        case 11: return skinProfile.desiredRoutineTime
        case 14: return skinProfile.fragrancePreference
        default: return ""
        }
    }
    
    private func getMultiSelections() -> [String] {
        switch currentQuestion.id {
        case 2: return skinProfile.skinGoals
        default: return []
        }
    }
    
    private func getToggleValue() -> Bool {
        switch currentQuestion.id {
        case 9: return skinProfile.usingPrescription
        case 12: return skinProfile.usesSPF
        case 13: return skinProfile.doubleCleanses
        case 15: return skinProfile.wantsProductRecommendations
        default: return false
        }
    }
    
    // Check if the current question has been answered
    private func isCurrentQuestionAnswered() -> Bool {
        switch currentQuestion.questionType {
        case .singleSelect:
            return !getSingleSelection().isEmpty
        case .multiSelect:
            // Allow multi-select to be optional (can proceed without selecting)
            return true
        case .toggle:
            // Toggle is always answered (default is false)
            return true
        case .textField:
            // Text field is optional
            return true
        }
    }
}

// MARK: - Supporting Views

struct OnboardingProgressBar: View {
    let progress: CGFloat
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 10)
                
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color("SalmonPink"))
                    .frame(width: geometry.size.width * progress, height: 10)
                    .animation(.spring(response: 0.5), value: progress)
            }
        }
    }
}

struct SingleSelectOptions: View {
    let options: [String]
    let selectedOption: String
    let onSelect: (String) -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            ForEach(options, id: \.self) { option in
                Button(action: {
                    onSelect(option)
                }) {
                    HStack {
                        Text(option)
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .foregroundColor(selectedOption == option ? .white : Color("CharcoalGray"))
                            .padding(.vertical, 16)
                            .padding(.leading, 16)
                        
                        Spacer()
                        
                        if selectedOption == option {
                            Image(systemName: "checkmark")
                                .foregroundColor(.white)
                                .padding(.trailing, 16)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(selectedOption == option ? Color("SalmonPink") : Color.white)
                            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal)
    }
}

struct MultiSelectOptions: View {
    let options: [String]
    let selectedOptions: [String]
    let onSelect: ([String]) -> Void
    
    @State private var localSelections: [String] = []
    
    var body: some View {
        VStack(spacing: 12) {
            ForEach(options, id: \.self) { option in
                let isSelected = localSelections.contains(option)
                
                Button(action: {
                    // Toggle selection
                    if isSelected {
                        localSelections.removeAll { $0 == option }
                    } else {
                        localSelections.append(option)
                    }
                    onSelect(localSelections)
                }) {
                    HStack {
                        Text(option)
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .foregroundColor(isSelected ? .white : Color("CharcoalGray"))
                            .padding(.vertical, 16)
                            .padding(.leading, 16)
                        
                        Spacer()
                        
                        if isSelected {
                            Image(systemName: "checkmark")
                                .foregroundColor(.white)
                                .padding(.trailing, 16)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(isSelected ? Color("SalmonPink") : Color.white)
                            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal)
        .onAppear {
            localSelections = selectedOptions
        }
    }
}

struct ToggleOption: View {
    @State private var isToggled: Bool
    let onToggle: (Bool) -> Void
    
    init(isOn: Bool, onToggle: @escaping (Bool) -> Void) {
        _isToggled = State(initialValue: isOn)
        self.onToggle = onToggle
    }
    
    var body: some View {
        HStack {
            Text(isToggled ? "Yes" : "No")
                .font(.system(size: 18, weight: .medium, design: .rounded))
                .foregroundColor(Color("CharcoalGray"))
            
            Spacer()
            
            Toggle("", isOn: $isToggled)
                .onChange(of: isToggled) { newValue in
                    onToggle(newValue)
                }
                .tint(Color("SalmonPink"))
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
        .padding(.horizontal)
    }
}

struct CustomTextField: View {
    @Binding var text: String
    let placeholder: String
    let onCommit: () -> Void
    
    var body: some View {
        VStack {
            TextField(placeholder, text: $text, axis: .vertical)
                .font(.system(size: 18, weight: .medium, design: .rounded))
                .foregroundColor(Color("CharcoalGray"))
                .padding()
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                .frame(height: 120, alignment: .top)
                .multilineTextAlignment(.leading)
                .onSubmit {
                    onCommit()
                }
        }
        .padding(.horizontal)
    }
}

struct OnboardingQuizView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingQuizView()
    }
} 