---
Title: Recent Ruby and Rails Regales
Author: Sami Samhuri
Date: 28th June, 2007
Timestamp: 2007-06-28T12:23:00-07:00
Tags: rails, rails on rules, regular expressions, ruby, sake, secure associations, regex
---

Some cool Ruby and [the former on] Rails things are springing up and I haven't written much about the two Rs lately, though I work with them daily.

### Rails on Rules ###

My friend <a href="http://jim.roepcke.com/">Jim Roepcke</a> is researching and implementing a plugin/framework designed to work with Rails called <a href="http://willingtofail.com/research/rules/index.html">Rails on Rules</a>.  His inspiration is <a href="http://developer.apple.com/documentation/WebObjects/Developing_With_D2W/Architecture/chapter_3_section_13.html">the rule system</a> from <a href="http://developer.apple.com/documentation/WebObjects/WebObjects_Overview/index.html">WebObjects'</a> <a href="http://developer.apple.com/documentation/WebObjects/Developing_With_D2W/Introduction/chapter_1_section_1.html">Direct to Web</a>.  He posted a good <a href="http://willingtofail.com/research/rules/example.html">example</a> for me, but this baby isn't just for template/view logic.  If some of the Rails conventions were specified in a default set of rules which the developer could further customize then you basically have a nice way of doing things that you would otherwise code by hand.  I think it would be a boon for the <a href="http://activescaffold.com/">ActiveScaffold</a> project.  We're meeting up to talk about this soon and I'll have more to say after then, but it sounds pretty cool.

### Sake Bomb! ###

I've noticed a trend among some <a href="http://www.railsenvy.com/2007/6/11/ruby-on-rails-rake-tutorial">recent posts</a> about Rake: the authors keep talking about booze.  Are we nothing but a bunch of booze hounds?!  Well one can hope.  There's some motivation to learn more about a tool, having more time to drink after work.  This week <a href="http://ozmm.org/">Chris Wanstrath</a> dropped a <a href="http://errtheblog.com/post/6069">Sake Bomb</a> on the Ruby community.  Like piston, sake is something you can just pick up and use instantly.  Interestingly the different pronunciations of <code>rake</code> and <code>sake</code> help me from confusing the two on the command line... so far.

### Secure Associations (for Rails) ###

<a href="http://tuples.us/">Jordan McKible</a> released the <a href="http://tuples.us/2007/06/28/secure_associations-plugin-gets-some-love/">secure_associations</a> plugin. It lets you protect your models' *_id attributes from mass-assignment via <code>belongs_to_protected</code> and <code>has_many_protected</code>. It's a mild enhancement, but an enhancement nonetheless. This is useful to enough people that it should be in Rails proper.

### Regular expressions and strings with embedded objects ###

<a href="http://t-a-w.blogspot.com/">taw</a> taught me a <a href="http://t-a-w.blogspot.com/2007/06/regular-expressions-and-strings-with.html">new technique for simplifying regular expressions</a> by transforming the text in a reversible manner.  In one example he replaced literal strings in SQL - which are easily parsed via a regex - with what he calls embedded objects.  They're just tokens to identify the temporarily removed strings, but the important thing is that they don't interfere with the regexes that operate on the other parts of the SQL, which would have been very difficult to get right with the strings inside it.  If I made it sound complicated just read the post, he explains it well.

If you believe anything <a href="http://steve-yegge.blogspot.com/2007/06/rich-programmer-food.html">Steve Yegge</a> says then that last regex trick may come in handy for Q&#38;D parsing in any language, be it Ruby, NBL, or whataver.

