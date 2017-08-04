import PackageDescription

let package = Package(
    name: "vapor_forms",
    targets: [
        Target(name: "App"),
        Target(name: "Run", dependencies: ["App"]),
    ],
    dependencies: [
        .Package(url: "https://github.com/vapor/vapor.git", majorVersion: 2),
        .Package(url: "https://github.com/vapor/leaf-provider.git", majorVersion: 1),
        .Package(url: "https://github.com/vapor/postgresql-provider.git", majorVersion: 2),
        .Package(url: "https://github.com/nodes-vapor/flash", majorVersion: 1),
        .Package(url: "https://github.com/vapor/validation", majorVersion: 1),
    ],
    exclude: [
        "Config",
        "Database",
        "Public",
        "Resources",
    ]
)

