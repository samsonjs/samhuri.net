---
Title: Funny how code can be beautiful
Author: Sami Samhuri
Date: 30th April, 2007
Timestamp: 2007-04-30T07:07:00-07:00
Tags: haskell
---

While reading a <a href="http://www.haskell.org/tutorial/index.html">Haskell tutorial</a> I came across the following code for defining the <a href="http://en.wikipedia.org/wiki/Fibonacci_number">Fibonacci numbers</a>:

    fib = 1 : 1 : [ a + b | (a, b) <- zip fib (tail fib) ]

After reading it a few times and understanding how it works I couldn’t help but think how <strong>beautiful</strong> it is. I don’t mean that it’s aesthetically pleasing to me; the beautiful part is the meaning and simplicity. Lazy evaluation is sweet.

<a href="http://www.haskell.org/">Haskell</a> is the most challenging <a href="http://en.wikipedia.org/wiki/Category:Esoteric_programming_languages"><em>real</em></a> language I have tried to wrap my head around. I haven’t done much with any functional languages yet but they are truly fascinating. I’m beginning to understand monads[1] but I’m quite sure I don’t see the whole picture yet.

<a href="http://www.erlang.org/">Erlang</a> looks like it may be more suited to real world apps so I would like to learn that some time. The <a href="http://pragprog.com/">pragmatic</a> guys have a <a href="http://www.pragmaticprogrammer.com/titles/jaerlang/">book</a> on Erlang in the works, and I love every book of theirs which I have read.

Going deeper down the functional rabbit-hole you’ll find things like <a href="http://swik.net/Haskell/del.icio.us+tag%2Fhaskell/A+polyglot+quine+in+Haskell,+OCaml+and+Scheme/41zs">this polyglot quine</a>, which absolutely blows my mind. I used to be impressed by the <a href="http://en.wikipedia.org/wiki/Just_another_Perl_hacker">JAPH</a> sigs or some of the various <a href="http://en.wikipedia.org/wiki/Obfuscated_code">obfuscated</a> contest winners but that first one definitely cleans the rest up with a perfect 10 in geekiness.

[1] The following links have all been helpful while trying to wrap my head around monads.

 * <a href="http://www.haskell.org/tutorial/monads.html">A Gentle Introduction to Haskell</a> (link is directly to chapter 9)
 * <a href="http://web.cecs.pdx.edu/~antoy/Courses/TPFLP/lectures/MONADS/Noel/research/monads.html">What the hell are Monads?</a>
 * <a href="http://en.wikibooks.org/wiki/Programming:Haskell_monads">Monads on WikiBooks</a>
 * <a href="http://www.engr.mun.ca/~theo/Misc/haskell_and_monads.htm">Monads for the Working Haskell Programmer</a>

