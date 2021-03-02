// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CouchTracker",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(name: "TrendingMovies", targets: ["TrendingMovies"]),
        .library(name: "HTTPClient", targets: ["HTTPClient"]),
        .library(name: "HTTPClientTestable", targets: ["HTTPClientTestable"]),
        .library(name: "RetrofitSwift", targets: ["RetrofitSwift"]),
        .library(name: "TraktSwift", targets: ["TraktSwift"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "0.15.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "TrendingMovies",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                "HTTPClient"
            ]
        ),
        .testTarget(
            name: "TrendingMoviesTests",
            dependencies: ["TrendingMovies"]
        ),
        .target(name: "HTTPClient"),
        .testTarget(
            name: "HTTPClientTests",
            dependencies: ["HTTPClient", "HTTPClientTestable"]
        ),
        .target(
            name: "HTTPClientTestable",
            dependencies: ["HTTPClient"]
        ),
        .target(
            name: "TraktSwift",
            dependencies: ["HTTPClient"]
        ),
        .testTarget(
            name: "TraktSwiftTests",
            dependencies: ["HTTPClient", "HTTPClientTestable"]
        ),
        .target(
            name: "RetrofitSwift",
            dependencies: ["HTTPClient"]
        ),
        .testTarget(
            name: "RetrofitSwiftTests",
            dependencies: ["HTTPClient", "HTTPClientTestable"]
        )
    ]
)