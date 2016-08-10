It's not hard to hide a whole lot of complexity behind a function call, so you have to be very aware of what the functions you are using actually do, and how long they take to do it.

Here's some example code illustrating a big performance problem I found in a codebase I've inherited. We have a dictionary keyed by a string representing a date, e.g. "2016-08-10", and where the values are arrays of videos for that given date. Due to some unimportant product details videos can actually appear in more than one of the array values. The goal is to get an array of all videos, sorted by date, and with no duplicates. So we need to discard duplicates when building the sorted array.

```Swift 
func allVideosSortedByDate(allVideos: [String:[Video]]) -> [Video] {
    var sortedVideos: [Video] = []
    // sort keys newest first
    var dateKeys = allVideos.allKeys.sort { $1 < $0 }
    for key in dateKeys {
        for video in allVideos[key] {
            if !sortedVideos.contains(video) {
                sortedVideos.append(video)
            }
        }
    }
    return sortedVideos
}
```

Can you spot the problem here? `sortedVideos.contains(_:)` is an `O(n)` algorithm which means that in the worst case it has to look at every single element of the collection to check if it contains the given item. It potentially does `n` operations every time you call it.

Because this is being called from within a loop that's already looping over all `n` items, that makes this an <code>O(n<sup>2</sup>)</code> algorithm, which is pretty terrible. If you ever write an <code>n<sup>2</sup></code> algorithm you should find a better solution ASAP. There almost always is one! If we have a modest collection of 1,000 videos that means we have to do 1,000,000 operations to get a sorted array of them. That's really bad. One measly line of innocuous looking code completely blew the performance of this function.

In this particular case my first instinct is to reach for a set. We want a collection of all the videos and want to ensure that they're unique, and that's what sets are for. So what about sorting? Well we can build up the set of all videos, then sort that set, converting it to an array in the process. Sounds like a lot of work right? Is it really faster? Let's see what it looks like.

```Swift
func allVideosSortedByDate(allVideos: [String:[Video]]) -> [Video] {
    var uniqueVideos: Set<Video> = []
    for key in allVideos.allKeys {
        for video in allVideos[key] {
            uniqueVideos.insert(video)
        }
    }
    // sort videos newest first
    let sortedVideos = uniqueVideos.sort { $1.creationDate < $0.creationDate }
    return sortedVideos
}
```

The for loops are still `O(n)` and now we've shifted some work outside of those loops. After the `O(n)` loops we have a sort method that is probably something like `O(n * log n)`, which is fairly typical. So the total complexity of the function is `O(n + n * log n)`. In order to simplify this we can inflate the first term a bit by increasing it to `n * log n` as well, making the whole thing `O(2n * log n)`, and since we discard constants that's `O(n * log n)` overall.

Putting the constant back in let's see how many operations it now takes to get an array of all videos sorted by date. Again saying we have a modest collection of 1,000 videos, that'll be `2 * 1,000 * log 1000` &rarr; `2,000 * 3` &rarr; `6,000` operations to do the whole thing. A far cry from 1,000,000!

Getting practical, in this case running the original function against **4,990 videos takes 29.653 seconds** on an iPhone 4S. Running the new function against the same set of videos takes **4.792 seconds**. Still not great and there's room for improvement, but that was a big, easy win already.

Mind your algorithms folks, it makes a huge difference in the real world.