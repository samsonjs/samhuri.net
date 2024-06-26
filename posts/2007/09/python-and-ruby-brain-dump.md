---
Title: Python and Ruby brain dump
Author: Sami Samhuri
Date: 26th September, 2007
Timestamp: 2007-09-26T03:34:00-07:00
Tags: python, ruby
---

It turns out that <a href="http://dev.laptop.org/git?p=security;a=blob;f=bitfrost.txt">Python is the language of choice on the OLPC</a>, both for implementing applications and exposing to the users.  There is a view source key available.  I think Python is a great choice.

I've been using Ruby almost exclusively for over a year but the last week I've been doing a personal project in Python using <a href="https://storm.canonical.com/">Storm</a> (which is pretty nice btw) and <a href="http://excess.org/urwid/">urwid</a>.  I'm remembering why I liked Python when I first learned it a few years ago.  It may not be as elegant as Ruby, conceptually, but it sure is fun to code in.  It really is executable pseudo-code for the most part.

I'm tripping up by typing <code>obj.setattr^W^Wsetattr(obj</code> and <code>def self.foo^W^Wfoo(self</code> but other than that I haven't had trouble switching back into Python.  I enjoy omitting <code>end</code> statements.  I enjoy Python's lack of curly braces, apart from literal dicts.  I hate the fact that in Emacs, in python-mode, <code>indent-region</code> only seems to piss me off (or <code>indent-*</code> really, anything except TAB).  I really like list comprehensions.

The two languages are so similar that at a glance you may think there are only shallow differences between the languages.  People are always busy arguing about the boring things that every language can do (web frameworks anyone?) while ignoring the interesting differences between the languages and their corresponding ecosystems.

Python has more libraries available as it's the more popular language.  The nature of software written in the languages is different though as the languages themselves are quite different.

Ruby has some Perl-ish features that make it a good sysadmin scripting language, hence we see nice tools such as <a href="http://www.capify.org/">Capistrano</a> and <a href="http://god.rubyforge.org/">god</a> written in Ruby and used by projects written in other languages.

Python is faster than Ruby so it is open to classes of software that would be cumbersome in Ruby.  Source control, for example.  You can write a slow SCM in Python though, as <a href="http://bazaar-vcs.org/">Bazaar</a> demonstrates.  You could probably write a passable one in Ruby as well.  If it didn't quite perform well enough right now it should fare better in a year's time.

I still think that my overall joy is greater when using Ruby, but if Ruby isn't the right tool for the job I'll probably look to Python next (unless some feature of the problem indicates something else would be more appropriate).  The reason I chose Python for my current project is because of libs like urwid and I needed an excuse to try out Storm and brush up on my Python. ;-)

