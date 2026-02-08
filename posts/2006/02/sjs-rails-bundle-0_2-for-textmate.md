---
Title: "SJ's Rails Bundle 0.2 for TextMate"
Author: Sami Samhuri
Date: "23rd February, 2006"
Timestamp: 2006-02-23T17:18:00-08:00
Tags: textmate, rails, coding, bundle, macros, rails, snippets, textmate
---

Everything that you've seen posted on my blog is now available in one bundle. Snippets for Rails database migrations and assertions are all included in this bundle.

There are 2 macros for class-end and def-end blocks, bound to <strong>⌃C</strong> and <strong>⌃D</strong> respectively. Type the class or method definition, except for <code>class</code> or <code>def</code>, and then type the keyboard shortcut and the rest is filled in for you.

I use an underscore to denote the position of the cursor  in the following example:

```ruby
method(arg1, arg2_)
```

Typing <strong>⌃D</strong> at this point results in this code:

```ruby
def method(arg1, arg2)
  _
end
```

There is a list of the snippets in Features.rtf, which is included in the disk image. Of course you can also browse them in the Snippets Editor built into TextMate.

Without further ado, here is the bundle:

<p style="text-align: center;"><img src="/images/download.png" title="Download" alt="Download"> <a href="/f/SJRailsBundle-0.2.dmg">Download SJ's Rails Bundle 0.2</a></p>

This is a work in progress, so any feedback you have is very helpful in making the next release better.

