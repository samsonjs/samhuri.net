---
Author: Sami Samhuri
Title: "Type-safe notifications and async stream monitoring with Swift 6"
Date: "6th June, 2025"
Timestamp: 2025-06-06T14:27:11-07:00
Tags: [Swift, iOS, notifications, async, concurrency, AsyncMonitor, NotificationSmuggler]
---

Swift 6 concurrency checking made handling notifications without warnings kinda tedious. The old Combine approach doesn't work with `@Sendable` closures and manually managing tasks gets repetitive. I made a couple of tiny Swift packages to help out with the situation: [AsyncMonitor](https://github.com/samsonjs/AsyncMonitor) which wraps task management, and [NotificationSmuggler](https://github.com/samsonjs/NotificationSmuggler) which adds a type-safe interface on top of `Notification` and `NotificationCenter`.

## The manual approach

Here's what I was writing over and over:

```swift
// Causes Sendable warnings in Swift 6
let task = Task { [weak self] in
    for await notification in NotificationCenter.default.notifications(named: .NSCalendarDayChanged) {
        guard let self else { return }
        await self.handleDayChange()
    }
}
// Store it somewhere, hope you remember to cancel it...
```

And when you have a bunch of these then you wind up with lots of properties to track them and other boilerplate.

## AsyncMonitor

[AsyncMonitor](https://github.com/samsonjs/AsyncMonitor) wraps the task lifecycle. Instead of managing tasks manually you use streams like Combine publishers:

```swift
import AsyncMonitor

let cancellable = NotificationCenter.default
    .notifications(named: .NSCalendarDayChanged)
    .map(\.name)
    .monitor { _ in
        print("The date is now \(Date.now)")
    }
```

The `monitor` method creates a `Task` internally and handles cleanup when the cancellable goes out of scope. The closure is async so you can await in it.

You're free to do the usual `[weak self]` and `guard let self else { return }` dance, but there's a variant that accepts a context parameter that's automatically weakified. Your closure receives a strong reference:

```swift
let cancellable = NotificationCenter.default
    .notifications(named: .NSCalendarDayChanged)
    .map(\.name)
    .monitor(context: self) { _self, _ in
        _self.dayChanged()
    }
```

The monitor finishes automatically after finding a nil context.

### Cancellation tokens

Similar to Combine there's the concept of a cancellable that ties the observation to the lifetime of that cancellable instance. And of course, we call it a dispose bag. Just kidding obviously, it's called `AsyncCancellable` and there's an `AnyAsyncCancellable` type-erasing wrapper. So very much like Combine you write this:

```swift
import AsyncMonitor

class Whatever {
    private var cancellables: Set<AnyAsyncCancellable> = []

    func something() {
        NotificationCenter.default
            .notifications(named: .NSCalendarDayChanged)
            .map(\.name)
            .monitor { _ in /* ... */ }
            .store(in: &cancellables)
    }
}
```

### KVO

Sometimes you need KVO and the old ways are best. There's a KVO extension that bridges to async sequences:

```swift
// AVPlayer's Combine publisher for rate doesn't publish all the values
player.monitorValues(for: \.rate) { rate in
    print("Player rate: \(rate)")
}.store(in: &cancellables)
```

### What about Combine?

Combine works but doesn't mesh well with Swift 6 concurrency. The `@Sendable` requirements make it annoying. You can write the Task code manually but it gets repetitive when you have a lot of observers.

## NotificationSmuggler

[NotificationSmuggler](https://github.com/samsonjs/NotificationSmuggler) solves a different problem: type-safe notifications. No more dumpster diving in `userInfo`.

Define your contraband:

```swift
import NotificationSmuggler

struct ProjectExportComplete: Smuggled, Sendable {
    let projectID: String
    let outputURL: URL
}
```

The `Smuggled` protocol generates a unique notification name and userInfo key from your type name.

Smuggle your illicit goods like so:

```swift
NotificationCenter.default.smuggle(ProjectExportComplete(projectID: "project-123", outputURL: exportURL))

// which is short for

NotificationCenter.default.post(.smuggle(ProjectExportComplete(projectID: "project-123", outputURL: exportURL)))
```

And on the other side it's as easy as any other notification using an extension on `NotificationCenter`:

```swift
for await notification in NotificationCenter.default.notifications(for: ProjectExportComplete.self) {
    print("Project \(notification.projectID) exported to \(notification.outputURL)")
}
```

## Using them together

They work well together. Here's a more full example:

```swift
import AsyncMonitor
import NotificationSmuggler

struct BackupCompleteNotification: Smuggled, Sendable {
    let success: Bool
    let totalSize: Int64
}

NotificationCenter.default
    .notifications(for: BackupCompleteNotification.self)
    .monitor(context: self) { _self, notification in
        _self.updateBackupStatus(success: notification.success)
    }.store(in: &cancellables)

// elsewhere

NotificationCenter.default.smuggle(BackupCompleteNotification(success: true, totalSize: 42))
```

## That's it

Both libraries are small and focused. AsyncMonitor is about 100 lines, NotificationSmuggler is smaller. Zero dependencies.

AsyncMonitor requires iOS 17. It supports both iOS 17 and iOS 18 with different initializers due to changes in inheriting actor isolation.

- [AsyncMonitor on GitHub](https://github.com/samsonjs/AsyncMonitor)
- [AsyncMonitor on Swift Package Index](https://swiftpackageindex.com/samsonjs/AsyncMonitor)

NotificationSmuggler requires iOS 17.

- [NotificationSmuggler on GitHub](https://github.com/samsonjs/NotificationSmuggler)
- [NotificationSmuggler on Swift Package Index](https://swiftpackageindex.com/samsonjs/NotificationSmuggler)
