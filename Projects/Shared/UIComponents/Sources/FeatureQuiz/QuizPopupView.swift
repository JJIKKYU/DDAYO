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
        switch quizSourceType {
        // 북마크일 경우에는 항상 true
        case .fromBookmark:
            return true

        default:
            return solvedQuizCnt == allQuizCnt
        }
    }

    public var body: some View {
        BasePopupView(
            isVisible: isVisible,
            title: title,
            desc: desc,
            leadingTitle: leadingTitle,
            trailingTitle: trailingTitle,
            allDone: allDone,
            onLeadingAction: {
                onAction(allDone ? .dismiss : .keepStudying)
                isVisible = false
            },
            onTrailingAction: {
                handleTrailingButtonAction()
            }
        )
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
        // 북마크일 경우에는 항상 마지막 문제를 풀면
        // 모든 문제를 풀었다고 노출
        switch quizSourceType {
        case .fromBookmark:
            return "모든 문제를 풀었어요! 👏"

        // 그 외 화면에서는 푼 문제 개수 노출
        default:
            switch allDone {
            case true:
                return "모든 문제를 풀었어요! 👏"

            case false:
                return "\(correctQuizCnt)문제를 맞혔어요!"
            }
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
            let roundedTarget = ((solvedQuizCnt + 9) / 10) * 10
            let remaining = roundedTarget - solvedQuizCnt
            return "\(remaining)문제만 더 풀면 \(roundedTarget)문제를 채울 수 있어요\n오늘의 공부를 마무리할까요?"
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
        switch quizSourceType {
        case .fromBookmark:
            return "복습하기"

        default:
            if !allDone { return "끝내기" }

            switch quizOption {
            case .startRandomQuiz:
                return "복습하기"

            case .startSubjectQuiz:
                return nextSubjectName != nil ? "다음 과목 풀기" : "복습하기"

            case .startLanguageQuiz:
                return nextSubjectName != nil ? "다음 언어 풀기" : "복습하기"
            }
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

        return next.displayName
    }

    private var messageContext: QuizPopupMessageContext {
        switch quizSourceType {
        case .fromBookmark:
            return .allDoneFromBookmark

        default:
            guard allDone else { return .notYetDone }

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
