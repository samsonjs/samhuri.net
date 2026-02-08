---
Title: "TextMate: Insert text into self.down"
Author: Sami Samhuri
Date: "21st February, 2006"
Timestamp: 2006-02-21T14:55:00-08:00
Tags: textmate, rails, hacking, commands, macro, rails, snippets, textmate
---

<p><em><strong>UPDATE:</strong> I got everything working and it's all packaged up <a href="/posts/2006/02/intelligent-migration-snippets-0_1-for-textmate">here</a>. There's an installation script this time as well.</em></p>

<p>Thanks to <a href="http://thread.gmane.org/gmane.editors.textmate.general/8520">a helpful thread</a> on the TextMate mailing list I have the beginning of a solution to insert text at 2 (or more) locations in a file.</p>

<p>I implemented this for a new snippet I was working on for migrations, <code>rename_column</code>. Since the command is the same in self.up and self.down simply doing a reverse search for <code>rename_column</code> in my <a href="/posts/2006/02/textmate-move-selection-to-self-down">hackish macro</a> didn't return the cursor the desired location.</p><p>That's enough introduction, here's the program to do the insertion:</p>

```ruby
#!/usr/bin/env ruby
def indent(s)
  s =~ /^(\s*)/
  ' ' * $1.length
end

up_line = 'rename_column "${1:table}", "${2:column}", "${3:new_name}"$0'
down_line = "rename_column \"$$1\", \"$$3\", \"$$2\"\n"

# find the end of self.down and insert 2nd line
lines = STDIN.read.to_a.reverse
ends_seen = 0
lines.each_with_index do |line, i|
  ends_seen += 1    if line =~ /^\s*end\b/
  if ends_seen == 2
    lines[i..i] = [lines[i], indent(lines[i]) * 2 + down_line]
    break
  end
end

# return the new text, escaping special chars
print up_line + lines.reverse.to_s.gsub(/([$`\\])/, '\\\\\1').gsub(/\$\$/, '$')
```

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
