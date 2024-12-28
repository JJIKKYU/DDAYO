import ProjectDescription

let project = Project(
    name: "DDAYO",
    targets: [
        .target(
            name: "DDAYO",
            destinations: .iOS,
            product: .app,
            bundleId: "io.tuist.DDAYO",
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
            dependencies: []
        ),
        .target(
            name: "DDAYOTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "io.tuist.DDAYOTests",
            infoPlist: .default,
            sources: ["DDAYO/Tests/**"],
            resources: [],
            dependencies: [.target(name: "DDAYO")]
        ),
    ]
)
