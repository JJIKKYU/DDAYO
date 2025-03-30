@preconcurrency import ProjectDescription

let project = Project(
    name: "FeatureSearch",
    targets: [
        // Framework
        .target(
            name: "FeatureSearch",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.jjikktu.FeatureSearch",
            infoPlist: .extendingDefault(
                with: [
                    "UILaunchScreen": [
                        "UIColorName": "",
                        "UIImageName": "",
                    ],
                ]
            ),
            sources: ["FeatureSearch/Sources/**"],
            resources: ["FeatureSearch/Resources/**"],
            dependencies: [
                .external(name: "ComposableArchitecture", condition: nil),

                // Shared
                .project(target: "UIComponents", path: "../../Shared/UIComponents", status: .required, condition: nil),
                .project(target: "Model", path: "../../Shared/Model", status: .required, condition: nil),
            ],
            settings: .settings(
                base: [
                    "DEVELOPMENT_TEAM": "V237TD2AXA"
                ]
            )
        ),
        // UnitTests
        .target(
            name: "FeatureSearchTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "com.jjikktu.FeatureSearchTests",
            infoPlist: .default,
            sources: ["FeatureSearch/Tests/**"],
            resources: [],
            dependencies: [.target(name: "FeatureSearch")]
        ),
    ]
)
