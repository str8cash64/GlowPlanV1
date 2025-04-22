import SwiftUI

struct OnboardingView: View {
    @State private var isNavigatingToQuiz = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [Color("SoftWhite"), Color("Peach")]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 40) {
                    Spacer()
                    
                    // Logo placeholder
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.7))
                            .frame(width: 160, height: 160)
                            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                        
                        Image(systemName: "sparkles")
                            .font(.system(size: 70))
                            .foregroundColor(Color("SalmonPink"))
                    }
                    
                    VStack(spacing: 16) {
                        Text("Welcome to GlowPlan")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(Color("CharcoalGray"))
                            .multilineTextAlignment(.center)
                        
                        Text("Personalized skincare & wellness just for you")
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .foregroundColor(Color("CharcoalGray").opacity(0.8))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                    
                    Spacer()
                    
                    NavigationLink(destination: QuizView()) {
                        Text("Get Started")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color("SalmonPink"))
                                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                            )
                            .foregroundColor(.white)
                            .padding(.horizontal)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.bottom, 48)
                }
            }
            .navigationBarHidden(true)
        }
    }
}

#if DEBUG
struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}
#endif 