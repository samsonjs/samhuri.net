---
Title: test/spec on rails declared awesome, just one catch
Author: Sami Samhuri
Date: 14th June, 2007
Timestamp: 2007-06-14T07:21:00-07:00
Tags: bdd, rails, test/spec
---

This last week I've been getting to know <a href="http://chneukirchen.org/blog/archive/2007/01/announcing-test-spec-0-3-a-bdd-interface-for-test-unit.html">test/spec</a> via <a href="http://errtheblog.com/">err's</a> <a href="http://require.errtheblog.com/plugins/wiki/TestSpecRails">test/spec on rails</a> plugin. I have to say that I really dig this method of testing my code and I look forward to trying out some actual <a href="http://behaviour-driven.org/">BDD</a> in the future.

I did hit a little snag with functional testing though. The method of declaring which controller to use takes the form:


<pre class="line-numbers">
</pre>
<pre><code>use_controller <span class="sy">:foo</span></code></pre>


and can be placed in the <code>setup</code> method, like so:


<pre class="line-numbers">1
2
3
4
5
6
7
8
9
<strong>10</strong>
11
12
13
14
15 
</pre>
<pre><code><span class="c"># in test/functional/sessions_controller_test.rb</span>

context <span class="s"><span class="dl">"</span><span class="k">A guest</span><span class="dl">"</span></span> <span class="r">do</span>
  fixtures <span class="sy">:users</span>

  setup <span class="r">do</span>
    use_controller <span class="sy">:sessions</span>
  <span class="r">end</span>

  specify <span class="s"><span class="dl">"</span><span class="k">can login</span><span class="dl">"</span></span> <span class="r">do</span>
    post <span class="sy">:create</span>, <span class="sy">:username</span> =&gt; <span class="s"><span class="dl">'</span><span class="k">sjs</span><span class="dl">'</span></span>, <span class="sy">:password</span> =&gt; <span class="s"><span class="dl">'</span><span class="k">blah</span><span class="dl">'</span></span>
    response.should.redirect_to user_url(users(<span class="sy">:sjs</span>))
    ...
  <span class="r">end</span>
<span class="r">end</span></code></pre>


This is great and the test will work. But let's say that I have another controller that guests can access:


<pre class="line-numbers">1
2
3
4
5
6
7
8
9
<strong>10</strong>
11
12
13 
</pre>
<pre><code><span class="c"># in test/functional/foo_controller_test.rb</span>

context <span class="s"><span class="dl">"</span><span class="k">A guest</span><span class="dl">"</span></span> <span class="r">do</span>
  setup <span class="r">do</span>
    use_controller <span class="sy">:foo</span>
  <span class="r">end</span>

  specify <span class="s"><span class="dl">"</span><span class="k">can do foo stuff</span><span class="dl">"</span></span> <span class="r">do</span>
    get <span class="sy">:fooriffic</span>
    status.should.be <span class="sy">:success</span>
    ...
  <span class="r">end</span>
<span class="r">end</span></code></pre>


This test will pass on its own as well, which is what really tripped me up. When I ran my tests individually as I wrote them, they passed. When I ran <code>rake test:functionals</code> this morning and saw over a dozen failures and errors I was pretty alarmed. Then I looked at the errors and was thoroughly confused. Of course the action <strong>fooriffic</strong> can't be found in <strong>SessionsController</strong>, it lives in <strong>FooController</strong> and that's the controller I said to use! What gives?!

The problem is that test/spec only creates one context with a specific name, and re-uses that context on subsequent tests using the same context name. The various <code>setup</code> methods are all added to a list and each one is executed, not just the one in the same <code>context</code> block as the specs. I can see how that's useful, but for me right now it's just a hinderance as I'd have to uniquely name each context. "Another guest" just looks strange in a file by itself, and I want my tests to work with my brain not against it.

My solution was to just create a new context each time and re-use nothing. Only 2 lines in test/spec need to be changed to achieve this, but I'm not sure if what I'm doing is a bad idea. My tests pass and right now that's basically all I care about though.

