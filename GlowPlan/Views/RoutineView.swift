import SwiftUI

struct RoutineView: View {
    @State private var navigateToSignup = false
    
    let routineSteps: [(number: Int, title: String, description: String, products: [String])] = [
        (number: 1, title: "Morning Cleanse", description: "Start with a gentle foaming cleanser to remove overnight buildup without stripping your skin", products: ["Gentle Foaming Cleanser", "Micellar Water"]),
        (number: 2, title: "Tone & Hydrate", description: "Apply alcohol-free toner to balance your skin's pH level", products: ["Balancing Toner"]),
        (number: 3, title: "Target Treatment", description: "Apply a vitamin C serum to brighten skin and protect against environmental damage", products: ["Vitamin C Serum"]),
        (number: 4, title: "Moisturize", description: "Lock in hydration with a lightweight moisturizer suitable for your combination skin", products: ["Oil-Free Moisturizer"]),
        (number: 5, title: "Sun Protection", description: "Always finish with SPF 30+ to protect against UV damage, even on cloudy days", products: ["SPF 50 Sunscreen", "Tinted Moisturizer with SPF"])
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("SoftWhite").ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 32) {
                        // Header
                        VStack(spacing: 16) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 36))
                                .foregroundColor(Color("SalmonPink"))
                                .padding(.top, 20)
                            
                            Text("Your Personalized Routine")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(Color("CharcoalGray"))
                                .multilineTextAlignment(.center)
                            
                            Text("Based on your quiz results, we've created the perfect routine for your skin needs")
                                .font(.system(size: 16, design: .rounded))
                                .foregroundColor(Color("CharcoalGray"))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)
                        }
                        .padding(.top, 20)
                        
                        // Routine steps
                        VStack(spacing: 16) {
                            ForEach(routineSteps, id: \.number) { step in
                                RoutineStepCard(
                                    stepNumber: step.number,
                                    title: step.title,
                                    description: step.description
                                )
                            }
                        }
                        .padding(.bottom, 100) // Extra padding for button
                    }
                }
                
                VStack {
                    Spacer()
                    
                    // Continue button at bottom
                    Button(action: {
                        navigateToSignup = true
                    }) {
                        Text("Continue to Save Routine")
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
                    .padding(.bottom, 32)
                    .background(
                        Rectangle()
                            .fill(Color("SoftWhite"))
                            .frame(height: 100)
                            .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: -5)
                            .ignoresSafeArea()
                    )
                }
                .fullScreenCover(isPresented: $navigateToSignup) {
                    SignupView()
                }
            }
            .navigationTitle("Your Routine")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#if DEBUG
struct RoutineView_Previews: PreviewProvider {
    static var previews: some View {
        RoutineView()
    }
}
#endif 
