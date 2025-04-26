@preconcurrency import ProjectDescription

let project = Project(
    name: "DI",
    targets: [
        // Framework
        .target(
            name: "DI",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.jjikktu.DI",
            infoPlist: .default,
            sources: ["./Sources/**"],
            dependencies: [
                .external(name: "ComposableArchitecture", condition: nil),
                .project(target: "Service", path: "../Service", status: .required, condition: nil),
                .project(target: "Model", path: "../Model", status: .required, condition: nil),
            ],
            settings: .settings(
                base: [
                    "DEVELOPMENT_TEAM": "V237TD2AXA"
                ]
            )
        ),
    ]
)
