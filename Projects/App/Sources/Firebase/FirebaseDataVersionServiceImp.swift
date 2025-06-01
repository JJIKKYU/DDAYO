//
//  FirebaseDataVersionServiceImp.swift
//  DDAYO
//
//  Created by 정진균 on 5/31/25.
//

import Foundation
import FirebaseFirestore
import Model
import Service

public struct FirebaseDataVersionServiceImp: DataVersionServiceProtocol {
    public init() {}

    public func fetchRemoteVersionInfo() async throws -> VersionsResponse {
        let snapshot = try await Firestore.firestore()
            .collection("versions")
            .document("version")
            .getDocument()

        let versionResponse = try snapshot.data(as: VersionsResponse.self)

        return versionResponse
    }
}
