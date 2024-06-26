---
Title: TextMate: Insert text into self.down
Author: Sami Samhuri
Date: 21st February, 2006
Timestamp: 2006-02-21T14:55:00-08:00
Tags: textmate, rails, hacking, commands, macro, rails, snippets, textmate
Styles: typocode.css
---

<p><em><strong>UPDATE:</strong> I got everything working and it's all packaged up <a href="/posts/2006/02/intelligent-migration-snippets-0_1-for-textmate">here</a>. There's an installation script this time as well.</em></p>

<p>Thanks to <a href="http://thread.gmane.org/gmane.editors.textmate.general/8520">a helpful thread</a> on the TextMate mailing list I have the beginning of a solution to insert text at 2 (or more) locations in a file.</p>


<p>I implemented this for a new snippet I was working on for migrations, <code>rename_column</code>. Since the command is the same in self.up and self.down simply doing a reverse search for <code>rename_column</code> in my <a href="/posts/2006/02/textmate-move-selection-to-self-down">hackish macro</a> didn't return the cursor the desired location.</p><p>That's enough introduction, here's the program to do the insertion:</p>


<div class="typocode"><pre><code class="typocode_ruby "><span class="comment">#!/usr/bin/env ruby</span>
<span class="keyword">def </span><span class="method">indent</span><span class="punct">(</span><span class="ident">s</span><span class="punct">)</span>
  <span class="ident">s</span> <span class="punct">=~</span> <span class="punct">/</span><span class="regex">^(<span class="escape">\s</span>*)</span><span class="punct">/</span>
  <span class="punct">'</span><span class="string"> </span><span class="punct">'</span> <span class="punct">*</span> <span class="global">$1</span><span class="punct">.</span><span class="ident">length</span>
<span class="keyword">end</span>

<span class="ident">up_line</span> <span class="punct">=</span> <span class="punct">'</span><span class="string">rename_column "${1:table}", "${2:column}", "${3:new_name}"$0</span><span class="punct">'</span>
<span class="ident">down_line</span> <span class="punct">=</span> <span class="punct">"</span><span class="string">rename_column <span class="escape">\"</span>$$1<span class="escape">\"</span>, <span class="escape">\"</span>$$3<span class="escape">\"</span>, <span class="escape">\"</span>$$2<span class="escape">\"\n</span></span><span class="punct">"</span>

<span class="comment"># find the end of self.down and insert 2nd line</span>
<span class="ident">lines</span> <span class="punct">=</span> <span class="constant">STDIN</span><span class="punct">.</span><span class="ident">read</span><span class="punct">.</span><span class="ident">to_a</span><span class="punct">.</span><span class="ident">reverse</span>
<span class="ident">ends_seen</span> <span class="punct">=</span> <span class="number">0</span>
<span class="ident">lines</span><span class="punct">.</span><span class="ident">each_with_index</span> <span class="keyword">do</span> <span class="punct">|</span><span class="ident">line</span><span class="punct">,</span> <span class="ident">i</span><span class="punct">|</span>
  <span class="ident">ends_seen</span> <span class="punct">+=</span> <span class="number">1</span>    <span class="keyword">if</span> <span class="ident">line</span> <span class="punct">=~</span> <span class="punct">/</span><span class="regex">^<span class="escape">\s</span>*end<span class="escape">\b</span></span><span class="punct">/</span>
  <span class="keyword">if</span> <span class="ident">ends_seen</span> <span class="punct">==</span> <span class="number">2</span>
    <span class="ident">lines</span><span class="punct">[</span><span class="ident">i</span><span class="punct">..</span><span class="ident">i</span><span class="punct">]</span> <span class="punct">=</span> <span class="punct">[</span><span class="ident">lines</span><span class="punct">[</span><span class="ident">i</span><span class="punct">],</span> <span class="ident">indent</span><span class="punct">(</span><span class="ident">lines</span><span class="punct">[</span><span class="ident">i</span><span class="punct">])</span> <span class="punct">*</span> <span class="number">2</span> <span class="punct">+</span> <span class="ident">down_line</span><span class="punct">]</span>
    <span class="keyword">break</span>
  <span class="keyword">end</span>
<span class="keyword">end</span>

<span class="comment"># return the new text, escaping special chars</span>
<span class="ident">print</span> <span class="ident">up_line</span> <span class="punct">+</span> <span class="ident">lines</span><span class="punct">.</span><span class="ident">reverse</span><span class="punct">.</span><span class="ident">to_s</span><span class="punct">.</span><span class="ident">gsub</span><span class="punct">('</span><span class="string">[$`<span class="escape">\\</span>]</span><span class="punct">',</span> <span class="punct">'</span><span class="string"><span class="escape">\\\\</span>\1</span><span class="punct">').</span><span class="ident">gsub</span><span class="punct">('</span><span class="string"><span class="escape">\\</span>$<span class="escape">\\</span>$</span><span class="punct">',</span> <span class="punct">'</span><span class="string">$</span><span class="punct">')</span></code></pre></div>

<p>Save this as a command in your Rails, or <a href="http://blog.inquirylabs.com/">syncPeople on Rails</a>, bundle. The command options should be as follows:</p>


<ul>
<li><strong>Save:</strong> Nothing</li>
  <li><strong>Input:</strong> Selected Text or Nothing</li>
  <li><strong>Output:</strong> Insert as Snippet</li>
  <li><strong>Activation:</strong> Whatever you want, I'm going to use a macro described below and leave this empty</li>
  <li><strong>Scope Selector:</strong> source.ruby.rails</li>
</ul>


<p>The first modification it needs is to get the lines to insert as command line arguments so we can use it for other snippets. Secondly, regardless of the <strong>Re-indent pasted text</strong> setting the text returned is indented incorrectly.</p>


The macro I'm thinking of to invoke this is tab-triggered and will simply:
<ul>
<li>Select word (<code><strong>⌃W</strong></code>)</li>
  <li>Delete (<code><strong>⌫</strong></code>)</li>
  <li>Select to end of file (<code><strong>⇧⌘↓</strong></code>)</li>
  <li>Run command "Put in self.down"</li>
</ul>


