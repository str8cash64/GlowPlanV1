import SwiftUI

struct OnboardingView: View {
    @State private var isNavigatingToQuiz = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background color
                Color("SoftWhite").ignoresSafeArea()
                
                VStack(spacing: 40) {
                    Spacer()
                    
                    // Skincare illustration
                    Image("skincare_illustration")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 300)
                        .padding(.horizontal, 20)
                    
                    VStack(spacing: 16) {
                        Text("Welcome to GlowPlan")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(Color("CharcoalGray"))
                            .multilineTextAlignment(.center)
                        
                        Text("Personalized skincare & wellness just for you")
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .foregroundColor(Color("CharcoalGray"))
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
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(Color("SalmonPink"), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
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