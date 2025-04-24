import SwiftUI
import UIKit
// We're using the GlowPlanModels namespace for our data models

// Use the new namespace model
struct RoutineTrackerView: View {
    @State private var selectedDate = Date()
    @State private var streakCount = 12
    @State private var showingRoutineDetail = false
    @State private var selectedRoutine: GlowPlanModels.Routine?
    @State private var selectedTab = "Morning"
    @State private var showHistoryView = false
    @State private var showingRoutineRunner = false
    
    // Use sample data from shared models
    private let routines = GlowPlanModels.sampleRoutines
    
    // Computed progress for each routine
    private func routineProgress(_ routine: GlowPlanModels.Routine) -> Double {
        let completedSteps = Double(routine.steps.filter { $0.isCompleted }.count)
        return completedSteps / Double(routine.steps.count)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Overall progress card
                ProgressCardView(routines: routines, showHistoryView: $showHistoryView)
                    .padding(.horizontal)
                
                // Routine navigation tabs
                VStack(spacing: 16) {
                    // Add start button
                    HStack {
                        Text(selectedTab == "Morning" ? "Morning Routine" : "Evening Routine")
                            .font(.title2.bold())
                            .foregroundColor(Color("CharcoalGray"))
                        
                        Spacer()
                        
                        Button(action: {
                            // Find the selected routine
                            selectedRoutine = routines.first { $0.timeOfDay == selectedTab }
                            showingRoutineRunner = true
                        }) {
                            Text("Start Now")
                                .font(.subheadline.bold())
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color("SalmonPink"))
                                .cornerRadius(20)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Tab buttons
                    HStack(spacing: 0) {
                        Button(action: {
                            selectedTab = "Morning"
                        }) {
                            Text("Morning")
                                .font(.headline)
                                .foregroundColor(selectedTab == "Morning" ? .white : Color("CharcoalGray"))
                                .padding(.vertical, 12)
                                .frame(maxWidth: .infinity)
                                .background(selectedTab == "Morning" ? Color("SalmonPink") : Color.gray.opacity(0.1))
                                .cornerRadius(8, corners: [.topLeft, .bottomLeft])
                        }
                        
                        Button(action: {
                            selectedTab = "Evening"
                        }) {
                            Text("Evening")
                                .font(.headline)
                                .foregroundColor(selectedTab == "Evening" ? .white : Color("CharcoalGray"))
                                .padding(.vertical, 12)
                                .frame(maxWidth: .infinity)
                                .background(selectedTab == "Evening" ? Color("SalmonPink") : Color.gray.opacity(0.1))
                                .cornerRadius(8, corners: [.topRight, .bottomRight])
                        }
                    }
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.bottom, 8)
                    
                    // Calendar weekday row
                    HStack(spacing: 0) {
                        ForEach(["S", "M", "T", "W", "T", "F", "S"], id: \.self) { day in
                            Text(day)
                                .font(.subheadline)
                                .frame(maxWidth: .infinity)
                                .foregroundColor(Color("CharcoalGray").opacity(0.7))
                        }
                    }
                    .padding(.horizontal, 8)
                    
                    // Calendar day buttons
                    HStack(spacing: 0) {
                        ForEach(["5", "6", "7", "8", "9", "10", "11", "12"], id: \.self) { day in
                            let isSelected = Int(day) == 8 || Int(day) == 9 || Int(day) == 10
                            
                            Text(day)
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(isSelected ? Color("SalmonPink").opacity(0.3) : Color.clear)
                                .cornerRadius(8)
                                .foregroundColor(isSelected ? Color("SalmonPink") : Color("CharcoalGray"))
                        }
                    }
                    .padding(.horizontal, 8)
                    
                    // Routine steps
                    VStack(spacing: 16) {
                        if selectedTab == "Morning" {
                            routineStepRow(number: 1, title: "Cleanse", description: "Gently wash face with lukewarm water", isCompleted: true)
                            routineStepRow(number: 2, title: "Apply Vitamin C", description: "Apply 2-3 drops to face and neck", isCompleted: true)
                            routineStepRow(number: 3, title: "Moisturize", description: "Apply cream to face and neck", isCompleted: false)
                            routineStepRow(number: 4, title: "Apply Sunscreen", description: "Use SPF 30 or higher", isCompleted: false)
                        } else {
                            routineStepRow(number: 1, title: "Oil Cleanse", description: "Remove makeup and sunscreen", isCompleted: false)
                            routineStepRow(number: 2, title: "Water Cleanse", description: "Cleanse with gentle cleanser", isCompleted: false)
                            routineStepRow(number: 3, title: "Apply Tretinoin", description: "Pea-sized amount to entire face", isCompleted: false)
                            routineStepRow(number: 4, title: "Moisturizer", description: "Apply generous amount", isCompleted: false)
                        }
                    }
                    .padding(.top, 16)
                }
                .padding(.horizontal)
                .padding(.bottom, 30)
            }
            .padding(.top, 16)
        }
        .background(Color("SoftWhite"))
        .navigationTitle("Routine Tracker")
        .navigationBarTitleDisplayMode(.inline)
        .applyGlowNavigationBarStyle(backgroundColor: UIColor(named: "SalmonPink") ?? .systemPink, textColor: .white)
        .sheet(isPresented: $showingRoutineDetail) {
            if let routine = selectedRoutine {
                RoutineDetailView(routine: routine)
            }
        }
        .fullScreenCover(isPresented: $showHistoryView) {
            NavigationStack {
                HistoryView()
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button {
                                showHistoryView = false
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.white)
                                    .imageScale(.large)
                            }
                        }
                    }
            }
            .accentColor(Color("SalmonPink"))
        }
        .navigationDestination(isPresented: $showingRoutineRunner) {
            if let routine = selectedRoutine {
                RoutineRunnerView(routine: routine)
            }
        }
    }
    
    // Helper function to create routine step rows
    private func routineStepRow(number: Int, title: String, description: String, isCompleted: Bool) -> some View {
        HStack(spacing: 16) {
            // Step number badge
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color("SalmonPink").opacity(0.2))
                    .frame(width: 44, height: 44)
                
                Text("\(number)")
                    .font(.headline.bold())
                    .foregroundColor(Color("SalmonPink"))
            }
            
            // Step details
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(Color("CharcoalGray"))
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(Color("CharcoalGray").opacity(0.7))
            }
            
            Spacer()
            
            // Completion checkmark
            if isCompleted {
                Image(systemName: "checkmark")
                    .font(.headline)
                    .foregroundColor(Color("SalmonPink"))
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

// Date slider component
struct DateSlider: View {
    @Binding var selectedDate: Date
    private let calendar = Calendar.current
    private let dateFormatter = DateFormatter()
    
    private var dates: [Date] {
        let today = calendar.startOfDay(for: Date())
        
        return (-3...3).map { offset in
            calendar.date(byAdding: .day, value: offset, to: today) ?? today
        }
    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(dates, id: \.self) { date in
                    DateCell(date: date, isSelected: calendar.isDate(date, inSameDayAs: selectedDate))
                        .onTapGesture {
                            selectedDate = date
                        }
                }
            }
            .padding(.vertical, 8)
        }
    }
    
    struct DateCell: View {
        let date: Date
        let isSelected: Bool
        private let calendar = Calendar.current
        
        var body: some View {
            VStack(spacing: 8) {
                Text(dayOfWeek)
                    .font(.caption)
                    .fontWeight(.medium)
                
                ZStack {
                    Circle()
                        .fill(isSelected ? Color("SalmonPink") : Color.clear)
                        .frame(width: 36, height: 36)
                    
                    Text(dayNumber)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(isSelected ? .white : .primary)
                }
            }
            .frame(width: 50)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? Color("SalmonPink").opacity(0.2) : Color.clear)
            )
        }
        
        var dayOfWeek: String {
            let formatter = DateFormatter()
            formatter.dateFormat = "E"
            return formatter.string(from: date)
        }
        
        var dayNumber: String {
            let formatter = DateFormatter()
            formatter.dateFormat = "d"
            return formatter.string(from: date)
        }
    }
}

// Streak badge component
struct StreakBadge: View {
    let count: Int
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "flame.fill")
                .foregroundColor(.orange)
            
            Text("\(count) Day Streak!")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.orange)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(Color.orange.opacity(0.15))
        )
    }
}

// Progress card component
struct ProgressCardView: View {
    let routines: [GlowPlanModels.Routine]
    @Binding var showHistoryView: Bool
    
    private var overallCompletion: Double {
        var totalSteps = 0
        var completedSteps = 0
        
        for routine in routines {
            totalSteps += routine.steps.count
            completedSteps += routine.steps.filter { $0.isCompleted }.count
        }
        
        return totalSteps > 0 ? Double(completedSteps) / Double(totalSteps) : 0
    }
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 32) {
                // Circular progress indicator
                ZStack {
                    Circle()
                        .stroke(Color("SalmonPink").opacity(0.3), lineWidth: 12)
                        .frame(width: 120, height: 120)
                    
                    Circle()
                        .trim(from: 0, to: CGFloat(overallCompletion))
                        .stroke(Color("SalmonPink"), style: StrokeStyle(lineWidth: 12, lineCap: .round))
                        .frame(width: 120, height: 120)
                        .rotationEffect(.degrees(-90))
                    
                    VStack {
                        Text("\(Int(overallCompletion * 100))%")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(Color("CharcoalGray"))
                        
                        Text("completed\ntoday")
                            .font(.system(size: 14))
                            .multilineTextAlignment(.center)
                            .foregroundColor(Color("CharcoalGray").opacity(0.7))
                    }
                }
                
                Spacer()
                
                // View History button
                Button(action: {
                    showHistoryView = true
                }) {
                    Text("View History")
                        .font(.headline)
                        .foregroundColor(Color("SalmonPink"))
                        .padding(.vertical, 12)
                        .padding(.horizontal, 24)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color("SalmonPink"), lineWidth: 1)
                        )
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            Divider()
                .padding(.vertical, 8)
            
            // Achievement badge
            HStack {
                Image(systemName: "trophy.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32, height: 32)
                    .foregroundColor(.yellow)
                
                Text("7-Day Glow Champion")
                    .font(.headline)
                    .foregroundColor(Color("CharcoalGray"))
                
                Spacer()
                
                Button(action: {
                    // See all achievements action
                }) {
                    Text("See All Achievements")
                        .font(.subheadline)
                        .foregroundColor(Color("SalmonPink"))
                }
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// Routine Progress Card
struct RoutineProgressCard: View {
    let routine: GlowPlanModels.Routine
    let progress: Double
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(routine.name)
                    .font(.headline)
                
                HStack {
                    Image(systemName: timeOfDayIcon)
                        .foregroundColor(timeOfDayColor)
                    
                    Text(routine.timeOfDay)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                HStack(spacing: 4) {
                    Text("\(Int(progress * 100))% Complete")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("•")
                        .foregroundColor(.secondary)
                    
                    Text("\(routine.steps.filter { $0.isCompleted }.count)/\(routine.steps.count) Steps")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 6)
                    .frame(width: 50, height: 50)
                
                Circle()
                    .trim(from: 0, to: CGFloat(progress))
                    .stroke(timeOfDayColor, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .frame(width: 50, height: 50)
                    .rotationEffect(.degrees(-90))
                
                Image(systemName: progress >= 1.0 ? "checkmark" : "arrow.right")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(timeOfDayColor)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(15)
    }
    
    var timeOfDayIcon: String {
        switch routine.timeOfDay.lowercased() {
        case "morning":
            return "sunrise.fill"
        case "evening":
            return "moon.stars.fill"
        case "weekend":
            return "calendar.badge.clock"
        default:
            return "clock.fill"
        }
    }
    
    var timeOfDayColor: Color {
        switch routine.timeOfDay.lowercased() {
        case "morning":
            return Color.orange
        case "evening":
            return Color.indigo
        case "weekend":
            return Color.purple
        default:
            return Color("SalmonPink")
        }
    }
}

// Consistency Insights View
struct ConsistencyInsightsView: View {
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("This Week")
                    .font(.headline)
                
                Spacer()
                
                Text("See More")
                    .font(.subheadline)
                    .foregroundColor(Color("SalmonPink"))
            }
            
            HStack(spacing: 20) {
                InsightCard(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "85%",
                    subtitle: "Completion Rate",
                    color: .green
                )
                
                InsightCard(
                    icon: "clock.badge.checkmark",
                    title: "6/7",
                    subtitle: "Consistent Days",
                    color: .blue
                )
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(15)
    }
}

struct InsightCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(color)
            }
            
            VStack(spacing: 4) {
                Text(title)
                    .font(.system(size: 20, weight: .bold))
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

// Achievements View
struct AchievementsView: View {
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Recent Achievements")
                    .font(.headline)
                
                Spacer()
                
                Text("See All")
                    .font(.subheadline)
                    .foregroundColor(Color("SalmonPink"))
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    AchievementBadge(
                        title: "7 Day Streak",
                        icon: "flame.fill",
                        color: .orange,
                        isUnlocked: true
                    )
                    
                    AchievementBadge(
                        title: "Perfect Week",
                        icon: "star.fill",
                        color: .yellow,
                        isUnlocked: true
                    )
                    
                    AchievementBadge(
                        title: "Early Bird",
                        icon: "sunrise.fill",
                        color: .orange,
                        isUnlocked: false
                    )
                    
                    AchievementBadge(
                        title: "Treatment Expert",
                        icon: "sparkles",
                        color: .purple,
                        isUnlocked: false
                    )
                }
                .padding(.horizontal, 4)
                .padding(.bottom, 6)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(15)
    }
}

struct AchievementBadge: View {
    let title: String
    let icon: String
    let color: Color
    let isUnlocked: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(isUnlocked ? color.opacity(0.15) : Color.gray.opacity(0.1))
                    .frame(width: 70, height: 70)
                
                if isUnlocked {
                    Image(systemName: icon)
                        .font(.system(size: 30))
                        .foregroundColor(color)
                } else {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 24))
                        .foregroundColor(Color.gray)
                }
            }
            
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(isUnlocked ? .primary : .secondary)
                .multilineTextAlignment(.center)
        }
        .frame(width: 90)
    }
}

#if DEBUG
struct RoutineTrackerView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            RoutineTrackerView()
        }
    }
}
#endif 