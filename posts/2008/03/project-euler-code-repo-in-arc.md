---
Title: Project Euler code repo in Arc
Author: Sami Samhuri
Date: 3rd March, 2008
Timestamp: 2008-03-03T08:24:00-08:00
Tags: arc, project euler
---

Release early and often. This is a code repo web app for solutions to <a href="http://projecteuler.net/">Project Euler</a> problems.  You can only see your own solutions so it's not that exciting yet (but it scratches my itch... once it highlights syntax).  You can <a href="http://nofxwiki.net:3141/euler">try it out</a> or <a href="https://samhuri.net/euler.tgz">download the source</a>. You'll need an up-to-date copy of <a href="http://arcfn.com/2008/02/git-and-anarki-arc-repository-brief.html">Anarki</a> to untar the source in.  Just run <strong>arc.sh</strong> then enter this at the REPL:


<pre><code>arc&gt; (load "euler.arc")
arc&gt; (esv)
</code></pre>

That will setup the web server on port 3141.  If you want a different port then run <code>(esv 25)</code> (just to mess with 'em).

