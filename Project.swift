import ProjectDescription
import ProjectDescriptionHelpers

/*
                +-------------+
                |             |
                |     App     | Contains CouchTracker2 App target and CouchTracker2 unit-test target
                |             |
         +------+-------------+-------+
         |         depends on         |
         |                            |
 +----v-----+                   +-----v-----+
 |          |                   |           |
 |   Kit    |                   |     UI    |   Two independent frameworks to share code and start modularising your app
 |          |                   |           |
 +----------+                   +-----------+

 */

// MARK: - Project

// Creates our project using a helper function defined in ProjectDescriptionHelpers

let targets = Project.makeAppTargets(
    name: "CouchTracker2",
    platform: .iOS,
    dependencies: [
        .package(product: "TraktSwift")
    ]
)

let project = Project(
    name: "CouchTracker2",
    organizationName: "Pietro Caselani",
    packages: [
        .local(path: "CouchTrackerPackages")
    ],
    settings: nil,
    targets: targets,
    schemes: [],
    additionalFiles: []
)
