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
import Foundation

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

                let isWrong: Bool = wrongAnswerIDs.contains(question.id)
                let tags: [String] = question.tags(isWrong: isWrong)

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
                    case .expected: return tags.contains("예상 문제")
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
                    let tags: [String] = $0.tags(isWrong: isWrong)

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
                    case .expected:
                        return item.tags.contains("예상 문제")
                    case .ai:
                        return item.tags.contains("AI 예상 문제")
                    }
                }()

                return matchesExamType && matchesQuestionType
            }
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

        // Bookmark
        case toggleBookmark(index: Int)
        case updateBookmarkStatus(index: Int, isBookmarked: Bool)

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
                let selectedOption: SortOption = state.conceptSort.selectedOption ?? .default
                return .run { send in
                    do {
                        // MainActor에서 fetch
                        let (allQuestions, allConcepts, bookmarkItems) = try await MainActor.run {
                            let allQuestions: [QuestionItem] = try modelContext.fetch(FetchDescriptor<QuestionItem>())
                            let allConcepts: [ConceptItem] = try modelContext.fetch(FetchDescriptor<ConceptItem>())
                            let bookmarkItems: [BookmarkItem] = try modelContext.fetch(FetchDescriptor<BookmarkItem>())
                            return (allQuestions, allConcepts, bookmarkItems)
                        }

                        let sortedConcepts: [ConceptItem]
                        switch selectedOption {
                        case .default:
                            sortedConcepts = allConcepts.sortedByDefault()

                        case .leastViewed:
                            sortedConcepts = allConcepts.sortedByViews(ascending: true)

                        case .mostViewed:
                            sortedConcepts = allConcepts.sortedByViews(ascending: false)

                        case .az:
                            sortedConcepts = allConcepts.sortedByTitle(ascending: true)

                        case .za:
                            sortedConcepts = allConcepts.sortedByTitle(ascending: false)
                        }

                        await send(.internalAction(.updateBookmarkData(
                            allQuestions: allQuestions,
                            allConcepts: sortedConcepts,
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
                    case .default:
                        state.allConcepts = state.allConcepts.sortedByDefault()
                    case .leastViewed:
                        state.allConcepts = state.allConcepts.sortedByViews(ascending: true)
                    case .mostViewed:
                        state.allConcepts = state.allConcepts.sortedByViews(ascending: false)
                    case .az:
                        state.allConcepts = state.allConcepts.sortedByTitle(ascending: true)
                    case .za:
                        state.allConcepts = state.allConcepts.sortedByTitle(ascending: false)
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

            case .toggleBookmark(let index): // New case handling
                switch state.selectedTab {
                case .문제:
                    guard let item: QuestionItem = state.filteredQuestions[safe: index] else { return .none }
                    let questionID: UUID = item.id
                    return .run { send in
                        let isBookmarked: Bool = try await MainActor.run {
                            let predicate = #Predicate<BookmarkItem> {
                                $0.questionID == questionID
                            }
                            if let existing: BookmarkItem = try? modelContext.fetch(FetchDescriptor<BookmarkItem>(predicate: predicate)).first {
                                modelContext.delete(existing)
                                try modelContext.save()
                                return false
                            } else {
                                let newBookmark: BookmarkItem = .init(questionID: questionID, type: .문제, reason: .manual)
                                modelContext.insert(newBookmark)
                                try modelContext.save()
                                return true
                            }
                        }

                        await send(.updateBookmarkStatus(index: index, isBookmarked: isBookmarked))
                    }

                case .개념:
                    guard let item: ConceptItem = state.filteredConceptItems[safe: index] else { return .none }
                    let conceptID: UUID = item.id
                    return .run { send in
                        let isBookmarked: Bool = try await MainActor.run {
                            let predicate = #Predicate<BookmarkItem> {
                                $0.questionID == conceptID
                            }
                            if let existing: BookmarkItem = try? modelContext.fetch(FetchDescriptor<BookmarkItem>(predicate: predicate)).first {
                                modelContext.delete(existing)
                                try modelContext.save()
                                return false
                            } else {
                                let newBookmark: BookmarkItem = .init(questionID: conceptID, type: .개념, reason: .manual)
                                modelContext.insert(newBookmark)
                                try modelContext.save()
                                return true
                            }
                        }

                        await send(.updateBookmarkStatus(index: index, isBookmarked: isBookmarked))
                    }
                }

            case .updateBookmarkStatus(let index, let isBookmarked):
                print("FeatureBookmarkMainReducer :: updateBookmarkStatus, index = \(index), isBookmarked = \(isBookmarked), tab = \(state.selectedTab)")

                switch state.selectedTab {
                case .문제:
                    guard let question: QuestionItem = state.filteredQuestions[safe: index] else { return .none }
                    state.bookmarkItems.removeAll { question.id == $0.questionID }

                    if !isBookmarked { return .none }
                    let newBookmark: BookmarkItem = .init(questionID: question.id, type: .문제, reason: .manual)
                    state.bookmarkItems.append(newBookmark)

                case .개념:
                    guard  let concept: ConceptItem = state.filteredConceptItems[safe: index] else { return .none }
                    state.bookmarkItems.removeAll { $0.questionID == concept.id }

                    if !isBookmarked { return .none }
                    let newBookmark: BookmarkItem = .init(questionID: concept.id, type: .개념, reason: .manual)
                    state.bookmarkItems.append(newBookmark)
               }
                return .none

            case .selectItem(let index):
                print("Selected item at index: \(index)")
                switch state.selectedTab {
                case .문제:
                    let filteredQuestions: [QuestionItem] = state.filteredQuestions
                    return .run { send in
                        try await MainActor.run {
                            guard let selectedQuestion: QuestionItem = filteredQuestions[safe: index] else { return }
                            selectedQuestion.viewCount += 1
                            modelContext.insert(selectedQuestion)
                            try modelContext.save()
                        }

                        await send(.navigateToQuizPlay(items: filteredQuestions, index: index))
                    }

                case .개념:
                    let filteredConcepts: [ConceptItem] = state.filteredConceptItems
                    guard let selectedConcept: ConceptItem =  filteredConcepts[safe: index] else { return .none }
                    return .run { send in
                        try await MainActor.run {

                            if let selectedConcept: ConceptItem = filteredConcepts[safe: index] {
                                selectedConcept.views += 1
                                modelContext.insert(selectedConcept)
                                try modelContext.save()
                            }
                        }
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
