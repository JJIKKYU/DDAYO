//
//  Plugins.swift
//  Manifests
//
//  Created by 정진균 on 12/28/24.
//

@preconcurrency import ProjectDescription

enum FeatureModule: String, CaseIterable {
  case Foo
  case Bar
}

enum CoreModule: String, CaseIterable {
  case Analytics
  case Auth
}
