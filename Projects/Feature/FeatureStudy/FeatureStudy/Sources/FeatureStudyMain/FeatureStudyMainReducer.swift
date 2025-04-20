//
//  FeatureStudyMainReducer.swift
//  FeatureStudy
//
//  Created by 정진균 on 3/1/25.
//

import ComposableArchitecture
import DI
import Foundation
import Model
import Service
import SwiftData

@Reducer
public struct FeatureStudyMainReducer {
    @Dependency(\.modelContext) var modelContext

    public init() {}

    @ObservableState
    public struct State: Equatable, Hashable {
        var allConcepts: [ConceptItem] = []
        var conceptFeedItems: [BookmarkFeedItem] = []
        var isSheetPresented: Bool = false
        var selectedSortOption: SortOption? = .default
        // bottomSheet에서 선택한 값을 임시로 저장하고
        // bottomSheet이 없어질때 반영하기 위해서 임시 저장
        var tempSortOption: SortOption? = .default
        var recentFeedItem: BookmarkFeedItem? = nil

        public init() {

        }
    }

    public enum Action {
        case onAppear
        case showSheet(Bool)

        case selectSortOption(SortOption?)
        case selectItem(Int)
        case selectRecentItem

        case dismiss
        case test
        case loadConcepts([ConceptItem])
        case setRecentItem(ConceptItem)

        // navigate
        case navigateToSearch(FeatureSearchSource)
        case navigateToStudyDetail(items: [ConceptItem], index: Int)

        // bookmark
        case toggleBookmark(index: Int)
        case updateBookmarkStatus(index: Int, isBookmarked: Bool)
    }

    public var body: some ReducerOf<Self> {
        Reduce {
            state,
            action in
            switch action {
            case .onAppear:
                let selectedSortOption: SortOption = state.selectedSortOption ?? .default
                return .run { send in
                    try await MainActor.run {
                        let descriptor = FetchDescriptor<ConceptItem>()
                        let items: [ConceptItem] = try modelContext.fetch(descriptor)

                        let sorted: [ConceptItem]
                        switch selectedSortOption {
                        case .default:
                            sorted = items.sortedByDefault()

                        case .leastViewed:
                            sorted = items.sortedByViews(ascending: true)

                        case .mostViewed:
                            sorted = items.sortedByViews(ascending: false)

                        case .az:
                            sorted = items.sortedByTitle(ascending: true)

                        case .za:
                            sorted = items.sortedByTitle(ascending: false)
                        }

                        let recentDescriptor: FetchDescriptor<RecentConceptItem> = .init()
                        let recentItems: [RecentConceptItem] = try modelContext.fetch(recentDescriptor)

                        if let recentId = recentItems.first?.conceptId,
                           let recentConcept: ConceptItem = sorted.first(where: { $0.id == recentId }) {
                            send(.setRecentItem(recentConcept))
                        }

                        send(.loadConcepts(sorted))
                    }
                }

            case .test:
                return .none

            case .showSheet(let isPresented):
                state.isSheetPresented = isPresented

                // bottomSheet가 닫히는 시점에만 반영
                if !isPresented,
                   let tempOption = state.tempSortOption {
                    switch tempOption {
                    case .default:
                        state.conceptFeedItems.sort {
                            guard let lhs = $0.originConceptItem,
                                  let rhs = $1.originConceptItem else {
                                return false
                            }

                            if lhs.subjectId == rhs.subjectId {
                                return lhs.id.uuidString < rhs.id.uuidString
                            } else {
                                return lhs.subjectId < rhs.subjectId
                            }
                        }

                    case .leastViewed:
                        state.conceptFeedItems.sort { $0.views < $1.views }

                    case .mostViewed:
                        state.conceptFeedItems.sort { $0.views > $1.views }

                    case .az:
                        state.conceptFeedItems.sort { $0.title < $1.title }

                    case .za:
                        state.conceptFeedItems.sort { $0.title > $1.title }
                    }

                    state.selectedSortOption = tempOption
                    state.tempSortOption = nil
                }
                return .none

            case let .selectSortOption(option):
                state.tempSortOption = option
                return .send(.showSheet(false))

            case .selectItem(let index):
                guard state.conceptFeedItems.indices.contains(index) else { return .none }

                var items = state.conceptFeedItems
                var selected = items[index]

                // views 업데이트
                let origin = selected.originConceptItem
                origin?.views += 1
                selected = BookmarkFeedItem(
                    category: selected.category,
                    title: selected.title,
                    views: "\(origin?.views ?? 0)",
                    tags: selected.tags,
                    isBookmarked: selected.isBookmarked,
                    originConceptItem: origin
                )
                items[index] = selected
                state.conceptFeedItems = items

                return .run { [items] send in
                    try await MainActor.run {
                        guard let origin else { return }
                        modelContext.insert(origin)
                        try modelContext.save()
                    }

                    await send(.navigateToStudyDetail(items: items.compactMap { $0.originConceptItem }, index: index))
                }

            case .selectRecentItem:
                // 현재까지 본 아이템이 있을 경우에만
                guard let recentItemId: UUID = state.recentFeedItem?.originConceptItem?.id else {
                    return .none
                }
                // 현재까지본 아이템의 id와 전체 리스트 id를 비교해서 index를 찾는다.
                guard let index: Int = state.conceptFeedItems
                    .firstIndex(where: { $0.originConceptItem?.id == recentItemId })
                else { return .none }

                let originItems: [ConceptItem] = state.conceptFeedItems.compactMap ({ $0.originConceptItem })

                return .run { send in
                    await send(.navigateToStudyDetail(items: originItems, index: index))
                }

            case .dismiss:
                print("FeatureStudyMainReducer :: dismiss")
                return .send(.showSheet(false))

            case let .loadConcepts(items):
                state.allConcepts = items
                let bookmarkedIDs = try? modelContext.fetch(FetchDescriptor<BookmarkItem>()).map(\.questionID)
                let bookmarkedSet = Set(bookmarkedIDs ?? [])
                state.conceptFeedItems = items.map {
                    BookmarkFeedItem(
                        category: $0.subject,
                        title: $0.title,
                        views: "\($0.views)",
                        tags: [],
                        isBookmarked: bookmarkedSet.contains($0.id),
                        originConceptItem: $0
                    )
                }
                return .none

            case let .setRecentItem(item):
                let bookmarkedIDs = try? modelContext.fetch(FetchDescriptor<BookmarkItem>()).map(\.questionID)
                let bookmarkedSet = Set(bookmarkedIDs ?? [])

                let feedItem = BookmarkFeedItem(
                    category: item.subject,
                    title: item.title,
                    views: "\(item.views)",
                    tags: [],
                    isBookmarked: bookmarkedSet.contains(item.id),
                    originConceptItem: item
                    )
                state.recentFeedItem = feedItem
                return .none

            case let .toggleBookmark(index):
                guard state.conceptFeedItems.indices.contains(index) else { return .none }
                let item: BookmarkFeedItem = state.conceptFeedItems[index]
                guard let conceptId = item.originConceptItem?.id else {
                    return .none
                }

                print("FeatureStudyMainReducer :: toggleBookmark[index]")

                return .run { send in
                    let isBookmarked: Bool = try await MainActor.run {
                        let predicate = #Predicate<BookmarkItem> {
                            $0.questionID == conceptId
                        }

                        if let existing = try modelContext.fetch(FetchDescriptor<BookmarkItem>(predicate: predicate)).first {
                            modelContext.delete(existing)
                            try modelContext.save()
                            return false
                        } else {
                            let newBookmark: BookmarkItem = .init(
                                questionID: conceptId,
                                type: .개념,
                                reason: .manual
                            )
                            modelContext.insert(newBookmark)
                            try modelContext.save()
                            return true
                        }
                    }

                    await send(.updateBookmarkStatus(index: index, isBookmarked: isBookmarked))
                }

            case .updateBookmarkStatus(let index, let isBookmarked):
                print("FeatureStudyMainReducer :: updateBookmarkStatus, index = \(index), isBookmarked = \(isBookmarked)")
                guard state.conceptFeedItems.indices.contains(index) else { return .none }

                var item = state.conceptFeedItems[index]
                item = BookmarkFeedItem(
                    category: item.category,
                    title: item.title,
                    views: item.views,
                    tags: item.tags,
                    isBookmarked: isBookmarked,
                    originConceptItem: item.originConceptItem
                )

                state.conceptFeedItems[index] = item

                // 공부중인 아이템과 동일한 UUID면 같이 반영
                if let recentId = state.recentFeedItem?.originConceptItem?.id,
                   recentId == item.originConceptItem?.id {
                    state.recentFeedItem = item
                }

                return .none

            case .navigateToSearch,
                    .navigateToStudyDetail:
                return .none
            }
        }
    }
}
