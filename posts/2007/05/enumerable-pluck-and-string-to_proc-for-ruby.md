---
Title: Enumurable#pluck and String#to_proc for Ruby
Author: Sami Samhuri
Date: 10th May, 2007
Timestamp: 2007-05-10T16:14:00-07:00
Tags: ruby, extensions
Styles: typocode.css
---

I wanted a method analogous to Prototype's <a href="http://prototypejs.org/api/enumerable/pluck">pluck</a>  and <a href="http://prototypejs.org/api/enumerable/invoke">invoke</a> in Rails for building lists for <a href="http://api.rubyonrails.org/classes/ActionView/Helpers/FormOptionsHelper.html#M000510">options_for_select</a>. Yes, I know about <a href="http://api.rubyonrails.org/classes/ActionView/Helpers/FormOptionsHelper.html#M000511">options_from_collection_for_select</a>.

I wanted something more general that I can use anywhere - not just in Rails - so I wrote one. In a second I'll introduce <code>Enumerable#pluck</code>, but first we need some other methods to help implement it nicely.

First you need <a href="http://pragdave.pragprog.com/pragdave/2005/11/symbolto_proc.html"><code>Symbol#to_proc</code></a>, which shouldn't need an introduction. If you're using Rails you have this already.

<div class="typocode"><div class="codetitle">Symbol#to_proc</div><pre><code class="typocode_ruby "><span class="keyword">class </span><span class="class">Symbol</span>
  <span class="comment"># Turns a symbol into a proc.</span>
  <span class="comment">#</span>
  <span class="comment"># Example:</span>
  <span class="comment">#   # The same as people.map { |p| p.birthdate }</span>
  <span class="comment">#   people.map(&amp;:birthdate)</span>
  <span class="comment">#</span>
  <span class="keyword">def </span><span class="method">to_proc</span>
    <span class="constant">Proc</span><span class="punct">.</span><span class="ident">new</span> <span class="punct">{|</span><span class="ident">thing</span><span class="punct">,</span> <span class="punct">*</span><span class="ident">args</span><span class="punct">|</span> <span class="ident">thing</span><span class="punct">.</span><span class="ident">send</span><span class="punct">(</span><span class="constant">self</span><span class="punct">,</span> <span class="punct">*</span><span class="ident">args</span><span class="punct">)}</span>
  <span class="keyword">end</span>
<span class="keyword">end</span>
</code></pre></div>

Next we define <code>String#to_proc</code>, which is nearly identical to the <code>Array#to_proc</code> method I previously wrote about.

<div class="typocode"><div class="codetitle">String#to_proc</div><pre><code class="typocode_ruby "><span class="keyword">class </span><span class="class">String</span>
  <span class="comment"># Turns a string into a proc.</span>
  <span class="comment">#</span>
  <span class="comment"># Example:</span>
  <span class="comment">#   # The same as people.map { |p| p.birthdate.year }</span>
  <span class="comment">#   people.map(&amp;'birthdate.year')</span>
  <span class="comment">#</span>
  <span class="keyword">def </span><span class="method">to_proc</span>
    <span class="constant">Proc</span><span class="punct">.</span><span class="ident">new</span> <span class="keyword">do</span> <span class="punct">|*</span><span class="ident">args</span><span class="punct">|</span>
      <span class="ident">split</span><span class="punct">('</span><span class="string">.</span><span class="punct">').</span><span class="ident">inject</span><span class="punct">(</span><span class="ident">args</span><span class="punct">.</span><span class="ident">shift</span><span class="punct">)</span> <span class="keyword">do</span> <span class="punct">|</span><span class="ident">thing</span><span class="punct">,</span> <span class="ident">msg</span><span class="punct">|</span>
        <span class="ident">thing</span> <span class="punct">=</span> <span class="ident">thing</span><span class="punct">.</span><span class="ident">send</span><span class="punct">(</span><span class="ident">msg</span><span class="punct">.</span><span class="ident">to_sym</span><span class="punct">,</span> <span class="punct">*</span><span class="ident">args</span><span class="punct">)</span>
      <span class="keyword">end</span>
    <span class="keyword">end</span>
  <span class="keyword">end</span>
<span class="keyword">end</span>
</code></pre></div>

Finally there's <code>Enumerable#to_proc</code> which returns a proc that passes its parameter through each of its members and collects their results. It's easier to explain by example.

<div class="typocode"><div class="codetitle">Enumerable#to_proc</div><pre><code class="typocode_ruby "><span class="keyword">module </span><span class="module">Enumerable</span>
  <span class="comment"># Effectively treats itself as a list of transformations, and returns a proc</span>
  <span class="comment"># which maps values to a list of the results of applying each transformation</span>
  <span class="comment"># in that list to the value.</span>
  <span class="comment">#</span>
  <span class="comment"># Example:</span>
  <span class="comment">#   # The same as people.map { |p| [p.birthdate, p.email] }</span>
  <span class="comment">#   people.map(&amp;[:birthdate, :email])</span>
  <span class="comment">#</span>
  <span class="keyword">def </span><span class="method">to_proc</span>
    <span class="attribute">@procs</span> <span class="punct">||=</span> <span class="ident">map</span><span class="punct">(&amp;</span><span class="symbol">:to_proc</span><span class="punct">)</span>
    <span class="constant">Proc</span><span class="punct">.</span><span class="ident">new</span> <span class="keyword">do</span> <span class="punct">|</span><span class="ident">thing</span><span class="punct">,</span> <span class="punct">*</span><span class="ident">args</span><span class="punct">|</span>
      <span class="attribute">@procs</span><span class="punct">.</span><span class="ident">map</span> <span class="keyword">do</span> <span class="punct">|</span><span class="ident">proc</span><span class="punct">|</span>
        <span class="ident">proc</span><span class="punct">.</span><span class="ident">call</span><span class="punct">(</span><span class="ident">thing</span><span class="punct">,</span> <span class="punct">*</span><span class="ident">args</span><span class="punct">)</span>
      <span class="keyword">end</span>
    <span class="keyword">end</span>
  <span class="keyword">end</span>
<span class="keyword">end</span></code></pre></div>

Here's the cool part, <code>Enumerable#pluck</code> for Ruby in all its glory.

<div class="typocode"><div class="codetitle">Enumerable#pluck</div><pre><code class="typocode_ruby "><span class="keyword">module </span><span class="module">Enumerable</span>
  <span class="comment"># Use this to pluck values from objects, especially useful for ActiveRecord models.</span>
  <span class="comment"># This is analogous to Prototype's Enumerable.pluck method but more powerful.</span>
  <span class="comment">#</span>
  <span class="comment"># You can pluck values simply, like so:</span>
  <span class="comment">#   &gt;&gt; people.pluck(:last_name)  #=&gt; ['Samhuri', 'Jones', ...]</span>
  <span class="comment">#</span>
  <span class="comment"># But with Symbol#to_proc defined this is effectively the same as:</span>
  <span class="comment">#   &gt;&gt; people.map(&amp;:last_name)   #=&gt; ['Samhuri', 'Jones', ...]</span>
  <span class="comment">#</span>
  <span class="comment"># Where pluck's power becomes evident is when you want to do something like:</span>
  <span class="comment">#   &gt;&gt; people.pluck(:name, :address, :phone)</span>
  <span class="comment">#        #=&gt; [['Johnny Canuck', '123 Maple Lane', '416-555-124'], ...]</span>
  <span class="comment">#</span>
  <span class="comment"># Instead of:</span>
  <span class="comment">#   &gt;&gt; people.map { |p| [p.name, p.address, p.phone] }</span>
  <span class="comment">#</span>
  <span class="comment">#   # map each person to: [person.country.code, person.id]</span>
  <span class="comment">#   &gt;&gt; people.pluck('country.code', :id)</span>
  <span class="comment">#        #=&gt; [['US', 1], ['CA', 2], ...]</span>
  <span class="comment">#</span>
  <span class="keyword">def </span><span class="method">pluck</span><span class="punct">(*</span><span class="ident">args</span><span class="punct">)</span>
    <span class="comment"># Thanks to Symbol#to_proc, Enumerable#to_proc and String#to_proc this Just Works(tm)</span>
    <span class="ident">map</span><span class="punct">(&amp;</span><span class="ident">args</span><span class="punct">)</span>
  <span class="keyword">end</span>
<span class="keyword">end</span></code></pre></div>

I wrote another version without using the various <code>#to_proc</code> methods so as to work with a standard Ruby while only patching 1 module.

<div class="typocode"><pre><code class="typocode_ruby "><span class="keyword">module </span><span class="module">Enumerable</span>
  <span class="comment"># A version of pluck which doesn't require any to_proc methods.</span>
  <span class="keyword">def </span><span class="method">pluck</span><span class="punct">(*</span><span class="ident">args</span><span class="punct">)</span>
    <span class="ident">procs</span> <span class="punct">=</span> <span class="ident">args</span><span class="punct">.</span><span class="ident">map</span> <span class="keyword">do</span> <span class="punct">|</span><span class="ident">msgs</span><span class="punct">|</span>
      <span class="comment"># always operate on lists of messages</span>
      <span class="keyword">if</span> <span class="constant">String</span> <span class="punct">===</span> <span class="ident">msgs</span>
        <span class="ident">msgs</span> <span class="punct">=</span> <span class="ident">msgs</span><span class="punct">.</span><span class="ident">split</span><span class="punct">('</span><span class="string">.</span><span class="punct">').</span><span class="ident">map</span> <span class="punct">{|</span><span class="ident">a</span><span class="punct">|</span> <span class="ident">a</span><span class="punct">.</span><span class="ident">to_sym</span><span class="punct">}</span> <span class="comment"># allow 'country.code'</span>
      <span class="keyword">elsif</span> <span class="punct">!(</span><span class="constant">Enumerable</span> <span class="punct">===</span> <span class="ident">msgs</span><span class="punct">)</span>
        <span class="ident">msgs</span> <span class="punct">=</span> <span class="punct">[</span><span class="ident">msgs</span><span class="punct">]</span>
      <span class="keyword">end</span>
      <span class="constant">Proc</span><span class="punct">.</span><span class="ident">new</span> <span class="keyword">do</span> <span class="punct">|</span><span class="ident">orig</span><span class="punct">|</span>
        <span class="ident">msgs</span><span class="punct">.</span><span class="ident">inject</span><span class="punct">(</span><span class="ident">orig</span><span class="punct">)</span> <span class="punct">{</span> <span class="punct">|</span><span class="ident">thing</span><span class="punct">,</span> <span class="ident">msg</span><span class="punct">|</span> <span class="ident">thing</span> <span class="punct">=</span> <span class="ident">thing</span><span class="punct">.</span><span class="ident">send</span><span class="punct">(</span><span class="ident">msg</span><span class="punct">)</span> <span class="punct">}</span>
      <span class="keyword">end</span>
    <span class="keyword">end</span>

    <span class="keyword">if</span> <span class="ident">procs</span><span class="punct">.</span><span class="ident">size</span> <span class="punct">==</span> <span class="number">1</span>
      <span class="ident">map</span><span class="punct">(&amp;</span><span class="ident">procs</span><span class="punct">.</span><span class="ident">first</span><span class="punct">)</span>
    <span class="keyword">else</span>
      <span class="ident">map</span> <span class="keyword">do</span> <span class="punct">|</span><span class="ident">thing</span><span class="punct">|</span>
        <span class="ident">procs</span><span class="punct">.</span><span class="ident">map</span> <span class="punct">{</span> <span class="punct">|</span><span class="ident">proc</span><span class="punct">|</span> <span class="ident">proc</span><span class="punct">.</span><span class="ident">call</span><span class="punct">(</span><span class="ident">thing</span><span class="punct">)</span> <span class="punct">}</span>
      <span class="keyword">end</span>
    <span class="keyword">end</span>
  <span class="keyword">end</span>
<span class="keyword">end</span></code></pre></div>

It's just icing on the cake considering Ruby's convenient block syntax, but there it is. Do with it what you will. You can change or extend any of these to support drilling down into hashes quite easily too.

*<strong>Update #1:</strong> Fixed a potential performance issue in <code>Enumerable#to_proc</code> by saving the results of <code>to_proc</code> in <code>@procs</code>.*

