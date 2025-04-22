import SwiftUI

struct SignupView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isShowingLogin = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("SoftWhite").ignoresSafeArea()
                
                VStack(spacing: 32) {
                    // Header
                    VStack(spacing: 16) {
                        Image(systemName: "person.crop.circle.fill.badge.plus")
                            .font(.system(size: 60))
                            .foregroundColor(Color("SalmonPink"))
                            .padding(.top, 60)
                        
                        Text(isShowingLogin ? "Welcome Back" : "Create your GlowPlan account")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(Color("CharcoalGray"))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                        
                        Text(isShowingLogin ? "Sign in to access your saved routines" : "Save your personalized skincare routine and track your progress")
                            .font(.system(size: 16, design: .rounded))
                            .foregroundColor(Color("CharcoalGray"))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                    
                    Spacer()
                    
                    // Form fields
                    VStack(spacing: 24) {
                        GlowTextField(
                            title: "Email",
                            placeholder: "Enter your email",
                            text: $email
                        )
                        
                        GlowTextField(
                            title: "Password",
                            placeholder: "Enter your password",
                            text: $password,
                            isSecure: true
                        )
                    }
                    
                    Spacer()
                    
                    // Sign up/Login button
                    NavigationLink(destination: MainTabView()) {
                        Text(isShowingLogin ? "Login" : "Sign Up")
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
                    
                    // Toggle between signup and login
                    Button {
                        withAnimation {
                            isShowingLogin.toggle()
                        }
                    } label: {
                        Text(isShowingLogin ? "Don't have an account? Sign Up" : "Already have an account? Login")
                            .font(.subheadline)
                            .foregroundColor(Color("SalmonPink"))
                    }
                    .padding(.bottom, 32)
                }
            }
            .navigationTitle(isShowingLogin ? "Login" : "Create Account")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#if DEBUG
struct SignupView_Previews: PreviewProvider {
    static var previews: some View {
        SignupView()
    }
}
#endif 