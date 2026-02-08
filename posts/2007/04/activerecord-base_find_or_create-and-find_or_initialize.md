---
Title: "ActiveRecord::Base.find_or_create and find_or_initialize"
Author: Sami Samhuri
Date: "11th April, 2007"
Timestamp: 2007-04-11T03:24:00-07:00
Tags: [activerecord, coding, rails, ruby]
---

I've extended ActiveRecord with `find_or_create(params)` and `find_or_initialize(params)`. Those are actually just wrappers around `find_or_do(action, params)` which does the heavy lifting.

They work exactly as you'd expect them to work with possibly one gotcha. If you pass in an `id` attribute then it will just find that record directly. If it fails it will try and find the record using the other params as it would have done normally.

Enough chat, here's the self-explanatory code:

```ruby
# extend ActiveRecord::Base with find_or_create and find_or_initialize.
ActiveRecord::Base.class_eval do
  include ActiveRecordExtensions
end
```

```ruby
module ActiveRecordExtensions
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def find_or_initialize(params)
      find_or_do('initialize', params)
    end

    def find_or_create(params)
      find_or_do('create', params)
    end

    private

    # Find a record that matches the attributes given in the +params+ hash, or do +action+
    # to retrieve a new object with the given parameters and return that.
    def find_or_do(action, params)
      # if an id is given just find the record directly
      self.find(params[:id])

    rescue ActiveRecord::RecordNotFound => e
      attrs = {}     # hash of attributes passed in params

      # search for valid attributes in params
      self.column_names.map(&:to_sym).each do |attrib|
        # skip unknown columns, and the id field
        next if params[attrib].nil? || attrib == :id

        attrs[attrib] = params[attrib]
      end

      # no valid params given, return nil
      return nil if attrs.empty?

      # call the appropriate ActiveRecord finder method
      self.send("find_or_#{action}_by_#{attrs.keys.join('_and_')}", *attrs.values)
    end
  end
end
```

