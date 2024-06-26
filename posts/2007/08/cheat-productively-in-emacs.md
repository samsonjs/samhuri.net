---
Title: Cheat productively in Emacs
Author: Sami Samhuri
Date: 21st August, 2007
Timestamp: 2007-08-21T11:20:00-07:00
Tags: Emacs
---

By now you may have heard about <a href="http://cheat.errtheblog.com/">cheat</a>, the command line cheat sheet collection that's completely open to editing, wiki style.  A couple of weeks ago I posted <a href="/posts/2007/08/cheat-from-emacs">cheat.el</a> which allows one to cheat from within Emacs.  There's an update.  However, before I get to cheat.el there's a small detour.

Cheat is not just about Ruby!  A few examples of cheats available are:

 * bash and zsh
 * $EDITOR (if you happen to like e, TextMate, vi, emacs, RadRails, ...)
 * GNU screen
 * Version control (darcs, svn, git)
 * Firebug
 * Markdown and Textile
 * Oracle and MySQL
 * Regular expressions
 * and of course Ruby, Rails, Capistrano, etc.

As of today, Aug-21 2007, the count is at <strong>166 cheat sheets</strong> so there's probably something there that you'll want to look up from the command line or Emacs sometime.  That's enough stroking cheat's ego, but there seems to be a notion that cheat is only for Ruby stuff and that's really not the case.

So what's new in this version of cheat.el?  <strong>Completion!</strong>  The only thing that bothered me about cheating in Emacs was the lack of completion.  It now has completion, thus it is now perfect. :)  In all likeliness this won't be the last release, but I can't really foresee adding anything else to it in the near future.  Enjoy!

Download it now: <a href="/f/cheat.el">cheat.el</a>

For any newcomers, just drop this into <code>~/.emacs.d</code>, <code>~/.elisp</code>, or any directory in your <code>load-path</code> and then <code>(require 'cheat)</code>.  For more info check the <a href="/posts/2007/08/cheat-from-emacs">original article</a> for a rundown on the cheat commands.

