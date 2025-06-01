//
//  Dependency+AppConfig.swift
//  DI
//
//  Created by 정진균 on 5/24/25.
//

import ComposableArchitecture
import Foundation

// MARK: - AppConfig

public struct AppConfig {
    // 개인정보 처리방침
    public let privacyPolicy: URL?

    // 서비스 이용약관
    public let termsOfService: URL?

    // 개인정보 수집 및 이용 동의서
    public let privacyConsent: URL?

    // 문제 출처
    public let attribution: URL?
}

// MARK: - DependencyValues

public extension DependencyValues {
    var appConfig: AppConfig {
        get { self[AppConfigKey.self] }
        set { self[AppConfigKey.self] = newValue }
    }
}

private enum AppConfigKey: DependencyKey {
    static let liveValue = AppConfig(
        privacyPolicy: URL(string: "https://www.notion.so/DDAYO-1d378869e5198090ace7d3bafbf707e8?pvs=4"),
        termsOfService: URL(string: "https://www.notion.so/DDAYO-1d378869e519802b941ce0c611ec0a95?pvs=4"),
        privacyConsent: URL(string: "https://www.notion.so/DDAYO-1d378869e51980309879f85a564e54ed?pvs=4"),
        attribution: URL(string: "https://www.notion.so/DDAYO-1e278869e51980ecbaf4f1220e265266?pvs=4")
    )
}
