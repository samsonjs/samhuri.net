---
Title: "Enumurable#pluck and String#to_proc for Ruby"
Author: Sami Samhuri
Date: "10th May, 2007"
Timestamp: 2007-05-10T16:14:00-07:00
Tags: [ruby, extensions]
---

I wanted a method analogous to Prototype's <a href="http://prototypejs.org/api/enumerable/pluck">pluck</a>  and <a href="http://prototypejs.org/api/enumerable/invoke">invoke</a> in Rails for building lists for <a href="http://api.rubyonrails.org/classes/ActionView/Helpers/FormOptionsHelper.html#M000510">options_for_select</a>. Yes, I know about <a href="http://api.rubyonrails.org/classes/ActionView/Helpers/FormOptionsHelper.html#M000511">options_from_collection_for_select</a>.

I wanted something more general that I can use anywhere - not just in Rails - so I wrote one. In a second I'll introduce <code>Enumerable#pluck</code>, but first we need some other methods to help implement it nicely.

First you need <a href="http://pragdave.pragprog.com/pragdave/2005/11/symbolto_proc.html"><code>Symbol#to_proc</code></a>, which shouldn't need an introduction. If you're using Rails you have this already.

**Symbol#to_proc**

```ruby
class Symbol
  # Turns a symbol into a proc.
  #
  # Example:
  #   # The same as people.map { |p| p.birthdate }
  #   people.map(&:birthdate)
  #
  def to_proc
    Proc.new {|thing, *args| thing.send(self, *args)}
  end
end
```

Next we define <code>String#to_proc</code>, which is nearly identical to the <code>Array#to_proc</code> method I previously wrote about.

**String#to_proc**

```ruby
class String
  # Turns a string into a proc.
  #
  # Example:
  #   # The same as people.map { |p| p.birthdate.year }
  #   people.map(&'birthdate.year')
  #
  def to_proc
    Proc.new do |*args|
      split('.').inject(args.shift) do |thing, msg|
        thing = thing.send(msg.to_sym, *args)
      end
    end
  end
end
```

Finally there's <code>Enumerable#to_proc</code> which returns a proc that passes its parameter through each of its members and collects their results. It's easier to explain by example.

**Enumerable#to_proc**

```ruby
module Enumerable
  # Effectively treats itself as a list of transformations, and returns a proc
  # which maps values to a list of the results of applying each transformation
  # in that list to the value.
  #
  # Example:
  #   # The same as people.map { |p| [p.birthdate, p.email] }
  #   people.map(&[:birthdate, :email])
  #
  def to_proc
    @procs ||= map(&:to_proc)
    Proc.new do |thing, *args|
      @procs.map do |proc|
        proc.call(thing, *args)
      end
    end
  end
end
```

Here's the cool part, <code>Enumerable#pluck</code> for Ruby in all its glory.

**Enumerable#pluck**

```ruby
module Enumerable
  # Use this to pluck values from objects, especially useful for ActiveRecord models.
  # This is analogous to Prototype's Enumerable.pluck method but more powerful.
  #
  # You can pluck values simply, like so:
  #   >> people.pluck(:last_name)  #=> ['Samhuri', 'Jones', ...]
  #
  # But with Symbol#to_proc defined this is effectively the same as:
  #   >> people.map(&:last_name)   #=> ['Samhuri', 'Jones', ...]
  #
  # Where pluck's power becomes evident is when you want to do something like:
  #   >> people.pluck(:name, :address, :phone)
  #        #=> [['Johnny Canuck', '123 Maple Lane', '416-555-124'], ...]
  #
  # Instead of:
  #   >> people.map { |p| [p.name, p.address, p.phone] }
  #
  #   # map each person to: [person.country.code, person.id]
  #   >> people.pluck('country.code', :id)
  #        #=> [['US', 1], ['CA', 2], ...]
  #
  def pluck(*args)
    # Thanks to Symbol#to_proc, Enumerable#to_proc and String#to_proc this Just Works(tm)
    map(&args)
  end
end
```

I wrote another version without using the various <code>#to_proc</code> methods so as to work with a standard Ruby while only patching 1 module.

```ruby
module Enumerable
  # A version of pluck which doesn't require any to_proc methods.
  def pluck(*args)
    procs = args.map do |msgs|
      # always operate on lists of messages
      if String === msgs
        msgs = msgs.split('.').map {|a| a.to_sym} # allow 'country.code'
      elsif !(Enumerable === msgs)
        msgs = [msgs]
      end
      Proc.new do |orig|
        msgs.inject(orig) { |thing, msg| thing = thing.send(msg) }
      end
    end

    if procs.size == 1
      map(&procs.first)
    else
      map do |thing|
        procs.map { |proc| proc.call(thing) }
      end
    end
  end
end
```

It's just icing on the cake considering Ruby's convenient block syntax, but there it is. Do with it what you will. You can change or extend any of these to support drilling down into hashes quite easily too.

*<strong>Update #1:</strong> Fixed a potential performance issue in <code>Enumerable#to_proc</code> by saving the results of <code>to_proc</code> in <code>@procs</code>.*

