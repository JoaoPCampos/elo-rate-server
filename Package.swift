// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "ranking-server",
    dependencies:
    [
        // fixes error: multiple products named 'Logging' in: Console, swift-log
        .package(url: "https://github.com/IBM-Swift/LoggerAPI.git",
                 .upToNextMinor(from: "1.8.0")),
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git",
                 from: "3.0.0"),

        // 🐘 Non-blocking, event-driven Swift client for PostgreSQL.
//        .package(url: "https://github.com/vapor/fluent-postgresql.git", from: "1.0.0"),
        .package(url: "https://github.com/vapor/fluent-sqlite.git",
                 from: "3.0.0"),


        // 🔐 Authentication package
        .package(url: "https://github.com/vapor/auth.git",
                 from: "2.0.0-rc"),

        /// 📤 Mail service
        .package(url: "https://github.com/IBM-Swift/Swift-SMTP",
                 .upToNextMinor(from: "5.1.0"))
    ],
    
    targets: [
        .target(name: "App",
                dependencies: [
                    "Vapor",
                    "FluentSQLite",
//                    "FluentPostgreSQL",
                    "Authentication",
                    "SwiftSMTP"]),

        .target(name: "Run",
                dependencies: ["App"]),

        .testTarget(name: "AppTests",
                    dependencies: ["App"])
    ]
)

