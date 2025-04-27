import SwiftUI
import FirebaseAuth
import FirebaseFirestore

// Import required components
// Alternatively we could move these components here

struct HomeView: View {
    @State private var showingNotifications = false
    @State private var activeIndex = 0
    @AppStorage("cached_user_name") private var userName = "User" // Use AppStorage instead of State
    @State private var showOnboarding = false // Add state for debug
    @Binding var mainTabSelection: Int // Add binding to parent's selected tab
    @ObservedObject private var routineManager = RoutineManager.shared // Add RoutineManager
    
    // Init with binding
    init(mainTabSelection: Binding<Int>) {
        self._mainTabSelection = mainTabSelection
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Welcome and profile section
                    HStack(alignment: .center) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Good Morning, \(userName)")
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundColor(Color("CharcoalGray"))
                                .lineLimit(1)
                            
                            Text("Your skin is looking radiant today!")
                                .font(.system(size: 16, design: .rounded))
                                .foregroundColor(Color("CharcoalGray").opacity(0.7))
                        }
                        
                        Spacer()
                        
                        // DEBUG BUTTON
                        Button {
                            showOnboarding = true
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(Color.orange.opacity(0.2))
                                    .frame(width: 44, height: 44)
                                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                                
                                Image(systemName: "arrow.clockwise")
                                    .font(.system(size: 18))
                                    .foregroundColor(Color.orange)
                                    .padding(12)
                            }
                        }
                        
                        Button {
                            showingNotifications.toggle()
                        } label: {
                            ZStack(alignment: .topTrailing) {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 44, height: 44)
                                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                                
                                Image(systemName: "bell.fill")
                                    .font(.system(size: 18))
                                    .foregroundColor(Color("SalmonPink"))
                                    .padding(12)
                                
                                Circle()
                                    .fill(Color("SalmonPink"))
                                    .frame(width: 12, height: 12)
                                    .offset(x: 2, y: -2)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                    
                    // Skincare Routine Tracker card
                    ZStack {
                        RoundedRectangle(cornerRadius: 24)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color("Peach"), Color("SalmonPink").opacity(0.7)]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 5)
                        
                        VStack(spacing: 16) {
                            HStack {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Daily Progress")
                                        .font(.system(size: 26, weight: .bold, design: .rounded))
                                        .foregroundColor(.white)
                                    
                                    Text("Your skin journey is looking great!")
                                        .font(.system(size: 18, weight: .medium, design: .rounded))
                                        .foregroundColor(.white.opacity(0.9))
                                }
                                
                                Spacer()
                                
                                ZStack {
                                    Circle()
                                        .stroke(Color.white.opacity(0.3), lineWidth: 6)
                                        .frame(width: 64, height: 64)
                                    
                                    Circle()
                                        .trim(from: 0, to: 0.7)
                                        .stroke(Color.white, lineWidth: 6)
                                        .frame(width: 64, height: 64)
                                        .rotationEffect(.degrees(-90))
                                    
                                    Text("70%")
                                        .font(.system(size: 16, weight: .bold, design: .rounded))
                                        .foregroundColor(.white)
                                }
                            }
                            
                            Divider()
                                .background(Color.white.opacity(0.5))
                            
                            HStack(spacing: 20) {
                                VStack(spacing: 10) {
                                    ZStack {
                                        Circle()
                                            .fill(Color.white.opacity(0.2))
                                            .frame(width: 48, height: 48)
                                        
                                        Image(systemName: "drop.fill")
                                            .font(.system(size: 22))
                                            .foregroundColor(.white)
                                    }
                                    
                                    Text("Cleanse")
                                        .font(.system(size: 14, weight: .medium, design: .rounded))
                                        .foregroundColor(.white)
                                }
                                
                                Spacer()
                                
                                VStack(spacing: 10) {
                                    ZStack {
                                        Circle()
                                            .fill(Color.white.opacity(0.2))
                                            .frame(width: 48, height: 48)
                                        
                                        Image(systemName: "sparkles")
                                            .font(.system(size: 22))
                                            .foregroundColor(.white)
                                    }
                                    
                                    Text("Treat")
                                        .font(.system(size: 14, weight: .medium, design: .rounded))
                                        .foregroundColor(.white)
                                }
                                
                                Spacer()
                                
                                VStack(spacing: 10) {
                                    ZStack {
                                        Circle()
                                            .fill(Color.white.opacity(0.2))
                                            .frame(width: 48, height: 48)
                                        
                                        Image(systemName: "sun.max.fill")
                                            .font(.system(size: 22))
                                            .foregroundColor(.white)
                                    }
                                    
                                    Text("Protect")
                                        .font(.system(size: 14, weight: .medium, design: .rounded))
                                        .foregroundColor(.white)
                                }
                            }
                        }
                        .padding(24)
                    }
                    .frame(height: 200)
                    .padding(.horizontal)
                    
                    // Feature cards carousel
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Skin Insights")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(Color("CharcoalGray"))
                            .padding(.horizontal)
                        
                        TabView(selection: $activeIndex) {
                            FeatureCard(
                                title: "Hydration Tip",
                                description: "Apply moisturizer to slightly damp skin for better absorption",
                                imageName: "drop.fill",
                                backgroundColor: Color.blue.opacity(0.7),
                                cardID: "hydration-tip"
                            )
                            .tag(0)
                            
                            FeatureCard(
                                title: "UV Protection",
                                description: "Use SPF 50+ daily, even on cloudy days for skin health",
                                imageName: "sun.max.fill",
                                backgroundColor: Color.orange.opacity(0.7),
                                cardID: "uv-protection"
                            )
                            .tag(1)
                            
                            FeatureCard(
                                title: "Nighttime Routine",
                                description: "Use retinol products at night for best results and less sun sensitivity",
                                imageName: "moon.stars.fill",
                                backgroundColor: Color.purple.opacity(0.7),
                                cardID: "nighttime-routine"
                            )
                            .tag(2)
                        }
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
                        .frame(height: 160)
                        
                        // Page indicator
                        HStack(spacing: 8) {
                            ForEach(0..<3, id: \.self) { index in
                                Circle()
                                    .fill(activeIndex == index ? Color("SalmonPink") : Color.gray.opacity(0.3))
                                    .frame(width: 8, height: 8)
                                    .id("PageIndicator-\(index)")
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Today's routine
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Today's Routine")
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                                .foregroundColor(Color("CharcoalGray"))
                            
                            Spacer()
                            
                            Button {
                                // Navigate to Tracker tab
                                mainTabSelection = 1
                            } label: {
                                Text("View All")
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                    .foregroundColor(Color("SalmonPink"))
                            }
                        }
                        .padding(.horizontal)
                        
                        // Get the morning routine from the shared routineManager
                        let morningRoutine = routineManager.getRoutineByTimeOfDay("Morning")
                        
                        if let morningRoutine = morningRoutine {
                            ForEach(morningRoutine.steps) { step in
                                HStack {
                                    ZStack {
                                        Circle()
                                            .fill(Color("Peach").opacity(0.3))
                                            .frame(width: 44, height: 44)
                                        
                                        Image(systemName: step.icon)
                                            .font(.system(size: 20))
                                            .foregroundColor(Color("SalmonPink"))
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(step.name)
                                            .font(.system(size: 16, weight: .medium, design: .rounded))
                                            .foregroundColor(Color("CharcoalGray"))
                                        
                                        // This is a simpler display without the product description
                                        Text(step.isCompleted ? "Completed" : "To do")
                                            .font(.system(size: 12, design: .rounded))
                                            .foregroundColor(Color("CharcoalGray").opacity(0.6))
                                    }
                                    .padding(.leading, 8)
                                    
                                    Spacer()
                                    
                                    Button {
                                        // Toggle step completion using the RoutineManager
                                        routineManager.toggleStepCompletion(
                                            routineId: morningRoutine.id,
                                            stepId: step.id
                                        )
                                    } label: {
                                        ZStack {
                                            Circle()
                                                .stroke(Color("SalmonPink").opacity(0.3), lineWidth: 2)
                                                .frame(width: 28, height: 28)
                                            
                                            if step.isCompleted {
                                                Image(systemName: "checkmark")
                                                    .font(.system(size: 14, weight: .bold))
                                                    .foregroundColor(Color("SalmonPink"))
                                            } else {
                                                Image(systemName: "checkmark")
                                                    .font(.system(size: 14, weight: .bold))
                                                    .foregroundColor(Color("SalmonPink").opacity(0.5))
                                            }
                                        }
                                    }
                                }
                                .padding(.vertical, 16)
                                .padding(.horizontal, 20)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.white)
                                        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
                                )
                                .padding(.horizontal)
                            }
                        } else {
                            // Fallback if no morning routine is found
                            Text("No routine steps found")
                                .foregroundColor(Color("CharcoalGray").opacity(0.6))
                                .padding(.horizontal)
                        }
                    }
                    
                    // Quick Actions
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Quick Actions")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(Color("CharcoalGray"))
                            .padding(.horizontal)
                        
                        HStack(spacing: 16) {
                            NavigationLink(destination: RoutineTrackerView()) {
                                QuickActionButton(title: "Routine Tracker", icon: "checklist", color: Color.purple.opacity(0.8))
                            }
                            .buttonStyle(PlainButtonStyle())
                            .accessibilityIdentifier("routineTrackerLink")
                            
                            QuickActionButton(title: "Track Symptoms", icon: "chart.line.uptrend.xyaxis", color: Color.green.opacity(0.8))
                            
                            QuickActionButton(title: "Log Water", icon: "drop.fill", color: Color.blue.opacity(0.8))
                        }
                        .padding(.horizontal)
                    }
                    
                    // Hormonal Wellness Tip
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Hormonal Wellness Tip")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(Color("CharcoalGray"))
                            .padding(.horizontal)
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white)
                                .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 5)
                            
                            HStack(spacing: 16) {
                                ZStack {
                                    Circle()
                                        .fill(Color("Peach").opacity(0.3))
                                        .frame(width: 60, height: 60)
                                    
                                    Image(systemName: "lightbulb.fill")
                                        .font(.system(size: 28))
                                        .foregroundColor(Color("SalmonPink"))
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Ovulation Skin Care")
                                        .font(.system(size: 18, weight: .bold, design: .rounded))
                                        .foregroundColor(Color("CharcoalGray"))
                                    
                                    Text("During ovulation, your skin tends to be more radiant naturally. Focus on hydration and sun protection rather than heavy products.")
                                        .font(.system(size: 14, design: .rounded))
                                        .foregroundColor(Color("CharcoalGray").opacity(0.8))
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                            .padding(20)
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 30)
                }
            }
            .background(Color("SoftWhite"))
            .navigationTitle("GlowPlan")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(Color("SalmonPink"), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .onAppear {
                fetchUserName()
            }
            .task {
                // Fetch username immediately when view appears
                fetchUserName()
            }
            .fullScreenCover(isPresented: $showOnboarding) {
                OnboardingView()
            }
        }
    }
    
    private func fetchUserName() {
        guard let userId = FirebaseManager.shared.userId else { return }
        
        let db = Firestore.firestore()
        db.collection("users").document(userId).getDocument { document, error in
            if let document = document, document.exists, 
               let data = document.data() {
                // Look for fullName first (what we store during signup)
                if let fullName = data["fullName"] as? String, !fullName.isEmpty {
                    self.userName = fullName
                } 
                // Fallback to displayName if fullName is not found
                else if let displayName = data["displayName"] as? String, !displayName.isEmpty {
                    self.userName = displayName
                } 
                // Try to get display name from Auth user as last resort
                else if let user = Auth.auth().currentUser, 
                    let displayName = user.displayName, 
                    !displayName.isEmpty {
                    self.userName = displayName
                }
            }
        }
    }
}

// MARK: - Supporting Components
// Feature Card for the carousel
struct FeatureCard: View {
    let title: String
    let description: String
    let imageName: String
    let backgroundColor: Color
    let cardID: String  // Add a unique ID property
    
    // Add default parameter for backward compatibility
    init(title: String, description: String, imageName: String, backgroundColor: Color, cardID: String = UUID().uuidString) {
        self.title = title
        self.description = description
        self.imageName = imageName
        self.backgroundColor = backgroundColor
        self.cardID = cardID
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(backgroundColor)
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                .id("FeatureCardBG-\(cardID)")
            
            HStack {
                VStack(alignment: .leading, spacing: 12) {
                    Text(title)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .id("FeatureCardTitle-\(cardID)")
                    
                    Text(description)
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))
                        .lineLimit(2)
                        .id("FeatureCardDesc-\(cardID)")
                }
                .padding(20)
                
                Spacer()
                
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.3))
                        .frame(width: 60, height: 60)
                        .id("FeatureCardIconBG-\(cardID)")
                    
                    Image(systemName: imageName)
                        .font(.system(size: 30))
                        .foregroundColor(.white)
                        .id("FeatureCardIcon-\(cardID)")
                }
                .padding(.trailing, 20)
            }
        }
        .padding(.horizontal)
    }
}

// Quick Action Button
struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        Button {
            // Button action
        } label: {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.2))
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: icon)
                        .font(.system(size: 24))
                        .foregroundColor(color)
                }
                
                Text(title)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(Color("CharcoalGray"))
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#if DEBUG
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(mainTabSelection: .constant(0))
    }
}
#endif 