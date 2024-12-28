@preconcurrency import ProjectDescription

let project = Project(
    name: "DDAYO",
    targets: [
        .target(
            name: "DDAYO",
            destinations: .iOS,
            product: .app,
            bundleId: "com.jjikkyu.DDAYO",
            infoPlist: .extendingDefault(
                with: [
                    "UILaunchScreen": [
                        "UIColorName": "",
                        "UIImageName": "",
                    ],
                ]
            ),
            sources: ["DDAYO/Sources/**"],
            resources: ["DDAYO/Resources/**"],
            dependencies: [
                .external(name: "ComposableArchitecture"),
            ],
            settings: .settings(
                base: [
                    "DEVELOPMENT_TEAM": "V237TD2AXA"
                ]
            )
        ),
        .target(
            name: "DDAYOTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "com.jjikkyu.DDAYOTests",
            infoPlist: .default,
            sources: ["DDAYO/Tests/**"],
            resources: [],
            dependencies: [.target(name: "DDAYO")]
        ),
    ]
)
