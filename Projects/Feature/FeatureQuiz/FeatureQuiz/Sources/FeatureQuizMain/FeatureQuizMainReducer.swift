//
//  FeatureQuizMainReducer.swift
//  FeatureQuiz
//
//  Created by JJIKKYU on 2/4/25.
//

import ComposableArchitecture
import Model

// MARK: - Reducer

@Reducer
public struct FeatureQuizMainReducer {

    public init() {}

    @ObservableState
    public struct State: Equatable, Hashable {
        public init() {}

        var selectedTab: QuizTab = .필기
        var examSections: [QuizTab: [ExamSectionData]] = [
            .필기 : [
                .init(title: "기출 문제", subtitle: "역대 시험에 출제된 문제들을 모았어요.", buttons: [.init(title: "랜덤 문제 풀기", action: .randomQuiz), .init(title: "과목별로 풀기", action: .subjectQuiz)]),
                .init(title: "AI 예상 문제", subtitle: "시험 트렌드를 학습한 AI의 예상 문제를 풀어보세요!", buttons: [.init(title: "랜덤 문제 풀기", action: .randomQuiz), .init(title: "과목별로 풀기", action: .subjectQuiz)]),
            ],
            .실기 : [
                .init(title: "기출 문제", subtitle: "역대 시험에 출제된 문제들을 모았어요.", buttons: [.init(title: "랜덤 문제 풀기", action: .randomQuiz), .init(title: "언어별로 풀기", action: .languagetQuiz), .init(title: "과목별로 풀기", action: .subjectQuiz)]),
                .init(title: "AI 예상 문제", subtitle: "시험 트렌드를 학습한 AI의 예상 문제를 풀어보세요!", buttons: [.init(title: "랜덤 문제 풀기", action: .randomQuiz), .init(title: "언어별로 풀기", action: .languagetQuiz), .init(title: "과목별로 풀기", action: .subjectQuiz)]),
            ]
        ]
    }

    public enum Action {
        case selectTab(QuizTab)
        case swipeTab(QuizTab)

        case navigateToQuizSubject(QuizTab)
        case navigateToSearch
    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .selectTab(let tab):
                print("FeatureQuizMainReducer :: selectedTab = \(tab)")
                state.selectedTab = tab
                return .none

            case .swipeTab(let tab):
                print("FeatureQuizMainReducer :: swipeTab = \(tab)")
                state.selectedTab = tab
                return .none

            case .navigateToQuizSubject:
                return .none

            case .navigateToSearch:
                return .none
            }
        }
    }
}

public struct ExamSectionData: Equatable, Hashable {
    var title: String
    var subtitle: String
    var buttons: [ExamSectionButton]
}

public struct ExamSectionButton: Equatable, Hashable {
    var title: String
    var action: ExamButtonAction
}

public enum ExamButtonAction: Equatable {
    case randomQuiz
    case subjectQuiz
    case languagetQuiz
    case timeLimitMode
}
