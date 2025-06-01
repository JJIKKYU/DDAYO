//
//  AnswerSheetView.swift
//  UIComponents
//
//  Created by 정진균 on 3/8/25.
//

import SwiftUI
import Model

public struct AnswerSheetView: View {
    let answers: [QuizAnswer]
    @Binding var isSheetPresented: Bool
    @Binding var selectedIndex: Int?
    @Binding var step: FeatureQuizPlayStep
    let isCorrect: Bool?
    @Binding var isBookmarked: Bool
    let question: QuestionItem?
    let onConfirmAnswer: () -> Void
    let onSelectBookmark: () -> Void
    @Binding var answerTotalHeight: CGFloat

    public init(
        answers: [QuizAnswer],
        isSheetPresented: Binding<Bool>,
        selectedIndex: Binding<Int?>,
        step: Binding<FeatureQuizPlayStep>,
        isCorrect: Bool?,
        isBookmarked: Binding<Bool>,
        question: QuestionItem?,
        onConfirmAnswer: @escaping () -> Void,
        onSelectBookmark: @escaping () -> Void,
        answerTotalHeight: Binding<CGFloat>
    ) {
        self.answers = answers
        self._isSheetPresented = isSheetPresented
        self._selectedIndex = selectedIndex
        self._step = step
        self.isCorrect = isCorrect
        self._isBookmarked = isBookmarked
        self.question = question
        self.onConfirmAnswer = onConfirmAnswer
        self.onSelectBookmark = onSelectBookmark
        self._answerTotalHeight = answerTotalHeight
    }

    public var btnTitle: String {
        switch step {
        case .showAnswers:
            return "정답 확인"

        case .confirmAnswers:
            return "다음 문제"

        case .solvedQuestion(let isCorrect):
            return "닫기"
        }
    }

    public var btnForegroundColor: Color {
        switch step {
        case .showAnswers:
            return Color.Grayscale.white

        case .confirmAnswers:
            return Color.Grayscale.white

        case .solvedQuestion(let isCorrect):
            return Color.Grayscale._900
        }
    }

    public var btnBackgroundColor: Color {
        switch step {
        case .showAnswers:
            return Color.Green._500

        case .confirmAnswers:
            return Color.Green._500

        case .solvedQuestion(let isCorrect):
            return Color.Grayscale._100
        }
    }

    public var body: some View {
        VStack(alignment: .leading) {
            Spacer()
                .frame(height: 30)

            switch step {
            case .showAnswers:
                VStack {
                    VStack(spacing: 12) {
                        ForEach(0..<answers.count, id: \.self) { index in
                            AnswerBtnView(
                                title: answers[index].title,
                                isChecked: Binding(
                                    get: { selectedIndex == index },  // ✅ 선택 여부 확인
                                    set: { newValue in
                                        if newValue { selectedIndex = index }  // ✅ 한 개만 선택되도록 업데이트
                                    }
                                ),
                                onHeightUpdate: { height in
                                    self.answerTotalHeight += height
                                }
                            )
                        }
                    }

                    Spacer()

                    HStack(spacing: 12) {
                        RoundImageButton(image: isBookmarked ? .bookmarkFilled : .bookmark, isBookmarked: $isBookmarked) {
                            onSelectBookmark()
                        }

                        Button(action: {
                            onConfirmAnswer()
                        }) {
                            Text(btnTitle)
                                .font(.headline)
                                .foregroundColor(btnForegroundColor)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(btnBackgroundColor)
                                .cornerRadius(12)
                        }
                    }
                }

            case .confirmAnswers, .solvedQuestion:
                ScrollView {
                    if let question, let selectedIndex {
                        // 필기 문제
                        if question.subject.isWrittenCase {
                            Text(isCorrect == true ? "정답이에요" : "오답이에요")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundStyle(Color.Grayscale._900)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.bottom, 15)

                            if isCorrect == true {
                                AnswerBtnView(
                                    title: question.choices[selectedIndex],
                                    isChecked: .constant(true),
                                    btnType: .correct
                                )
                            } else {
                                AnswerBtnView(
                                    title: question.choices[selectedIndex],
                                    isChecked: .constant(false),
                                    btnType: .incorrectWrongAnswer
                                )
                                AnswerBtnView(
                                    title: question.choices[question.answer - 1],
                                    isChecked: .constant(false),
                                    btnType: .incorrectCorrectAnswer
                                )
                            }

                            MarkdownTextView(text: question.explanation.text)
                                .padding(.top, 10)
                                .font(.system(size: 15, weight: .regular))
                                .foregroundStyle(Color.Grayscale._700)
                                .lineSpacing(5.0)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        // 실기 문제
                        else {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("정답")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundStyle(Color.Grayscale._900)

                                Text("\(question.choices[question.answer - 1])")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundStyle(Color.Grayscale._900)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .lineSpacing(4.5)
                            }

                            MarkdownTextView(text: question.explanation.text)
                                .padding(.top, 10)
                                .font(.system(size: 15, weight: .regular))
                                .foregroundStyle(Color.Grayscale._700)
                                .lineSpacing(5.0)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
                .padding(.init(top: 0, leading: 0, bottom: 0, trailing: 0))

                Spacer()

                HStack(spacing: 12) {
                    RoundImageButton(image: isBookmarked ? .bookmarkFilled : .bookmark, isBookmarked: $isBookmarked) {
                        onSelectBookmark()
                    }

                    Button(action: {
                        onConfirmAnswer()
                    }) {
                        Text(btnTitle)
                            .font(.headline)
                            .foregroundColor(btnForegroundColor)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(btnBackgroundColor)
                            .cornerRadius(12)
                    }
                }
            }
        }
        .onAppear {
            answerTotalHeight = 0  // ✅ 시트가 열릴 때 높이 초기화
        }
        .padding(.horizontal, 20)
        .animation(.easeInOut(duration: 0.3), value: step)
        .background(Color.Background._1.ignoresSafeArea())
    }
}

#Preview {
    @Previewable @State var isSheetPresented: Bool = false
    @Previewable @State var selectedIndex: Int? = nil
    let answers: [QuizAnswer] = [
        .init(number: 0, title: "선택지 내용 0"),
        .init(number: 1, title: "선택지 내용 1"),
        .init(number: 2, title: "선택지 내용 2"),
        .init(number: 3, title: "선택지 내용 3"),
    ]

    AnswerSheetView(
        answers: answers,
        isSheetPresented: $isSheetPresented,
        selectedIndex: $selectedIndex,
        step: .constant(.showAnswers),
        isCorrect: true,
        isBookmarked: .constant(false),
        question: nil,
        onConfirmAnswer: {
            print("onConfirm!")
        },
        onSelectBookmark: {
            print("onSelectBookmark!")
        },
        answerTotalHeight: .constant(10)
    )
}
