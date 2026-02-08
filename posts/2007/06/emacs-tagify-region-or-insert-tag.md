---
Title: "Emacs: tagify-region-or-insert-tag"
Author: Sami Samhuri
Date: "25th June, 2007"
Timestamp: 2007-06-25T15:13:00-07:00
Tags: emacs, tagify
---

After <a href="/posts/2007/06/rtfm">axing</a> half of <a href="/posts/2007/06/emacs-for-textmate-junkies">wrap-region.el</a> I renamed it to <a href="/f/tagify.el">tagify.el</a> and improved it ever so slightly. It's leaner, and does more!

<code>tagify-region-or-insert-tag</code> does the same thing as <code>wrap-region-with-tag</code> except if there is no region it now inserts the opening and closing tags and sets point in between them. I have this bound to <code>C-z t</code>, as I use <code>C-z</code> as my personal command prefix.

<code>&lt;</code> is bound to <code>tagify-region-or-insert-self</code> which really doesn't warrant an explanation.

