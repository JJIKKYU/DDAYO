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

        case navigateToSearch(FeatureSearchSource)
    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { [modelContext] send in
                    do {
                        let descriptor = FetchDescriptor<ConceptItem>()
                        let items = try modelContext.fetch(descriptor)
                        await send(.loadConcepts(items))
                    } catch {
                        print("⚠️ Failed to fetch ConceptItems: \(error)")
                    }
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

            // index는 변경 필요
            case .selectItem(let index):
                state.detail = FeatureStudyDetailReducer.State(
                    items: state.concepts,
                    index: index
                )
                return .none

            case .presentDetail(.presented(.dismiss)):
                state.detail = nil
                return .none

            case .presentDetail(let action):
                return .none

            case .dismiss:
                print("FeatureStudyMainReducer :: dismiss")
                return .none

            case let .loadConcepts(items):
                state.concepts = items
                return .none

            case .navigateToSearch:
                return .none
            }
        }
        .ifLet(\.$detail, action: \.presentDetail) {
            FeatureStudyDetailReducer()
        }
    }
}
