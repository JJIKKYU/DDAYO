//
//  Tabs.swift
//  FeatureQuiz
//
//  Created by JJIKKYU on 2/7/25.
//

import SwiftUI
import ComposableArchitecture

struct Tab2 {
    var tab: QuizTab
    var title: String
}

struct Tabs: View {
    var tabs: [Tab2]
    let animationNamespace: Namespace.ID

    @Binding var selectedTab: QuizTab
    @State private var tabWidths: [CGFloat] = []

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 10) {
                ForEach(0 ..< tabs.count, id: \.self) { row in
                    Button {
                        selectedTab = tabs[row].tab
                    } label: {
                        Text(tabs[row].title)
                            .font(Font.system(size: 18, weight: .semibold))
                            .foregroundColor(Color.green)
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
                    if let selectedIndex = tabs.firstIndex(where: { $0.tab == selectedTab }), tabWidths.indices.contains(selectedIndex) {
                        Rectangle()
                            .fill(Color.green)
                            .frame(width: tabWidths[selectedIndex], height: 3) // ✅ 선택된 탭의 width 적용
                            .offset(x: tabWidths.prefix(selectedIndex).reduce(0, +) + CGFloat(selectedIndex) * 10, y: 25) // ✅ 선택된 탭 위치로 이동
                            .matchedGeometryEffect(id: "underline", in: animationNamespace)
                    }
                },
                alignment: .bottomLeading
            )
        }
        .animation(.easeInOut, value: selectedTab)
    }
}

struct Tabs_Previews: PreviewProvider {
    @Namespace private static var animationNamespace // matchedGeometryEffect 사용

    static var previews: some View {
        Tabs(tabs: [.init(tab: .필기, title: "필기"),
                    .init(tab: .실기, title: "실기")],
             animationNamespace: animationNamespace,
             selectedTab: .constant(.필기))
    }
}
