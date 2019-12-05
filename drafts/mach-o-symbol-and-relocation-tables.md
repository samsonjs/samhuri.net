---
Title: Mach-O Symbol and Relocation Tables
Author: Sami Samhuri
Date: 28th June, 2015
Timestamp: 1435527198
Tags:
---

The latest technology I've been learning is Palm's SDK for webOS,
Mojo. My first impression is that it's a great platform and
Palm could do a great job of 2.0 if they cut down on some of the
verbosity of gluing together the UI. I have learned to like
JavaScript over the years as I learned that despite its
warts [there are good parts](http://ca.video.yahoo.com/watch/630959/2974197)
too. If you squint just right you can see that it's scheme with
Algol syntax. HTML and CSS are what they are, but with WebKit running
the show and only a single engine to target it's not that bad. I've
gone from Eclipse to Emacs for the coding itself and highly recommend
Emacs for Mojo development. There is nothing that I miss from the
Eclipse or Komodo Edit thanks to the fact that Mojo uses open
languages and standards.


As far as actual development goes the Mojo documentation steers you
towards a combination of Eclipse, Palm's Mojo plugin for Eclipse,
and the Aptana Studio plugin. My editor of choice is Emacs but
I decided to give it a spin just to get started quickly, how bad
could it be? I'm not going to get into details but I will say that I
don't think I'll ever use Eclipse for anything; it's far too
sluggish and provides no compelling features for the languages
that I use. I tried Komodo Edit and it was significantly
better but still not for me. Emacs is great for editing HTML,
JavaScript, and CSS so all I really missed from the IDEs were the
shortcuts to package, install, and launch apps in the
emulator. I headed over to
the [Emacs Wiki](http://www.emacswiki.org/) and
downloaded Jonathan
Arkell's [Mojo
support for Emacs](http://www.emacswiki.org/emacs/MojoSdk)
which provided a great base to get
started with. There are wrappers around (all?) of the Palm SDK
commands but it needed a bit of work to make it just do what I
wanted with as little input and thought as possible.
