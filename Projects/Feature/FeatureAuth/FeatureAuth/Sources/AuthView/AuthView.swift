//
//  AuthView.swift
//  FeatureAuth
//
//  Created by 정진균 on 5/4/25.
//

import SwiftUI
import ComposableArchitecture
import _AuthenticationServices_SwiftUI
import DI

public struct AuthView: View {
    @Environment(\.openURL) private var openURL
    @Dependency(\.appConfig) private var appConfig

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

                /*
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
                */

                Button(action: {
                    viewStore.send(.navigateToAuthAgreementView(userName: ""))
                }) {
                    Text("시작하기")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color.Grayscale.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16.5)
                        .background(Color.Green._500)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 20)

                TermsAgreementText(
                    onTermsTapped: {
                        if let url = appConfig.termsOfService {
                            openURL(url)
                        }
                    },
                    onPrivacyTapped: {
                        if let url = appConfig.privacyPolicy {
                            openURL(url)
                        }
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
