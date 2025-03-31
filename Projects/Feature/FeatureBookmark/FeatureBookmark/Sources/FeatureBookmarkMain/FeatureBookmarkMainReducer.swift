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
        var showOnlyWrongAnswers: Bool = false
        let bookmarkFeedItems: [BookmarkFeedItem] = [
            .init(category: "소프트웨어 개발 보안 구축", title: "UML에서 활용되는 다이어그램 중, 시스템의 동작을 표현하는 행위 다이어그램에 해당하지 않는 것은?", views: "99999+", tags: ["필기시험", "틀린 문제"], isBookmarked: true),
            .init(category: "데이터베이스", title: "정규화 과정 중 BCNF의 정의로 올바른 것은?", views: "8823", tags: ["필기시험", "기출 문제"], isBookmarked: true),
            .init(category: "운영체제", title: "프로세스와 스레드의 차이점에 대한 설명으로 옳은 것을 고르시오.", views: "4312", tags: ["틀린 문제", "AI 예상 문제"], isBookmarked: true),
            .init(category: "자료구조", title: "B-Tree와 B+Tree의 차이점 중 틀린 것은?", views: "2304", tags: ["필기시험"], isBookmarked: true),
            .init(category: "네트워크", title: "OSI 7계층 중 전송 계층의 역할로 적절한 것은?", views: "11993", tags: ["틀린 문제", "기출 문제"], isBookmarked: true),
            .init(category: "정보보호론", title: "해시 함수의 충돌 회피 전략 중 설명으로 틀린 것은?", views: "1394", tags: ["필기시험", "AI 예상 문제"], isBookmarked: true),
            .init(category: "프로그래밍 언어", title: "Swift에서 struct와 class의 차이점 중 맞는 것을 고르시오.", views: "8932", tags: ["필기시험", "기출 문제"], isBookmarked: true),
            .init(category: "소프트웨어 공학", title: "Agile 개발 방법론의 핵심 원칙으로 적절하지 않은 것은?", views: "9982", tags: ["틀린 문제"], isBookmarked: true),
            .init(category: "자료구조", title: "Stack과 Queue의 차이점으로 맞는 설명은?", views: "2039", tags: ["필기시험"], isBookmarked: true),
            .init(category: "컴퓨터 구조", title: "캐시 메모리의 지역성 원칙에 대한 설명으로 틀린 것은?", views: "7451", tags: ["틀린 문제"], isBookmarked: true),
            .init(category: "알고리즘", title: "다익스트라 알고리즘의 시간 복잡도는?", views: "1321", tags: ["기출 문제"], isBookmarked: true),
            .init(category: "보안", title: "공개키 암호 방식의 특징으로 옳은 것은?", views: "2442", tags: ["실기시험"], isBookmarked: true),
            .init(category: "인공지능", title: "머신러닝과 딥러닝의 차이는?", views: "8123", tags: ["AI 예상 문제"], isBookmarked: true),
            .init(category: "운영체제", title: "세마포어와 뮤텍스의 차이점은?", views: "9183", tags: ["실기시험"], isBookmarked: true),
            .init(category: "컴파일러", title: "어휘 분석기의 역할은 무엇인가?", views: "342", tags: ["기출 문제"], isBookmarked: true),
            .init(category: "네트워크", title: "TCP와 UDP의 차이점은?", views: "9001", tags: ["기출 문제"], isBookmarked: true),
            .init(category: "데이터베이스", title: "트랜잭션의 4가지 특성은?", views: "8744", tags: ["AI 예상 문제"], isBookmarked: true),
            .init(category: "모바일", title: "iOS와 Android의 메모리 관리 차이는?", views: "1934", tags: ["실기시험", "틀린 문제"], isBookmarked: true),
            .init(category: "운영체제", title: "페이지 교체 알고리즘의 종류는?", views: "763", tags: ["기출 문제"], isBookmarked: true),
            .init(category: "알고리즘", title: "퀵정렬의 평균 시간 복잡도는?", views: "1284", tags: ["필기시험"], isBookmarked: true),
            .init(category: "프로그래밍 언어", title: "자바의 캡슐화란 무엇인가?", views: "2372", tags: ["AI 예상 문제"], isBookmarked: true),
            .init(category: "소프트웨어 공학", title: "폭포수 모델과 애자일 모델의 차이는?", views: "4923", tags: ["기출 문제"], isBookmarked: true),
            .init(category: "컴퓨터 구조", title: "파이프라이닝의 효과는?", views: "5423", tags: ["필기시험", "틀린 문제"], isBookmarked: true),
            .init(category: "데이터베이스", title: "인덱스의 종류와 사용법은?", views: "3512", tags: ["기출 문제"], isBookmarked: true),
            .init(category: "보안", title: "SQL Injection 방지 방법은?", views: "6782", tags: ["AI 예상 문제"], isBookmarked: true),
            .init(category: "네트워크", title: "DHCP의 역할은 무엇인가?", views: "7841", tags: ["기출 문제", "틀린 문제"], isBookmarked: true),
            .init(category: "운영체제", title: "프로세스 스케줄링 알고리즘 비교", views: "3043", tags: ["필기시험"], isBookmarked: true),
            .init(category: "프로그래밍 언어", title: "함수형 프로그래밍의 특징은?", views: "1783", tags: ["AI 예상 문제"], isBookmarked: true),
            .init(category: "소프트웨어 공학", title: "요구사항 분석 시 고려할 점은?", views: "2014", tags: ["기출 문제"], isBookmarked: true),
            .init(category: "컴퓨터 구조", title: "RISC와 CISC의 차이점은?", views: "938", tags: ["실기시험"], isBookmarked: true)
        ]
        var conceptItems: [ConceptItem] = [
            .init(title: "가. 개념학습 1", description: "안녕하세요 반갑습니다 안녕하세요 반갑습니다 안녕하세요 반갑습니다 안녕하세요 반갑습니다", views: 1),
            .init(title: "나. 개념학습 2", description: "안녕하세요 반갑습니다 안녕하세요 반갑습니다 안녕하세요 반갑습니다 안녕하세요 반갑습니다", views: 223),
            .init(title: "다. 개념학습 3", description: "안녕하세요 반갑습니다 안녕하세요 반갑습니다 안녕하세요 반갑습니다 안녕하세요 반갑습니다", views: 3),
            .init(title: "아. 개념학습 4", description: "안녕하세요 반갑습니다 안녕하세요 반갑습니다 안녕하세요 반갑습니다 안녕하세요 반갑습니다", views: 44),
            .init(title: "카. 개념학습 5", description: "안녕하세요 반갑습니다 안녕하세요 반갑습니다 안녕하세요 반갑습니다 안녕하세요 반갑습니다", views: 51),
            .init(title: "하. 개념학습 6", description: "안녕하세요 반갑습니다 안녕하세요 반갑습니다 안녕하세요 반갑습니다 안녕하세요 반갑습니다", views: 6),
        ]

        var questionFilter: QuestionFilterReducer.State = .init()
        var conceptSort: ConceptSortingReducer.State = .init()

        // Sheet
        @Presents var filter: QuestionFilterReducer.State?
        @Presents var conceptSortSheet: ConceptSortingReducer.State?

        var filteredBookmarkFeedItems: [BookmarkFeedItem] {
            bookmarkFeedItems.filter { item in
                let matchesWrongOnly = !showOnlyWrongAnswers || item.tags.contains("틀린 문제")

                let matchesExamType: Bool = {
                    switch questionFilter.examType {
                    case .all:
                        return true
                    case .written:
                        return item.tags.contains("필기시험")
                    case .practical:
                        return item.tags.contains("실기시험")
                    }
                }()

                let matchesQuestionType: Bool = {
                    switch questionFilter.questionType {
                    case .all:
                        return true
                    case .past:
                        return item.tags.contains("기출 문제")
                    case .predicted:
                        return item.tags.contains("AI 예상 문제")
                    }
                }()

                return matchesWrongOnly && matchesExamType && matchesQuestionType
            }
        }
    }

    public enum Action {
        case selectTab(BookmarkTabType)
        case swipeTab(BookmarkTabType)

        case questionFilter(QuestionFilterReducer.Action)
        case conceptSort(ConceptSortingReducer.Action)
        case filter(PresentationAction<QuestionFilterReducer.Action>)
        case sort(PresentationAction<ConceptSortingReducer.Action>)
        case openFilter
        case openSort
        case toggleWrongOnly
        case onAppear
    }

    public var body: some ReducerOf<Self> {
        Scope(state: \.questionFilter, action: \.questionFilter) {
            QuestionFilterReducer()
        }

        Scope(state: \.conceptSort, action: \.conceptSort) {
            ConceptSortingReducer()
        }

        Reduce { state, action in
            switch action {
            case .onAppear:
                return .none

            case .openFilter:
                state.filter = state.questionFilter // ✅ 기존 값으로 초기화
                return .none

            case .filter(.presented(.dismiss)):
                if let filtered = state.filter {
                    state.questionFilter = filtered
                }
                state.filter = nil
                return .none

            case .filter(.dismiss):
                // ✅ 시트에서 dismiss 되었을 때 값 동기화
                print("FeatureBookmarkMainReducer :: 값 동기화!, filter = \(state.filter)")
                if let filtered = state.filter {
                    state.questionFilter = filtered
                }
                return .none

            case .filter:
                return .none

            case .selectTab(let tab):
                print("FeatureBookmarkMainReducer :: selectedTab = \(tab)")
                state.selectedTab = tab
                return .none

            case .swipeTab(let tab):
                print("FeatureBookmarkMainReducer :: swipeTab = \(tab)")
                state.selectedTab = tab
                return .none

            case .questionFilter:
                return .none

            case .openSort:
                state.conceptSortSheet = state.conceptSort
                return .none

            case .sort(.dismiss):
                print("FeatureBookmarkMainReducer :: .sort(.dismiss)")
                if let sorted = state.conceptSortSheet {
                    state.conceptSort = sorted
                }
                return .none

            case .sort(.presented(.dismiss)):
                print("FeatureBookmarkMainReducer :: .sort(.presented(.dismiss))")
                if let sorted = state.conceptSortSheet {
                    state.conceptSort = sorted

                    switch sorted.selectedOption {
                    case .leastViewed:
                        state.conceptItems.sort { $0.views < $1.views }

                    case .mostViewed:
                        state.conceptItems.sort { $0.views > $1.views }

                    case .az:
                        state.conceptItems.sort { $0.title < $1.title }

                    case .za:
                        state.conceptItems.sort { $0.title > $1.title }

                    case .none:
                        break
                    }
                }
                state.conceptSortSheet = nil
                return .none

            case .conceptSort:
                return .none

            case .sort:
                return .none

            case .toggleWrongOnly:
                state.showOnlyWrongAnswers.toggle()
                return .none
            }
        }
        .ifLet(\.$filter, action: \.filter) {
            QuestionFilterReducer()
        }
        .ifLet(\.$conceptSortSheet, action: \.sort) {
            ConceptSortingReducer()
        }
    }
}
