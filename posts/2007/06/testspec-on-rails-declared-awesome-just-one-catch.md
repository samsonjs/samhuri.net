---
Title: "test/spec on rails declared awesome, just one catch"
Author: Sami Samhuri
Date: "14th June, 2007"
Timestamp: 2007-06-14T07:21:00-07:00
Tags: [bdd, rails, test/spec]
---

This last week I've been getting to know <a href="http://chneukirchen.org/blog/archive/2007/01/announcing-test-spec-0-3-a-bdd-interface-for-test-unit.html">test/spec</a> via <a href="http://errtheblog.com/">err's</a> <a href="http://require.errtheblog.com/plugins/wiki/TestSpecRails">test/spec on rails</a> plugin. I have to say that I really dig this method of testing my code and I look forward to trying out some actual <a href="http://behaviour-driven.org/">BDD</a> in the future.

I did hit a little snag with functional testing though. The method of declaring which controller to use takes the form:

```ruby
use_controller :foo
```

and can be placed in the <code>setup</code> method, like so:

```ruby
# in test/functional/sessions_controller_test.rb

context "A guest" do
  fixtures :users

  setup do
    use_controller :sessions
  end

  specify "can login" do
    post :create, :username => 'sjs', :password => 'blah'
    response.should.redirect_to user_url(users(:sjs))
    ...
  end
end
```

This is great and the test will work. But let's say that I have another controller that guests can access:

```ruby
# in test/functional/foo_controller_test.rb

context "A guest" do
  setup do
    use_controller :foo
  end

  specify "can do foo stuff" do
    get :fooriffic
    status.should.be :success
    ...
  end
end
```

This test will pass on its own as well, which is what really tripped me up. When I ran my tests individually as I wrote them, they passed. When I ran <code>rake test:functionals</code> this morning and saw over a dozen failures and errors I was pretty alarmed. Then I looked at the errors and was thoroughly confused. Of course the action <strong>fooriffic</strong> can't be found in <strong>SessionsController</strong>, it lives in <strong>FooController</strong> and that's the controller I said to use! What gives?!

The problem is that test/spec only creates one context with a specific name, and re-uses that context on subsequent tests using the same context name. The various <code>setup</code> methods are all added to a list and each one is executed, not just the one in the same <code>context</code> block as the specs. I can see how that's useful, but for me right now it's just a hinderance as I'd have to uniquely name each context. "Another guest" just looks strange in a file by itself, and I want my tests to work with my brain not against it.

My solution was to just create a new context each time and re-use nothing. Only 2 lines in test/spec need to be changed to achieve this, but I'm not sure if what I'm doing is a bad idea. My tests pass and right now that's basically all I care about though.

