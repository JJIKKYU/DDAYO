//
//  BottomSheetView.swift
//  UIComponents
//
//  Created by 정진균 on 3/1/25.
//

import SwiftUI

public struct BottomSheetView: View {
    public let closeAction: () -> Void  // 닫기 액션만 전달

    public init(closeAction: @escaping () -> Void) {
        self.closeAction = closeAction
    }

    public var body: some View {
        VStack(spacing: 20) {
            Text("정렬")
                .font(.headline)

            Button("A-Z순") { closeAction() }
            Button("Z-A순") { closeAction() }
            Button("적게 읽은 순") { closeAction() }
            Button("많이 읽은 순") { closeAction() }

            Button(action: closeAction) {
                Text("닫기")
                    .font(.headline)
                    .foregroundColor(.white)
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
