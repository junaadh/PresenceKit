// swift-tools-version: 6.2
import PackageDescription

let package = Package(
	name: "PresenceKit",
	platforms: [
		.macOS(.v14)  // Adjust if needed
	],
	products: [
		.library(
			name: "PresenceKit",
			targets: ["PresenceKit"]
		)
	],
	targets: [
		.target(
			name: "PresenceKit",
			path: "Sources/PresenceKit"
		)
	]
)
