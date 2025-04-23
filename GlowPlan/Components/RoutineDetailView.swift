import SwiftUI

struct RoutineDetailView: View {
    let routineName: String
    let timeOfDay: String
    let isActive: Bool
    @State private var steps: [RoutineDetailStep]
    
    init(routineName: String, timeOfDay: String, isActive: Bool, steps: [RoutineDetailStep]) {
        self.routineName = routineName
        self.timeOfDay = timeOfDay
        self.isActive = isActive
        self._steps = State(initialValue: steps)
    }
    
    // Update initializer to use the shared model
    init(routine: GlowPlanModels.Routine) {
        self.routineName = routine.name
        self.timeOfDay = routine.timeOfDay
        self.isActive = routine.isActive
        
        // Convert shared RoutineStep to RoutineDetailStep
        let convertedSteps = routine.steps.map { step in
            RoutineDetailStep(title: step.name, isCompleted: step.isCompleted)
        }
        self._steps = State(initialValue: convertedSteps)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 4) {
                    Text(routineName)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(Color("CharcoalGray"))
                    
                    HStack {
                        Image(systemName: "clock")
                            .foregroundColor(Color("SalmonPink"))
                        
                        Text(timeOfDay)
                            .font(.subheadline)
                            .foregroundColor(Color.gray)
                        
                        Spacer()
                        
                        HStack(spacing: 6) {
                            Circle()
                                .fill(isActive ? Color.green : Color.gray)
                                .frame(width: 8, height: 8)
                            
                            Text(isActive ? "Active" : "Inactive")
                                .font(.caption)
                                .foregroundColor(isActive ? Color.green : Color.gray)
                        }
                    }
                }
                .padding(.bottom, 10)
                
                Divider()
                
                // Progress section
                let completedCount = steps.filter { $0.isCompleted }.count
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Progress")
                        .font(.headline)
                        .foregroundColor(Color("CharcoalGray"))
                    
                    HStack {
                        Text("\(completedCount)/\(steps.count) steps completed")
                            .font(.subheadline)
                            .foregroundColor(Color.gray)
                        
                        Spacer()
                        
                        Text("\(Int((Double(completedCount) / Double(steps.count)) * 100))%")
                            .font(.subheadline)
                            .foregroundColor(Color("SalmonPink"))
                            .fontWeight(.medium)
                    }
                    
                    // Progress bar
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 8)
                                .cornerRadius(4)
                            
                            Rectangle()
                                .fill(Color("SalmonPink"))
                                .frame(width: geometry.size.width * CGFloat(Double(completedCount) / Double(max(1, steps.count))), height: 8)
                                .cornerRadius(4)
                        }
                    }
                    .frame(height: 8)
                }
                .padding(.vertical, 10)
                
                Divider()
                
                // Steps section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Steps")
                        .font(.headline)
                        .foregroundColor(Color("CharcoalGray"))
                    
                    ForEach(0..<steps.count, id: \.self) { index in
                        RoutineStepView(
                            stepNumber: index + 1,
                            stepTitle: steps[index].title,
                            isCompleted: steps[index].isCompleted,
                            onToggle: {
                                steps[index].isCompleted.toggle()
                            }
                        )
                        
                        if index < steps.count - 1 {
                            Divider()
                                .padding(.leading, 48)
                        }
                    }
                }
            }
            .padding()
        }
        .background(Color("SoftWhite"))
        .navigationBarTitleDisplayMode(.inline)
    }
}

// Renamed to avoid namespace conflicts
struct RoutineDetailStep: Identifiable {
    let id = UUID()
    let title: String
    var isCompleted: Bool
}

#if DEBUG
struct RoutineDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            RoutineDetailView(
                routineName: "Morning Skincare",
                timeOfDay: "Morning",
                isActive: true,
                steps: [
                    RoutineDetailStep(title: "Wash face with cleanser", isCompleted: true),
                    RoutineDetailStep(title: "Apply toner", isCompleted: true),
                    RoutineDetailStep(title: "Apply serum", isCompleted: false),
                    RoutineDetailStep(title: "Apply moisturizer", isCompleted: false),
                    RoutineDetailStep(title: "Apply sunscreen (SPF 30+)", isCompleted: false)
                ]
            )
        }
    }
}
#endif 