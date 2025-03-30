//
//  BookmarkFilterSheetView.swift
//  UIComponents
//
//  Created by 정진균 on 3/29/25.
//

import SwiftUI
import ComposableArchitecture

struct BookmarkFilterSheetView: View {
    let store: StoreOf<QuestionFilterReducer>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack {
                QuestionFilterView(store: store)
            }
            .presentationDetents([.height(340)])
            .padding()
        }
    }
}
