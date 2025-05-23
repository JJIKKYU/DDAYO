//
//  FirebaseRemoteConfigImp.swift
//  DDAYO
//
//  Created by 정진균 on 5/23/25.
//

import Service
import FirebaseRemoteConfigInternal

public final class FirebaseRemoteConfigServiceImp: FirebaseRemoteConfigService {
    private let remoteConfig = RemoteConfig.remoteConfig()

    public init() {
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0
        remoteConfig.configSettings = settings
        remoteConfig.setDefaults(["isMixpanelEnabled": false as NSObject])
    }

    public func fetchMixpanelEnabled() async -> Bool {
        do {
            try await remoteConfig.fetchAndActivate()
            return remoteConfig.configValue(forKey: "isMixpanelEnabled").boolValue
        } catch {
            print("Error :: ❌ RemoteConfig 에러! : \(error)")
            return false
        }
    }
}
