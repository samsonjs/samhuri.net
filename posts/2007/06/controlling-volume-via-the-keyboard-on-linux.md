---
Title: Controlling volume via the keyboard on Linux
Author: Sami Samhuri
Date: 30th June, 2007
Timestamp: 2007-06-30T16:13:00-07:00
Tags: alsa, linux, ruby, volume
---

I was using Amarok's global keyboard shortcuts to control the volume of my music via the <a href="http://pfuca-store.stores.yahoo.net/haphackeylit1.html">keyboard</a> but I wanted to control the system volume as well. A quick script later and now I can control both, and thanks to libnotify I get some feedback on what happened. It's not as pretty as OS X's volume control or <a href="http://growl.info/">Growl</a> but it'll certainly do.

<a href="/f/volume.rb">&darr; Download volume.rb</a>

I save this as <strong>~/bin/volume</strong> and call it thusly: <code>volume +</code> and <code>volume -</code>. I bind Alt-+ and Alt—to those in my fluxbox config. If you don't have a preferred key binding program I recommend trying <a href="http://hocwp.free.fr/xbindkeys/xbindkeys.html">xbindkeys</a>. apt-get install, emerge, paludis -i, or rpm -i as needed.

