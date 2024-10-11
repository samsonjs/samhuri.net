---
Author: Sami Samhuri
Title: Reverse-engineering the photos-navigation URL scheme on iOS
Date: 18th April, 2024
Timestamp: 2024-04-18T20:08:02-07:00
Tags: iOS, Swift, hacking
---

It would be cool to open up the Photos app to a specific asset on iOS, just like the Photo Shuffle lock screen.

![Screenshot showing the Show Photo in Library menu item on the Photo Shuffle lock screen configuration screen](/images/photo-shuffle-show-photo.jpeg)

There are some references to the `photos-navigation` URL scheme out on the web but they all effectively just say that they have no clue how to actually use it. And the obvious guesses haven't worked for me. The only way forward was to roll up my sleeves and dive into some aarch64 assembly, which is a bit of an adventure because I don't know anything about that architecture.

Decompiling the Photos app (a.k.a. MobileSlideShow) and looking through the methods `-[PhotosWindowSceneDelegate openRoutingURL:]` and `-[PhotosURLNavigationRequest _navigateAllowingRetry:]` uncovered some candidates:

- `photos-navigation://asset?uuid={uuid}`
- `photos-navigation://album?name=recents&revealassetuuid={uuid}` (opens the album so at least that's something, but not my goal)
- `photos-navigation://contentmode?id=photos&assetuuid={uuid}&oneUp=1`

Opening up an album by name works but so far I've had no luck figuring out how to show a specific asset. And ideally it would open up in the Library tab and not the Albums tab, just like the Photo Shuffle lock screen.

An interesting tidbit I learned along the way is that there are a handful of well-known named albums and those are the only identifiers allowed for the `name` parameter, you can't just pass the name of any album. The known album names from `-[PhotosURLNavigationRequest _albumForKnownName:orUUID:requestIsValid:]` are the following:

- `photo-library`
- `recents` a.k.a. `camera-roll`
- `favorites`
- `all-imported`
- `last-imported`
- `recently-deleted`

And some other hosts / actions that seem to be supported:

- `photos-navigation://oneyearago`
- `photos-navigation://memories`
- `photos-navigation://people`

It looks like these are supported for the `photos:` URL scheme as well but I had zero luck opening that URL at all, rather than the `photos-navigation:` scheme which at least opens the app in all cases.

The next step might be trying to figure out which app/framework handles the Photo Shuffle lock screen and then decompile that to figure out which URL it calls.

----

_Update 2024-10-11: `photos-navigation://memories` works on the iOS 18.1 beta however I've still had no luck with navigation to a specific asset._
