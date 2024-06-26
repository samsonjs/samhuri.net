---
Title: Typo and I are friends again
Author: Sami Samhuri
Date: 1st May, 2007
Timestamp: 2007-05-01T21:51:37-07:00
Tags: typo
---

<p>I've been really frustrated with <a href="http://www.typosphere.org/">Typo</a> recently. For some reason changing my <a href="/posts/2007/04/funny-how-code-can-be-beautiful">last post</a> would cause MySQL to timeout and I'd have to kill the rogue ruby process manually before any other changes to the DB would work, instead of hanging for a minute or two then timing out. Luckily I was able to disable the post using the command line client, the bug only manifested itself when issuing an UPDATE with all the fields present. Presumably the body was tripping things up because most other fields are simple booleans, numbers, or very short strings.

Add to that the random HTTP 500 errors which were very noticeable while I was trying to fix that post and I was about to write my own blog or switch to WordPress.

I don't love WP so I decided to just upgrade Typo instead. I was using Typo 2.6, and the current stable version is 4.1. They skipped version 3 to preclude any confusion that may have ensued between Typo v3 and the CMS <a href="http://typo3.com/">Typo3</a>. So it really isn't a big upgrade and it went perfectly. I checked out a new copy of the repo because I had some difficulty getting <code>svn switch --relocate</code> to work, configured the database settings and issued a <code>rake db:migrate</code>, copied my theme over and it all just worked. Bravo Typo team, that's how an upgrade should work.

No more random 500 errors, things seem faster (better caching perhaps), and that troublesome post is troublesome no more. I am happy with Typo again.

