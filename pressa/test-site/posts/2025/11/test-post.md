---
Title: Testing Pressa with Ruby and Phlex
Author: Trent Reznor
Date: 11th November, 2025
Timestamp: 2025-11-11T14:00:00-08:00
Tags: Ruby, Phlex, Static Sites
---

This is a test post to verify that Pressa is working correctly. We're building a static site generator using:

- Ruby 3.4
- Phlex for HTML generation
- Kramdown with Rouge for Markdown and syntax highlighting
- dry-struct for immutable data models

## Code Example

Here's some Ruby code:

```ruby
class Post < Dry::Struct
  attribute :title, Types::String
  attribute :body, Types::String
end

post = Post.new(title: "Hello World", body: "This is a test")
puts post.title
```

## Features

The generator supports:

1. Hierarchical post organization (year/month)
2. Link posts (external URLs)
3. JSON and RSS feeds
4. Archive pages
5. Projects section

Pretty cool, right?
