---
Author: sjs
Title: Migrating to Swift 6 by keeping code on Swift 5 forever
Date: 22nd July, 2026
Timestamp: 2026-07-22T22:38:40-06:00
Tags: swift, concurrency
---

This week I’m at [the inaugural Swift Rockies conference][swiftrockies] in Calgary and it’s been great so far. At [Matt Massicotte’s lab][lab] yesterday there was a whole lot of discussion about Swift concurrency which was enlightening and fun (seriously).

[swiftrockies]: https://swiftrockies.com
[lab]: /posts/2026/06/swift-concurrency-lab-next-month/

Those discussions made me realize that I should share a trick that I haven’t seen mentioned anywhere yet.

Recently while migrating to Swift 6, I came across some code that was seemingly never gonna compile, no matter how many non-isolated unsafe declarations I plastered around. It’s a class called `AsyncFuture` that, shockingly, bridges Combine futures to async/await. So it’s not entirely unexpected that there are a lot of concurrency issues since Combine is notorious here.

My solution to this was to create a new target in that SPM package containing only `AsyncFuture`, and setting it to language mode 5 with a comment stating that it’ll stay there until it goes away and we migrate code off of it. Swift still supports language mode 4 so it doesn’t seem like Swift 5 will go away anytime soon at all, and this let me migrate the main target in this package to Swift 6.

Anyway, that’s it and I hope you might find it helpful. It’s a simple manoeuvre and targets are cheap in SPM, so I recommend sending any code to Swift 5 prison if it has no business playing in the Swift 6 world. Life sentence.
