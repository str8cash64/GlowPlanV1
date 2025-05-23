import SwiftUI
// Import needed views explicitly
import Foundation
import FirebaseAuth
import FirebaseFirestore
// Import our components
// Add a comment to ensure RoutineTrackerView is accessible
// Make sure RoutineTrackerView.swift is added to the project target

extension Color {
    func withUniqueID(_ id: String) -> some View {
        self.id(id)
    }
}

extension Text {
    func withUniqueTag(_ tag: String) -> some View {
        self.id(tag)
    }
}

struct MainTabView: View {
    @State private var selectedTab = 0
    
    init() {
        // Set the tab bar appearance
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.backgroundColor = UIColor.white
        
        let itemAppearance = UITabBarItemAppearance()
        itemAppearance.normal.iconColor = UIColor.gray
        itemAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.gray]
        
        // Convert SalmonPink color to UIColor
        let salmonPinkUIColor = UIColor(red: 1.0, green: 0.55, blue: 0.55, alpha: 1.0) // #FF8C8C
        
        itemAppearance.selected.iconColor = salmonPinkUIColor
        itemAppearance.selected.titleTextAttributes = [.foregroundColor: salmonPinkUIColor]
        
        tabBarAppearance.stackedLayoutAppearance = itemAppearance
        tabBarAppearance.inlineLayoutAppearance = itemAppearance
        tabBarAppearance.compactInlineLayoutAppearance = itemAppearance
        
        UITabBar.appearance().standardAppearance = tabBarAppearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        }
        
        // Set the navigation bar appearance with SalmonPink color
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithOpaqueBackground()
        navigationBarAppearance.backgroundColor = salmonPinkUIColor
        navigationBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        UINavigationBar.appearance().standardAppearance = navigationBarAppearance
        UINavigationBar.appearance().compactAppearance = navigationBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
        
        // Set the navigation bar items tint color to white for better contrast
        UINavigationBar.appearance().tintColor = .white
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(mainTabSelection: $selectedTab)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)
            
            RoutineTrackerView()
                .tabItem {
                    Label("Tracker", systemImage: "list.clipboard.fill")
                }
                .tag(1)
            
            RecommendationsView()
                .tabItem {
                    Label("For You", systemImage: "sparkles")
                }
                .tag(2)
            
            ChatAssistantView()
                .tabItem {
                    Label("Chat", systemImage: "message.fill")
                }
                .tag(3)
            
            AccountView()
                .tabItem {
                    Label("Account", systemImage: "person.fill")
                }
                .tag(4)
        }
        .accentColor(Color("SalmonPink"))
    }
}

// MARK: - Routines List View
struct RoutinesListView: View {
    @State private var selectedCategory = "Daily"
    private let categories = ["Daily", "Weekly", "Monthly"]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Routines categories
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(Array(zip(categories.indices, categories)), id: \.0) { index, category in
                                Button {
                                    selectedCategory = category
                                } label: {
                                    Text(category)
                                        .font(.system(size: 16, weight: .medium, design: .rounded))
                                        .foregroundColor(category == selectedCategory ? .white : Color("CharcoalGray"))
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 10)
                                        .background(
                                            RoundedRectangle(cornerRadius: 20)
                                                .fill(category == selectedCategory ? Color("SalmonPink") : Color.white)
                                                .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 2)
                                        )
                                }
                                .id("CategoryButton-\(index)") // Add explicit ID
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.top, 16)
                    
                    // Morning routine
                    RoutineSection(
                        title: "Morning Routine",
                        icon: "sun.max.fill",
                        steps: [
                            RoutineSimpleStep(number: 1, title: "Cleanse", description: "Gently wash face with lukewarm water"),
                            RoutineSimpleStep(number: 2, title: "Apply Vitamin C", description: "Apply 2-3 drops to face and neck"),
                            RoutineSimpleStep(number: 3, title: "Sunscreen", description: "Apply liberally to face and exposed skin")
                        ]
                    )
                    
                    // Evening routine
                    RoutineSection(
                        title: "Evening Routine",
                        icon: "moon.stars.fill",
                        steps: [
                            RoutineSimpleStep(number: 1, title: "Double Cleanse", description: "Oil cleanser followed by water-based cleanser"),
                            RoutineSimpleStep(number: 2, title: "Exfoliate", description: "Use 2x per week during ovulation"),
                            RoutineSimpleStep(number: 3, title: "Moisturize", description: "Apply generous amount to face and neck")
                        ]
                    )
                    
                    // Add new routine button
                    Button {
                        // Action to add new routine
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 22))
                            
                            Text("Create New Routine")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                        }
                        .foregroundColor(Color("SalmonPink"))
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color("SalmonPink"), lineWidth: 2)
                                .background(Color.white.cornerRadius(16))
                        )
                        .padding(.horizontal)
                    }
                    .padding(.top, 8)
                    .padding(.bottom, 30)
                }
            }
            .background(Color.softWhite)
            .navigationTitle("My Routines")
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(Color("SalmonPink"), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }
}

// Simplified Routine Step
struct RoutineSimpleStep: Identifiable {
    let id = UUID()
    let number: Int
    let title: String
    let description: String
}

// Routine Section Component
struct RoutineSection: View {
    let title: String
    let icon: String
    let steps: [RoutineSimpleStep]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(title)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(Color("CharcoalGray"))
                
                Spacer()
                
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(Color("SalmonPink"))
            }
            .padding(.horizontal)
            
            ForEach(steps) { step in
                HStack {
                    ZStack {
                        Circle()
                            .fill(Color("SalmonPink"))
                            .frame(width: 36, height: 36)
                        
                        Text("\(step.number)")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(step.title)
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(Color("CharcoalGray"))
                        
                        Text(step.description)
                            .font(.system(size: 14, design: .rounded))
                            .foregroundColor(Color("CharcoalGray").opacity(0.7))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.leading, 12)
                    
                    Spacer()
                    
                    Button {
                        // Edit action
                    } label: {
                        Image(systemName: "pencil")
                            .font(.system(size: 16))
                            .foregroundColor(Color("CharcoalGray").opacity(0.6))
                            .padding(8)
                            .background(
                                Circle()
                                    .fill(Color.gray.opacity(0.1))
                            )
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                )
                .padding(.horizontal)
            }
        }
    }
}

// MARK: - Recommendations View
struct RecommendationsView: View {
    let categories = ["Face", "Body", "Supplements", "Self-Care"]
    @State private var selectedCategory = "Face"
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Category selector
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(Array(zip(categories.indices, categories)), id: \.0) { index, category in
                                Button {
                                    selectedCategory = category
                                } label: {
                                    Text(category)
                                        .font(.system(size: 16, weight: .medium, design: .rounded))
                                        .foregroundColor(selectedCategory == category ? .white : .charcoalGray)
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 8)
                                        .background(
                                            RoundedRectangle(cornerRadius: 20)
                                                .fill(selectedCategory == category ? Color.salmonPink : Color.white)
                                                .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 2)
                                        )
                                }
                                .id("RecommendationCategory-\(index)")
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.top, 16)
                    
                    // Featured product
                    ZStack {
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color.peach.opacity(0.3))
                            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                        
                        HStack {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Perfect for Your Cycle")
                                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                                    .foregroundColor(.salmonPink)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.white.opacity(0.7))
                                    )
                                
                                Spacer()
                                
                                Text("Hydrating Serum")
                                    .font(.system(size: 24, weight: .bold, design: .rounded))
                                    .foregroundColor(.charcoalGray)
                                
                                Text("Formulated for ovulation phase")
                                    .font(.system(size: 16, design: .rounded))
                                    .foregroundColor(.secondary)
                                
                                Spacer()
                                
                                Button {} label: {
                                    Text("View Details")
                                        .font(.system(size: 16, weight: .medium, design: .rounded))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 8)
                                        .background(
                                            RoundedRectangle(cornerRadius: 16)
                                                .fill(Color.salmonPink)
                                        )
                                }
                            }
                            .padding(20)
                            
                            Spacer()
                            
                            ZStack {
                                Circle()
                                    .fill(Color.white.opacity(0.7))
                                    .frame(width: 120, height: 120)
                                
                                Image(systemName: "drop.fill")
                                    .font(.system(size: 50))
                                    .foregroundColor(.salmonPink)
                            }
                            .padding(.trailing, 20)
                        }
                    }
                    .frame(height: 200)
                    .padding(.horizontal)
                    
                    // Recommended products grid
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Recommended for You")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.charcoalGray)
                            .padding(.horizontal)
                        
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            ForEach(0..<4, id: \.self) { index in
                                VStack {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(Color.white)
                                            .frame(height: 160)
                                            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                                        
                                        VStack {
                                            ZStack {
                                                Circle()
                                                    .fill(Color.peach.opacity(0.3))
                                                    .frame(width: 80, height: 80)
                                                
                                                Image(systemName: ["sparkles", "drop.fill", "leaf.fill", "sun.max.fill"][index])
                                                    .font(.system(size: 30))
                                                    .foregroundColor(.salmonPink)
                                            }
                                            
                                            Text(["Brightening Mask", "Hydrating Toner", "Natural Cleanser", "SPF 50 Sunscreen"][index])
                                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                                .foregroundColor(.charcoalGray)
                                                .multilineTextAlignment(.center)
                                                .lineLimit(2)
                                                .frame(height: 40)
                                            
                                            Text("$\([24, 18, 22, 30][index])")
                                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                                .foregroundColor(.salmonPink)
                                        }
                                        .padding(8)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                    }
                }
            }
            .background(Color.softWhite)
            .navigationTitle("Recommendations")
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(Color("SalmonPink"), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }
}

// MARK: - Chat View
struct GlowBotChatView: View {
    @State private var messageText = ""
    @State private var messages: [(id: UUID, content: String, isUser: Bool, timestamp: Date)] = [
        (UUID(), "Hello! I'm your GlowBot skincare assistant. How can I help you today?", false, Date(timeIntervalSinceNow: -3600)),
        (UUID(), "I've been noticing more breakouts during my period. What should I do?", true, Date(timeIntervalSinceNow: -3500)),
        (UUID(), "That's very common due to hormonal fluctuations! During your period, your estrogen levels drop and testosterone can become more dominant, leading to increased oil production.", false, Date(timeIntervalSinceNow: -3400)),
        (UUID(), "I recommend using a gentle salicylic acid cleanser in the days leading up to your period, and adding a non-comedogenic moisturizer to keep your skin balanced.", false, Date(timeIntervalSinceNow: -3300))
    ]
    @State private var isTyping = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Chat messages
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(messages, id: \.id) { message in
                            MessageBubble(
                                content: message.content,
                                isUser: message.isUser,
                                timestamp: message.timestamp
                            )
                        }
                        
                        if isTyping {
                            CustomTypingIndicator()
                                .padding(.top, 8)
                        }
                    }
                    .padding(.vertical, 12)
                }
                .background(Color.softWhite)
                
                // Message input field
                VStack(spacing: 0) {
                    Divider()
                    
                    HStack {
                        TextField("Type a message...", text: $messageText)
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.white)
                                    .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)
                            )
                        
                        Button {
                            sendMessage()
                        } label: {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.system(size: 32))
                                .foregroundColor(.salmonPink)
                        }
                        .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                    .background(Color.softWhite)
                }
            }
            .navigationTitle("GlowBot")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        // Information action
                    } label: {
                        Image(systemName: "info.circle")
                            .foregroundColor(.white)
                    }
                }
            }
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(Color("SalmonPink"), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }
    
    private func sendMessage() {
        let trimmedMessage = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedMessage.isEmpty else { return }
        
        let newMessage = (id: UUID(), content: trimmedMessage, isUser: true, timestamp: Date())
        messages.append(newMessage)
        messageText = ""
        
        // Simulate bot typing
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isTyping = true
            
            // Simulate bot response after typing
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                isTyping = false
                let botResponse = (id: UUID(), content: "I'm analyzing your question about \"\(trimmedMessage)\". Let me provide some personalized advice for your skin type and current cycle phase.", isUser: false, timestamp: Date())
                messages.append(botResponse)
            }
        }
    }
}

// MARK: - Account View
struct AccountView: View {
    @AppStorage("cached_user_name") private var name = "User"
    @State private var email = ""
    @State private var birthdate = Date()
    @State private var skinType = ""
    @State private var notifications = true
    @State private var cycleTracking = true
    @State private var showingLogoutConfirmation = false
    @State private var isLoggingOut = false
    @State private var navigateToOnboarding = false
    @State private var navigateToAuth = false
    @State private var showingResetConfirmation = false
    @State private var isLoggedIn = false
    
    // Create state object for auth view model
    @StateObject private var authViewModel = AuthViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Profile header
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(Color("SalmonPink").opacity(0.8))
                                .frame(width: 100, height: 100)
                                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 3)
                            
                            if isLoggedIn {
                                Text(String(name.prefix(1).uppercased()))
                                    .font(.system(size: 36, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                            } else {
                                Image(systemName: "person.crop.circle.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.top, 20)
                        
                        if isLoggedIn {
                            Text(name)
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundColor(Color("CharcoalGray"))
                            
                            Text(email)
                                .font(.system(size: 16, design: .rounded))
                                .foregroundColor(Color("CharcoalGray").opacity(0.7))
                            
                            Button {
                                // Edit profile action
                            } label: {
                                Text("Edit Profile")
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .foregroundColor(Color("SalmonPink"))
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color("SalmonPink"), lineWidth: 1)
                                    )
                            }
                        } else {
                            Text("Sign In to Access Your Account")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(Color("CharcoalGray"))
                                .padding(.top, 8)
                            
                            Text("Create an account to save your skincare routine and track your progress")
                                .font(.system(size: 16, design: .rounded))
                                .foregroundColor(Color("CharcoalGray").opacity(0.7))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                                .padding(.bottom, 8)
                            
                            Button {
                                navigateToAuth = true
                            } label: {
                                Text("Sign In / Sign Up")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(Color("SalmonPink"))
                                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                                    )
                            }
                        }
                    }
                    
                    if isLoggedIn {
                        // Settings sections for logged in users
                        VStack(spacing: 8) {
                            settingSection(title: "Account", items: [
                                ("person.fill", "Personal Information"),
                                ("lock.fill", "Privacy & Security"),
                                ("bell.fill", "Notifications")
                            ])
                            
                            settingSection(title: "Preferences", items: [
                                ("heart.fill", "Skin Type: \(skinType)"),
                                ("calendar", "Cycle Tracking: \(cycleTracking ? "On" : "Off")"),
                                ("moon.stars.fill", "Dark Mode: Off")
                            ])
                            
                            settingSection(title: "Support", items: [
                                ("questionmark.circle.fill", "Help Center"),
                                ("envelope.fill", "Contact Us"),
                                ("star.fill", "Rate the App")
                            ])
                        }
                        .padding(.bottom, 20)
                        
                        // DEBUG OPTIONS
                        VStack(spacing: 12) {
                            Text("Debug Options")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(Color("CharcoalGray"))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 20)
                            
                            Button {
                                showingResetConfirmation = true
                            } label: {
                                HStack {
                                    Image(systemName: "arrow.clockwise.circle.fill")
                                        .font(.system(size: 18))
                                        .foregroundColor(.orange)
                                    
                                    Text("Reset Onboarding")
                                        .font(.system(size: 16, weight: .medium, design: .rounded))
                                        .foregroundColor(.orange)
                                }
                                .padding(.vertical, 12)
                                .frame(maxWidth: .infinity)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.orange, lineWidth: 1)
                                )
                            }
                            .padding(.horizontal)
                        }
                        .padding(.bottom, 12)
                        
                        Button {
                            showingLogoutConfirmation = true
                        } label: {
                            HStack {
                                if isLoggingOut {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .red))
                                        .padding(.trailing, 8)
                                }
                                
                                Text("Log Out")
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .foregroundColor(.red)
                            }
                            .padding(.vertical, 12)
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.red, lineWidth: 1)
                            )
                        }
                        .disabled(isLoggingOut)
                        .padding(.horizontal)
                        .padding(.bottom, 32)
                    } else {
                        // Simple settings for guest users
                        VStack(spacing: 8) {
                            settingSection(title: "General", items: [
                                ("questionmark.circle.fill", "Help Center"),
                                ("envelope.fill", "Contact Us"),
                                ("doc.text.fill", "Terms & Privacy Policy")
                            ])
                        }
                        .padding(.bottom, 20)
                    }
                }
            }
            .background(Color("SoftWhite"))
            .navigationTitle("My Account")
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(Color("SalmonPink"), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .alert("Log Out", isPresented: $showingLogoutConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Log Out", role: .destructive) {
                    logoutUser()
                }
            } message: {
                Text("Are you sure you want to log out?")
            }
            .alert("Reset Onboarding", isPresented: $showingResetConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    // Reset onboarding
                    if let userId = FirebaseManager.shared.userId {
                        // Mark quiz as not completed in Firestore
                        let db = Firestore.firestore()
                        db.collection("users").document(userId).setData(["quizCompleted": false], merge: true) { error in
                            if let error = error {
                                print("Error resetting quizCompleted flag: \(error.localizedDescription)")
                            }
                            // Navigate to onboarding
                            navigateToOnboarding = true
                        }
                    } else {
                        navigateToOnboarding = true
                    }
                }
            } message: {
                Text("This will restart the onboarding process including the skincare quiz. Continue?")
            }
            .fullScreenCover(isPresented: $navigateToOnboarding) {
                OnboardingView()
            }
            .fullScreenCover(isPresented: $navigateToAuth) {
                AuthView()
            }
            .onAppear {
                checkLoginStatus()
                loadUserData()
            }
            .task {
                // This ensures data is loaded even when user returns to this tab
                checkLoginStatus()
                loadUserData()
            }
        }
    }
    
    private func checkLoginStatus() {
        isLoggedIn = Auth.auth().currentUser != nil
    }
    
    private func loadUserData() {
        // Fetch current user data from Firebase
        if let user = Auth.auth().currentUser {
            self.email = user.email ?? ""
            
            // Get user's name and skin type from Firestore
            let db = Firestore.firestore()
            db.collection("users").document(user.uid).getDocument { document, error in
                if let document = document, document.exists {
                    if let data = document.data() {
                        // Look for fullName first (what we store during signup)
                        if let fullName = data["fullName"] as? String, !fullName.isEmpty {
                            self.name = fullName
                        }
                        // Fallback to displayName if fullName not found
                        else if let displayName = data["displayName"] as? String, !displayName.isEmpty {
                            self.name = displayName
                        } 
                        // Try Auth user display name as last resort
                        else if let displayName = user.displayName, !displayName.isEmpty {
                            self.name = displayName
                        }
                    }
                }
            }
            
            // Get skin profile data
            db.collection("users").document(user.uid).collection("profile").document("info").getDocument { document, error in
                if let document = document, document.exists {
                    if let data = document.data() {
                        self.skinType = data["skinType"] as? String ?? "Not set"
                    }
                }
            }
        }
    }
    
    private func logoutUser() {
        isLoggingOut = true
        
        // Reset the cached name
        name = "User"
        
        // Sign out the user
        FirebaseManager.shared.signOut()
        
        // Add a slight delay for the UI to show loading state
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            isLoggingOut = false
            isLoggedIn = false
            navigateToOnboarding = true
        }
    }
    
    // Helper function for setting sections
    private func settingSection(title: String, items: [(icon: String, text: String)]) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(Color("CharcoalGray"))
                .padding(.horizontal, 20)
            
            VStack(spacing: 0) {
                ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                    Button {
                        // Setting action
                    } label: {
                        HStack {
                            Image(systemName: item.icon)
                                .font(.system(size: 16))
                                .foregroundColor(Color("SalmonPink"))
                                .frame(width: 24)
                            
                            Text(item.text)
                                .font(.system(size: 16, design: .rounded))
                                .foregroundColor(Color("CharcoalGray"))
                            
                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical, 16)
                        .padding(.horizontal, 20)
                    }
                    
                    if index < items.count - 1 {
                        Divider()
                            .padding(.leading, 60)
                    }
                }
            }
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
            .padding(.horizontal)
        }
        .padding(.top, 8)
    }
}

#if DEBUG
struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
#endif 