---
Title: Using Emacs to Develop Mojo Apps for WebOS
Author: Sami Samhuri
Date: 21st November, 2009
Timestamp: 2009-11-21T00:00:00-08:00
Tags: emacs, mojo, webos, lisp, javascript
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

A couple of of Lisp hacking sessions later and I'm happy enough with
mojo.el to bump the version to v0.9. I've checked off what I
feel are the most important checkpoints on
the [webOS
Internals comparison of editors](http://www.webos-internals.org/wiki/Comparison_of_Editors)
and the framework is in place to make implementing most of the
remaining commands very trivial. I might take a bit of time today
to flesh things out just to check more points off so people feel
more confident that it's a fully featured environment, because it
certainly is.

It now requires json.el in order to parse appinfo.json. json.el
might be included with Emacs if you have a very recent version,
otherwise you can google for it or get it from
my [config file repo on github](https://github.com/samsonjs/config/tree/master/emacs.d)
where you can also find my latest version of mojo.el. You still
just `(require 'mojo)` in your .emacs file.

The wrappers around Palm SDK commands now search upwards for the
Mojo project root directory (from the default-directory for
current-buffer) and parse appinfo.json to give you sane defaults for
mojo-package, mojo-install, mojo-launch, mojo-delete, and
mojo-inspect. You can list installed apps and when entering app
ids there is completion and history, as you have come to expect in
Emacs. The most useful command for development is
mojo-package-install-and-inspect which does exactly what it says:
packages, installs, and launches the application for
inspection. No interaction is required as long as you are
editing a buffer inside your Mojo project.

If you read the install instructions in mojo.el and decide to setup
some keybindings then you will have single-task commands for
packaging, installing, launching, or all three steps at once.

Please give me some feedback if you try this out. I've
developed it on Mac OS X and Jonathan on Windows so please try it on
Linux and send me a patch or even better a pull request on github if
it needs some work. There is room for improvement.  The next feature
on my radar before I would consider it worthy of a v1.0 tag is
intelligent switching to corresponding buffers,
e.g. mojo-switch-to-view, mojo-switch-to-assistant, things like
that.  Basically things I miss from the Rails package for Emacs.

Happy hacking!

