---
Title: Back on Gentoo, trying new things
Author: Sami Samhuri
Date: 18th June, 2007
Timestamp: 2007-06-18T18:05:00-07:00
Tags: emacs, gentoo, linux, vim
---

I started using my Gentoo box for development again and there are a few things about Linux I didn't realize I had been missing.

### Shell completion is awesome out of the box ###

zsh has an impressive completion system but I just don't feel the urge to ever customize it extensively.  I just use the basic completion stuff on OS X because it's easy.  On Gentoo I have rake tasks and all sorts of other crap completed for me by including a few lines in my .zshrc (iirc a script does this automatically anyway).  Generally Linux distros try to knit everything together nicely so you never even think about things like whether or not a package will have readline support, and default configs will be tweaked and enhanced beyond the official zsh package.

### Linux is stable. Really stable. ###

While people bash Microsoft daily for tying the GUI layer to the kernel, Apple seems to get away with it scot-free.  I don't know if it's caused by my external display hooked up to the dock, or the Prolific Firewire chip in my external disk enclosure but something causes the mysterious "music plays until the end of the song, mouse can be moved, but nothing works" bug now and then and all I can do is a hard reset.

On Linux I currently use Fluxbox so everything is rock solid and fast (except Firefox! ;-), but in the extremely rare event that shit does hit the fan usually only a single app will crash, though sometimes X (and hence many others) go with it.  A <code>sudo /etc/init.d/gdm restart</code> fixes that.  The only times I've had to hard reset Linux was because of a random bug (strangely similar to my MacBook bug) with Nvidia's driver with dual head setups.  All this is pretty moot since Linux is generally just stable.

Those are 2 relatively small things but the added comfort they provide is very nice.

In the spirit of switching things up I'm going to forgo my usual routine of using gvim on Linux and try out emacs.  I've been frustrated with vim's lack of a decent file browser and I've never much liked the tree plugin.  Vim is a fantastic editor when it comes to navigating, slicing, and dicing text.  After that it sort of falls flat though.  After getting hooked on TextMate I have come to love integration with all sorts of external apps such as Subversion, rake, and the shell because it makes my work easier.  Emacs seems to embrace that sort of philosophy and I'm more impressed with the efforts to integrate Rails development into Emacs than vim.  I'm typing this post using the Textile mode for Emacs and the markup is rendered giving me a live preview of my post.  It's not WYSIWYG like Typo's preview but it's still pretty damn cool.  I think can get used to emacs.

I'm just waiting for a bunch of crap to compile – because I use Gentoo – and soon I'll have a Gtk-enabled Emacs to work in.  If I can paste to and from Firefox then I'll be happy. I'll have to open this in vim or gedit to paste it into Firefox, funny!

I'm also going to try replacing a couple of desktop apps with web alternatives. I'm starting with 2 no-brainers: mail and feeds with Gmail and Google Reader.  I never got into the Gmail craze and never really even used Gmail very much. After looking at the shortcuts I think I can get used to it.  Seeing j/k for up/down is always nice.  Thunderbird is ok but there isn't a mail client on Linux that I really like, except mutt.  That played a part in my Gmail choice.  I hadn't used G-Reader before either and it seems alright, but it'll be hard to beat NetNewsWire.

