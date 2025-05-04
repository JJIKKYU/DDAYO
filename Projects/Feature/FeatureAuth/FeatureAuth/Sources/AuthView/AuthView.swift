//
//  AuthView.swift
//  FeatureAuth
//
//  Created by 정진균 on 5/4/25.
//

import SwiftUI
import ComposableArchitecture
import _AuthenticationServices_SwiftUI

public struct AuthView: View {
    public let store: StoreOf<AuthFeatureReducer>

    public init(store: StoreOf<AuthFeatureReducer>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            VStack {
                Image(.authViewTitle)
                    .padding(.top, 100)

                Spacer()

                SignInWithAppleButton(
                    onRequest: { request in
                        request.requestedScopes = [.fullName, .email]
                    },
                    onCompletion: { result in
                        print("AuthView :: result = \(result)")
                        switch result {
                        case .success(let auth):
                            viewStore.send(.appleSignInCompleted(auth))

                        case .failure(let error):
                            print("AuthView :: error = \(error)")
                        }
                    }
                )
                .signInWithAppleButtonStyle(.black)
                .frame(height: 50)
                .padding()

                TermsAgreementText(
                    onTermsTapped: {
                        // ex. Safari 열기 또는 시트로 약관 띄우기
                    },
                    onPrivacyTapped: {
                        // ex. Safari 열기 또는 시트로 처리방침 띄우기
                    }
                )
                .multilineTextAlignment(.center)
                .font(.footnote)
                .padding()
            }
        }
    }
}

#Preview {
    AuthView(store: Store(initialState: AuthFeatureReducer.State()) {
        AuthFeatureReducer()
    })
}
