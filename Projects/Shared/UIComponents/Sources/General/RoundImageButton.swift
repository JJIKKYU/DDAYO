//
//  RoundImageButton.swift
//  UIComponents
//
//  Created by 정진균 on 3/8/25.
//

import SwiftUI

public struct RoundImageButton: View {
    public let image: ImageResource
    public let onTap: () -> Void

    public init(image: ImageResource, onTap: @escaping () -> Void) {
        self.image = image
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
                .foregroundStyle(.gray)
        }
        .frame(width: 52, height: 52, alignment: .center)
        .background(Color.white)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray, lineWidth: 1)
        )

    }
}
