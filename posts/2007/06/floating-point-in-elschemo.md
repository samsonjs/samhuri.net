### Parsing floating point numbers ###

The first task is extending the <code>LispVal</code> type to grok floats.


<pre class="line-numbers">1
2
3
4
5
6
7
8
9
<strong>10</strong>
11
12
13
14
15
</pre>
<pre><code>type LispInt = Integer
type LispFloat = Float

-- numeric data types
data LispNum = Integer LispInt
             | Float LispFloat

-- data types
data LispVal = Atom String
             | List [LispVal]
             | DottedList [LispVal] LispVal
             | Number LispNum
             | Char Char
             | String String
             | ...</code></pre>


The reason for using the new <code>LispNum</code> type and not just throwing a new <code>Float Float</code> constructor in there is so that functions can accept and operate on parameters of any supported numeric type.  First the floating point numbers need to be parsed.  For now I only parse floating point numbers in decimal because the effort to parse other bases is too great for the benefits gained (none, for me).

ElSchemo now parses negative numbers so I'll start with 2 helper functions that are used when parsing both integers and floats:


<pre class="line-numbers">1
2
3
4
5
6
7
</pre>
<pre><code>parseSign :: Parser Char
parseSign = do try (char '-')
           &lt;|&gt; do optional (char '+')
                  return '+'

applySign :: Char -&gt; LispNum -&gt; LispNum
applySign sign n = if sign == '-' then negate n else n</code></pre>


<code>parseSign</code> is straightforward as it follows the convention that a literal number is positive unless explicitly marked as negative with a leading minus sign. A leading plus sign is allowed but not required.

<code>applySign</code> takes a sign character and a <code>LispNum</code> and negates it if necessary, returning a <code>LispNum</code>.

Armed with these 2 functions we can now parse floating point numbers in decimal. Conforming to R5RS an optional <code>#d</code> prefix is allowed.


<pre class="line-numbers">1
2
3
4
5
6
7
8
</pre>
<pre><code>parseFloat :: Parser LispVal
parseFloat = do optional (string "#d")
                sign &lt;- parseSign
                whole &lt;- many1 digit
                char '.'
                fract &lt;- many1 digit
                return . Number $ applySign sign (makeFloat whole fract)
    where makeFloat whole fract = Float . fst . head . readFloat $ whole ++ "." ++ fract</code></pre>


The first 6 lines should be clear. Line 7 simply applies the parsed sign to the parsed number and returns it, delegating most of the work to <code>makeFloat</code>.  <code>makeFloat</code> in turn delegates the work to the <code>readFloat</code> library function, extracts the result and constructs a <code>LispNum</code> for it.

The last step for parsing is to modify <code>parseExpr</code> to try and parse floats.


<pre class="line-numbers">1
2
3
4
5
6
7
8
9
<strong>10</strong>
11
12
13
14
</pre>
<pre><code>-- Integers, floats, characters and atoms can all start with a # so wrap those with try.
-- (Left factor the grammar in the future)
parseExpr :: Parser LispVal
parseExpr = (try parseFloat)
        &lt;|&gt; (try parseInteger)
        &lt;|&gt; (try parseChar)
        &lt;|&gt; parseAtom
        &lt;|&gt; parseString
        &lt;|&gt; parseQuoted
        &lt;|&gt; do char '('
               x &lt;- (try parseList) &lt;|&gt; parseDottedList
               char ')'
               return x
        &lt;|&gt; parseComment</code></pre>


### Displaying the floats ###


That's it for parsing, now let's provide a way to display these suckers.  <code>LispVal</code> is an instance of show, where <code>show</code> = <code>showVal</code> so <code>showVal</code> is our first stop.  Remembering that <code>LispVal</code> now has a single <code>Number</code> constructor we modify it accordingly:


<pre class="line-numbers">1
2
3
4
5
6
7
</pre>
<pre><code>showVal (Number n) = showNum n

showNum :: LispNum -&gt; String
showNum (Integer contents) = show contents
showNum (Float contents) = show contents

instance Show LispNum where show = showNum</code></pre>


One last, and certainly not least, step is to modify <code>eval</code> so that numbers evaluate to themselves.


    eval env val@(Number _) = return val

There's a little more housekeeping to be done such as fixing <code>integer?</code>, <code>number?</code>, implementing <code>float?</code> but I will leave those as an exercise to the reader, or just wait until I share the full code.  As it stands now floating point numbers can be parsed and displayed.  If you fire up the interpreter and type <code>2.5</code> or <code>-10.88</code> they will be understood.  Now try adding them:

    (+ 2.5 1.1)
    Invalid type: expected integer, found 2.5

Oops, we don't know how to operate on floats yet!

### Operating on floats ###

Parsing was the easy part.  Operating on the new floats is not necessarily difficult, but it was more work than I realized it would be.  I don't claim that this is the best or the only way to operate on any <code>LispNum</code>, it's just the way I did it and it seems to work.  There's a bunch of boilerplate necessary to make <code>LispNum</code> an instance of the required classes, Eq, Num, Real, and Ord.  I don't think I have done this properly but for now it works.  What is clearly necessary is the code that operates on different types of numbers.  I think I've specified sane semantics for coercion.  This will be very handy shortly.


<pre class="line-numbers">1
2
3
4
5
6
7
8
9
<strong>10</strong>
11
12
13
14
15
16
17
18
19
<strong>20</strong>
21
22
23
24
25
26
27
28
29
<strong>30</strong>
31
32
33
34
35
36
37
38
39
<strong>40</strong>
41
42
43
44
45
46
47
48
49
<strong>50</strong>
51
52
53
54
55
56
57
58
59
<strong>60</strong>
61
62
63
64
65
66
67
68
69
<strong>70 </strong>
</pre>
<pre><code>lispNumEq :: LispNum -&gt; LispNum -&gt; Bool
lispNumEq (Integer arg1) (Integer arg2) = arg1 == arg2
lispNumEq (Integer arg1) (Float arg2) = (fromInteger arg1) == arg2
lispNumEq (Float arg1) (Float arg2) = arg1 == arg2
lispNumEq (Float arg1) (Integer arg2) = arg1 == (fromInteger arg2)

instance Eq LispNum where (==) = lispNumEq

lispNumPlus :: LispNum -&gt; LispNum -&gt; LispNum
lispNumPlus (Integer x) (Integer y) = Integer $ x + y
lispNumPlus (Integer x) (Float y)   = Float $ (fromInteger x) + y
lispNumPlus (Float x)   (Float y)   = Float $ x + y
lispNumPlus (Float x)   (Integer y) = Float $ x + (fromInteger y)

lispNumMinus :: LispNum -&gt; LispNum -&gt; LispNum
lispNumMinus (Integer x) (Integer y) = Integer $ x - y
lispNumMinus (Integer x) (Float y)   = Float $ (fromInteger x) - y
lispNumMinus (Float x)   (Float y)   = Float $ x - y
lispNumMinus (Float x)   (Integer y) = Float $ x - (fromInteger y)

lispNumMult :: LispNum -&gt; LispNum -&gt; LispNum
lispNumMult (Integer x) (Integer y) = Integer $ x * y
lispNumMult (Integer x) (Float y)   = Float $ (fromInteger x) * y
lispNumMult (Float x)   (Float y)   = Float $ x * y
lispNumMult (Float x)   (Integer y) = Float $ x * (fromInteger y)

lispNumDiv :: LispNum -&gt; LispNum -&gt; LispNum
lispNumDiv (Integer x) (Integer y) = Integer $ x `div` y
lispNumDiv (Integer x) (Float y)   = Float $ (fromInteger x) / y
lispNumDiv (Float x)   (Float y)   = Float $ x / y
lispNumDiv (Float x)   (Integer y) = Float $ x / (fromInteger y)

lispNumAbs :: LispNum -&gt; LispNum
lispNumAbs (Integer x) = Integer (abs x)
lispNumAbs (Float x) = Float (abs x)

lispNumSignum :: LispNum -&gt; LispNum
lispNumSignum (Integer x) = Integer (signum x)
lispNumSignum (Float x) = Float (signum x)

instance Num LispNum where
    (+) = lispNumPlus
    (-) = lispNumMinus
    (*) = lispNumMult
    abs = lispNumAbs
    signum = lispNumSignum
    fromInteger x = Integer x


lispNumToRational :: LispNum -&gt; Rational
lispNumToRational (Integer x) = toRational x
lispNumToRational (Float x) = toRational x

instance Real LispNum where
    toRational = lispNumToRational


lispIntQuotRem :: LispInt -&gt; LispInt -&gt; (LispInt, LispInt)
lispIntQuotRem n d = quotRem n d

lispIntToInteger :: LispInt -&gt; Integer
lispIntToInteger x = x

lispNumLessThanEq :: LispNum -&gt; LispNum -&gt; Bool
lispNumLessThanEq (Integer x) (Integer y) = x &lt;= y
lispNumLessThanEq (Integer x) (Float y)   = (fromInteger x) &lt;= y
lispNumLessThanEq (Float x)   (Integer y) = x &lt;= (fromInteger y)
lispNumLessThanEq (Float x)   (Float y)   = x &lt;= y

instance Ord LispNum where (&lt;=) = lispNumLessThanEq</code></pre>


Phew, ok with that out of the way now we can actually extend our operators to work with any type of <code>LispNum</code>.  Our Scheme operators are defined using the functions <code>numericBinop</code> and <code>numBoolBinop</code>.  First we'll slightly modify our definition of <code>primitives</code>:


<pre class="line-numbers">1
2
3
4
5
6
7
8
9
<strong>10</strong>
11
12
13
14
15
</pre>
<pre><code>primitives :: [(String, [LispVal] -&gt; ThrowsError LispVal)]
primitives = [("+", numericBinop (+)),
              ("-", subtractOp),
              ("*", numericBinop (*)),
              ("/", floatBinop (/)),
              ("mod", integralBinop mod),
              ("quotient", integralBinop quot),
              ("remainder", integralBinop rem),
              ("=", numBoolBinop (==)),
              ("&lt;", numBoolBinop (&lt;)),
              ("&gt;", numBoolBinop (&gt;)),
              ("/=", numBoolBinop (/=)),
              ("&gt;=", numBoolBinop (&gt;=)),
              ("&lt;=", numBoolBinop (&lt;=)),
              ...]</code></pre>


Note that <code>mod</code>, <code>quotient</code>, and <code>remainder</code> are only defined for integers and as such use <code>integralBinop</code>, while division (/) is only defined for floating point numbers using <code>floatBinop</code>.  <code>subtractOp</code> is different to support unary usage, e.g. <code>(- 4) =&gt; -4</code>, but it uses <code>numericBinop</code> internally when more than 1 argument is given.  On to the implementation!  First extend <code>unpackNum</code> to work with any <code>LispNum</code>, and provide separate <code>unpackInt</code> and <code>unpackFloat</code> functions to handle both kinds of <code>LispNum</code>.


<pre class="line-numbers">1
2
3
4
5
6
7
8
9
<strong>10</strong>
11
12
13
14
15
</pre>
<pre><code>unpackNum :: LispVal -&gt; ThrowsError LispNum
unpackNum (Number (Integer n)) = return $ Integer n
unpackNum (Number (Float n)) = return $ Float n
unpackNum notNum = throwError $ TypeMismatch "number" notNum

unpackInt :: LispVal -&gt; ThrowsError Integer
unpackInt (Number (Integer n)) = return n
unpackInt (List [n]) = unpackInt n
unpackInt notInt = throwError $ TypeMismatch "integer" notInt

unpackFloat :: LispVal -&gt; ThrowsError Float
unpackFloat (Number (Float f)) = return f
unpackFloat (Number (Integer f)) = return $ fromInteger f
unpackFloat (List [f]) = unpackFloat f
unpackFloat notFloat = throwError $ TypeMismatch "float" notFloat</code></pre>


The initial work of separating integers and floats into the <code>LispNum</code> abstraction, and the code I said would be handy shortly, are going to be really handy here.  There's relatively no change in <code>numericBinop</code> except for the type signature.  <code>integralBinop</code> and <code>floatBinop</code> are just specific versions of the same function.  I'm sure there's a nice Haskelly way of doing this with less repetition, and I welcome such corrections.


<pre class="line-numbers">1
2
3
4
5
6
7
8
9
<strong>10</strong>
11
12
13
14
15
16
17
18
</pre>
<pre><code>numericBinop :: (LispNum -&gt; LispNum -&gt; LispNum) -&gt; [LispVal] -&gt; ThrowsError LispVal
numericBinop op singleVal@[_] = throwError $ NumArgs 2 singleVal
numericBinop op params = mapM unpackNum params &gt;&gt;= return . Number . foldl1 op

integralBinop :: (LispInt -&gt; LispInt -&gt; LispInt) -&gt; [LispVal] -&gt; ThrowsError LispVal
integralBinop op singleVal@[_] = throwError $ NumArgs 2 singleVal
integralBinop op params = mapM unpackInt params &gt;&gt;= return . Number . Integer . foldl1 op

floatBinop :: (LispFloat -&gt; LispFloat -&gt; LispFloat) -&gt; [LispVal] -&gt; ThrowsError LispVal
floatBinop op singleVal@[_] = throwError $ NumArgs 2 singleVal
floatBinop op params = mapM unpackFloat params &gt;&gt;= return . Number . Float . foldl1 op

subtractOp :: [LispVal] -&gt; ThrowsError LispVal
subtractOp num@[_] = unpackNum (head num) &gt;&gt;= return . Number . negate
subtractOp params = numericBinop (-) params

numBoolBinop :: (LispNum -&gt; LispNum -&gt; Bool) -&gt; [LispVal] -&gt; ThrowsError LispVal
numBoolBinop op params = boolBinop unpackNum op params</code></pre>


That was a bit of work but now ElSchemo supports floating point numbers, and if you're following along then your Scheme might too if I haven't missed any important details!


Next time I'll go over some of the special forms I have added, including short-circuiting <code>and</code> and <code>or</code> forms and the full repetoire of <code>let</code>, <code>let*</code>, and <code>letrec</code>. Stay tuned!
