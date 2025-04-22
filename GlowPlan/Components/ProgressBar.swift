import SwiftUI

struct ProgressBar: View {
    let value: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color("Peach").opacity(0.3))
                    .cornerRadius(12)
                    .frame(width: geometry.size.width, height: 12)
                
                Rectangle()
                    .fill(Color("SalmonPink"))
                    .cornerRadius(12)
                    .frame(width: min(CGFloat(self.value) * geometry.size.width, geometry.size.width), height: 12)
            }
        }
        .frame(height: 12)
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