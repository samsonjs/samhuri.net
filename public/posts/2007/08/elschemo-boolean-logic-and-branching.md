I've been developing a Scheme
interpreter in Haskell called
<a href="/posts/2007/06/floating-point-in-elschemo">ElSchemo</a>.
It started from <a href="http://halogen.note.amherst.edu/~jdtang/scheme_in_48/tutorial/overview.html">Jonathan's excellent Haskell
tutorial</a>
which I followed in order to learn both Haskell and Scheme.  Basically
that means the code here is for me to get some feedback as much
as to show others how to do this kind of stuff.  This may not be too
interesting if you haven't at least browsed the tutorial.


I'm going to cover 3 new special forms: <code>and</code>, <code>or</code>, and <code>cond</code>.  I
promised to cover the <code>let</code> family of special forms this time around
but methinks this is long enough as it is.  My sincere apologies if
you've been waiting for those.

## Short-circuiting Boolean logic ##

Two functions from the tutorial which may irk you immediately are
<code>and</code> and <code>or</code>, defined in Scheme in the given standard library.  If
your code is free of side-effects then it may not bother you so
much.  It bothered me.  The problem with the implementation in
stdlib.scm is that all the arguments are evaluated before control
enters the function.  Besides being inefficient by doing unnecessary work,
if any of the arguments have side-effects you can make use of short-circuiting
by using <code>and</code> to sequence actions, bailing out if any fail (by returning <code>nil</code>),
and using <code>or</code> to define a set of alternative actions which will bail out when the first in the list succeeds (by returning anything but <code>nil</code>).  Had we macros then we could implement them as
macros.  We don't, so we'll write them as special forms in Haskell.

Unlike the special forms defined in the tutorial I'm going to
implement these as separate functions for clarity, rather than lump
them all in <code>eval</code>.  However, they will be invoked directly from
<code>eval</code> so their type is easy; it's the same as <code>eval</code>'s.

Code first, ask questions later.  Haskell is a pretty clear and
concise language.  My explanations may be redundant because of this.

### lispAnd ###


<pre class="line-numbers">1
2
3
4
5
6
7
8 
</pre>
<pre><code>lispAnd :: Env -&gt; [LispVal] -&gt; IOThrowsError LispVal
lispAnd env [] = return $ Bool True
lispAnd env [pred] = eval env pred
lispAnd env (pred:rest) = do
    result &lt;- eval env pred
    case result of
      Bool False -&gt; return result
      _ -&gt; lispAnd env rest</code></pre>


Starting with the trivial case, <code>and</code> returns <code>#t</code> with zero
arguments.

With one argument, a single predicate, simply evaluate and
return that argument.

Given a list of predicates, evaluate the first and inspect its value.
If the argument evaluated to <code>#f</code> then our work is done and we return
<code>#f</code>, otherwise we keep plugging along by making a recursive call with
the first argument stripped off.  Eventually we will reach our base
case with only one predicate.

It's possible to eliminate the case of one predicate.  I think that
just complicates things but it's a viable solution.

### lispOr ###

Predictably this is quite similar to <code>lispAnd</code>.


<pre class="line-numbers">1
2
3
4
5
6
7
8 
</pre>
<pre><code>lispOr :: Env -&gt; [LispVal] -&gt; IOThrowsError LispVal
lispOr env [] = return $ Bool False
lispOr env [pred] = eval env pred
lispOr env (pred:rest) = do
    result &lt;- eval env pred
    case result of
        Bool False -&gt; lispOr env rest
        _ -&gt; return result</code></pre>


With no arguments <code>lispOr</code> returns <code>#f</code>, and with one argument it
evaluates and returns the result.

With 2 or more arguments the first is evaluated, but this time if the
result is <code>#f</code> then we continue looking for a truthy value.  If the
result is anything else at all then it's returned and we are done.

## A new branching construct ##

First let me define a convenience function that I have added to
ElSchemo.  It maps a list of expressions to their values by evaluating
each one in the given environment.


<pre class="line-numbers">1
2 
</pre>
<pre><code>evalExprs :: Env -&gt; [LispVal] -&gt; IOThrowsError [LispVal]
evalExprs env exprs = mapM (eval env) exprs</code></pre>


### lispCond ###

Again, <code>lispCond</code> has the same type as <code>eval</code>.


<pre class="line-numbers">1
2
3
4
5
6 
</pre>
<pre><code>lispCond :: Env -&gt; [LispVal] -&gt; IOThrowsError LispVal
lispCond env (List (pred:conseq) : rest) = do
    result &lt;- eval env pred
    case result of
        Bool False -&gt; if null rest then return result else lispCond env rest
        _ -&gt; liftM last $ evalExprs env conseq</code></pre>


Unlike Lisp – which uses a predicate of <code>T</code> (true) – Scheme uses a
predicate of <code>else</code> to trigger the default branch.  When the pattern
matching on <code>Atom "else"</code> succeeds, we evaluate the default
expressions and return the value of the last one.  This is one
possible base case.  <code>Atom "else"</code> could be defined to evaluate to
<code>#t</code>, but we don't want <code>else</code> to be evaluated as <code>#t</code> anywhere except
in a <code>cond</code> so I have chosen this solution.

If the first predicate is not <code>else</code> then we evaluate it and check the
resulting value.  If we get <code>#f</code> then we look at the rest of the
statement, if it's empty then we return <code>#f</code>, otherwise we recurse on
the rest of the parameters.  If the predicate evaluates to a truthy
value – that is, anything but <code>#f</code> – then we evaluate the consequent
expressions and return the value of the last one.

## Plumbing ##

Now all that's left is to hook up the new functions in <code>eval</code>.


<pre class="line-numbers">1
2
3 
</pre>
<pre><code>eval env (List (Atom "and" : params)) = lispAnd env params
eval env (List (Atom "or" : params)) = lispOr env params
eval env (List (Atom "cond" : params)) = lispCond env params</code></pre>


You could, of course, throw the entire definitions in <code>eval</code> itself but <code>eval</code> is big
enough for me as it is.  YMMV.

## Done! ##

So, that's a wrap.  It only took 20 lines of code for the 3 new
special forms, and it could easily be done with less code.  Next time
I will show you how to implement the various <code>let</code> functions.  Really!

*Do you like me describing ElSchemo piece by piece as I have been?  I
plan on posting the Haskell code and my stdlib.scm in their entirety
sometime, and I could do that before or after I finish writing about
the features I've developed beyond the tutorial.  Just let me know in
the comments.*
