---
Author: Sami Samhuri
Title: "Reverse-engineering the photos-navigation URL scheme on iOS"
Date: "18th April, 2024"
Timestamp: 2024-04-18T20:08:02-07:00
Tags: ios, swift, coding
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

_Update 2026-10-24: OUTLINE, to be written up_

- Reader email (Mark): `photos://asset?uuid=<uuid>` works
  - UUID is the first component of `PHAsset.localIdentifier`; the full `UUID/L0/001` works too
  - Get it from the Content Graph in Shortcuts
  - Confirmed on iPhone 13 mini and 14 Pro, iOS 26.7.1 (Mark: 16.7.2 and 26.7.1)
- Why I had "zero luck" with `photos:` before
  - Photos marks the scheme private (`CFBundleURLIsPrivate` in its Info.plist)
  - Third-party apps get -10814
  - Works from a Shortcuts Open URLs action because Shortcuts is a system app
- Things that don't get around it
  - App Intent returning `OpenURLIntent`: in-app `Button(intent:)`, Spotlight App Shortcut, Shortcuts action
  - All fail with "The provided URL scheme `photos` is unsupported; launch is prohibited"
  - Widgets and controls untested (controls run the same kind of intent)
- Workaround for personal apps: hand off to a shortcut
  - `shortcuts://x-callback-url/run-shortcut?name=Show%20Photos&input=text&text=<uuid>&x-error=<callback>`
  - Shortcut: URL action with `photos://asset?uuid=` + Shortcut Input, then Open URLs
  - `x-error` fires when the shortcut is missing, so the app can show setup steps
  - Daily Drip's "Show in Photos" does this
- Shippable alternative: open a date instead of an asset
  - `photos-navigation://search?searchTerm=2003-01-01` shows just that day
  - "1 January 2003" works too; "October 26" matches every year; "October 2024" the month
  - ISO avoids localized month names
- Still open
  - How Photo Shuffle does it; no public API to reveal an asset
