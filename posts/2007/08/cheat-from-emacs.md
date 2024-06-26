---
Title: Cheat from Emacs
Author: Sami Samhuri
Date: 9th August, 2007
Timestamp: 2007-08-09T18:56:00-07:00
Tags: Emacs
---

*Update: I had inadvertently used <code>string-join</code>, a function provided by something in my ~/.emacs.d. The script has been updated to work with a vanilla Emacs (23, but should work with 22 as well).*

*Update #2 [2007.08.10]: Editing cheats and diffs have been implemented.*

*Update #3 [2007.08.21]: I <a href="/posts/2007/08/cheat-productively-in-emacs">added completion</a> to cheat.el. The file linked on this page is still the latest version.*

We all know and love <a href="http://cheat.errtheblog.com/">cheat</a>.  Now you can cheat without leaving Emacs (and without using a shell in Emacs).

Just save <a href="/f/cheat.el">cheat.el</a> in ~/.emacs.d and then <code>(require 'cheat)</code> in your ~/.emacs.  I also bind <code>C-z C-c</code> to <code>cheat</code>, you may want to do something similar.


<del>You can't do everything you can do with cheat on the command line yet</del>, and for most of the commands the cheat command itself is used. *Now you can do everything the command line client does from within Emacs, though you may need to revert to using <code>cheat-command</code> (described below).*

Here's the rundown:

*Any time you enter a cheat name there are both completion and a cheat-specific history available.  Unless you are adding a new cheat.  In that case you should use a new, unique name (duh).*

 * <code>cheat</code> – Lookup a cheat sheet interactively (<code>cheat &lt;name&gt;</code>)
 * <code>cheat-sheets</code> – List all cheat sheets (<code>cheat sheets</code>)
 * <code>cheat-recent</code> – List recently added cheat sheets (<code>cheat recent</code>)
 * <code>cheat-versions</code> – List versions of a cheat sheet interactively (<code>cheat &lt;name&gt; --versions</code>)
 * <code>cheat-clear-cache</code> – Clear all cached sheets.
 * <code>cheat-add-current-buffer</code> – Add a new cheat using the specified name and the contents of the current buffer as the body. (<code>cheat &lt;name&gt; --add</code>)
 * <code>cheat-edit</code> – Retrieve a fresh copy of the named cheat and display the body in a buffer for editing.
 * <code>cheat-save-current-buffer</code> – Save the current cheat buffer, which should be named <code>*cheat-&lt;name&gt;*</code>.
 * <code>cheat-diff</code> – Show the diff between the current version and the given version of the named cheat. If the version given is of the form <em>m:n</em> then show the diff between versions <em>m</em> and <em>n</em>. (<code>cheat &lt;name&gt; --diff &lt;version&gt;</code>)
 * <code>cheat-command</code> – Pass any arguments you want to cheat interactively.

*(Added)* <del>I may add support for <code>--diff</code> and <code>--edit</code> in the future.</del>

Please do send me your patches so everyone can benefit from them.

