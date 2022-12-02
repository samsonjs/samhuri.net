---
Title: ActiveRecord::Base.find_or_create and find_or_initialize
Author: Sami Samhuri
Date: 11th April, 2007
Timestamp: 2007-04-11T03:24:00-07:00
Tags: activerecord, coding, rails, ruby
---

I've extended ActiveRecord with `find_or_create(params)` and `find_or_initialize(params)`. Those are actually just wrappers around `find_or_do(action, params)` which does the heavy lifting.

They work exactly as you'd expect them to work with possibly one gotcha. If you pass in an `id` attribute then it will just find that record directly. If it fails it will try and find the record using the other params as it would have done normally.

Enough chat, here's the self-explanatory code:

<pre class="line-numbers">1
2
3
4
</pre>
<pre><code><span class="c"># extend ActiveRecord::Base with find_or_create and find_or_initialize.</span>
<span class="co">ActiveRecord</span>::<span class="co">Base</span>.class_eval <span class="r">do</span>
  include <span class="co">ActiveRecordExtensions</span>
<span class="r">end</span></code></pre>


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
16
17
18
19
<strong>20</strong>
21
22
23
24
25
26
27
28
29
<strong>30</strong>
31
32
33
34
35
36
37
38
39
<strong>40</strong>
41
</pre>
<pre><code><span class="r">module</span> <span class="cl">ActiveRecordExtensions</span>
  <span class="r">def</span> <span class="pc">self</span>.included(base)
    base.extend(<span class="co">ClassMethods</span>)
  <span class="r">end</span>

  <span class="r">module</span> <span class="cl">ClassMethods</span>
    <span class="r">def</span> <span class="fu">find_or_initialize</span>(params)
      find_or_do(<span class="s"><span class="dl">'</span><span class="k">initialize</span><span class="dl">'</span></span>, params)
    <span class="r">end</span>

    <span class="r">def</span> <span class="fu">find_or_create</span>(params)
      find_or_do(<span class="s"><span class="dl">'</span><span class="k">create</span><span class="dl">'</span></span>, params)
    <span class="r">end</span>

    private

    <span class="c"># Find a record that matches the attributes given in the +params+ hash, or do +action+</span>
    <span class="c"># to retrieve a new object with the given parameters and return that.</span>
    <span class="r">def</span> <span class="fu">find_or_do</span>(action, params)
      <span class="c"># if an id is given just find the record directly</span>
      <span class="pc">self</span>.find(params[<span class="sy">:id</span>])

    <span class="r">rescue</span> <span class="co">ActiveRecord</span>::<span class="co">RecordNotFound</span> =&gt; e
      attrs = {}     <span class="c"># hash of attributes passed in params</span>

      <span class="c"># search for valid attributes in params</span>
      <span class="pc">self</span>.column_names.map(&amp;<span class="sy">:to_sym</span>).each <span class="r">do</span> |attrib|
        <span class="c"># skip unknown columns, and the id field</span>
        <span class="r">next</span> <span class="r">if</span> params[attrib].nil? || attrib == <span class="sy">:id</span>

        attrs[attrib] = params[attrib]
      <span class="r">end</span>

      <span class="c"># no valid params given, return nil</span>
      <span class="r">return</span> <span class="pc">nil</span> <span class="r">if</span> attrs.empty?

      <span class="c"># call the appropriate ActiveRecord finder method</span>
      <span class="pc">self</span>.send(<span class="s"><span class="dl">"</span><span class="k">find_or_</span><span class="il"><span class="dl">#{</span>action<span class="dl">}</span></span><span class="k">_by_</span><span class="il"><span class="dl">#{</span>attrs.keys.join(<span class="s"><span class="dl">'</span><span class="k">_and_</span><span class="dl">'</span></span>)<span class="dl">}</span></span><span class="dl">"</span></span>, *attrs.values)
    <span class="r">end</span>
  <span class="r">end</span>
<span class="r">end</span></code></pre>

