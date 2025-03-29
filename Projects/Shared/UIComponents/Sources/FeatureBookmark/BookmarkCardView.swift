//
//  BookmarkCardView.swift
//  UIComponents
//
//  Created by 정진균 on 3/29/25.
//

import SwiftUI

public struct BookmarkCardView: View {
    public let category: String
    public let title: String
    public let views: String
    public let tags: [String]
    public let isBookmarked: Bool

    public init(category: String, title: String, views: String, tags: [String], isBookmarked: Bool) {
        self.category = category
        self.title = title
        self.views = views
        self.tags = tags
        self.isBookmarked = isBookmarked
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 상단 카테고리
            HStack(alignment: .center) {
                Text(category)
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(.Grayscale._500)
                    .padding(.bottom, 6)

                Spacer()

                AIBadgeView()
            }

            // 문제 제목
            Text(title)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.Grayscale._900)
                .lineSpacing(4)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .padding(.bottom, 8)

            // 하단 뱃지 영역
            HStack(spacing: 8) {
                HStack(spacing: 4) {
                    Image(.eye)
                        .resizable()
                        .renderingMode(.template)
                        .foregroundStyle(Color.Grayscale._300)
                        .frame(width: 16, height: 16)
                        .scaledToFit()

                    Text(views)
                        .font(.system(size: 11, weight: .regular))
                        .foregroundStyle(Color.Grayscale._400)
                }
                .foregroundColor(.Grayscale._400)

                ForEach(tags, id: \.self) { tag in
                    TagBadgeView(text: tag)
                }

                Spacer()

                Image(isBookmarked ? .bookmark : .bookmarkFilled)
                    .resizable()
                    .frame(width: 24, height: 24)
                    .scaledToFit()
                    .foregroundColor(.Grayscale._300)
            }
        }
        .padding(.init(top: 16, leading: 20, bottom: 16, trailing: 20))
        .background(Color.Grayscale.white)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.Grayscale._100)
        )
    }
}

struct TagBadgeView: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.system(size: 11, weight: .medium))
            .padding(.horizontal, 6)
            .padding(.vertical, 4)
            .background(tagColor(for: text))
            .foregroundColor(.white)
            .cornerRadius(4)
    }

    private func tagColor(for text: String) -> Color {
        switch text {
        case "필기시험":
            return .Grayscale._300

        case "틀린 문제":
            return .Red._400

        default:
            return .Blue._300
        }
    }
}

struct AIBadgeView: View {
    var body: some View {
        HStack(alignment: .center, spacing: 3) {
            Image(.AI)
                .resizable()
                .renderingMode(.template)
                .foregroundStyle(Color.Blue._600)
                .frame(width: 12, height: 12)

            Text("AI 예상")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(Color.Blue._600)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 4)
        .background(Color.Blue._50)
        .cornerRadius(4)
    }
}

#Preview {
    BookmarkCardView(
        category: "소프트웨어 개발 보안 구축",
        title: "UML에서 활용되는 다이어그램 중, 시스템의 동작을 표현하는 행위(Bohavlral) 다이어그램에 해당하지 않는 것은?",
        views: "99999+",
        tags: ["필기시험", "틀린 문제"],
        isBookmarked: true
    )
    .padding()
    .background(Color.Grayscale._50)
}
