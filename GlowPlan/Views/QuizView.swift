import SwiftUI

struct QuizQuestion {
    let question: String
    let options: [QuizOption]
}

struct QuizOption {
    let emoji: String
    let text: String
}

struct QuizView: View {
    @State private var currentQuestionIndex = 0
    @State private var selectedAnswers: [Int] = []
    
    let questions: [QuizQuestion] = [
        QuizQuestion(
            question: "What's your skin type?",
            options: [
                QuizOption(emoji: "💧", text: "Dry"),
                QuizOption(emoji: "✨", text: "Normal"),
                QuizOption(emoji: "🛢️", text: "Oily"),
                QuizOption(emoji: "🔄", text: "Combination")
            ]
        ),
        QuizQuestion(
            question: "What skin concerns do you have?",
            options: [
                QuizOption(emoji: "🔴", text: "Acne"),
                QuizOption(emoji: "🌞", text: "Sun damage"),
                QuizOption(emoji: "🧵", text: "Fine lines"),
                QuizOption(emoji: "🌈", text: "Uneven tone")
            ]
        ),
        QuizQuestion(
            question: "How does your skin change during your cycle?",
            options: [
                QuizOption(emoji: "📈", text: "More breakouts"),
                QuizOption(emoji: "🧴", text: "Drier than usual"),
                QuizOption(emoji: "🌡️", text: "More sensitive"),
                QuizOption(emoji: "🤷‍♀️", text: "No major changes")
            ]
        ),
        QuizQuestion(
            question: "What's your typical sleep quality?",
            options: [
                QuizOption(emoji: "😴", text: "Great, 7-9 hours"),
                QuizOption(emoji: "😐", text: "OK, 5-7 hours"),
                QuizOption(emoji: "😫", text: "Poor, under 5 hours"),
                QuizOption(emoji: "🔄", text: "Varies a lot")
            ]
        ),
        QuizQuestion(
            question: "How stressed do you feel on most days?",
            options: [
                QuizOption(emoji: "😌", text: "Low stress"),
                QuizOption(emoji: "😊", text: "Moderate"),
                QuizOption(emoji: "😰", text: "High stress"),
                QuizOption(emoji: "🎢", text: "Varies significantly")
            ]
        )
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("SoftWhite").ignoresSafeArea()
                
                VStack(spacing: 30) {
                    // Progress bar
                    QuizProgressBar(
                        currentQuestion: currentQuestionIndex + 1,
                        totalQuestions: questions.count
                    )
                    .padding(.top, 20)
                    
                    // Question
                    Text(questions[currentQuestionIndex].question)
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(Color("CharcoalGray"))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                        .padding(.top, 10)
                    
                    Spacer()
                    
                    // Answer options
                    VStack(spacing: 16) {
                        ForEach(0..<questions[currentQuestionIndex].options.count, id: \.self) { index in
                            let option = questions[currentQuestionIndex].options[index]
                            Button {
                                selectAnswer(index: index)
                            } label: {
                                HStack {
                                    Text(option.emoji)
                                        .font(.system(size: 28))
                                        .padding(.leading, 8)
                                    
                                    Text(option.text)
                                        .font(.system(size: 18, weight: .medium, design: .rounded))
                                        .foregroundColor(Color("CharcoalGray"))
                                        .padding(.vertical, 16)
                                    
                                    Spacer()
                                }
                                .frame(maxWidth: .infinity)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.white)
                                        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    Spacer()
                    
                    // Bottom button area
                    HStack {
                        if isLastQuestion {
                            NavigationLink {
                                RoutineView()
                            } label: {
                                SubmitButtonContent()
                            }
                        } else {
                            Button {
                                currentQuestionIndex += 1
                            } label: {
                                NextButtonContent()
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 48)
                }
            }
            .navigationTitle("Skin Quiz")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // Extract button contents into separate views
    private func SubmitButtonContent() -> some View {
        Text("Submit")
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
    }
    
    private func NextButtonContent() -> some View {
        Text("Next")
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
    }
    
    private var isLastQuestion: Bool {
        currentQuestionIndex == questions.count - 1
    }
    
    private func selectAnswer(index: Int) {
        if selectedAnswers.count > currentQuestionIndex {
            selectedAnswers[currentQuestionIndex] = index
        } else {
            selectedAnswers.append(index)
        }
        
        // Auto-advance after short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if !isLastQuestion {
                currentQuestionIndex += 1
            }
        }
    }
}

#if DEBUG
struct QuizView_Previews: PreviewProvider {
    static var previews: some View {
        QuizView()
    }
}
#endif 