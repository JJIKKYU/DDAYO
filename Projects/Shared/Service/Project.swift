@preconcurrency import ProjectDescription

let project = Project(
    name: "Service",
    targets: [
        // Framework
        .target(
            name: "Service",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.jjikktu.Service",
            infoPlist: .default,
            sources: ["./Sources/**"],
            dependencies: [
                .external(name: "ComposableArchitecture", condition: nil)
            ],
            settings: .settings(
                base: [
                    "DEVELOPMENT_TEAM": "V237TD2AXA"
                ]
            )
        ),
    ]
)
