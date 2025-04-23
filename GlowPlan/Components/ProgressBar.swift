import SwiftUI

struct ProgressBar: View {
    var value: Double
    var height: CGFloat = 12
    var backgroundColor: Color = Color.gray.opacity(0.2)
    var foregroundColor: Color = Color("SalmonPink")
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(backgroundColor)
                    .frame(width: geometry.size.width, height: height)
                
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(foregroundColor)
                    .frame(width: min(CGFloat(value) * geometry.size.width, geometry.size.width), height: height)
                    .animation(.easeInOut, value: value)
            }
        }
        .frame(height: height)
    }
}

struct QuizProgressBar: View {
    let currentQuestion: Int
    let totalQuestions: Int
    
    var body: some View {
        VStack(spacing: 8) {
            ProgressBar(value: Double(currentQuestion) / Double(totalQuestions))
                .frame(height: 12)
            
            HStack {
                Text("Question \(currentQuestion) of \(totalQuestions)")
                    .font(.subheadline)
                    .foregroundColor(Color("CharcoalGray"))
                
                Spacer()
                
                Text("\(Int((Double(currentQuestion) / Double(totalQuestions)) * 100))%")
                    .font(.subheadline)
                    .foregroundColor(Color("CharcoalGray"))
            }
        }
        .padding(.horizontal)
    }
}

#if DEBUG
struct ProgressBar_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            QuizProgressBar(currentQuestion: 2, totalQuestions: 5)
            QuizProgressBar(currentQuestion: 3, totalQuestions: 5)
            QuizProgressBar(currentQuestion: 5, totalQuestions: 5)
        }
        .padding()
        .background(Color("SoftWhite"))
    }
}
#endif 