//
//  TermsAgreementText.swift
//  FeatureAuth
//
//  Created by 정진균 on 5/4/25.
//

import SwiftUI
import UIComponents

struct TermsAgreementText: View {
    var onTermsTapped: () -> Void
    var onPrivacyTapped: () -> Void

    var body: some View {
        VStack(spacing: 6) {
            HStack(spacing: 0) {
                Text("계속 진행하면 ")
                    .foregroundStyle(Color.Grayscale._500)
                    .font(.system(size: 12, weight: .regular))

                Text("이용 약관")
                    .foregroundStyle(Color.Grayscale._500)
                    .font(.system(size: 12, weight: .regular))
                    .underline()
                    .onTapGesture {
                        onTermsTapped()
                    }
                Text("에 동의하고")
                    .foregroundStyle(Color.Grayscale._500)
                    .font(.system(size: 12, weight: .regular))
            }
            HStack(spacing: 0) {
                Text("개인정보 처리방침")
                    .foregroundStyle(Color.Grayscale._500)
                    .font(.system(size: 12, weight: .regular))
                    .underline()
                    .onTapGesture {
                        onPrivacyTapped()
                    }

                Text("을 확인했음을 인정하게 됩니다.")
                    .foregroundStyle(Color.Grayscale._500)
                    .font(.system(size: 12, weight: .regular))
            }
        }
    }
}
