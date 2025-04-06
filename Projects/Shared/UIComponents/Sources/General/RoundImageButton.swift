//
//  RoundImageButton.swift
//  UIComponents
//
//  Created by 정진균 on 3/8/25.
//

import SwiftUI

public struct RoundImageButton: View {
    public let image: ImageResource
    @Binding public var isBookmarked: Bool
    public let onTap: () -> Void

    public init(image: ImageResource, isBookmarked: Binding<Bool>, onTap: @escaping () -> Void) {
        self.image = image
        self._isBookmarked = isBookmarked
        self.onTap = onTap
    }

    public var body: some View {
        Button {
            onTap()
        } label: {
            Image(image)
                .resizable()
                .renderingMode(.template)
                .frame(width: 24, height: 24)
                .foregroundStyle(isBookmarked ? Color.Grayscale._900 : Color.Grayscale._500)
        }
        .frame(width: 52, height: 52, alignment: .center)
        .background(Color.Grayscale.white)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray, lineWidth: 1)
        )

    }
}
