---
Title: "More Scheming with Haskell"
Author: Sami Samhuri
Date: "14th June, 2007"
Timestamp: 2007-06-13T18:09:00-07:00
Tags: coding, haskell, scheme
---

It's been a little while since I wrote about Haskell and the <a href="/posts/2007/05/a-scheme-parser-in-haskell-part-1">Scheme interpreter</a> I've been using to learn and play with both Haskell and Scheme. I finished the tutorial and got myself a working Scheme interpreter and indeed it has been fun to use it for trying out little things now and then. (Normally I would use Emacs or Dr. Scheme for that sort of thing.) There certainly are <a href="http://www.lshift.net/blog/2007/06/11/folds-and-continuation-passing-style">interesting things</a> to try floating around da intranet. And also things to read and learn from, such as <a href="http://cubiclemuses.com/cm/blog/tags/Misp">misp</a> (via <a href="http://moonbase.rydia.net/mental/blog/programming/misp-is-a-lisp">Moonbase</a>).

*I'm going to describe two new features of my Scheme in this post. The second one is more interesting and was more fun to implement (cond).*

### Pasing Scheme integers ###

Last time I left off at parsing <a href="http://www.schemers.org/Documents/Standards/R5RS/HTML/r5rs-Z-H-9.html#%_sec_6.3.5">R5RS compliant numbers</a>, which is exercise 3.3.4 if you're following along the tutorial. Only integers in binary, octal, decimal, and hexadecimal are parsed right now. The syntaxes for those are <code>#b101010</code>, <code>#o52</code>, <code>42</code> (or <code>#d42</code>), and <code>#x2a</code>, respectively. To parse these we use the <code>readOct</code>, <code>readDec</code>, <code>readHex</code>, and <code>readInt</code> functions provided by the Numeric module, and import them thusly:

```haskell
import Numeric (readOct, readDec, readHex, readInt)
```

In order to parse binary digits we need to write a few short functions to help us out. For some reason I couldn't find <code>binDigit</code>, <code>isBinDigit</code> and <code>readBin</code> in their respective modules but luckily they're trivial to implement. The first two are self-explanatory, as is the third if you look at the <a href="http://www.cse.ogi.edu/~diatchki/MonadTransformers/pfe.cgi?Numeric">implementation</a> of its relatives for larger bases. In a nutshell <code>readBin</code> says to: "read an integer in base 2, validating digits with <code>isBinDigit</code>."

```haskell
-- parse a binary digit, analagous to decDigit, octDigit, hexDigit
binDigit :: Parser Char
binDigit = oneOf "01"

-- analogous to isDigit, isOctdigit, isHexDigit
isBinDigit :: Char - Bool
isBinDigit c = (c == '0' || c == '1')

-- analogous to readDec, readOct, readHex
readBin :: (Integral a) = ReadS a
readBin = readInt 2 isBinDigit digitToInt
```

The next step is to augment <code>parseNumber</code> so that it can handle R5RS numbers in addition to regular decimal numbers. To refresh, the tutorial's <code>parseNumber</code> function looks like this:

```haskell
parseNumber :: Parser LispVal
parseNumber = liftM (Number . read) $ many1 digit
```

Three more lines in this function will give us a decent starting point:

```haskell
parseNumber = do char '#'
                 base <- oneOf "bdox"
                 parseDigits base
```

Translation: First look for an R5RS style base, and if found call <code>parseDigits</code> with the given base to do the dirty work. If that fails then fall back to parsing a boring old string of decimal digits.

That brings us to actually parsing the numbers. <code>parseDigits</code> is simple, but there might be a more Haskell-y way of doing this.

```haskell
-- Parse a string of digits in the given base.
parseDigits :: Char - Parser LispVal
parseDigits base = many1 d >>= return
    where d = case base of
                'b' -> binDigit
                'd' -> digit
                'o' -> octDigit
                'x' -> hexDigit
```

The trickiest part of all this was figuring out how to use the various <code>readFoo</code> functions properly. They return a list of pairs so <code>head</code> grabs the first pair and <code>fst</code> grabs the first element of the pair. Once I had that straight it was smooth sailing. Having done this, parsing R5RS characters (#\a, #\Z, #\?, ...) is a breeze so I won't bore you with that.

### The cond function ###

It still takes me some time to knit together meaningful Haskell statements. Tonight I spent said time cobbling together an implementation of <a href="http://schemers.org/Documents/Standards/R5RS/HTML/r5rs-Z-H-7.html#%_sec_4.1.5">cond</a> as a new special form. Have a look at the code. The explanation follows.

```haskell
eval env (List (Atom "cond" : List (Atom "else" : exprs) : [])) =
    liftM last $ mapM (eval env) exprs
eval env (List (Atom "cond" : List (pred : conseq) : rest)) = 
    do result <- eval env $ pred
       case result of
         Bool False -> case rest of
                         [] -> return $ List []
                         _ -> eval env $ List (Atom "cond" : rest)
         _ -> liftM last $ mapM (eval env) conseq
```

 * __Lines 1-2:__ Handle <code>else</code> clauses by evaluating the given expression(s), returning the last result. It must come first or it's overlapped by the next pattern.
 * __Line 3:__ Evaluate a <code>cond</code> by splitting the first condition into <strong>predicate</strong> and <strong>consequence</strong>, tuck the remaining conditions into <code>rest</code> for later.
 * __Line 4:__ Evaluate <code>pred</code>
 * __Line 5:__ and if the result is:
 * __Line 6:__ <code>#f</code> then look at the rest of the conditions.
 * __Line 7:__ If there are no more conditions return the empty list.
 * __Line 8:__ Otherwise call ourselves recursively with the remaining conditions.
 * __Line 9:__ Anything other than <code>#f</code> is considered true and causes <code>conseq</code> to be evaluated and returned. Like <code>else</code>, <code>conseq</code> can be a sequence of expressions.

So far my Scheme weighs in at 621 lines, 200 more than the tutorial's final code listing. Hopefully I'll keep adding things on my TODO list and it will grow a little bit more. Now that I have <code>cond</code> it will be more fun to expand my stdlib.scm as well.
