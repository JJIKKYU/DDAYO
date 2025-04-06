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

        var selectedTab: BookmarkTabType = .문제
        var showOnlyWrongAnswers: Bool = false

        var filteredQuestions: [QuestionItem] {
            let bookmarked = bookmarkItems
                .filter { $0.type == .문제 }
                .sorted(by: { $0.date > $1.date })

            let bookmarkedIDs = Set(bookmarked
                .map { $0.questionID })

            let wrongAnswerIDs = Set(bookmarked
                .filter({ $0.reason == .wrong })
                .map { $0.questionID })

            let questionMap = Dictionary(uniqueKeysWithValues: allQuestions.map { ($0.id, $0) })

            return bookmarked.compactMap { bookmark in
                guard let question = questionMap[bookmark.questionID] else { return nil }

                let isWrong = wrongAnswerIDs.contains(question.id)
                let tags = makeTags(for: question, isWrong: isWrong)

                if showOnlyWrongAnswers && !tags.contains("틀린 문제") {
                    return nil
                }

                let matchesExamType: Bool = {
                    switch questionFilter.examType {
                    case .all: return true
                    case .written: return tags.contains("필기시험")
                    case .practical: return tags.contains("실기시험")
                    }
                }()

                let matchesQuestionType: Bool = {
                    switch questionFilter.questionType {
                    case .all: return true
                    case .past: return tags.contains("기출 문제")
                    case .ai: return tags.contains("AI 예상 문제")
                    }
                }()

                return (matchesExamType && matchesQuestionType) ? question : nil
            }
        }
        var bookmarkFeedItems: [BookmarkFeedItem] {
            let bookmarkedIDs = Set(
                bookmarkItems
                    .filter { $0.type == .문제 }
                    .map { $0.questionID }
            )
            let wrongAnswerIDs = Set(
                bookmarkItems
                    .filter { $0.type == .문제 && $0.reason == .wrong }
                    .map { $0.questionID }
            )

            return filteredQuestions
                .map {
                    let isWrong = wrongAnswerIDs.contains($0.id)
                    let isBookmarked = bookmarkedIDs.contains($0.id)
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

        var allConcepts: [ConceptItem] = []
        var filteredConceptItems: [ConceptItem] {
            let bookmarkedIDs = Set(
                bookmarkItems
                    .filter { $0.type == .개념 }
                    .map { $0.questionID }
            )
            return allConcepts.filter { bookmarkedIDs.contains($0.id) }
        }
        var filteredConceptFeedItems: [BookmarkFeedItem] {
            filteredConceptItems.map {
                return BookmarkFeedItem(
                    category: $0.subject,
                    title: $0.title,
                    views: "\($0.views)",
                    tags: [],
                    isBookmarked: true,
                    originConceptItem: $0
                )
            }
        }

        var questionFilter: QuestionFilterReducer.State = .init()
        var conceptSort: ConceptSortingReducer.State = .init()

        // Sheet
        @Presents var filter: QuestionFilterReducer.State?
        @Presents var conceptSortSheet: ConceptSortingReducer.State?
    }

    public enum InternalAction {
        case updateBookmarkData(
            allQuestions: [QuestionItem],
            allConcepts: [ConceptItem],
            bookmarks: [BookmarkItem]
        )
    }

    public enum Action {
        case selectTab(BookmarkTabType)
        case swipeTab(BookmarkTabType)
        case selectItem(Int)

        case questionFilter(QuestionFilterReducer.Action)
        case conceptSort(ConceptSortingReducer.Action)
        case filter(PresentationAction<QuestionFilterReducer.Action>)
        case sort(PresentationAction<ConceptSortingReducer.Action>)
        case openFilter
        case openSort
        case toggleWrongOnly
        case onAppear
        case internalAction(InternalAction)

        case navigateToStudyDetail(items: [ConceptItem], idnex: Int)
        case navigateToQuizPlay(items: [QuestionItem], index: Int)
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
                    do {
                        // MainActor에서 fetch
                        let (allQuestions, allConcepts, bookmarkItems) = try await MainActor.run {
                            let allQuestions: [QuestionItem] = try modelContext.fetch(FetchDescriptor<QuestionItem>())
                            let allConcepts: [ConceptItem] = try modelContext.fetch(FetchDescriptor<ConceptItem>())
                            let bookmarkItems: [BookmarkItem] = try modelContext.fetch(FetchDescriptor<BookmarkItem>())
                            return (allQuestions, allConcepts, bookmarkItems)
                        }

                        await send(.internalAction(.updateBookmarkData(
                            allQuestions: allQuestions,
                            allConcepts: allConcepts,
                            bookmarks: bookmarkItems
                        )))
                    } catch {
                        print("FeatureBookmarkMainReducer :: modelContext fetch error: \(error)")
                    }
                }

            case .internalAction(.updateBookmarkData(let allQuestions, let allConcepts, let bookmarks)):
                state.allQuestions = allQuestions
                state.allConcepts = allConcepts
                state.bookmarkItems = bookmarks
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
                        state.allConcepts.sort { $0.views < $1.views }

                    case .mostViewed:
                        state.allConcepts.sort { $0.views > $1.views }

                    case .az:
                        state.allConcepts.sort { $0.title < $1.title }

                    case .za:
                        state.allConcepts.sort { $0.title > $1.title }

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

            case .selectItem(let index):
                print("Selected item at index: \(index)")
                switch state.selectedTab {
                case .문제:
                    let filteredQuestions: [QuestionItem] = state.filteredQuestions
                    Task {
                        await MainActor.run {
                            if let selectedQuestion: QuestionItem = filteredQuestions[safe: index] {
                                selectedQuestion.viewCount += 1
                                modelContext.insert(selectedQuestion)
                                try? modelContext.save()
                            }
                        }
                    }

                    return .run { send in
                        await send(.navigateToQuizPlay(items: filteredQuestions, index: index))
                    }

                case .개념:
                    let filteredConcepts: [ConceptItem] = state.filteredConceptItems
                    Task {
                        await MainActor.run {
                            if let selectedConcept: ConceptItem = filteredConcepts[safe: index] {
                                selectedConcept.views += 1
                                modelContext.insert(selectedConcept)
                                try? modelContext.save()
                            }
                        }
                    }

                    return .run { send in
                        await send(.navigateToStudyDetail(items: filteredConcepts, idnex: index))
                    }
                }

            case .navigateToStudyDetail, .navigateToQuizPlay:
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
