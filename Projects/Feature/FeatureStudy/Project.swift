@preconcurrency import ProjectDescription

let project = Project(
    name: "FeatureStudy",
    targets: [
        // Framework
        .target(
            name: "FeatureStudy",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.jjikktu.FeatureStudy",
            infoPlist: .extendingDefault(
                with: [
                    "UILaunchScreen": [
                        "UIColorName": "",
                        "UIImageName": "",
                    ],
                ]
            ),
            sources: ["FeatureStudy/Sources/**"],
            resources: ["FeatureStudy/Resources/**"],
            dependencies: [
                .external(name: "ComposableArchitecture", condition: nil),

                // Feature
                .project(target: "FeatureSearch", path: "../../Feature/FeatureSearch", status: .required, condition: nil),

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
            name: "FeatureStudyTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "com.jjikktu.FeatureStudyTests",
            infoPlist: .default,
            sources: ["FeatureStudy/Tests/**"],
            resources: [],
            dependencies: [.target(name: "FeatureStudy")]
        ),
    ]
)
