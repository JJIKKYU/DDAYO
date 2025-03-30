//
//  BookmarkFilterChipView.swift
//  UIComponents
//
//  Created by 정진균 on 3/29/25.
//

import SwiftUI

public struct BookmarkFilterChipView: View {
    public let text: String
    public let isSelected: Bool
    public let onTap: () -> Void

    public init(text: String, isSelected: Bool, onTap: @escaping () -> Void) {
        self.text = text
        self.isSelected = isSelected
        self.onTap = onTap
    }

    public var body: some View {
        Button(action: onTap) {
            Text(text)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(isSelected ? Color.Green._600 : Color.Grayscale._600)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    Group {
                        if isSelected {
                            Color.Green._50
                        } else {
                            Color.white
                        }
                    }
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isSelected ? Color.Green._600 : Color.Grayscale._200, lineWidth: 1)
                )
                .cornerRadius(20)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    BookmarkFilterChipView(text: "타이틀", isSelected: true, onTap: { print("!!") })
}
