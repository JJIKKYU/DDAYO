//
//  BottomSheetView.swift
//  UIComponents
//
//  Created by 정진균 on 3/1/25.
//

import SwiftUI
import Model

public struct BottomSheetView: View {
    public let closeAction: () -> Void  // 닫기 액션만 전달

    public init(closeAction: @escaping () -> Void) {
        self.closeAction = closeAction
    }

    public var body: some View {
        VStack(spacing: 20) {
            Text("정렬")
                .font(.headline)


            ForEach(SortOption.allCases, id: \.self) { sortOption in
                Button(action: {
                    closeAction()
                }) {
                    Text(sortOption.displayName)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color.Grayscale._900)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 10)
                }
            }

            Button(action: closeAction) {
                Text("닫기")
                    .font(.headline)
                    .foregroundColor(Color.Grayscale.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.gray)
                    .cornerRadius(8)
            }
            .padding(.top, 10)
        }
        .padding()
    }
}
