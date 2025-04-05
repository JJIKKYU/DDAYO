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
        var concepts: [ConceptItem] = []
        var isSheetPresented: Bool = false
        var selectedSortOption: SortOption? = .az
        // bottomSheet에서 선택한 값을 임시로 저장하고
        // bottomSheet이 없어질때 반영하기 위해서 임시 저장
        var tempSortOption: SortOption? = .az
        var recentItem: ConceptItem? = nil
        @Presents var detail: FeatureStudyDetailReducer.State?

        public init() {

        }
    }

    public enum Action {
        case onAppear
        case showSheet(Bool)

        case selectSortOption(SortOption?)
        case selectItem(Int)
        case presentDetail(PresentationAction<FeatureStudyDetailReducer.Action>)
        case dismiss
        case test
        case loadConcepts([ConceptItem])
        case setRecentItem(ConceptItem)

        case navigateToSearch(FeatureSearchSource)
        case navigateToStudyDetail(items: [ConceptItem], index: Int)
    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
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
                if !isPresented, let tempOption = state.tempSortOption {
                    switch tempOption {
                    case .leastViewed:
                        state.concepts.sort { $0.views < $1.views }

                    case .mostViewed:
                        state.concepts.sort { $0.views > $1.views }

                    case .az:
                        state.concepts.sort { $0.title < $1.title }

                    case .za:
                        state.concepts.sort { $0.title > $1.title }
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
                var items = state.concepts
                guard items.indices.contains(index) else {
                    return .none
                }

                var selected = items[index]
                selected.views += 1
                items[index] = selected
                state.concepts = items

                return .run { [selected, modelContext] send in
                    modelContext.insert(selected)
                    try? modelContext.save()
                    await send(.navigateToStudyDetail(items: items, index: index))
                }

            case .presentDetail(let action):
                return .none

            case .dismiss:
                print("FeatureStudyMainReducer :: dismiss")
                return .none

            case let .loadConcepts(items):
                state.concepts = items
                return .none

            case let .setRecentItem(item):
                state.recentItem = item
                return .none

            case .navigateToSearch, .navigateToStudyDetail:
                return .none
            }
        }
        .ifLet(\.$detail, action: \.presentDetail) {
            FeatureStudyDetailReducer()
        }
    }
}
