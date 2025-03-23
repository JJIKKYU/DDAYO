@preconcurrency import ProjectDescription

let project = Project(
    name: "FeatureBookmark",
    targets: [
        // Framework
        .target(
            name: "FeatureBookmark",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.jjikktu.FeatureBookmark",
            infoPlist: .extendingDefault(
                with: [
                    "UILaunchScreen": [
                        "UIColorName": "",
                        "UIImageName": "",
                    ],
                ]
            ),
            sources: ["FeatureBookmark/Sources/**"],
            resources: ["FeatureBookmark/Resources/**"],
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
            name: "FeatureBookmarkTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "com.jjikktu.FeatureBookmarkTests",
            infoPlist: .default,
            sources: ["FeatureBookmark/Tests/**"],
            resources: [],
            dependencies: [.target(name: "FeatureBookmark")]
        ),
    ]
)
