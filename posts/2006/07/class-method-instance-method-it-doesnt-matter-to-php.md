---
Title: Class method? Instance method? It doesn't matter to PHP
Author: Sami Samhuri
Date: 21st July, 2006
Timestamp: 2006-07-21T07:56:00-07:00
Tags: php, coding
---

*Update: This has <a href="http://www.php.net/~derick/meeting-notes.html#method-calls">been discussed</a> for PHP6. A little late, but I guess better than never.*

I made a mistake while I was coding, for shame! Anyway this particular mistake was that I invoked a class method on the wrong class. The funny part was that this method was an instance method in the class which I typed by mistake. In the error log I saw something like "Invalid use of $this in class function."

I knew for a fact I hadn't used $this in a class method, so it was kind of a confusing error. I went to the file in question and found out that it was calling an instance method as a class method. Now that is some crazy shit.

I would fully expect the PHP parser to give me an error like "No class method [foo] in class [blah]", rather than try and execute it as a class method. The syntax is completely different; you use :: to call a class method and -&gt; to call an instance method. And you use the name of a <em>class</em> when you call a class method.

This code:

<pre><code>
class Foo {
  public static function static_fun()
  {
    return "This is a class method!\n";
  }

  public function not_static()
  {
    return "This is an instance method!\n";
  }
}

echo '&lt;pre&gt;';
echo "From Foo:\n";
echo Foo::static_fun();
echo Foo::not_static();
echo "\n";

echo "From \$foo = new Foo():\n";
$foo = new Foo();
echo $foo-&gt;static_fun();
echo $foo-&gt;not_static();
echo '&lt;/pre&gt;';
</code></pre>

Produces:

<pre><code>
From Foo:
This is a class method!
This is an instance method!

From $foo = new Foo():
This is a class method!
This is an instance method!
</code></pre>

What the fuck?! <a href="http://www.php.net/manual/en/language.oop5.static.php">http://www.php.net/manual/en/language.oop5.static.php</a> is lying to everyone.

