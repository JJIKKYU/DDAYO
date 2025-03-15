//
//  QuizBottomBtnView.swift
//  UIComponents
//
//  Created by 정진균 on 3/8/25.
//

import Model
import SwiftUI

public struct QuizBottomBtnView: View {
    @Binding private var isSheetPresented: Bool
    let answers: [QuizAnswer]
    @Binding var selectedIndex: Int?
    @Binding var step: FeatureQuizPlayStep
    let isCorrect: Bool?
    let onConfirmAnswer: () -> Void

    public init(
        isSheetPresented: Binding<Bool>,
        answers: [QuizAnswer],
        selectedIndex: Binding<Int?>,
        step: Binding<FeatureQuizPlayStep>,
        isCorrect: Bool?,
        onConfirmAnswer: @escaping () -> Void
    ) {
        self._isSheetPresented = isSheetPresented
        self.answers = answers
        self._selectedIndex = selectedIndex
        self._step = step
        self.isCorrect = isCorrect
        self.onConfirmAnswer = onConfirmAnswer
    }

    public var body: some View {
        ZStack(alignment: .bottom) {
            Color.clear.ignoresSafeArea()

            VStack {
                Spacer()

                HStack(spacing: 12) {
                    RoundImageButton(image: .bookmark) {
                        print("북마크 버튼 터치!")
                    }

                    Button(action: {
                        isSheetPresented.toggle()  // ✅ 버튼을 눌러 Sheet 표시
                    }) {
                        Text("정답 맞히기")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.Green._500)
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
                .padding(.top, 16)
                .clipShape(RoundedCornerShape(radius: 16, corners: [.topLeft, .topRight]))
                .background(.white)
                .background(.shadow(.drop(color: .black.opacity(0.06), radius: 20, x: 0, y: -2)))
            }
        }
        .ignoresSafeArea()
        .sheet(isPresented: $isSheetPresented) {
            AnswerSheetView(
                answers: self.answers,
                isSheetPresented: $isSheetPresented,
                selectedIndex: $selectedIndex,
                step: $step,
                isCorrect: isCorrect,
                onConfirmAnswer: onConfirmAnswer
            )
            .presentationDetents([.fraction(0.45), .medium, .large])
        }
    }
}

struct QuizBottomSheetView_Previews: PreviewProvider {
    static var previews: some View {
        @Previewable @State var selectedIndex: Int? = nil

        QuizBottomBtnView(
            isSheetPresented: .constant(true),
            answers: [
                .init(number: 0, title: "선택지 내용 1"),
                .init(number: 1, title: "선택지 내용 2"),
                .init(number: 2, title: "선택지 내용 3"),
                .init(number: 3, title: "선택지 내용 4"),
            ],
            selectedIndex: $selectedIndex,
            step: .constant(.confirmAnswers),
            isCorrect: false,
            onConfirmAnswer: {
                print("onConfirm!")
            }
        )
    }
}
