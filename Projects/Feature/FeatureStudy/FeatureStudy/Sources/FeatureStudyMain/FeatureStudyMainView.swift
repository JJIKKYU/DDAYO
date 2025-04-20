//
//  FeatureStudyMainView.swift
//  FeatureStudy
//
//  Created by 정진균 on 3/1/25.
//

import ComposableArchitecture
import SwiftUI
import UIComponents
import Model

public struct FeatureStudyMainView: View {
    public let store: StoreOf<FeatureStudyMainReducer>

    public init(store: StoreOf<FeatureStudyMainReducer>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store, observe:  { $0 }) { viewStore in
            VStack(spacing: 0) {
                NaviBar(type: .study, title: "개념학습", trailing1: {
                    store.send(.navigateToSearch(.study))
                })

                ScrollView {
                    if let recentFeedItem: BookmarkFeedItem = viewStore.recentFeedItem,
                       let originConceptItem: ConceptItem = recentFeedItem.originConceptItem {
                        HStack {
                            Text("최근 본")
                                .foregroundStyle(Color.Grayscale._800)
                                .font(.system(size: 20, weight: .bold))
                                .padding(.horizontal, 20)

                            Spacer()
                        }
                        .padding(.top, 20)
                        .padding(.bottom, 0)

                        ConceptListCell(
                            concept: originConceptItem,
                            type: .continueLearning,
                            isBookmarked: viewStore.binding(
                                get: { _ in recentFeedItem.isBookmarked },
                                send: FeatureStudyMainReducer.Action.toggleBookmark(index: viewStore.conceptFeedItems.firstIndex(where: { $0.originConceptItem?.id == recentFeedItem.originConceptItem?.id }) ?? 0)
                            ),
                            onTap: {
                                viewStore.send(.selectRecentItem)
                        })
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                        .padding(.top, 12)
                    }

                    HStack {
                        Text("모든 개념")
                            .foregroundStyle(Color.Grayscale._800)
                            .font(.system(size: 20, weight: .bold))
                            .padding(.horizontal, 20)

                        Spacer()
                    }
                    .padding(.all, 0)
                    .padding(.top, 15)
                    .padding(.bottom, 16)

                    HStack {
                        SortingBtnView(title: viewStore.selectedSortOption?.displayName ?? SortOption.default.displayName, onTap: {
                            viewStore.send(.showSheet(true))
                        })
                        .sheet(
                            isPresented: viewStore.binding(
                                get: \.isSheetPresented,
                                send: FeatureStudyMainReducer.Action.showSheet
                            )
                        ) {
                            SortBottomSheetView(
                                selectedOption: viewStore.selectedSortOption,
                                onSelect: { viewStore.send(.selectSortOption($0)) },
                                onClose: { viewStore.send(.dismiss) }
                            )
                            .presentationDetents(
                                [.height(360)]
                            )
                        }

                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 8)

                    LazyVStack(spacing: 8) {
                        ForEach(Array(zip(viewStore.conceptFeedItems.indices, viewStore.conceptFeedItems)), id: \.1.id) { index, data in
                            ConceptListCell(
                                concept: data.originConceptItem!,
                                type: .regular,
                                isBookmarked: viewStore.binding(
                                    get: { _ in data.isBookmarked},
                                    send: FeatureStudyMainReducer.Action.toggleBookmark(index: index)
                                ),
                                onTap: {
                                    viewStore.send(.selectItem(index))
                                }
                            )
                            .padding(.horizontal, 20)
                        }
                    }
                }
            }
            .task {
                viewStore.send(.onAppear)
            }
        }
        .background(Color.Background._2)
    }
}

struct FeatureStudyMainView_Previews: PreviewProvider {
    static var previews: some View {
        FeatureStudyMainView(
            store: Store(
                initialState: FeatureStudyMainReducer.State(),
                reducer: { FeatureStudyMainReducer() }
            )
        )
        .previewLayout(.sizeThatFits)
    }
}
