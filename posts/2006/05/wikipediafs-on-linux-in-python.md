---
Title: WikipediaFS on Linux, in Python
Author: Sami Samhuri
Date: 7th May, 2006
Timestamp: 2006-05-07T20:49:00-07:00
Tags: hacking, python, linux, fuse, linux, mediawiki, python, wikipediafs
---

Until now I've been using my own version of <a href="http://meta.wikimedia.org/wiki/Pywikipedia">pywikipedia</a> for scripting MediaWiki, and it works well. But I read about <a href="http://wikipediafs.sourceforge.net/">WikipediaFS</a> and had to check it out. It's a user space filesystem for Linux that's built using the <a href="http://fuse.sourceforge.net/wiki/index.php/LanguageBindings">Python bindings</a> for <a href="http://fuse.sourceforge.net/">FUSE</a>. What it does is mounts a filesystem that represents your wiki, with articles as text files. You can use them just like any other files with mv, cp, ls, vim, and so on.

There hasen't been any action on that project for 13 months though, and it doesn't work on my wiki (MediaWiki 1.4.15) so I'm going to try and make it work after I upgrade to MediaWiki 1.6.3 tonight. This will be pretty cool when it works. I haven't looked at the code yet but it's only 650 lines.

