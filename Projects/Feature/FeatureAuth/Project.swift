@preconcurrency import ProjectDescription

let project = Project(
    name: "FeatureAuth",
    targets: [
        // Framework
        .target(
            name: "FeatureAuth",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.jjikktu.FeatureAuth",
            infoPlist: .extendingDefault(
                with: [
                    "UILaunchScreen": [
                        "UIColorName": "",
                        "UIImageName": "",
                    ],
                ]
            ),
            sources: ["FeatureAuth/Sources/**"],
            resources: ["FeatureAuth/Resources/**"],
            dependencies: [
                .external(name: "ComposableArchitecture", condition: nil),
                // .external(name: "FirebaseAuth", condition: nil),

                // Shared
                .project(target: "Model", path: "../../Shared/Model", status: .required, condition: nil),
                .project(target: "Service", path: "../../Shared/Service", status: .required, condition: nil),
                .project(target: "DI", path: "../../Shared/DI", status: .required, condition: nil),
            ],
            settings: .settings(
                base: [
                    "DEVELOPMENT_TEAM": "V237TD2AXA"
                ]
            )
        ),
        // UnitTests
        .target(
            name: "FeatureAuthTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "com.jjikktu.FeatureAuthTests",
            infoPlist: .default,
            sources: ["FeatureAuth/Tests/**"],
            resources: [],
            dependencies: [.target(name: "FeatureAuth")]
        ),
    ]
)
