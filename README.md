# PresenceKit

PresenceKit is a Swift library for integrating Discord Rich Presence into your macOS applications via Discord's IPC (Inter-Process Communication) protocol.

## Features
- Connect and reconnect to Discord IPC
- Set and clear Discord Rich Presence activities
- Handle handshakes and error responses
- Send and receive raw IPC data

## Installation
Add PresenceKit to your Xcode project. If using Swift Package Manager, add the repository URL to your dependencies.

## Usage

```swift
import PresenceKit

var client = DiscordIPCClient(client_id: /**/)

do {
    try client.connect()
    let activity = Activity(/* configure your activity */).set/* builder api */
    try client.setActivity(activity)
} catch {
    print("Discord IPC error: \(error)")
}
```
