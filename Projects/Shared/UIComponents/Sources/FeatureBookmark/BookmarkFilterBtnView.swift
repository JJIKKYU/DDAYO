//
//  BookmarkFilterBtnView.swift
//  UIComponents
//
//  Created by 정진균 on 3/29/25.
//

import SwiftUI

public struct BookmarkFilterBtnView: View {
    public let title: String
    public let onTap: () -> Void

    public init(title: String, onTap: @escaping () -> Void) {
        self.title = title
        self.onTap = onTap
    }

    public var body: some View {
        Button {
            onTap()
        } label: {
            HStack(alignment: .center, spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color.Grayscale._900)

                Image(.directionDown)
                    .renderingMode(.template)
                    .foregroundStyle(Color.Grayscale._900)
                    .frame(width: 16, height: 16)
            }
            .padding(.init(top: 7, leading: 12, bottom: 7, trailing: 10))
            .background(Color.Grayscale.white) // ✅ 배경
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.Grayscale._200, lineWidth: 1)
            )
            .cornerRadius(16)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    BookmarkFilterBtnView(title: "모든 시험", onTap: { print("모든 시험")})
}
