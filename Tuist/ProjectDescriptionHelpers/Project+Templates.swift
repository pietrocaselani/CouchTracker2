import ProjectDescription

/// Project helpers are functions that simplify the way you define your project.
/// Share code to create targets, settings, dependencies,
/// Create your own conventions, e.g: a func that makes sure all shared targets are "static frameworks"
/// See https://tuist.io/docs/usage/helpers/

extension Project {
    /// Helper function to create the application target and the unit test target.
    public static func makeAppTargets(
        name: String,
        platform: Platform,
        dependencies: [TargetDependency]
    ) -> [Target] {
        let platform: Platform = platform
        let infoPlist: [String: InfoPlist.Value] = [
            "CFBundleShortVersionString": "1.0",
            "CFBundleVersion": "1",
            "UIMainStoryboardFile": "",
            "UILaunchStoryboardName": "LaunchScreen"
        ]

        let mainTarget = Target(
            name: name,
            platform: platform,
            product: .app,
            bundleId: "io.github.pietrocaselani.couchtracker.\(name)",
            infoPlist: .extendingDefault(with: infoPlist),
            sources: ["App/\(name)/Sources/**"],
            resources: ["App/\(name)/Resources/**"],
            dependencies: dependencies
        )

        let testTarget = Target(
            name: "\(name)Tests",
            platform: platform,
            product: .unitTests,
            bundleId: "io.github.pietrocaselani.couchtracker.\(name)Tests",
            infoPlist: .default,
            sources: ["App/\(name)/Tests/**"],
            dependencies: [
                .target(name: "\(name)")
            ]
        )
        return [mainTarget, testTarget]
    }
}
