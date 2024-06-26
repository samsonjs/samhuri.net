---
Title: Thoughts on Arc
Author: Sami Samhuri
Date: 19th February, 2008
Timestamp: 2008-02-19T03:26:00-08:00
Tags: lisp arc
---

*NB: This is just a braindump.  There's nothing profound or particularly insightful in this post.*

You may have heard that <a href="http://www.paulgraham.com/">Paul Graham</a> recently released his pet dialect of Lisp: <a href="http://arclanguage.org/">Arc</a>.  It's a relatively small language consisting of just 4500 lines of code.  In just under <a href="http://arclanguage.com/install">1200 lines</a> of <a href="http://www.plt-scheme.org/">PLT Scheme</a> the core of Arc is defined.  The rest of the language is written in Arc itself.  The heart of that is a file arc.arc, weighing in at 1500 lines.  The remaining 1000-1300 lines are spread between libraries, mainly for writing web apps: html.arc, srv.arc, app.arc, and a few others.

I'm not going to go into great detail, but Arc is a fun language.  You can read all the code in one or two sittings and start hacking on it in no time.  The code is simple where simple gets the job done and if you can follow <a href="http://mitpress.mit.edu/sicp/">SICP</a> then you should understand it with relative ease (assuming you're somewhat familiar with Lisp).

### Parsing, Markdown ###

I'm writing a simple parser combinators library (loosely modeled on <a href="http://legacy.cs.uu.nl/daan/parsec.html">Parsec</a>) in order to write a nice Markdown implementation.  Overkill?  Indeed.  Parsec is a wonderful library and it is written beautifully.  If I end up with something 1/2 as powerful and 1/10th as beautiful I'll be pleased.  This was all in order to beef up the version of Markdown bundled with Arc so I could write a basic wiki.  I've been <a href="http://arclanguage.org/item?id=1456">beaten</a> to the punch, <a href="http://arclanguage.org/item?id=2037">twice</a>!  Perhaps I'll retrofit Markdown onto jgc's wiki once I get something decent finished.

### Brevity and Innovation ###

The brevity of Arc is both a blessing and a curse.  On the one hand it makes for a very hacking-friendly language.  It's easy/fun to try things in the REPL and write throwaway code for learning purposes.  Paul's wanton removal of extraneous parentheses is a great boon.  On the flip side Arc code can be a little cryptic at a first glance.  While reading code there's a small period of time where you have to figure out what the short names are and what they do, but because the language is so small it's utterly trivial to grep or read the source and find out exactly how everything fits together and get the context you need.  Once you're familiar with the domain then the terse names not only make sense, but they make the interesting parts of the code stand out more.  I want to emphasize the pleasure of using Arc to learn.  I think that Paul is on to something with the general brevity and simple nature of Arc.

Some interesting ways that Paul has reduced code is by introducing new intra-symbol operators.  Besides the usual backquote/quasiquote and comma/unquote translations, several other special characters are translated when they appear within/around symbols.

There is the colon/compose operator that reduces code such as: <code>(sym (string "pre-" something "-suffix"))</code> to <code>(sym:string "pre-" something "-suffix")</code>.  It can help with car/cdr chains without defining monstrosities such as <code>cadadr</code>, though whether <code>(cadadr ...)</code> is better than <code>(cadr:cadr ...)</code> is better than <code>(car (cdr (car (cdr ...))))</code> is up to you.

My favourite is the tilde to mean logical negation: <code>no</code> in Arc, <code>not</code> in most other languages.  It doesn't shorten code much but it helps with parens.  <code>(if (no (empty str)) ...)</code> becomes <code>(if (~empty str) ...)</code>.  Not much to be said about it, but it reads very nicely in code.

Some newer ones are the dot and exclamation point to aide in the composition of functions requiring arguments.  I won't go into detail as their use is trivial.  If you're interested read <a href="http://arclanguage.org/item?id=2166">Paul's explanation</a> of them.

### Web programming ###

Paul has touted Arc as a good web programming language, most notably in his <a href="http://www.paulgraham.com/arcchallenge.html">Arc Challenge</a> that caused a minor stir in a few blogs and on Reddit.  I'm writing a small web app for myself in Arc.  I may host it somewhere public when it's useable.  It's a somewhat <a href="http://pastie.caboo.se/">pastie</a>-like app specifically for storing/sharing solutions to problems over at <a href="http://projecteuler.net/">Project Euler</a>, which I recently started tackling.  "What's wrong with saving the code on your hard disk without a web app?", you ask? It doesn't give me an excuse to try Arc as a web language. ;-)

So far I find that Arc is quite a nice web language.  With the handy HTML tag library you can generate 90s-style, quirks-mode-compliant tag soup in a blink.  I haven't had trouble producing HTML 4.01 (strict) that validates.  There's no need for a template language or partials (à la Rails), you just compose tags-as-sexps using Arc itself.  This turns out to be quite elegant, even if somewhat reminiscent of my first forays into web programming with PHP.  I don't feel as if I'm writing a web app so much as I'm writing an app that happens to present its UI in HTML.  <em>(I'm reminded a little of <a href="http://webpy.org/">web.py</a>, which I enjoy as the antithesis of Rails.)</em>  I suppose it takes some discipline to separate your logic &amp; design when everything's mixed in the same file, but there's nothing stopping you from separating the logic and views into their own files if you really prefer to do it that way.

There's no distinction between GET and POST params.  This surprised me, but then I thought about it and it's not a big deal for most apps, imo.

The app I'm writing is standard CRUD stuff so I haven't done anything cool using continuations yet.  I plan to use call/cc for backtracking in my parser, but I'm still a ways from implementing that kind of functionality!

### Non-conclusion ###

I feel as though I should have a conclusion, but I don't.  I've only been using Arc for a short time.  It feels nice.  I think Paul is doing a good job on the design by keeping it small, compact, and simple.  Seeing as it's still in its infancy it's just a toy for me, but a toy with some decent potential.  And hopefully an impact on other Lisps.  Common Lisp may have industrial implementations and a 1500 page spec, but Arc is more fun and hackable.  More so than Scheme, too.  I think Arc has out-Schemed Scheme.

