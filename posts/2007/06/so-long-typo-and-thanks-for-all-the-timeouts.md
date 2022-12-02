---
Title: so long typo (and thanks for all the timeouts)
Author: Sami Samhuri
Date: 8th June, 2007
Timestamp: 2007-06-08T18:01:00-07:00
Tags: mephisto, typo
---

Well for just over a year Typo ran the show. I thought I had worked out most of the kinks with Typo and Dreamhost but the latest problem I ran into was pretty major. I couldn't post new articles. If the stars aligned perfectly and I sacrificed baby animals and virgins, every now and then I could get it to work. Ok, all I really had to do was refresh several dozen times, waiting 1 minute for it to timeout every time, but it sucked nonetheless.

Recently I had looked at converting Typo to Mephisto and it seemed pretty painless. I installed Mephisto and followed whatever instructions I found via Google and it all just worked, with one caveat. The Typo converter for Mephisto only supports Typo's schema version 56, while my Typo schema was at version 61. Rather than migrate backwards I brought Mephisto's Typo converter up to date instead. If you're interested, <a href="/f/mephisto_converters-typo-schema_version_61.patch">download the patch</a>. The patch is relative to vendor/plugins, so patch accordingly.

After running that code snippet to fix my tags, I decided to completely ditch categories in favour of tags. I tagged each new Mephisto article with a tag for each Typo category it had previously belonged to. I fired up <code>RAILS_ENV=production script/console</code> and typed something similar to the following:

<pre class="line-numbers">1
2
3
4
5
6
7 
</pre>
<pre><code>require <span class="s"><span class="dl">'</span><span class="k">converters/base</span><span class="dl">'</span></span>
require <span class="s"><span class="dl">'</span><span class="k">converters/typo</span><span class="dl">'</span></span>
articles = <span class="co">Typo</span>::<span class="co">Article</span>.find(<span class="sy">:all</span>).map {|a| [a, <span class="co">Article</span>.find_by_permalink(a.permalink)] }
articles.each <span class="r">do</span> |ta, ma|
  <span class="r">next</span> <span class="r">if</span> ma.nil?
  ma.tags &lt;&lt; <span class="co">Tag</span>.find_or_create(ta.categories.map(&amp;<span class="sy">:name</span>))
<span class="r">end</span></code></pre>


When I say something similar I mean exactly that. I just typed that from memory so it may not work, or even be syntactically correct. If any permalinks changed then you'll have to manually add new tags corresponding to old Typo categories. The only case where this bit me was when I had edited the title of an article, in which case the new Mephisto permalink matched the new title while the Typo permalink matched the initial title, whatever it was.

I really dig Mephisto so far. It's snappier than Typo and the admin interface is slick. I followed the herd and went with the scribbish theme. Perhaps I'll get around to customizing it sometime, but who knows maybe I'll like a white background for a change.

