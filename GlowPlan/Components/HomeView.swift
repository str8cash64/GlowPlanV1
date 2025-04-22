import SwiftUI

struct MainHomeView: View {
    @State private var isDarkMode = false
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Dashboard tab
            NavigationStack {
                ZStack {
                    Color("SoftWhite")
                        .ignoresSafeArea()
                    
                    ScrollView {
                        VStack(alignment: .leading, spacing: 24) {
                            // Welcome section
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Good Morning!")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color("CharcoalGray"))
                                
                                Text("Let's take care of your skin today")
                                    .font(.subheadline)
                                    .foregroundColor(Color.gray)
                            }
                            .padding(.horizontal)
                            
                            // Daily routine reminder
                            DailyRoutineCard()
                            
                            // Current progress section
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Today's Progress")
                                    .font(.headline)
                                    .foregroundColor(Color("CharcoalGray"))
                                    .padding(.horizontal)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 16) {
                                        ProgressCard(
                                            title: "Morning Routine",
                                            progress: 0.4,
                                            completed: 2,
                                            total: 5,
                                            color: Color("SalmonPink")
                                        )
                                        
                                        ProgressCard(
                                            title: "Evening Routine",
                                            progress: 0.6,
                                            completed: 3,
                                            total: 5,
                                            color: Color("LavenderPurple")
                                        )
                                        
                                        ProgressCard(
                                            title: "Weekly Treatment",
                                            progress: 0.0,
                                            completed: 0,
                                            total: 3,
                                            color: Color("MintGreen")
                                        )
                                    }
                                    .padding(.horizontal)
                                }
                            }
                            
                            // Quick access to routines
                            VStack(alignment: .leading, spacing: 16) {
                                HStack {
                                    Text("My Routines")
                                        .font(.headline)
                                        .foregroundColor(Color("CharcoalGray"))
                                    
                                    Spacer()
                                    
                                    NavigationLink(destination: RoutineListView()) {
                                        Text("See All")
                                            .font(.subheadline)
                                            .foregroundColor(Color("SalmonPink"))
                                    }
                                }
                                .padding(.horizontal)
                                
                                VStack(spacing: 12) {
                                    RoutineRow(
                                        name: "Morning Skincare",
                                        icon: "sun.max.fill",
                                        time: "Morning",
                                        steps: 5,
                                        color: Color("SalmonPink").opacity(0.2),
                                        iconColor: Color("SalmonPink")
                                    )
                                    
                                    RoutineRow(
                                        name: "Evening Skincare",
                                        icon: "moon.stars.fill",
                                        time: "Evening",
                                        steps: 5,
                                        color: Color("LavenderPurple").opacity(0.2),
                                        iconColor: Color("LavenderPurple")
                                    )
                                }
                                .padding(.horizontal)
                            }
                            
                            // Skin diary prompt
                            SkinDiaryPrompt()
                                .padding(.horizontal)
                        }
                        .padding(.top, 16)
                        .padding(.bottom, 24)
                    }
                }
                .navigationTitle("GlowPlan")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            isDarkMode.toggle()
                        }) {
                            Image(systemName: isDarkMode ? "sun.max.fill" : "moon.fill")
                                .foregroundColor(Color("SalmonPink"))
                        }
                    }
                }
            }
            .tabItem {
                Image(systemName: "house.fill")
                Text("Home")
            }
            .tag(0)
            
            // Routines tab
            RoutineListView()
                .tabItem {
                    Image(systemName: "list.bullet.clipboard")
                    Text("Routines")
                }
                .tag(1)
            
            // Calendar tab
            Text("Calendar View")
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Calendar")
                }
                .tag(2)
            
            // Profile tab
            Text("Profile View")
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
                .tag(3)
        }
        .accentColor(Color("SalmonPink"))
    }
}

struct DailyRoutineCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "bell.fill")
                    .foregroundColor(.white)
                    .padding(10)
                    .background(Color("SalmonPink"))
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Evening Routine")
                        .font(.headline)
                        .foregroundColor(Color("CharcoalGray"))
                    
                    Text("Scheduled for 8:00 PM")
                        .font(.subheadline)
                        .foregroundColor(Color.gray)
                }
                
                Spacer()
                
                Button(action: {}) {
                    Text("Start")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color("SalmonPink"))
                        .cornerRadius(20)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
    }
}

struct ProgressCard: View {
    let title: String
    let progress: Double
    let completed: Int
    let total: Int
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundColor(Color("CharcoalGray"))
            
            ZStack {
                Circle()
                    .stroke(color.opacity(0.2), lineWidth: 8)
                
                Circle()
                    .trim(from: 0, to: CGFloat(progress))
                    .stroke(color, lineWidth: 8)
                    .rotationEffect(.degrees(-90))
                
                VStack(spacing: 4) {
                    Text("\(Int(progress * 100))%")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(color)
                    
                    Text("\(completed)/\(total)")
                        .font(.caption)
                        .foregroundColor(Color.gray)
                }
            }
            .frame(width: 100, height: 100)
            
            Button(action: {}) {
                Text("Continue")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(color)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(color.opacity(0.1))
                    .cornerRadius(20)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .frame(width: 160)
    }
}

struct RoutineRow: View {
    let name: String
    let icon: String
    let time: String
    let steps: Int
    let color: Color
    let iconColor: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .foregroundColor(iconColor)
                .padding(12)
                .background(color)
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.headline)
                    .foregroundColor(Color("CharcoalGray"))
                
                Text("\(time) • \(steps) steps")
                    .font(.subheadline)
                    .foregroundColor(Color.gray)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(Color.gray)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct SkinDiaryPrompt: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "book.fill")
                    .foregroundColor(.white)
                    .padding(10)
                    .background(Color("MintGreen"))
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Skin Diary")
                        .font(.headline)
                        .foregroundColor(Color("CharcoalGray"))
                    
                    Text("How is your skin feeling today?")
                        .font(.subheadline)
                        .foregroundColor(Color.gray)
                }
                
                Spacer()
            }
            
            Button(action: {}) {
                Text("Add Entry")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(Color("MintGreen"))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color("MintGreen").opacity(0.1))
                    .cornerRadius(20)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

#if DEBUG
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
#endif 
