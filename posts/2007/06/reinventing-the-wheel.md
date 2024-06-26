---
Title: Reinventing the wheel
Author: Sami Samhuri
Date: 20th June, 2007
Timestamp: 2007-06-20T09:27:00-07:00
Tags: emacs, snippets
---

Emacs is very impressive. I only felt lost and unproductive for minutes and now it seems natural to use and get around in. I've got <a href="/posts/2007/06/more-scheming-with-haskell">ElSchemo</a> set as the default scheme, and running inferior processes interactively is an absolute dream. My scheme doesn't have readline support (which bothers me to the point where I've thought about adding it just so I can use the thing) but when running it under Emacs there's absoutely no need for anything like that since I have the power of my editor when interacting with any program.

There has been a considerable amount of work done to aide in Rails development which makes Emacs especially comfortable for me. I now know why people have Emacs windows maximized on their screens. Because of its age Emacs is a handy window manager that basically eliminates the need for anything like <a href="http://en.wikipedia.org/wiki/GNU_Screen">GNU screen</a> or a window manager such as <a href="http://www.nongnu.org/ratpoison/">Rat poison</a> (which is great if you like screen), just maximize that Emacs "frame" or open one for each display and get to it. If you need a shell you just split the window and run your shell, when you're done you can easily switch back to your editing and your shell will wait in the background until you need it again. With rails-mode on I can run script/console (or switch back to it) with <code>C-c C-c s c</code>. My zsh alias for script/console is <code>sc</code> and I have other similarly succint ones for other stuff, so I took right to the shortcuts for all the handy things that I no longer have to switch applications to do:

 * <code>C-c C-c .</code> – Run the tests for this file. If I'm in a unit test it runs it, if I'm in the model it runs the corresponding unit tests.
 * <code>C-c C-c w s</code> – Run the web server (script/server).
 * <code>C-c C-c t</code> – Run tests. The last value entered is the default choice, and the options are analogous to the rake test:* tasks.
 * and so on...

The Rails integration is simply stunning and I could go on all day about the mature indentation support, the Speedbar and what not, but I won't. I'm fairly sure that Emacs has taken the place of TextMate as my weapon of choice now, on all platforms. And after only 2 days!

Anyway, the point of all this was to mention the one thing that's missing: support for <a href="/posts/2006/02/intelligent-migration-snippets-0_1-for-textmate">intelligent snippets</a> which insert text at more than one point in the document (well, they appear to do so). I don't have any E-Lisp-fu to break out and solve the deficiency but if it ever bugs me enough I might try implementing it for Emacs one day. If they were useful to me outside of writing migrations I might have more incentive to do so, but I guess they aren't useful in normal editing situations (maybe I just haven't recognised the need).

