//
//  QuizPopupView.swift
//  UIComponents
//
//  Created by 정진균 on 3/15/25.
//

import SwiftUI
import Model

public struct QuizPopupView: View {
    public let onAction: (Bool) -> Void
    @Binding private var isVisible: Bool
    // 푼 문제
    public let solvedQuizCnt: Int
    // 전체 문제
    public let allQuizCnt: Int
    // 맞춘 문제
    public let correctQuizCnt: Int
    public let quizOption: QuizStartOption

    public init(
        visible: Binding<Bool>,
        solvedQuizCnt: Int,
        allQuizCnt: Int,
        correctQuizCnt: Int,
        quizOption: QuizStartOption,
        onAction: @escaping (Bool) -> Void
    ) {
        self._isVisible = visible
        self.solvedQuizCnt = solvedQuizCnt
        self.allQuizCnt = allQuizCnt
        self.correctQuizCnt = correctQuizCnt
        self.quizOption = quizOption
        self.onAction = onAction
    }

    private var allDone: Bool {
        return solvedQuizCnt == allQuizCnt
    }

    private var title: String {
        switch allDone {
        case true:
            return "모든 문제를 풀었어요! 👏"

        case false:
            return "\(correctQuizCnt)문제를 맞혔어요!"
        }
    }

    private var desc: String {
        switch allDone {
        case true:
            switch quizOption {
            case .startRandomQuiz:
                return "랜덤 문제로 복습해볼까요?"

            case .startSubjectQuiz:
                return "다음 과목 {과목명} 문제를 풀어볼까요?"

            case .startLanguageQuiz:
                return "다음 언어 {언어명} 문제를 풀어볼까요?"
            }

        case false:
            return "\(allQuizCnt - solvedQuizCnt)문제만 더 풀면 \(allQuizCnt)문제를 채울 수 있어요\n오늘의 공부를 마무리할까요?"
        }
    }

    private var leadingTitle: String {
        switch allDone {
        case true:
            return "나가기"

        case false:
            return "더 공부하기"
        }
    }

    private var trailingTitle: String {
        switch allDone {
        case true:
            switch quizOption {
            case .startRandomQuiz:
                return "복습하기"

            case .startSubjectQuiz:
                return "다음 과목 풀기"

            case .startLanguageQuiz:
                return "다음 언어 풀기"
            }

        case false:
            return "끝내기"
        }
    }

    public var body: some View {
        ZStack {
            if isVisible {
                // 배경 어둡게
                Color.Grayscale.black.opacity(0.6)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        onAction(true) // 배경 클릭 시 닫힘
                        isVisible = false
                    }

                // 팝업 컨텐츠
                VStack(alignment: .leading, spacing: 0) {
                    VStack(alignment: .leading) {
                        HStack {
                            Text(title)
                                .font(.system(size: 18, weight: .bold))
                                .foregroundStyle(Color.Grayscale._900)

                            Spacer()
                        }
                        .padding(.bottom, 6)

                        Text(desc)
                            .lineSpacing(4.0)
                            .font(.system(size: 15, weight: .regular))
                            .foregroundStyle(Color.Grayscale._800)
                            .multilineTextAlignment(.leading)
                    }
                    .padding(.all, 8)

                    HStack(spacing: 12) {
                        Button(action: {
                            onAction(true) // 닫기
                            isVisible = false
                        }) {
                            Text(leadingTitle)
                                .font(.system(size: 16, weight: .semibold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14.5)
                                .background(Color.Grayscale._100)
                                .foregroundColor(Color.Grayscale._900)
                                .cornerRadius(12)
                        }

                        Button(action: {
                            print("공부 종료") // 원하는 동작 실행
                            onAction(false)
                            isVisible = false
                        }) {
                            Text(trailingTitle)
                                .font(.system(size: 16, weight: .semibold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14.5)
                                .background(allDone ? Color.Green._500 : Color.Red._500)
                                .foregroundColor(Color.Grayscale.white)
                                .cornerRadius(12)
                        }
                    }
                    .padding(.top, 12)
                    .frame(maxWidth: .infinity)
                }
                .padding(.all, 20)
                .frame(maxWidth: UIScreen.main.bounds.width - 40)
                .background(Color.Grayscale.white)
                .cornerRadius(24)
            }
        }
        .animation(.easeInOut, value: isVisible)
    }
}

#Preview {
    QuizPopupView(
        visible: .constant(false),
        solvedQuizCnt: 20,
        allQuizCnt: 10,
        correctQuizCnt: 7,
        quizOption: .startLanguageQuiz,
        onAction: { _ in }
    )
}
