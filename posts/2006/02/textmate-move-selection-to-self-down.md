---
Title: TextMate: Move selection to self.down
Author: Sami Samhuri
Date: 21st February, 2006
Timestamp: 2006-02-21T00:26:00-08:00
Tags: textmate, rails, hacking, hack, macro, rails, textmate
Styles: typocode.css
---

<p><strong>UPDATE:</strong> <em>This is obsolete, see <a href="/posts/2006/02/textmate-insert-text-into-self-down">this post</a> for a better solution.</em></p>

<p><a href="/posts/2006/02/some-textmate-snippets-for-rails-migrations.html#comment-3">Duane's comment</a> prompted me to think about how to get the <code>drop_table</code> and <code>remove_column</code> lines inserted in the right place. I don't think TextMate's snippets are built to do this sort of text manipulation. It would be nicer, but a quick hack will suffice for now.</p><p>Use <acronym title="Migration Create and Drop Table">MCDT</acronym> to insert:</p>

<div class="typocode"><pre><code class="typocode_ruby "><span class="ident">create_table</span> <span class="punct">"</span><span class="string">table</span><span class="punct">"</span> <span class="keyword">do</span> <span class="punct">|</span><span class="ident">t</span><span class="punct">|</span>

<span class="keyword">end</span>
<span class="ident">drop_table</span> <span class="punct">"</span><span class="string">table</span><span class="punct">"</span></code></pre></div>

<p>Then press tab once more after typing the table name to select the code <code>drop_table "table"</code>. I created a macro that cuts the selected text, finds <code>def self.down</code> and pastes the line there. Then it searches for the previous occurence of <code>create_table</code> and moves the cursor to the next line, ready for you to add some columns.</p>


<p>I have this bound to <strong>⌃⌥⌘M</strong> because it wasn't in use. If your Control key is to the left the A key it's quite comfortable to hit this combo. Copy the following file into <strong>~/Library/Application Support/TextMate/Bundles/Rails.tmbundle/Macros</strong>.</p>


<p style="text-align: center;"><a href="http://sami.samhuri.net/files/move-to-self.down.plist">Move selection to self.down</a></p>


<p>This works for the <acronym title="Migration Add and Remove Column">MARC</acronym> snippet as well. I didn't tell you the whole truth, the macro actually finds the previous occurence of <code>(create_table|add_column)</code>.</p>


<p>The caveat here is that if there is a <code>create_table</code> or <code>add_column</code> between <code>self.down</code> and the table you just added, it will jump back to the wrong spot. It's still faster than doing it all manually, but should be improved. If you use these exclusively, the order they occur in <code>self.down</code> will be opposite of that in <code>self.up</code>. That means either leaving things backwards or doing the re-ordering manually. =/</p>

