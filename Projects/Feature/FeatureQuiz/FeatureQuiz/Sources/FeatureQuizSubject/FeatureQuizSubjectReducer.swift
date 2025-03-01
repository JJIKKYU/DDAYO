//
//  FeatureQuizSubjectReducer.swift
//  FeatureQuiz
//
//  Created by 정진균 on 2/22/25.
//

import ComposableArchitecture

@Reducer
public struct FeatureQuizSubjectReducer {
    public init() {}

    public struct State: Equatable {
        public init(selectedSujbect: QuizTab = .필기) {
            self.selectedSujbect = selectedSujbect
        }

        public var selectedSujbect: QuizTab = .필기
        public var subjectList: [QuizTab: [String]] = [
            .필기: [
                "소프트웨어 설계",
                "소프트웨어 개발",
                "데이터베이스 구축",
                "프로그래밍 언어 활용",
                "정보시스템 구축 관리",
                "소프트웨어 설계",
                "소프트웨어 개발",
                "데이터베이스 구축",
                "프로그래밍 언어 활용",
                "정보시스템 구축 관리",
                "소프트웨어 설계",
                "소프트웨어 개발",
                "데이터베이스 구축",
                "프로그래밍 언어 활용",
                "정보시스템 구축 관리",
            ],
            .실기: [
                "소프트웨어 설계",
                "소프트웨어 개발",
                "데이터베이스 구축",
                "프로그래밍 언어 활용",
                "정보시스템 구축 관리",
            ]
        ]
    }

    public enum Action: Equatable {
        case onAppear
        // TODO: 필요한 액션 추가
    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                // TODO: 초기 로직 추가
                return .none
            }
        }
    }
}
