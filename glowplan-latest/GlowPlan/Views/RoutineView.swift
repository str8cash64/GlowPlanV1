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
    
    // Convert routineSteps to the format expected by RoutineSaveHandlerView
    private var convertedRoutineSteps: [RoutineStep] {
        return routineSteps.map { step in
            return RoutineStep(
                name: step.title,
                product: step.products.first ?? "",
                description: step.description
            )
        }
    }
    
    // Create a skin profile to pass to SignupView
    private var skinProfile: UserSkinProfile {
        let profile = UserSkinProfile()
        profile.skinType = "Combination"
        profile.primaryConcern = "General"
        profile.sensitivityLevel = "Normal"
        return profile
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("SoftWhite").ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        ForEach(routineSteps, id: \.number) { step in
                            RoutineViewStepCard(
                                number: step.number,
                                title: step.title,
                                description: step.description,
                                products: step.products
                            )
                        }
                        .padding(.horizontal)
                    }
                    .padding(.top, 24)
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
                    SignupView(skinProfile: skinProfile, skinRoutine: convertedRoutineSteps)
                }
            }
            .navigationTitle("Your Routine")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(Color("SalmonPink"), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }
}

struct RoutineViewStepCard: View {
    let number: Int
    let title: String
    let description: String
    let products: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 16) {
                // Step number circle
                ZStack {
                    Circle()
                        .fill(Color("SalmonPink").opacity(0.2))
                        .frame(width: 36, height: 36)
                    
                    Text("\(number)")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(Color("SalmonPink"))
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    // Step title
                    Text(title)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(Color("CharcoalGray"))
                    
                    // Step description
                    Text(description)
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(Color("CharcoalGray").opacity(0.8))
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            
            // Products
            VStack(alignment: .leading, spacing: 8) {
                Text("Recommended products:")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(Color("CharcoalGray"))
                
                ForEach(products, id: \.self) { product in
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 14))
                            .foregroundColor(Color("SalmonPink"))
                        
                        Text(product)
                            .font(.system(size: 14, design: .rounded))
                            .foregroundColor(Color("CharcoalGray"))
                    }
                }
            }
            .padding(.leading, 52)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
    }
}

#if DEBUG
struct RoutineView_Previews: PreviewProvider {
    static var previews: some View {
        RoutineView()
    }
}
#endif 
