---
Author: Sami Samhuri
Title: "A nil-coalescing alternative for Swift"
Date: "6th October, 2017"
Timestamp: 2017-10-06T14:20:13-07:00
Tags: [iOS, Swift]
---

Swift compile times leave something to be desired and a common culprit is the affectionately-named [nil-coalescing operator][nilop]. A small extension to `Optional` can improve this without sacrificing a lot of readability.

```swift
extension Optional {
    func or(_ defaultValue: Wrapped) -> Wrapped {
        switch self {
        case .none: return defaultValue
        case let .some(value): return value
        }
    }
}
```

And you use it like so:

```swift
let dict: [String : String] = [:]
let maybeString = dict["not here"]
print("the string is: \(maybeString.or("default"))")
let otherString = dict["not here"].or("something else")
```

I'm sure someone else has come up with this already but I haven't seen it yet.

_([gist available here][gist])_

[nilop]: https://developer.apple.com/library/content/documentation/Swift/Conceptual/Swift_Programming_Language/BasicOperators.html#//apple_ref/doc/uid/TP40014097-CH6-ID72
[gist]: https://gist.github.com/samsonjs/c8933c07ad985b74aba994f2fdab8b47
