import SwiftUI

struct RoutineListView: View {
    // Using GlowPlanModels namespace to avoid conflicts with model names
    @State private var routines: [GlowPlanModels.Routine] = GlowPlanModels.sampleRoutines
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("SoftWhite")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(routines) { routine in
                            NavigationLink(destination: RoutineDetailView(routine: routine)) {
                                RoutineCardView(routine: routine)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .padding(.bottom, 16)
                }
            }
            .navigationTitle("My Routines")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        // Action for adding new routine
                    }) {
                        Image(systemName: "plus")
                            .foregroundColor(Color("SalmonPink"))
                    }
                }
            }
        }
    }
}

struct RoutineCardView: View {
    let routine: GlowPlanModels.Routine
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(routine.name)
                        .font(.headline)
                        .foregroundColor(Color("CharcoalGray"))
                    
                    HStack(spacing: 6) {
                        Image(systemName: "clock")
                            .font(.caption)
                            .foregroundColor(Color("SalmonPink"))
                        
                        Text(routine.timeOfDay)
                            .font(.subheadline)
                            .foregroundColor(Color.gray)
                    }
                }
                
                Spacer()
                
                HStack(spacing: 6) {
                    Circle()
                        .fill(routine.isActive ? Color.green : Color.gray)
                        .frame(width: 8, height: 8)
                    
                    Text(routine.isActive ? "Active" : "Inactive")
                        .font(.caption)
                        .foregroundColor(routine.isActive ? Color.green : Color.gray)
                }
            }
            
            // Progress Bar
            let completedCount = routine.steps.filter { $0.isCompleted }.count
            let progress = Double(completedCount) / Double(max(1, routine.steps.count))
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("\(completedCount)/\(routine.steps.count) steps completed")
                        .font(.caption)
                        .foregroundColor(Color.gray)
                    
                    Spacer()
                    
                    Text("\(Int(progress * 100))%")
                        .font(.caption)
                        .foregroundColor(Color("SalmonPink"))
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 6)
                            .cornerRadius(3)
                        
                        Rectangle()
                            .fill(Color("SalmonPink"))
                            .frame(width: geometry.size.width * CGFloat(progress), height: 6)
                            .cornerRadius(3)
                    }
                }
                .frame(height: 6)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

#if DEBUG
struct RoutineListView_Previews: PreviewProvider {
    static var previews: some View {
        RoutineListView()
    }
}
#endif 