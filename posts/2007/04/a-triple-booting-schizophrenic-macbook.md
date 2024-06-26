---
Title: A triple-booting, schizophrenic MacBook
Author: Sami Samhuri
Date: 4th April, 2007
Timestamp: 2007-04-04T23:30:00-07:00
Tags: linux, mac os x, windows
---

The steps are well documented so I won’t get into detail here but if you have a backup and can wipe your disk all you do is:

 * Install OS X to a single partition filling your disk (optionally use your existing OS X intall)
 * Install <a href="http://refit.sourceforge.net/">rEFIt</a> (no need to reboot just yet)
 * Re-partition your disk into 3 partitions with <code>diskutil resizeVolume</code>, reboot and confirm it all works
 * Boot the Vista install DVD and install to disk0s4 aka Partition 4
 * Install Gentoo (or other distro) to disk0s3 aka /dev/sda3

With <a href="http://www.macports.org/">MacPorts</a> and <a href="http://www.metadistribution.org/macos/">Gentoo/MacOSX</a> the Gentoo install is superfluous but I’ll spare 12G just to see Gentoo run on this fine machine. Setting up the hardware should be fun. Right now I’m compiling X, (package 77 of 94) and the Core Duo is crunching code very nicely with 2G to work with, <strong>without any swap</strong>. I fully intend to put off creating a swap file unless I have to. Needless to say I’ll be running fluxbox or Xfce, none of that Gnome or KDE stuff. If I ever need a swap file I will eat my keyboard.

*[edit: 25 minutes to compile X.org, not too shabby!]*

My initial experience with Vista is quite good. Sadly the <a href="http://www.manicai.net/comp/swap-caps-ctrl.html">same old registry hack</a> is required to swap Caps lock and Control but I was just glad it worked. I really like the new Start menu and the eye-candy is fairly pleasant for the most part. Until now I’d only used RC2 on a machine incapable of running Aero Glass and it looked terrible. I switched to Windows Classic just like I do with XP. Not so with Aero at its finest though. Without thinking about the price Vista is a nice upgrade to Windows. But because of the price and uncertainty of running Aero Glass I still hesitate to urge non-geeks to upgrade.

OS X is OS X. It’s my favourite desktop OS right now because of apps like LaunchBar/Quicksilver and TextMate, a generally excellent UI, good old *nix stability, zsh out of the box! When I need WireShark or the GIMP X11 is there waiting.  Mac notebooks are great and tight integration with the hardware is a clear advantage for OS X.

Oh yeah, I also have a Parallels VM for Windows 3.11. It boots in about second to the <code>C:\&gt;</code> prompt and then another second to type <code>win</code> and Windows to start. Without TCP/IP there’s not much to do though (I’m not going to write a driver for Parallels’ ethernet adapter).

  * Dual head setups are more work than plugging in a 2nd monitor, which is too much work.

  * X requires a restart to enable or disable a 2nd display.

  * Overall clunkiness such as displaying the houndstooth background before the WM starts,

  * and/or going through a screwed up mode with a black & white scrambled screen for a seconds before getting to the houndstooth.

Like I said the X.org boys are doing amazing work. Hopefully soon after the current eye-candy craze is over they’ll get to more important work that needs to be done.

