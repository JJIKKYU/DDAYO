//
//  QuizPopupView.swift
//  UIComponents
//
//  Created by 정진균 on 3/15/25.
//

import Model
import SwiftUI

public struct QuizPopupView: View {
    public let onAction: (QuizPopupAction) -> Void
    @Binding private var isVisible: Bool
    // 푼 문제
    public let solvedQuizCnt: Int
    // 전체 문제
    public let allQuizCnt: Int
    // 맞춘 문제
    public let correctQuizCnt: Int
    public let quizOption: QuizStartOption
    public let quizSubject: QuizSubject?
    public let quizSourceType: QuizSourceType

    public init(
        visible: Binding<Bool>,
        solvedQuizCnt: Int,
        allQuizCnt: Int,
        correctQuizCnt: Int,
        quizOption: QuizStartOption,
        quizSubject: QuizSubject?,
        quizSourceType: QuizSourceType,
        onAction: @escaping (QuizPopupAction) -> Void
    ) {
        self._isVisible = visible
        self.solvedQuizCnt = solvedQuizCnt
        self.allQuizCnt = allQuizCnt
        self.correctQuizCnt = correctQuizCnt
        self.quizOption = quizOption
        self.quizSubject = quizSubject
        self.quizSourceType = quizSourceType
        self.onAction = onAction
    }

    private var allDone: Bool {
        return solvedQuizCnt == allQuizCnt
    }

    public var body: some View {
        ZStack {
            if isVisible {
                // 배경 어둡게
                Color.Grayscale.black.opacity(0.6)
                    .edgesIgnoringSafeArea(.all)

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
                            onAction(allDone ? .dismiss : .keepStudying)
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
                            handleTrailingButtonAction()
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
        visible: .constant(true),
        solvedQuizCnt: 10,
        allQuizCnt: 10,
        correctQuizCnt: 7,
        quizOption: .startSubjectQuiz,
        quizSubject: .applicationTesting,
        quizSourceType: .subject(nil, nil),
        onAction: { _ in }
    )
}

// MARK: - String Token

extension QuizPopupView {
    private var title: String {
        switch allDone {
        case true:
            return "모든 문제를 풀었어요! 👏"

        case false:
            return "\(correctQuizCnt)문제를 맞혔어요!"
        }
    }

    private var desc: String {
        switch messageContext {
        case .allDoneFromBookmark:
            return "처음부터 다시 복습해볼까요?"

        case .allDoneFromRandom:
            return "랜덤 문제로 복습해볼까요?"

        case .allDoneFromSubject(let next):
            return next != nil
                ? "다음 과목 \(next!) 문제를 풀어볼까요?"
                : "랜덤 문제로 복습해볼까요?"

        case .allDoneFromLanguage(let next):
            return next != nil
                ? "다음 언어 \(next!) 문제를 풀어볼까요?"
                : "랜덤 문제로 복습해볼까요?"

        case .notYetDone:
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
        if allDone {
            switch quizSourceType {
            case .fromBookmark:
                return "복습하기"

            default:
                switch quizOption {
                case .startRandomQuiz:
                    return "복습하기"

                case .startSubjectQuiz:
                    return nextSubjectName != nil ? "다음 과목 풀기" : "복습하기"

                case .startLanguageQuiz:
                    return nextSubjectName != nil ? "다음 언어 풀기" : "복습하기"
                }
            }
        } else {
            return "끝내기"
        }
    }

    private var nextSubjectName: String? {
        guard solvedQuizCnt == allQuizCnt,
              let quizSubject = quizSubject
        else { return nil }

        let group = quizSubject.group
        guard !group.isEmpty,
              let index = group.firstIndex(of: quizSubject),
              let next = group[safe: index + 1]
        else {
            return nil
        }

        return next.rawValue
    }

    private var messageContext: QuizPopupMessageContext {
        guard allDone else { return .notYetDone }

        switch quizSourceType {
        case .fromBookmark:
            return .allDoneFromBookmark

        default:
            switch quizOption {
            case .startRandomQuiz:
                return .allDoneFromRandom

            case .startSubjectQuiz:
                return .allDoneFromSubject(next: nextSubjectName)

            case .startLanguageQuiz:
                return .allDoneFromLanguage(next: nextSubjectName)
            }
        }
    }

    private func handleTrailingButtonAction() {
        print("공부 종료") // 원하는 동작 실행

        switch quizSourceType {
        case .fromBookmark:
            if allDone {
                onAction(.reviewRandomFromBookmark)
            }

        default:
            switch quizOption {
            case .startRandomQuiz:
                onAction(allDone ? .reviewRandom : .finishStudy)

            case .startSubjectQuiz:
                if allDone {
                    if nextSubjectName != nil {
                        onAction(.nextSubject)
                    } else {
                        onAction(.reviewRandom)
                    }
                } else {
                    onAction(.finishStudy)
                }

            case .startLanguageQuiz:
                if allDone {
                    if nextSubjectName != nil {
                        onAction(.nextLanguage)
                    } else {
                        onAction(.reviewRandom)
                    }
                } else {
                    onAction(.finishStudy)
                }
            }
        }

        isVisible = false
    }
}

private extension QuizSourceType {
    var isBookmarkSource: Bool {
        if case .fromBookmark = self {
            return true
        }
        return false
    }
}
