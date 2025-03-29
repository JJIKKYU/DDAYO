//
//  FeatureBookmarkMainReducer.swift
//  FeatureStudy
//
//  Created by 정진균 on 3/29/25.
//

import ComposableArchitecture
import Model

@Reducer
public struct FeatureBookmarkMainReducer {

    public init() {}

    @ObservableState
    public struct State: Equatable, Hashable {

        public init() {}

        var selectedTab: BookmarkTabType = .문제
        let bookmarkItems: [BookmarkItem] = [
            .init(category: "소프트웨어 개발 보안 구축", title: "UML에서 활용되는 다이어그램 중, 시스템의 동작을 표현하는 행위 다이어그램에 해당하지 않는 것은?", views: "99999+", tags: ["필기시험", "틀린 문제"], isBookmarked: true),
            .init(category: "데이터베이스", title: "정규화 과정 중 BCNF의 정의로 올바른 것은?", views: "8823", tags: ["필기시험"], isBookmarked: false),
            .init(category: "운영체제", title: "프로세스와 스레드의 차이점에 대한 설명으로 옳은 것을 고르시오.", views: "4312", tags: ["틀린 문제"], isBookmarked: true),
            .init(category: "자료구조", title: "B-Tree와 B+Tree의 차이점 중 틀린 것은?", views: "2304", tags: ["필기시험"], isBookmarked: false),
            .init(category: "네트워크", title: "OSI 7계층 중 전송 계층의 역할로 적절한 것은?", views: "11993", tags: ["틀린 문제"], isBookmarked: true),
            .init(category: "정보보호론", title: "해시 함수의 충돌 회피 전략 중 설명으로 틀린 것은?", views: "1394", tags: ["필기시험"], isBookmarked: false),
            .init(category: "프로그래밍 언어", title: "Swift에서 struct와 class의 차이점 중 맞는 것을 고르시오.", views: "8932", tags: ["필기시험"], isBookmarked: true),
            .init(category: "소프트웨어 공학", title: "Agile 개발 방법론의 핵심 원칙으로 적절하지 않은 것은?", views: "9982", tags: ["틀린 문제"], isBookmarked: true),
            .init(category: "자료구조", title: "Stack과 Queue의 차이점으로 맞는 설명은?", views: "2039", tags: ["필기시험"], isBookmarked: false),
            .init(category: "컴퓨터 구조", title: "캐시 메모리의 지역성 원칙에 대한 설명으로 틀린 것은?", views: "7451", tags: ["틀린 문제"], isBookmarked: false)
        ]
        var conceptItems: [ConceptItem] = [
            .init(title: "가. 개념학습 1", description: "안녕하세요 반갑습니다 안녕하세요 반갑습니다 안녕하세요 반갑습니다 안녕하세요 반갑습니다", views: 1),
            .init(title: "나. 개념학습 2", description: "안녕하세요 반갑습니다 안녕하세요 반갑습니다 안녕하세요 반갑습니다 안녕하세요 반갑습니다", views: 223),
            .init(title: "다. 개념학습 3", description: "안녕하세요 반갑습니다 안녕하세요 반갑습니다 안녕하세요 반갑습니다 안녕하세요 반갑습니다", views: 3),
            .init(title: "아. 개념학습 4", description: "안녕하세요 반갑습니다 안녕하세요 반갑습니다 안녕하세요 반갑습니다 안녕하세요 반갑습니다", views: 44),
            .init(title: "카. 개념학습 5", description: "안녕하세요 반갑습니다 안녕하세요 반갑습니다 안녕하세요 반갑습니다 안녕하세요 반갑습니다", views: 51),
            .init(title: "하. 개념학습 6", description: "안녕하세요 반갑습니다 안녕하세요 반갑습니다 안녕하세요 반갑습니다 안녕하세요 반갑습니다", views: 6),
        ]
    }

    public enum Action {
        case selectTab(BookmarkTabType)
        case swipeTab(BookmarkTabType)

        case onAppear
    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .none

            case .selectTab(let tab):
                print("FeatureBookmarkMainReducer :: selectedTab = \(tab)")
                state.selectedTab = tab
                return .none

            case .swipeTab(let tab):
                print("FeatureBookmarkMainReducer :: swipeTab = \(tab)")
                state.selectedTab = tab
                return .none
            }
        }
    }
}
