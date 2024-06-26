---
Title: Catch compiler errors at runtime
Author: Sami Samhuri
Date: 19th August, 2007
Timestamp: 2007-08-19T15:17:00-07:00
Tags: ruby
---

While coding just now I had a small epiphany about Ruby.  Though Ruby is highly dynamic and compiled at runtime, that doesn't preclude one catching some mistakes at compile time.  I'm not talking about mere syntax errors or anything either.  The only proviso to catching mistakes at compile time is that you must have a decent chunk of code executed during compilation.  One benefit of Ruby's blurring of compile time and runtime is that you can run real code at compile time.  This is largely how metaprogramming tricks are pulled off elegantly and with ease in projects such as Rails.

Sure you won't get all the benefits of a strictly and/or statically typed compiler, but you can get some of them.  If you have a library that makes substantial use of executing code at compile time then the mere act of loading your library causes your code to run, thus it compiles.  If you <code>require</code> your lib and get <code>true</code> back then you know the code that bootstraps the runtime code is at least partially correct.

Compile time is runtime.  Runtime is compile time.  Just because you have to run the code to compile it doesn't mean you can't catch a good chunk of compiler errors before you send out your code.  Tests will always be there for the rest of your mistakes, but if you can pull work into compile time then Ruby's compiler can augment your regular testing practices.

I admit that this is of limited use most of the time, but let it not be said that you can't catch any errors with your compiler just because you have to run your code to compile it.  With Ruby the more meta you get the more the compiler rewards you.

*[Of course this is true of languages such as Common Lisp too, which make available the full programming language at compile time. I just happened to be using Ruby when I realized this.]*

