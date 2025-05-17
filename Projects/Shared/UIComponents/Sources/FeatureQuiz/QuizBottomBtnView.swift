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
    let question: QuestionItem?
    @Binding var isBookmarked: Bool
    let onConfirmAnswer: () -> Void
    let onSelectBookmark: () -> Void
    @State private var answerTotalHeight: CGFloat = 0

    public init(
        isSheetPresented: Binding<Bool>,
        answers: [QuizAnswer],
        selectedIndex: Binding<Int?>,
        step: Binding<FeatureQuizPlayStep>,
        isCorrect: Bool?,
        question: QuestionItem?,
        isBookmarked: Binding<Bool>,
        onConfirmAnswer: @escaping () -> Void,
        onSelectBookmark: @escaping () -> Void
    ) {
        self._isSheetPresented = isSheetPresented
        self.answers = answers
        self._selectedIndex = selectedIndex
        self._step = step
        self.isCorrect = isCorrect
        self.question = question
        self._isBookmarked = isBookmarked
        self.onConfirmAnswer = onConfirmAnswer
        self.onSelectBookmark = onSelectBookmark
    }

    public var foregroundColor: Color {
        switch step {
        case .showAnswers, .confirmAnswers:
            return Color.Grayscale.white

        case .solvedQuestion:
            return Color.Grayscale._900
        }
    }

    public var backgroundColor: Color {
        switch step {
        case .showAnswers, .confirmAnswers:
            return Color.Green._500

        case .solvedQuestion:
            return Color.Grayscale._100
        }
    }

    public var body: some View {
        ZStack(alignment: .bottom) {
            Color.clear.ignoresSafeArea()

            VStack {
                Spacer()

                HStack(spacing: 12) {
                    RoundImageButton(image: isBookmarked ? .bookmarkFilled : .bookmark, isBookmarked: $isBookmarked) {
                        onSelectBookmark()
                    }

                    Button(action: {
                        isSheetPresented.toggle()  // ✅ 버튼을 눌러 Sheet 표시
                    }) {
                        Text("정답 맞히기")
                            .font(.headline)
                            .foregroundColor(foregroundColor)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(backgroundColor)
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
                .padding(.top, 16)
                .clipShape(RoundedCornerShape(radius: 16, corners: [.topLeft, .topRight]))
                .background(Color.Grayscale.white)
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
                isBookmarked: $isBookmarked,
                question: question,
                onConfirmAnswer: onConfirmAnswer,
                onSelectBookmark: onSelectBookmark,
                answerTotalHeight: $answerTotalHeight
            )
            .presentationDetents(dynamicDetents(from: answerTotalHeight))
        }
    }
}

// MARK: - 높이 계산

extension QuizBottomBtnView {
    private func dynamicDetents(from height: CGFloat) -> Set<PresentationDetent> {
        // 실기 같은 경우에는 답안 선택이 없으므로 항상 일정 크기로 제공
        if let question = question {
            if question.subject.isPracticalCase || question.subject.isPracticalLanguageCase {
                return [.fraction(0.45), .medium, .large]
            }
        }

        let screenHeight = UIScreen.main.bounds.height
        let bottomPadding: CGFloat = 170 // 버튼 영역 등 포함한 하단 고정 영역
        let extraPadding: CGFloat = 30 // 여유 여백 추가

        let totalNeededHeight = height + bottomPadding + extraPadding
        let ratio = totalNeededHeight / screenHeight
        let clamped = min(max(ratio, 0.3), 0.95)

        print("▶️ height: \(height), total: \(totalNeededHeight), clamped: \(clamped)")

        // 정답 확인할 때는 동적 크기가 아닌 정적 크기로 변환
        if step == .confirmAnswers {
            return [.fraction(clamped), .medium, .large]
        }

        return [.fraction(clamped)]
    }

    private func fractionDetent(for totalLines: Int) -> CGFloat {
        let baseFraction: CGFloat = 0.25  // 최소 시작 높이
        let lineHeightFraction: CGFloat = 0.05  // 한 줄마다 추가되는 비율

        let fraction = baseFraction + (CGFloat(totalLines) * lineHeightFraction)
        return min(fraction, 0.9)  // 최대 높이 제한
    }

    private var lineHeight: CGFloat {
        UIFont.systemFont(ofSize: 15).lineHeight
    }

    private func estimatedLines(for text: String) -> Int {
        let width: CGFloat = UIScreen.main.bounds.width - 40 - 24 - 32
        let font = UIFont.systemFont(ofSize: 15)
        let lineSpacing: CGFloat = 4.5
        let nsText = text as NSString
        let boundingRect = nsText.boundingRect(
            with: CGSize(width: width, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: [.font: font],
            context: nil
        )
        let lineHeight = font.lineHeight + lineSpacing
        let totalHeight = ceil(boundingRect.height)

        return Int(ceil(totalHeight / lineHeight))
    }
}

// MARK: - Preview

struct QuizBottomSheetView_Previews: PreviewProvider {
    static var previews: some View {
        @Previewable @State var selectedIndex: Int? = nil
        @Previewable @State var isBookmarked: Bool = false

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
            question: nil,
            isBookmarked: $isBookmarked,
            onConfirmAnswer: {
                print("onConfirm!")
            },
            onSelectBookmark: {
                print("북마크 선택됨")
            }
        )
    }
}
