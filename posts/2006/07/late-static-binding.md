---
Title: Late static binding
Author: Sami Samhuri
Date: 19th July, 2006
Timestamp: 2006-07-19T10:23:00-07:00
Tags: php, coding, coding, php
---

*Update: This has <a href="http://www.php.net/~derick/meeting-notes.html#late-static-binding-using-this-without-or-perhaps-with-a-different-name">been discussed</a> and will be uh, sort of fixed, in PHP6. You'll be able to use static::my_method() to get the real reference to self in class methods. Not optimal, but still a solution I guess.*

As colder on ##php (freenode) told me today, class methods in PHP don't have what they call late static binding. What's that? It means that this code:

<pre>
<code>
class Foo
{
  public static function my_method()
  {
    echo "I'm a " . get_class() . "!\n";
  }
}

class Bar extends Foo
{}

Bar::my_method();
</code>
</pre>

outputs "I'm a Foo!", instead of "I'm a Bar!". That's not fun.

Using <code>__CLASS__</code> in place of <code>get_class()</code> makes zero difference. You end up with proxy methods in each subclass of Foo that pass in the real name of the calling class, which sucks.

<pre>
<code>
class Bar extends Foo
{
  public static function my_method()
  {
    return parent::my_method( get_class() );
  }
}
</code>
</pre>

I was told that they had a discussion about this on the internal PHP list, so at least they're thinking about this stuff. Too bad PHP5 doesn't have it. I guess I should just be glad I won't be maintaining this code.

The resident PHP coder said "just make your code simpler", which is what I was trying to do by removing duplication. Too bad that plan sort of backfired. I guess odd things like this are where PHP starts to show that OO was tacked on as an after-thought.

