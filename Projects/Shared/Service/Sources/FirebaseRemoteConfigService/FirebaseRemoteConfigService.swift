//
//  FirebaseRemoteConfigService.swift
//  Service
//
//  Created by 정진균 on 5/23/25.
//

import Foundation

public protocol FirebaseRemoteConfigService {
    func fetchMixpanelEnabled() async -> Bool
}
