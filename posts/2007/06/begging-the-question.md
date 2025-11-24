---
Title: "Begging the question"
Author: Sami Samhuri
Date: "15th June, 2007"
Timestamp: 2007-06-15T11:49:00-07:00
Tags: [english, life, pedantry]
---

I'm currently reading <a href="http://mitpress.mit.edu/sicp/full-text/book/book.html">SICP</a> since it's highly recommended by many people, available for free, and interesting. The fact that I have a little <a href="/posts/2007/06/more-scheming-with-haskell">Scheme interpreter</a> to play with makes it much more fun since I can add missing functionality to it as I progress through the book, thereby learning more Haskell in the process. Yay!

Anyway I was very pleased to see the only correct usage of the phrase "begs the question" I have seen in a while. It's a pet peeve of mine, but I have submitted myself to the fact that the phrase is so oft used to mean "begs for the following question to be asked..." that it may as well be re-defined. In its correct usage the sentence seems to hang there if you try to apply the commonly mistaken meaning to it. That's all very hazy so here's the usage in SICP (emphasis my own):

<blockquote> As a case in point, consider the problem of computing square roots. We can define the square-root function as <img src="/images/ch1-Z-G-4.gif" alt="√x = the y such that y ≥ 0 and y² = x">

This describes a perfectly legitimate mathematical function. We could use it to recognize whether one number is the square root of another, or to derive facts about square roots in general. On the other hand, the definition does not describe a procedure. Indeed, it tells us almost nothing about how to actually find the square root of a given number. It will not help matters to rephrase this definition in pseudo-Lisp:

<pre><code>(define (sqrt x)
  (the y (and (= y 0)
              (= (square y) x))))</code></pre>

<strong>This only begs the question.</strong>
</blockquote>

Begging the question is to assume what one is trying to prove (or here, define) and use that as the basis for a conclusion. Read the <a href="http://en.wikipedia.org/wiki/Begging_the_question">Wikipedia article</a> for a better definition and some nice examples.

