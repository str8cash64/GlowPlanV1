import SwiftUI

struct QuizQuestion {
    let question: String
    let options: [String]
    let allowsMultipleSelections: Bool
}

struct QuizView: View {
    @State private var currentQuestionIndex = 0
    @State private var selectedAnswers: [[Int]] = Array(repeating: [], count: 5) // Store multiple selections per question
    @State private var navigateToRoutine = false
    
    let questions: [QuizQuestion] = [
        QuizQuestion(
            question: "What's your skin type?",
            options: [
                "Dry",
                "Normal",
                "Oily",
                "Combination"
            ],
            allowsMultipleSelections: false
        ),
        QuizQuestion(
            question: "What skin concerns do you have?",
            options: [
                "Acne",
                "Sun damage",
                "Fine lines",
                "Uneven tone"
            ],
            allowsMultipleSelections: true
        ),
        QuizQuestion(
            question: "How does your skin react to environmental changes?",
            options: [
                "More breakouts",
                "Drier than usual",
                "More sensitive",
                "No major changes"
            ],
            allowsMultipleSelections: true
        ),
        QuizQuestion(
            question: "What's your typical sleep quality?",
            options: [
                "Great, 7-9 hours",
                "OK, 5-7 hours",
                "Poor, under 5 hours",
                "Varies a lot"
            ],
            allowsMultipleSelections: false
        ),
        QuizQuestion(
            question: "How stressed do you feel on most days?",
            options: [
                "Low stress",
                "Moderate",
                "High stress",
                "Varies significantly"
            ],
            allowsMultipleSelections: false
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
                    
                    // For multiple selection questions, show helper text
                    if questions[currentQuestionIndex].allowsMultipleSelections {
                        Text("Select all that apply")
                            .font(.system(size: 16, design: .rounded))
                            .foregroundColor(Color("CharcoalGray").opacity(0.7))
                            .padding(.top, 5)
                    }
                    
                    Spacer()
                    
                    // Answer options
                    VStack(spacing: 16) {
                        ForEach(0..<questions[currentQuestionIndex].options.count, id: \.self) { index in
                            let option = questions[currentQuestionIndex].options[index]
                            let isSelected = selectedAnswers[currentQuestionIndex].contains(index)
                            
                            Button {
                                selectAnswer(index: index)
                            } label: {
                                HStack {
                                    Text(option)
                                        .font(.system(size: 18, weight: .medium, design: .rounded))
                                        .foregroundColor(isSelected ? .white : Color("CharcoalGray"))
                                        .padding(.vertical, 16)
                                        .padding(.leading, 16)
                                    
                                    Spacer()
                                    
                                    if isSelected {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.white)
                                            .padding(.trailing, 16)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(isSelected ? Color("SalmonPink") : Color.white)
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
                            Button {
                                navigateToRoutine = true
                            } label: {
                                SubmitButtonContent()
                            }
                            .disabled(selectedAnswers[currentQuestionIndex].isEmpty)
                            .opacity(selectedAnswers[currentQuestionIndex].isEmpty ? 0.5 : 1.0)
                        } else {
                            Button {
                                currentQuestionIndex += 1
                            } label: {
                                NextButtonContent()
                            }
                            .disabled(selectedAnswers[currentQuestionIndex].isEmpty)
                            .opacity(selectedAnswers[currentQuestionIndex].isEmpty ? 0.5 : 1.0)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 48)
                }
                .fullScreenCover(isPresented: $navigateToRoutine) {
                    RoutineView()
                }
            }
            .navigationTitle("Skin Quiz")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(Color("SalmonPink"), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
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
        let currentQuestion = questions[currentQuestionIndex]
        
        // If this question doesn't allow multiple selections, clear any existing selections
        if !currentQuestion.allowsMultipleSelections {
            selectedAnswers[currentQuestionIndex] = [index]
        } else {
            // For multiple selection questions
            if selectedAnswers[currentQuestionIndex].contains(index) {
                // If already selected, deselect it
                selectedAnswers[currentQuestionIndex].removeAll { $0 == index }
            } else {
                // Otherwise add to selections
                selectedAnswers[currentQuestionIndex].append(index)
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