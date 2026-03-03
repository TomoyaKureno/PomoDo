// swift-tools-version: 5.9
import PackageDescription
import AppleProductTypes

let package = Package(
    name: "PomoDo",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .iOSApplication(
            name: "PomoDo",
            targets: ["AppModule"],
            bundleIdentifier: "com.example.PomoDo",
            teamIdentifier: "",
            displayVersion: "1.0",
            bundleVersion: "1",
            supportedDeviceFamilies: [.pad, .phone],
            supportedInterfaceOrientations: [
                .portrait,
                .portraitUpsideDown,
                .landscapeLeft,
                .landscapeRight
            ]
        )
    ],
    targets: [
        .executableTarget(
            name: "AppModule",
            path: "Sources/AppModule",
            resources: [
                .process("Resources")
            ]
        )
    ]
)
