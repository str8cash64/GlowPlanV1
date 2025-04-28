import SwiftUI
import UIKit

// Import the navigation bar extension from the Extensions directory 
// We'll fix this import during project configuration

struct HistoryView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.presentationMode) private var presentationMode
    @State private var selectedDate = Calendar.current.date(from: DateComponents(year: 2024, month: 4, day: 6)) ?? Date()
    @State private var currentMonth = Calendar.current.date(from: DateComponents(year: 2024, month: 4)) ?? Date()
    
    // Calendar configuration
    private let calendar = Calendar.current
    private let weekdaySymbols = ["S", "M", "T", "W", "T", "F", "S"]
    
    // Sample completed dates (pink circles) to match the image
    private let completedDates: [Int] = [3, 6, 8, 9, 10, 12, 14, 15, 16, 19, 22]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Title
                Text("History")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(Color("CharcoalGray"))
                    .padding(.horizontal)
                
                // Month navigation
                HStack {
                    Button(action: previousMonth) {
                        Image(systemName: "chevron.left")
                            .font(.headline)
                            .foregroundColor(Color("SalmonPink"))
                            .padding(12)
                            .background(Circle().fill(Color.white))
                            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                    }
                    
                    Spacer()
                    
                    Text(monthYearString(from: currentMonth))
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(Color("CharcoalGray"))
                    
                    Spacer()
                    
                    Button(action: nextMonth) {
                        Image(systemName: "chevron.right")
                            .font(.headline)
                            .foregroundColor(Color("SalmonPink"))
                            .padding(12)
                            .background(Circle().fill(Color.white))
                            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                    }
                }
                .padding(.horizontal)
                
                // Calendar weekday headers
                HStack(spacing: 0) {
                    ForEach(weekdaySymbols, id: \.self) { symbol in
                        Text(symbol)
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .frame(maxWidth: .infinity)
                            .foregroundColor(Color("CharcoalGray").opacity(0.7))
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
                
                // Calendar days grid
                let daysInMonth = generateDaysInMonth()
                let columns = Array(repeating: GridItem(.flexible()), count: 7)
                
                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(daysInMonth) { day in
                        if day.day == 0 {
                            Text("")
                                .frame(height: 40)
                        } else {
                            Button(action: {
                                if day.day > 0 {
                                    selectDate(day: day.day)
                                }
                            }) {
                                ZStack {
                                    if calendar.isDate(day.date, inSameDayAs: selectedDate) {
                                        Circle()
                                            .fill(Color("SalmonPink"))
                                            .frame(width: 36, height: 36)
                                    } else if [14, 15, 16].contains(day.day) {
                                        // These are highlighted in pink in the image
                                        Circle()
                                            .fill(Color("SalmonPink"))
                                            .frame(width: 36, height: 36)
                                    } else if completedDates.contains(day.day) {
                                        Circle()
                                            .fill(Color("SalmonPink").opacity(0.2))
                                            .frame(width: 36, height: 36)
                                    }
                                    
                                    Text("\(day.day)")
                                        .font(.system(size: 16, weight: calendar.isDate(day.date, inSameDayAs: selectedDate) ? .bold : .regular, design: .rounded))
                                        .foregroundColor(calendar.isDate(day.date, inSameDayAs: selectedDate) || [14, 15, 16].contains(day.day) ? .white : Color("CharcoalGray"))
                                }
                                .frame(height: 40)
                            }
                        }
                    }
                }
                .padding(.horizontal)
                
                // Selected date details
                VStack(alignment: .leading, spacing: 16) {
                    Text("Monday, April 6")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(Color("CharcoalGray"))
                    
                    // Morning Routine Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Morning Routine")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(Color("CharcoalGray"))
                        
                        RoutineCompletionItem(title: "Cleanse", description: "Gentle face wash", isCompleted: true)
                    }
                    .padding(20)
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
                    
                    // Evening Routine Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Evening Routine")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(Color("CharcoalGray"))
                        
                        RoutineCompletionItem(title: "Double Cleanse", description: "Oil + water based", isCompleted: true)
                    }
                    .padding(20)
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
                }
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
            .padding(.top, 16)
        }
        .background(Color("SoftWhite"))
        .navigationTitle("History")
        .navigationBarTitleDisplayMode(.inline)
        .applyGlowNavigationBarStyle(backgroundColor: UIColor(named: "SalmonPink") ?? .systemPink, textColor: .white)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.white)
                        .imageScale(.large)
                }
            }
        }
        .onAppear {
            // Ensure navigation bar appears correctly
            UINavigationBar.appearance().tintColor = .white
        }
    }
    
    // MARK: - Helper Methods
    
    private func monthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
    
    private func formattedSelectedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter.string(from: selectedDate)
    }
    
    private func previousMonth() {
        guard let newMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) else { return }
        currentMonth = newMonth
    }
    
    private func nextMonth() {
        guard let newMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) else { return }
        currentMonth = newMonth
    }
    
    private func selectDate(day: Int) {
        var components = calendar.dateComponents([.year, .month], from: currentMonth)
        components.day = day
        if let date = calendar.date(from: components) {
            selectedDate = date
        }
    }
    
    private func generateDaysInMonth() -> [CalendarDay] {
        var days = [CalendarDay]()
        
        // Get the first day of the month
        var components = calendar.dateComponents([.year, .month], from: currentMonth)
        components.day = 1
        
        guard let firstDayOfMonth = calendar.date(from: components) else {
            return days
        }
        
        // Get the weekday of the first day (0 is Sunday in our grid)
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth) - 1
        
        // Add empty days for the beginning of the first week
        for _ in 0..<firstWeekday {
            days.append(CalendarDay(day: 0, date: Date()))
        }
        
        // Get the range of days in the month
        let range = calendar.range(of: .day, in: .month, for: currentMonth)!
        
        // Add all days of the month
        for day in range {
            components.day = day
            if let date = calendar.date(from: components) {
                days.append(CalendarDay(day: day, date: date))
            }
        }
        
        return days
    }
}

// MARK: - Supporting Views

struct RoutineCompletionItem: View {
    let title: String
    let description: String
    let isCompleted: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            // Checkmark circle
            ZStack {
                Circle()
                    .fill(isCompleted ? Color("SalmonPink") : Color.gray.opacity(0.2))
                    .frame(width: 32, height: 32)
                
                if isCompleted {
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            
            // Title and description
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(Color("CharcoalGray"))
                
                Text(description)
                    .font(.system(size: 14, design: .rounded))
                    .foregroundColor(Color("CharcoalGray").opacity(0.7))
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Model Objects

struct CalendarDay: Identifiable {
    let id = UUID()
    let day: Int
    let date: Date
}

// MARK: - Preview Provider

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            HistoryView()
        }
    }
} 