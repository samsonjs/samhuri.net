---
Title: "Dumping Objects to the Browser in Rails"
Author: Sami Samhuri
Date: "15th May, 2007"
Timestamp: 2007-05-15T13:38:00-07:00
Tags: [rails]
---

Here's an easy way to solve a problem that may have nagged you as it did me. Simply using <code>foo.inspect</code> to dump out some object to the browser dumps one long string which is barely useful except for short strings and the like. The ideal output is already available using the <a href="http://www.ruby-doc.org/stdlib/libdoc/prettyprint/rdoc/index.html"><code>PrettyPrint</code></a> module so we just need to use it.

Unfortunately typing <code>&lt;pre&gt;&lt;%= PP.pp(@something, '') %&gt;&lt;/pre&gt;</code> to quickly debug some possibly large object (or collection) can get old fast so we need a shortcut.

Taking the definition of <a href="http://extensions.rubyforge.org/rdoc/classes/Object.html#M000020"><code>Object#pp_s</code></a> from the <a href="http://extensions.rubyforge.org/rdoc/">extensions project</a> it's trivial to create a helper method to just dump out an object in a reasonable manner.

**/app/helpers/application_helper.rb**

```ruby
def dump(thing)
  s = StringIO.new
  PP.pp(thing, s)
  s.string
end
```

Alternatively you could do as the extensions folks do and actually define <code>Object#pp_s</code> so you can use it in your logs or anywhere else you may want to inspect an object. If you do this you probably want to change the <code>dump</code> helper method accordingly in case you decide to change <code>pp_s</code> in the future.

**lib/local_support/core_ext/object.rb**

```ruby
class Object
  def pp_s
    pps = StringIO.new
    PP.pp(self, pps)
    pps.string
  end
end
```

