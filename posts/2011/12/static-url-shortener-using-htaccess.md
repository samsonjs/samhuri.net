---
Title: A Static URL Shortener Using .htaccess
Author: Sami Samhuri
Date: 10th December, 2011
Timestamp: 2011-12-10T22:29:09-08:00
Tags: s42.ca, url, shortener, samhuri.net, url shortener
---

This blog is statically generated. A few Ruby and Node.js scripts along with a Makefile and some duct tape hold it all together. All of [samhuri.net is on Github][GH] if you want to take a look. Most of it is quite minimal, sometimes to a fault. Little improvements are made here and there and the most recent one is a neat [.htaccess][htaccess-wiki] hack. I want to automatically announce new posts on Twitter so short URLs are in order.

I try to strike a reasonable balance between writing everything for this site myself and using libraries. A quick look at a few short URL projects was enough to see they weren't what I was looking for. They were all database backed servers. Comments on this blog are served up dynamically but everything else is static and I try to avoid dynamic behaviour when possible. Comments are moving to a more static system sometime. Anyway I registered the domain [s42.ca][s42] and nabbed [an algorithm for creating the short codes from Jonathan Snook][snook] before diving into TextMate to implement my idea.

The result is about two dozen additional lines of Ruby in my static generator, and a command added to a Makefile. The Ruby code generates a short URL for each of my blog posts and then creates a [RewriteRule][RewriteRule] directive to redirect that short codes to each corresponding blog post. Then the directives are dumped into a .htaccess file which is [scp][scp]'d to s42.ca when I run `make publish_blog`.

<script src="https://gist.github.com/1458844.js" integrity="iNDnkp2oj64ircMerEnfkbzlYeoUammDd8nZRZfUl5KVhbXEdNDaIR3Gj71L/x2Y" crossorigin="anonymous"></script>

I think this is a pretty neat hack and have not seen this technique anywhere else so I thought I'd share it. Maybe someone else will find it interesting or useful for their blog. How far it scales won't be a concern until I have thousands of posts. That sounds like a good problem for future Sami to solve should it arise.

[GH]: https://github.com/samsonjs/samhuri.net
[htaccess-wiki]: http://en.wikipedia.org/wiki/Htaccess
[s42]: http://s42.ca
[snook]: http://snook.ca/archives/php/url-shortener
[RewriteRule]: http://httpd.apache.org/docs/current/mod/mod_rewrite.html#rewriterule
[scp]: http://en.wikipedia.org/wiki/Secure_copy

