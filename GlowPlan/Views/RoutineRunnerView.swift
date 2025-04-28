import SwiftUI

// MARK: - Runner Components
enum RunnerComponents {
    case progressBar
    case stepView
    case actionButtons
    case completionView
}

struct RoutineRunnerView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var currentStepIndex: Int = 0
    @State private var isRoutineComplete: Bool = false
    @State private var showingCompletionScreen: Bool = false
    @State private var animationProgress: CGFloat = 0.0
    
    let routine: GlowPlanModels.Routine
    
    // Computed progress percentage
    private var progress: CGFloat {
        guard !routine.steps.isEmpty else { return 1.0 }
        return CGFloat(currentStepIndex) / CGFloat(routine.steps.count)
    }
    
    var body: some View {
        ZStack {
            Color("SoftWhite").edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 24) {
                // MARK: Header with Progress
                headerView
                
                // MARK: Current Step Card
                if !isRoutineComplete {
                    currentStepView
                    
                    // MARK: Action Buttons
                    actionButtonsView
                } else {
                    // MARK: Completion View
                    completionView
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
        }
        .navigationTitle("Running Routine")
        .navigationBarTitleDisplayMode(.inline)
        .applyGlowNavigationBarStyle(backgroundColor: UIColor(named: "SalmonPink") ?? .systemPink, textColor: .white)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                if !isRoutineComplete {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.white)
                            .imageScale(.large)
                    }
                }
            }
        }
    }
    
    // MARK: - Component Views
    
    // Header with progress bar component
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(routine.name)
                .font(.title.bold())
                .foregroundColor(Color("CharcoalGray"))
            
            // Progress indicator
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 10)
                
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color("SalmonPink"))
                    .frame(width: UIScreen.main.bounds.width * 0.9 * progress, height: 10)
                    .animation(.spring(response: 0.5), value: progress)
            }
            
            HStack {
                Text("\(currentStepIndex + 1) of \(routine.steps.count)")
                    .font(.subheadline)
                    .foregroundColor(Color("CharcoalGray").opacity(0.7))
                
                Spacer()
                
                Text("\(Int(progress * 100))% Complete")
                    .font(.subheadline)
                    .foregroundColor(Color("SalmonPink"))
            }
        }
    }
    
    // Current step view component
    private var currentStepView: some View {
        VStack(spacing: 0) {
            let currentStep = routine.steps[currentStepIndex]
            
            // Step Card
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                
                VStack(spacing: 24) {
                    // Icon
                    ZStack {
                        Circle()
                            .fill(Color("SalmonPink").opacity(0.2))
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: currentStep.icon)
                            .font(.system(size: 32))
                            .foregroundColor(Color("SalmonPink"))
                    }
                    .padding(.top, 30)
                    
                    // Text
                    VStack(spacing: 12) {
                        Text("Step \(currentStepIndex + 1)")
                            .font(.headline)
                            .foregroundColor(Color("SalmonPink"))
                        
                        Text(currentStep.name)
                            .font(.title3.bold())
                            .foregroundColor(Color("CharcoalGray"))
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.horizontal)
                        
                        // Timer animation (placeholder)
                        ZStack {
                            Circle()
                                .stroke(Color.gray.opacity(0.2), lineWidth: 4)
                                .frame(width: 60, height: 60)
                            
                            Circle()
                                .trim(from: 0, to: animationProgress)
                                .stroke(Color("SalmonPink"), lineWidth: 4)
                                .frame(width: 60, height: 60)
                                .rotationEffect(.degrees(-90))
                                .animation(.linear(duration: 0.5), value: animationProgress)
                            
                            Image(systemName: "checkmark")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(Color("SalmonPink"))
                                .opacity(animationProgress >= 1.0 ? 1.0 : 0.0)
                        }
                        .onAppear {
                            withAnimation(.easeOut(duration: 2.0)) {
                                animationProgress = 1.0
                            }
                        }
                    }
                    
                    Spacer()
                }
                .padding(.bottom, 30)
            }
            .frame(height: 300)
        }
        .padding(.vertical, 20)
    }
    
    // Action buttons component
    private var actionButtonsView: some View {
        VStack(spacing: 16) {
            // Main action button
            Button(action: {
                markCurrentStepComplete()
            }) {
                Text("Complete Step")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color("SalmonPink"))
                    .cornerRadius(12)
            }
            
            // Skip button
            Button(action: {
                moveToNextStep()
            }) {
                Text("Skip Step")
                    .font(.headline)
                    .foregroundColor(Color("CharcoalGray"))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
            }
        }
    }
    
    // Completion view component
    private var completionView: some View {
        VStack(spacing: 30) {
            // Success image
            ZStack {
                Circle()
                    .fill(Color("SalmonPink").opacity(0.2))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(Color("SalmonPink"))
            }
            
            // Text
            VStack(spacing: 12) {
                Text("Great job!")
                    .font(.title.bold())
                    .foregroundColor(Color("CharcoalGray"))
                
                Text("You've completed your \(routine.name.lowercased()).")
                    .font(.title3)
                    .foregroundColor(Color("CharcoalGray").opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            // Stats
            HStack(spacing: 20) {
                statBlock(title: "Steps", value: "\(routine.steps.count)")
                statBlock(title: "Time", value: "5 min")
                statBlock(title: "Streak", value: "3 days")
            }
            .padding(.top, 20)
            
            // Done button
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Done")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color("SalmonPink"))
                    .cornerRadius(12)
            }
            .padding(.top, 30)
        }
        .padding(30)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
        .padding(.vertical, 30)
    }
    
    // Helper view for stats block
    private func statBlock(title: String, value: String) -> some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.title2.bold())
                .foregroundColor(Color("SalmonPink"))
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(Color("CharcoalGray").opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color("SalmonPink").opacity(0.1))
        .cornerRadius(12)
    }
    
    // MARK: - Helper Methods
    
    private func markCurrentStepComplete() {
        // Here we would update the model to mark the step complete
        // For now we just move to the next step
        moveToNextStep()
    }
    
    private func moveToNextStep() {
        // Reset animation progress for next step
        animationProgress = 0.0
        
        // Move to next step or complete routine
        if currentStepIndex < routine.steps.count - 1 {
            currentStepIndex += 1
            
            // Start animation for next step
            withAnimation(.easeOut(duration: 2.0)) {
                animationProgress = 1.0
            }
        } else {
            // Routine is complete
            isRoutineComplete = true
        }
    }
}

// MARK: - Preview
struct RoutineRunnerView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            RoutineRunnerView(routine: GlowPlanModels.sampleRoutines[0])
        }
    }
} 