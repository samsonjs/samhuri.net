---
Title: A Scheme parser in Haskell: Part 1
Author: Sami Samhuri
Date: 3rd May, 2007
Timestamp: 2007-05-03T00:47:50-07:00
Tags: coding, haskell
---

From <a href="http://halogen.note.amherst.edu/~jdtang/scheme_in_48/tutorial/firststeps.html">Write Yourself a Scheme in 48 hours</a>:

<blockquote>
  <p>Basically, a monad is a way of saying "there's some extra information attached to this value, which most functions don't need to worry about". In this example, the "extra information" is the fact that this action performs IO, and the basic value is nothing, represented as "()". Monadic values are often called "actions", because the easiest way to think about the IO monad is a sequencing of actions that each might affect the outside world.</p>
</blockquote>

I really like this tutorial. I'm only on part 3.3 of 12, <a href="http://halogen.note.amherst.edu/~jdtang/scheme_in_48/tutorial/parser.html">parsing</a>, but I'm new to Haskell so I'm learning left, right & centre. The exercises are taking me hours of reading and experimenting, and it's lots of fun! ghc's errors are usually quite helpful and of course ghci is a big help as well.

I'm going to explain one of the exercises because converting between the various syntax for dealing with monads wasn't plainly obvious to me. Perhaps I wasn't paying enough attention to the docs I read. In any case if you're interested in Haskell at all, I recommend the tutorial and if you're stuck on exercise 3.3.1 like I was then come on back here. Whether you're following the tutorial or not the point of this post should stand on its own with a basic knowledge of Haskell.

Last night I rewrote <code>parseNumber</code> using <code>do</code> and <code>&gt;&gt;=</code> (bind) notations (ex. 3.3.1). Here's <code>parseNumber</code> using the <code>liftM</code> method given in the tutorial:

<pre><code>parseNumber :: Parser LispVal
parseNumber :: liftM (Number . read) $ many1 digit
</code></pre>
Okay that's pretty simple right? Let's break it down, first looking at the right-hand side of the <code>$</code> operator, then the left.

 * <code>many1 digit</code> reads as many decimal digits as it can.
 * <code>Number . read</code> is a <a href="http://en.wikipedia.org/wiki/Function_composition_(computer_science%29">function composition</a> just like we're used to using in math. It applies <code>read</code> to its argument, then applies <code>Number</code> to that result.
 * <code>liftM</code> is concisely and effectively defined <a href="http://members.chello.nl/hjgtuyl/tourdemonad.html#liftM">elsewhere</a>, and I'll borrow their description:

<blockquote>
  <p><code>liftM f m</code> lets a non-monadic function <code>f</code> operate on the contents of monad <code>m</code></p>
</blockquote>

<code>liftM</code>'s type is also quite telling: <code>liftM :: (Monad m) =&gt; (a -&gt; b) -&gt; (m a -&gt; m b)</code>

In a nutshell <code>liftM</code> turns a function from <code>a</code> to <code>b</code> to a function from a monad containing <code>a</code> to a monad containing <code>b</code>.

That results in a function on the left-hand side of <code>$</code>, which operates on and outputs a monad. The content of the input monad is a <code>String</code>. The content of the output monad is a <code>LispVal</code> (defined earlier in the tutorial). Specifically it is a <code>Number</code>.

The <code>$</code> acts similar to a pipe in <code>$FAVOURITE_SHELL</code>, and is right associative which means the expression on the right is passed to the expression (function) on the left. It's exactly the same as <code>(liftM (Number . read)) (many1 digit)</code> except it looks cleaner. If you know LISP or Scheme (sadly I do not) then it's analogous to the <code>apply</code> function.

So how does a Haskell newbie go about re-writing that using other notations which haven't even been explained in the tutorial? Clearly one must search the web and read as much as they can until they understand enough to figure it out (which is one thing I like about the tutorial). If you're lazy like me, here are 3 equivalent pieces of code for you to chew on. <code>parseNumber</code>'s type is <code>Parser LispVal</code> (Parser is a monad).


Familiar <code>liftM</code> method:
<pre><code>parseNumber -&gt; liftM (Number . read) $ many1 digit
</code></pre>

Using <code>do</code> notation:
<pre><code>parseNumber -&gt; do digits &lt;- many1 digit
                  return $ (Number . read) digits
</code></pre>
If you're thinking "Hey a <code>return</code>, I know that one!" then the devious masterminds behind Haskell are certainly laughing evilly right now. <code>return</code> simply wraps up it's argument in a monad of some sort. In this case it's the <code>Parser</code> monad. The <code>return</code> part may seem strange at first. Since <code>many1 digit</code> yields a monad why do we need to wrap anything? The answer is that using <code>&lt;-</code> causes <code>digits</code> to contain a <code>String</code>, stripped out of the monad which resulted from <code>many1 digit</code>. Hence we no longer use <code>liftM</code> to make <code>(Number . read)</code> monads, and instead need to use <code>return</code> to properly wrap it back up in a monad.

In other words <code>liftM</code> eliminates the need to explicitly re-monadize the contents as is necessary using <code>do</code>.


Finally, using <code>&gt;&gt;=</code> (bind) notation:
<pre><code>parseNumber -&gt; many1 digit &gt;&gt;= \digits -&gt;
               return $ (Number . read) digits
</code></pre>
At this point I don't think this warrants much of an explanation. The syntactic sugar provided by <code>do</code> should be pretty obvious. Just in case it's not, <code>&gt;&gt;=</code> passes the contents of its left argument (a monad) to the <em>function</em> on its right. Once again <code>return</code> is needed to wrap up the result and send it on its way.

When I first read about Haskell I was overwhelmed by not knowing anything, and not being able to apply my previous knowledge of programming to <em>anything</em> in Haskell. One piece of syntax at a time I am slowly able to understand more of the Haskell found <a href="http://www.google.com/url?sa=t&amp;ct=res&amp;cd=2&amp;url=http%3A%2F%2Fblog.moertel.com%2Farticles%2F2005%2F03%2F25%2Fwriting-a-simple-ruby-evaluator-in-haskell&amp;ei=Q1A6RtWPLZvYigGZsMjxAQ&amp;usg=AFrqEzdrRepwsuNaQqe1gHYjHvqdCDKfoA&amp;sig2=0qNTIOB9XxeZRqKR7J61Iw">in the wild</a>.

I'm currently working on ex. 3.3.4, which is parsing <a href="http://www.schemers.org/Documents/Standards/R5RS/HTML/r5rs-Z-H-9.html#%_sec_6.3.5">R5RS compliant numbers</a> <em>(e.g. #o12345670, #xff, #d987)</em>. I'll probably write something about that once I figure it out, but in the meantime if you have any hints I'm all ears.

*Update #1: I should do more proof-reading if I'm going to try and explain things. I made some changes in wording.*

