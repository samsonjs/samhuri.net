---
Title: Dumping Objects to the Browser in Rails
Author: Sami Samhuri
Date: 15th May, 2007
Timestamp: 2007-05-15T13:38:00-07:00
Tags: rails
Styles: typocode.css
---

Here's an easy way to solve a problem that may have nagged you as it did me. Simply using <code>foo.inspect</code> to dump out some object to the browser dumps one long string which is barely useful except for short strings and the like. The ideal output is already available using the <a href="http://www.ruby-doc.org/stdlib/libdoc/prettyprint/rdoc/index.html"><code>PrettyPrint</code></a> module so we just need to use it.


Unfortunately typing <code><pre><%= PP.pp(@something, '') %></pre></code> to quickly debug some possibly large object (or collection) can get old fast so we need a shortcut.


Taking the definition of <a href="http://extensions.rubyforge.org/rdoc/classes/Object.html#M000020"><code>Object#pp_s</code></a> from the <a href="http://extensions.rubyforge.org/rdoc/">extensions project</a> it's trivial to create a helper method to just dump out an object in a reasonable manner.


<div class="typocode"><div class="codetitle">/app/helpers/application_helper.rb</div><pre><code class="typocode_ruby "><span class="keyword">def </span><span class="method">dump</span><span class="punct">(</span><span class="ident">thing</span><span class="punct">)</span>
  <span class="ident">s</span> <span class="punct">=</span> <span class="constant">StringIO</span><span class="punct">.</span><span class="ident">new</span>
  <span class="constant">PP</span><span class="punct">.</span><span class="ident">pp</span><span class="punct">(</span><span class="ident">thing</span><span class="punct">,</span> <span class="ident">s</span><span class="punct">)</span>
  <span class="ident">s</span><span class="punct">.</span><span class="ident">string</span>
<span class="keyword">end</span></code></pre></div>

Alternatively you could do as the extensions folks do and actually define <code>Object#pp_s</code> so you can use it in your logs or anywhere else you may want to inspect an object. If you do this you probably want to change the <code>dump</code> helper method accordingly in case you decide to change <code>pp_s</code> in the future.


<div class="typocode"><div class="codetitle">lib/local_support/core_ext/object.rb</div><pre><code class="typocode_ruby "><span class="keyword">class </span><span class="class">Object</span>
  <span class="keyword">def </span><span class="method">pp_s</span>
    <span class="ident">pps</span> <span class="punct">=</span> <span class="constant">StringIO</span><span class="punct">.</span><span class="ident">new</span>
    <span class="constant">PP</span><span class="punct">.</span><span class="ident">pp</span><span class="punct">(</span><span class="constant">self</span><span class="punct">,</span> <span class="ident">pps</span><span class="punct">)</span>
    <span class="ident">pps</span><span class="punct">.</span><span class="ident">string</span>
  <span class="keyword">end</span>
<span class="keyword">end</span></code></pre></div>

