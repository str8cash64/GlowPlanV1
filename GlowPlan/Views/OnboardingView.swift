import SwiftUI
import UIKit

struct OnboardingView: View {
    @State private var currentPage = 0
    @State private var showLogin = false
    @State private var startQuiz = false
    
    // Onboarding content data
    private let pages = [
        OnboardingPage(
            image: "onboarding_1",
            title: "Welcome to GlowPlan",
            description: "Your personal skincare assistant to help you achieve healthier, glowing skin."
        ),
        OnboardingPage(
            image: "onboarding_2",
            title: "Personalized Skincare Routines",
            description: "Get a customized routine based on your unique skin type, concerns, and goals."
        ),
        OnboardingPage(
            image: "onboarding_3",
            title: "Track Your Progress",
            description: "Log your skincare journey and watch your skin transform over time."
        )
    ]
    
    var body: some View {
        ZStack {
            // Background
            Color("SoftWhite").ignoresSafeArea()
            
            VStack {
                // Skip button (except on last page)
                if currentPage < pages.count - 1 {
                    HStack {
                        Spacer()
                        
                        Button("Skip") {
                            withAnimation {
                                currentPage = pages.count - 1
                            }
                        }
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(Color("SalmonPink"))
                        .padding()
                    }
                } else {
                    // Placeholder for consistent spacing
                    Spacer().frame(height: 50)
                }
                
                // Page content
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        OnboardingPageView(page: pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentPage)
                
                // Page indicator
                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Circle()
                            .fill(currentPage == index ? Color("SalmonPink") : Color.gray.opacity(0.3))
                            .frame(width: 8, height: 8)
                            .scaleEffect(currentPage == index ? 1.2 : 1.0)
                            .animation(.spring(), value: currentPage)
                    }
                }
                .padding(.top, 24)
                
                Spacer()
                
                // Action buttons
                if currentPage == pages.count - 1 {
                    // Final page buttons
                    VStack(spacing: 16) {
                        Button(action: {
                            startQuiz = true
                        }) {
                            Text("Start Your Skincare Journey")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color("SalmonPink"))
                                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                                )
                        }
                    }
                    .padding(.horizontal, 32)
                    .padding(.bottom, 32)
                } else {
                    // Next button
                    Button(action: {
                        withAnimation {
                            currentPage += 1
                        }
                    }) {
                        Text("Next")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color("SalmonPink"))
                                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                            )
                    }
                    .padding(.horizontal, 32)
                    .padding(.bottom, 32)
                }
            }
        }
        .fullScreenCover(isPresented: $startQuiz) {
            OnboardingQuizView()
        }
    }
}

// Individual page view
struct OnboardingPageView: View {
    let page: OnboardingPage
    
    var body: some View {
        VStack(spacing: 24) {
            // Image with fallback to system image if onboarding image is not available
            Group {
                if UIImage(named: page.image) != nil {
                    Image(page.image)
                        .resizable()
                        .scaledToFit()
                } else {
                    // Fallback to system image
                    Image(systemName: "star.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(Color("SalmonPink"))
                }
            }
            .frame(width: 280, height: 280)
            .padding(.top, 40)
            
            // Text content
            VStack(spacing: 16) {
                Text(page.title)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(Color("CharcoalGray"))
                    .multilineTextAlignment(.center)
                
                Text(page.description)
                    .font(.system(size: 16, design: .rounded))
                    .foregroundColor(Color("CharcoalGray").opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            Spacer()
        }
    }
}

// Onboarding page data model
struct OnboardingPage {
    let image: String
    let title: String
    let description: String
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
} 