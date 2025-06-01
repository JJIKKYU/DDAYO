//
//  BasePopupView.swift
//  UIComponents
//
//  Created by 정진균 on 4/26/25.
//

import SwiftUI

public struct BasePopupView: View {
    @Binding public var isVisible: Bool
    public let title: String
    public let desc: String
    public let leadingTitle: String
    public let trailingTitle: String
    public let allDone: Bool
    public let onLeadingAction: () -> Void
    public let onTrailingAction: () -> Void

    public init(
        isVisible: Binding<Bool>,
        title: String,
        desc: String,
        leadingTitle: String,
        trailingTitle: String,
        allDone: Bool,
        onLeadingAction: @escaping () -> Void,
        onTrailingAction: @escaping () -> Void
    ) {
        self._isVisible = isVisible
        self.title = title
        self.desc = desc
        self.leadingTitle = leadingTitle
        self.trailingTitle = trailingTitle
        self.allDone = allDone
        self.onLeadingAction = onLeadingAction
        self.onTrailingAction = onTrailingAction
    }

    public var body: some View {
        ZStack {
            if isVisible {
                Color.Grayscale.black.opacity(0.6)
                    .edgesIgnoringSafeArea(.all)

                VStack(alignment: .leading, spacing: 0) {
                    VStack(alignment: .leading) {
                        HStack {
                            Text(title)
                                .font(.system(size: 18, weight: .bold))
                                .foregroundStyle(Color.Grayscale._900)
                            Spacer()
                        }
                        .padding(.bottom, 6)

                        Text(desc)
                            .lineSpacing(4.0)
                            .font(.system(size: 15, weight: .regular))
                            .foregroundStyle(Color.Grayscale._800)
                            .multilineTextAlignment(.leading)
                    }
                    .padding(8)

                    HStack(spacing: 12) {
                        Button(action: onLeadingAction) {
                            Text(leadingTitle)
                                .font(.system(size: 16, weight: .semibold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14.5)
                                .background(Color.Grayscale._100)
                                .foregroundColor(Color.Grayscale._900)
                                .cornerRadius(12)
                        }

                        Button(action: onTrailingAction) {
                            Text(trailingTitle)
                                .font(.system(size: 16, weight: .semibold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14.5)
                                .background(allDone ? Color.Green._500 : Color.Red._500)
                                .foregroundColor(Color.Grayscale.white)
                                .cornerRadius(12)
                        }
                    }
                    .padding(.top, 12)
                    .frame(maxWidth: .infinity)
                }
                .padding(20)
                .frame(maxWidth: UIScreen.main.bounds.width - 40)
                .background(Color.Grayscale.white)
                .cornerRadius(24)
            }
        }
        .animation(.easeInOut, value: isVisible)
    }
}
