//
//  BookmarkTabs.swift
//  FeatureBookmark
//
//  Created by 정진균 on 3/29/25.
//

import SwiftUI
import ComposableArchitecture
import UIComponents
import Model

struct BookmarkTabView: View {
    var tabs: [BookmarkTabType]
    let animationNamespace: Namespace.ID

    @Binding var selectedTab: BookmarkTabType
    @State private var tabWidths: [CGFloat] = []

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 10) {
                ForEach(0 ..< tabs.count, id: \.self) { row in
                    Button {
                        selectedTab = tabs[row]
                    } label: {
                        Text(tabs[row].getName())
                            .font(Font.system(size: 24, weight: .bold))
                            .foregroundColor(selectedTab == tabs[row] ? Color.Green._600 : Color.Grayscale._400)
                            .background(GeometryReader { geo in
                                Color.clear
                                    .onAppear {
                                        if tabWidths.count < tabs.count {
                                            tabWidths.append(geo.size.width)
                                        }
                                    }
                            })
                    }
                    .buttonStyle(PlainButtonStyle())
                }

                Spacer()
            }
            .overlay(
                GeometryReader { geo in
                    if let selectedIndex = tabs.firstIndex(where: { $0 == selectedTab }), tabWidths.indices.contains(selectedIndex) {
                        Rectangle()
                            .fill(Color.Green._600)
                            .frame(width: tabWidths[selectedIndex], height: 3)
                            .offset(x: tabWidths.prefix(selectedIndex).reduce(0, +) + CGFloat(selectedIndex) * 10, y: 37) // ✅ 선택된 탭 위치로 이동
                            .matchedGeometryEffect(id: "underline", in: animationNamespace)
                    }
                },
                alignment: .bottomLeading
            )
        }
        .animation(.easeInOut, value: selectedTab)
    }
}

struct BookmarkTabView_Previews: PreviewProvider {
    @Namespace private static var animationNamespace // matchedGeometryEffect 사용

    static var previews: some View {
        BookmarkTabView(tabs: [.문제, .개념], animationNamespace: animationNamespace, selectedTab: .constant(.문제))
    }
}
