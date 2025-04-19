//
//  RecentSearchCellView.swift
//  UIComponents
//
//  Created by 정진균 on 3/30/25.
//

import SwiftUI

public struct RecentSearchCellView: View {
    public let keyword: String
    public let searchedAt: Date
    public let onClose: (() -> Void)

    public init(
        keyword: String,
        searchedAt: Date,
        onClose: @escaping () -> Void
    ) {
        self.keyword = keyword
        self.searchedAt = searchedAt
        self.onClose = onClose
    }

    public var body: some View {
        HStack {
            Image(.clock)
                .resizable()
                .renderingMode(.template)
                .foregroundColor(Color.Grayscale._400)
                .frame(width: 16, height: 16)

            Text(keyword)
                .foregroundColor(Color.Grayscale._900)
                .font(.system(size: 16, weight: .medium))

            Spacer()

            HStack(alignment: .center, spacing: 6) {
                Text(searchedAt.description)
                    .lineLimit(1)
                    .multilineTextAlignment(.trailing)
                    .font(.system(size: 11))
                    .foregroundColor(Color.Grayscale._500)

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
    }
}
