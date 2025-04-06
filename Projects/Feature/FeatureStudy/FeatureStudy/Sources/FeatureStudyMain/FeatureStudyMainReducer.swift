//
//  FeatureStudyMainReducer.swift
//  FeatureStudy
//
//  Created by 정진균 on 3/1/25.
//

import ComposableArchitecture
import Model
import SwiftData
import DI
import Service

@Reducer
public struct FeatureStudyMainReducer {
    @Dependency(\.modelContext) var modelContext

    public init() {}

    @ObservableState
    public struct State: Equatable, Hashable {
        var allConcepts: [ConceptItem] = []
        var conceptFeedItems: [BookmarkFeedItem] = []
        var isSheetPresented: Bool = false
        var selectedSortOption: SortOption? = .az
        // bottomSheet에서 선택한 값을 임시로 저장하고
        // bottomSheet이 없어질때 반영하기 위해서 임시 저장
        var tempSortOption: SortOption? = .az
        var recentFeedItem: BookmarkFeedItem? = nil

        public init() {

        }
    }

    public enum Action {
        case onAppear
        case showSheet(Bool)

        case selectSortOption(SortOption?)
        case selectItem(Int)

        case dismiss
        case test
        case loadConcepts([ConceptItem])
        case setRecentItem(ConceptItem)

        // navigate
        case navigateToSearch(FeatureSearchSource)
        case navigateToStudyDetail(items: [ConceptItem], index: Int)
    }

    public var body: some ReducerOf<Self> {
        Reduce {
            state,
            action in
            switch action {
            case .onAppear:
                return .run { [modelContext] send in
                    await Task { @MainActor in
                        do {
                            let descriptor = FetchDescriptor<ConceptItem>()
                            let items: [ConceptItem] = try modelContext.fetch(descriptor)
                                .sorted { $0.title < $1.title }
                            
                            // Load recent item
                            let recentDescriptor = FetchDescriptor<RecentConceptItem>()
                            let recentItems = try modelContext.fetch(recentDescriptor)
                            
                            
                            if let recentId = recentItems.first?.conceptId,
                               let recentConcept: ConceptItem = items
                                .filter({ $0.id == recentId })
                                .first {
                                send(.setRecentItem(recentConcept))
                            }
                            
                            send(.loadConcepts(items))
                        } catch {
                            print("⚠️ ConceptItems 또는 RecentConceptItem을 불러오는데 실패: \(error)")
                        }
                    }.value
                }
                
            case .test:
                return .none
                
            case .showSheet(let isPresented):
                state.isSheetPresented = isPresented
                
                // bottomSheet가 닫히는 시점에만 반영
                if !isPresented,
                   let tempOption = state.tempSortOption {
                    switch tempOption {
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
                return .run { send in
                    await send(.showSheet(false))
                }
                
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
                
                return .run { [modelContext] send in
                    guard let origin else { return }
                    modelContext.insert(origin)
                    try? modelContext.save()
                    await send(.navigateToStudyDetail(items: items.compactMap { $0.originConceptItem }, index: index))
                }
                
            case .dismiss:
                print("FeatureStudyMainReducer :: dismiss")
                return .none
                
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
                
            case .navigateToSearch,
                    .navigateToStudyDetail:
                return .none
            }
        }
    }
}
