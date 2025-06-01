//
//  DataVersionService.swift
//  Service
//
//  Created by 정진균 on 5/31/25.
//

import Model
import Foundation

// MARK: - DataVersionServiceProtocol

public protocol DataVersionServiceProtocol {
    func fetchRemoteVersionInfo() async throws -> VersionsResponse
}
