//
//  NaviBar.swift
//  UIComponents
//
//  Created by 정진균 on 2/22/25.
//

import SwiftUI

public enum NaviBarType {
    case main    // (타이틀만, 왼쪽 정렬)
    case quiz    // (백버튼 + 타이틀 + 닫기 버튼)
    case quizPlay// (백버튼 + 타이틀 + 닫기 버튼)
    case search  // (검색 필드 + 닫기 버튼)
    case study   // (타이틀, 검색버튼)
}

public struct NaviBar: View {
    public let type: NaviBarType
    public let title: String
    public var leading1: (() -> Void)? = nil
    public var leading2: (() -> Void)? = nil
    public var trailing1: (() -> Void)? = nil
    public var trailing2: (() -> Void)? = nil

    @Environment(\.presentationMode) var presentationMode

    public init(
        type: NaviBarType,
        title: String,
        leading1: (() -> Void)? = nil,
        leading2: (() -> Void)? = nil,
        trailing1: (() -> Void)? = nil,
        trailing2: (() -> Void)? = nil
    ) {
        self.type = type
        self.title = title
        self.leading1 = leading1
        self.leading2 = leading2
        self.trailing1 = trailing1
        self.trailing2 = trailing2
    }

    public var body: some View {
        HStack {
            navBarContent
        }
        .padding()
    }

    @ViewBuilder
    private var navBarContent: some View {
        switch type {
        case .main:
            // ✅ 메인: 타이틀만 왼쪽 정렬
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.Grayscale._900)
                .frame(maxWidth: .infinity, alignment: .leading)

        case .quiz, .quizPlay:
            // ✅ 퀴즈: (백버튼) (타이틀) (닫기 버튼)
            if let leading1 = leading1 {
                Button(action: leading1) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.Grayscale._900)
                }
            }

            Spacer()

            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.Grayscale._900)

            Spacer()

            if let trailing1 = trailing1 {
                Button(action: trailing1) {
                    Image(systemName: "xmark")
                        .foregroundColor(.Grayscale._900)
                }
            }

        case .search:
            // ✅ 검색: (돋보기 아이콘) (텍스트 필드) (닫기 버튼)
            if let leading1 = leading1 {
                Button(action: leading1) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.Grayscale._900)
                }
            }

            TextField("검색어 입력", text: .constant(""))
                .textFieldStyle(RoundedBorderTextFieldStyle())

            if let trailing1 = trailing1 {
                Button(action: trailing1) {
                    Image(systemName: "xmark")
                        .foregroundColor(.Grayscale._900)
                }
            }

        case .study:
            Text(title)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.Grayscale._800)
                .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()

            if let trailing1 {
                Button(action: trailing1) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.Grayscale._900)
                        .scaledToFit()
                        .frame(width: 28, height: 28)
                }
            }
        }
    }
}
