//
//  FeatureBookmarkMainReducer.swift
//  FeatureStudy
//
//  Created by 정진균 on 3/29/25.
//

import ComposableArchitecture
import DI
import Model
import SwiftData

@Reducer
public struct FeatureBookmarkMainReducer {
    @Dependency(\.modelContext) var modelContext

    public init() {}

    @ObservableState
    public struct State: Equatable, Hashable {

        public init() {}

        var allQuestions: [QuestionItem] = []
        var bookmarkItems: [BookmarkItem] = []
        var allWrongAnswers: [WrongAnswerItem] = []

        var selectedTab: BookmarkTabType = .문제
        var showOnlyWrongAnswers: Bool = false

        var bookmarkFeedItems: [BookmarkFeedItem] {
            let bookmarkedIDs = Set(bookmarkItems.map { $0.questionID })
            let wrongAnswerIDs = Set(allWrongAnswers.map { $0.questionID })

            return allQuestions
                .filter { bookmarkedIDs.contains($0.id) || wrongAnswerIDs.contains($0.id) }
                .map {
                    let isWrong = wrongAnswerIDs.contains($0.id)
                    let isBookmarked = bookmarkedIDs.contains($0.id)
                    print("isBookmarked = \(isBookmarked)")
                    let tags = makeTags(for: $0, isWrong: isWrong)

                    return BookmarkFeedItem(
                        category: $0.subject.rawValue,
                        title: $0.title,
                        views: "\($0.viewCount)",
                        tags: tags,
                        isBookmarked: isBookmarked
                    )
                }
        }

        private func makeTags(for question: QuestionItem, isWrong: Bool) -> [String] {
            var tags: [String] = []

            // 시험 유형
            tags.append(question.questionType.displayName)

            if isWrong {
                tags.append("틀린 문제")
            }

            // 필기/실기 (예시는 subject 기준으로 임의 처리)
            if QuizSubject.writtenCases.contains(question.subject) {
                tags.append("필기시험")
            } else {
                tags.append("실기시험")
            }

            // 틀린 문제 여부 판단은 별도 로직 필요 시 추가
            return tags
        }

        var allConceptItems: [ConceptItem] = []
        var filteredConceptFeedItems: [ConceptItem] {
            return []
        }

        var questionFilter: QuestionFilterReducer.State = .init()
        var conceptSort: ConceptSortingReducer.State = .init()

        // Sheet
        @Presents var filter: QuestionFilterReducer.State?
        @Presents var conceptSortSheet: ConceptSortingReducer.State?

        var filteredBookmarkFeedItems: [BookmarkFeedItem] {
            bookmarkFeedItems.filter { item in
                let isWrong = item.tags.contains("틀린 문제")
                if showOnlyWrongAnswers && !isWrong {
                    return false
                }

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
                    case .ai:
                        return item.tags.contains("AI 예상 문제")
                    }
                }()

                return matchesExamType && matchesQuestionType
            }
        }
    }

    public enum InternalAction {
        case updateBookmarkData(allQuestions: [QuestionItem], bookmarks: [BookmarkItem], wrongAnswers: [WrongAnswerItem])
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
        case internalAction(InternalAction)
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
                return .run { send in
                    let allQuestions = try modelContext.fetch(FetchDescriptor<QuestionItem>())
                    let bookmarkItems = try modelContext.fetch(FetchDescriptor<BookmarkItem>())
                    let wrongAnswers = try modelContext.fetch(FetchDescriptor<WrongAnswerItem>())
                    await send(.internalAction(.updateBookmarkData(allQuestions: allQuestions, bookmarks: bookmarkItems, wrongAnswers: wrongAnswers)))
                }

            case .internalAction(.updateBookmarkData(let allQuestions, let bookmarks, let wrongAnswers)):
                state.allQuestions = allQuestions
                state.bookmarkItems = bookmarks
                state.allWrongAnswers = wrongAnswers
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
                        state.allConceptItems.sort { $0.views < $1.views }

                    case .mostViewed:
                        state.allConceptItems.sort { $0.views > $1.views }

                    case .az:
                        state.allConceptItems.sort { $0.title < $1.title }

                    case .za:
                        state.allConceptItems.sort { $0.title > $1.title }

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
