//
//  FeatureQuizMainReducer.swift
//  FeatureQuiz
//
//  Created by JJIKKYU on 2/4/25.
//

import ComposableArchitecture

// MARK: - 필기, 실기 선택 상태 정의

public enum QuizTab: Int, Equatable, CaseIterable {
    case 필기 = 0
    case 실기 = 1
}

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
                .init(title: "필기1 기출 문제", subtitle: "역대 시험에 출제된 문제들을 모았어요.", buttons: [.init(title: "랜덤 문제 풀기", action: .randomQuiz), .init(title: "과목별로 풀기", action: .subjectQuiz)]),
                .init(title: "필기2 기출 문제", subtitle: "역대 시험에 출제된 문제들을 모았어요.", buttons: [.init(title: "랜덤 문제 풀기", action: .randomQuiz), .init(title: "과목별로 풀기", action: .subjectQuiz)]),
            ],
            .실기 : [
                .init(title: "실기1 기출 문제", subtitle: "역대 시험에 출제된 문제들을 모았어요.", buttons: [.init(title: "랜덤 문제 풀기", action: .randomQuiz), .init(title: "과목별로 풀기", action: .subjectQuiz)]),
                .init(title: "실기2 기출 문제", subtitle: "역대 시험에 출제된 문제들을 모았어요.", buttons: [.init(title: "랜덤 문제 풀기", action: .randomQuiz), .init(title: "과목별로 풀기", action: .subjectQuiz)]),
            ]
        ]
    }

    public enum Action {
        case selectTab(QuizTab)
        case swipeTab(QuizTab)

        case navigateToQuizSubject(QuizTab)
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
    case timeLimitMode
}
