//
//  RecentSearchCellView.swift
//  UIComponents
//
//  Created by 정진균 on 3/30/25.
//

import Model
import SwiftUI

public struct RecentSearchCellView: View {
    public let keyword: String
    public let searchedAt: Date
    public let onClose: (() -> Void)
    public let onSelect: (() -> Void)

    public init(
        keyword: String,
        searchedAt: Date,
        onClose: @escaping () -> Void,
        onSelect: @escaping () -> Void
    ) {
        self.keyword = keyword
        self.searchedAt = searchedAt
        self.onClose = onClose
        self.onSelect = onSelect
    }

    public var body: some View {
        Button {
            onSelect()
        } label: {
            HStack {
                Image(.clock)
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(Color.Grayscale._400)
                    .frame(width: 16, height: 16)

                Text(keyword)
                    .foregroundColor(Color.Grayscale._900)
                    .font(.system(size: 16, weight: .medium))
                    .lineSpacing(5.0)

                Spacer()

                HStack(alignment: .center, spacing: 6) {
                    Text(searchedAt.relativeDescription)
                        .lineLimit(1)
                        .multilineTextAlignment(.trailing)
                        .font(.system(size: 11))
                        .foregroundColor(Color.Grayscale._500)
                        .lineSpacing(5.0)

                    Button {
                        onClose()
                    } label: {
                        Image(.close)
                            .resizable()
                            .renderingMode(.template)
                            .foregroundColor(Color.Grayscale._400)
                            .frame(width: 16, height: 16)
                    }
                }
            }
            .contentShape(Rectangle())
        }
    }
}
