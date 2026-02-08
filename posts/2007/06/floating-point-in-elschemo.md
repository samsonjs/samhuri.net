---
Title: "Floating point in ElSchemo"
Author: Sami Samhuri
Date: "24th June, 2007"
Timestamp: 2007-06-24T11:53:00-07:00
Tags: [elschemo, haskell, scheme]
---

### Parsing floating point numbers ###

The first task is extending the <code>LispVal</code> type to grok floats.

```haskell
type LispInt = Integer
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
             | ...
```

The reason for using the new <code>LispNum</code> type and not just throwing a new <code>Float Float</code> constructor in there is so that functions can accept and operate on parameters of any supported numeric type.  First the floating point numbers need to be parsed.  For now I only parse floating point numbers in decimal because the effort to parse other bases is too great for the benefits gained (none, for me).

ElSchemo now parses negative numbers so I'll start with 2 helper functions that are used when parsing both integers and floats:

```haskell
parseSign :: Parser Char
parseSign = do try (char '-')
           <|> do optional (char '+')
                  return '+'

applySign :: Char -> LispNum -> LispNum
applySign sign n = if sign == '-' then negate n else n
```

<code>parseSign</code> is straightforward as it follows the convention that a literal number is positive unless explicitly marked as negative with a leading minus sign. A leading plus sign is allowed but not required.

<code>applySign</code> takes a sign character and a <code>LispNum</code> and negates it if necessary, returning a <code>LispNum</code>.

Armed with these 2 functions we can now parse floating point numbers in decimal. Conforming to R5RS an optional <code>#d</code> prefix is allowed.

```haskell
parseFloat :: Parser LispVal
parseFloat = do optional (string "#d")
                sign <- parseSign
                whole <- many1 digit
                char '.'
                fract <- many1 digit
                return . Number $ applySign sign (makeFloat whole fract)
    where makeFloat whole fract = Float . fst . head . readFloat $ whole ++ "." ++ fract
```

The first 6 lines should be clear. Line 7 simply applies the parsed sign to the parsed number and returns it, delegating most of the work to <code>makeFloat</code>.  <code>makeFloat</code> in turn delegates the work to the <code>readFloat</code> library function, extracts the result and constructs a <code>LispNum</code> for it.

The last step for parsing is to modify <code>parseExpr</code> to try and parse floats.

```haskell
-- Integers, floats, characters and atoms can all start with a # so wrap those with try.
-- (Left factor the grammar in the future)
parseExpr :: Parser LispVal
parseExpr = (try parseFloat)
        <|> (try parseInteger)
        <|> (try parseChar)
        <|> parseAtom
        <|> parseString
        <|> parseQuoted
        <|> do char '('
               x <- (try parseList) <|> parseDottedList
               char ')'
               return x
        <|> parseComment
```

### Displaying the floats ###

That's it for parsing, now let's provide a way to display these suckers.  <code>LispVal</code> is an instance of show, where <code>show</code> = <code>showVal</code> so <code>showVal</code> is our first stop.  Remembering that <code>LispVal</code> now has a single <code>Number</code> constructor we modify it accordingly:

```haskell
showVal (Number n) = showNum n

showNum :: LispNum -> String
showNum (Integer contents) = show contents
showNum (Float contents) = show contents

instance Show LispNum where show = showNum
```

One last, and certainly not least, step is to modify <code>eval</code> so that numbers evaluate to themselves.

```haskell
eval env val@(Number _) = return val
```

There's a little more housekeeping to be done such as fixing <code>integer?</code>, <code>number?</code>, implementing <code>float?</code> but I will leave those as an exercise to the reader, or just wait until I share the full code.  As it stands now floating point numbers can be parsed and displayed.  If you fire up the interpreter and type <code>2.5</code> or <code>-10.88</code> they will be understood.  Now try adding them:

```scheme
(+ 2.5 1.1)
Invalid type: expected integer, found 2.5
```

Oops, we don't know how to operate on floats yet!

### Operating on floats ###

Parsing was the easy part.  Operating on the new floats is not necessarily difficult, but it was more work than I realized it would be.  I don't claim that this is the best or the only way to operate on any <code>LispNum</code>, it's just the way I did it and it seems to work.  There's a bunch of boilerplate necessary to make <code>LispNum</code> an instance of the required classes, Eq, Num, Real, and Ord.  I don't think I have done this properly but for now it works.  What is clearly necessary is the code that operates on different types of numbers.  I think I've specified sane semantics for coercion.  This will be very handy shortly.

```haskell
lispNumEq :: LispNum -> LispNum -> Bool
lispNumEq (Integer arg1) (Integer arg2) = arg1 == arg2
lispNumEq (Integer arg1) (Float arg2) = (fromInteger arg1) == arg2
lispNumEq (Float arg1) (Float arg2) = arg1 == arg2
lispNumEq (Float arg1) (Integer arg2) = arg1 == (fromInteger arg2)

instance Eq LispNum where (==) = lispNumEq

lispNumPlus :: LispNum -> LispNum -> LispNum
lispNumPlus (Integer x) (Integer y) = Integer $ x + y
lispNumPlus (Integer x) (Float y)   = Float $ (fromInteger x) + y
lispNumPlus (Float x)   (Float y)   = Float $ x + y
lispNumPlus (Float x)   (Integer y) = Float $ x + (fromInteger y)

lispNumMinus :: LispNum -> LispNum -> LispNum
lispNumMinus (Integer x) (Integer y) = Integer $ x - y
lispNumMinus (Integer x) (Float y)   = Float $ (fromInteger x) - y
lispNumMinus (Float x)   (Float y)   = Float $ x - y
lispNumMinus (Float x)   (Integer y) = Float $ x - (fromInteger y)

lispNumMult :: LispNum -> LispNum -> LispNum
lispNumMult (Integer x) (Integer y) = Integer $ x * y
lispNumMult (Integer x) (Float y)   = Float $ (fromInteger x) * y
lispNumMult (Float x)   (Float y)   = Float $ x * y
lispNumMult (Float x)   (Integer y) = Float $ x * (fromInteger y)

lispNumDiv :: LispNum -> LispNum -> LispNum
lispNumDiv (Integer x) (Integer y) = Integer $ x `div` y
lispNumDiv (Integer x) (Float y)   = Float $ (fromInteger x) / y
lispNumDiv (Float x)   (Float y)   = Float $ x / y
lispNumDiv (Float x)   (Integer y) = Float $ x / (fromInteger y)

lispNumAbs :: LispNum -> LispNum
lispNumAbs (Integer x) = Integer (abs x)
lispNumAbs (Float x) = Float (abs x)

lispNumSignum :: LispNum -> LispNum
lispNumSignum (Integer x) = Integer (signum x)
lispNumSignum (Float x) = Float (signum x)

instance Num LispNum where
    (+) = lispNumPlus
    (-) = lispNumMinus
    (*) = lispNumMult
    abs = lispNumAbs
    signum = lispNumSignum
    fromInteger x = Integer x

lispNumToRational :: LispNum -> Rational
lispNumToRational (Integer x) = toRational x
lispNumToRational (Float x) = toRational x

instance Real LispNum where
    toRational = lispNumToRational

lispIntQuotRem :: LispInt -> LispInt -> (LispInt, LispInt)
lispIntQuotRem n d = quotRem n d

lispIntToInteger :: LispInt -> Integer
lispIntToInteger x = x

lispNumLessThanEq :: LispNum -> LispNum -> Bool
lispNumLessThanEq (Integer x) (Integer y) = x <= y
lispNumLessThanEq (Integer x) (Float y)   = (fromInteger x) <= y
lispNumLessThanEq (Float x)   (Integer y) = x <= (fromInteger y)
lispNumLessThanEq (Float x)   (Float y)   = x <= y

instance Ord LispNum where (<=) = lispNumLessThanEq
```

Phew, ok with that out of the way now we can actually extend our operators to work with any type of <code>LispNum</code>.  Our Scheme operators are defined using the functions <code>numericBinop</code> and <code>numBoolBinop</code>.  First we'll slightly modify our definition of <code>primitives</code>:

```haskell
primitives :: [(String, [LispVal] -> ThrowsError LispVal)]
primitives = [("+", numericBinop (+)),
              ("-", subtractOp),
              ("*", numericBinop (*)),
              ("/", floatBinop (/)),
              ("mod", integralBinop mod),
              ("quotient", integralBinop quot),
              ("remainder", integralBinop rem),
              ("=", numBoolBinop (==)),
              ("<", numBoolBinop (<)),
              (">", numBoolBinop (>)),
              ("/=", numBoolBinop (/=)),
              (">=", numBoolBinop (>=)),
              ("<=", numBoolBinop (<=)),
              ...]
```

Note that <code>mod</code>, <code>quotient</code>, and <code>remainder</code> are only defined for integers and as such use <code>integralBinop</code>, while division (/) is only defined for floating point numbers using <code>floatBinop</code>.  <code>subtractOp</code> is different to support unary usage, e.g. <code>(- 4) =&gt; -4</code>, but it uses <code>numericBinop</code> internally when more than 1 argument is given.  On to the implementation!  First extend <code>unpackNum</code> to work with any <code>LispNum</code>, and provide separate <code>unpackInt</code> and <code>unpackFloat</code> functions to handle both kinds of <code>LispNum</code>.

```haskell
unpackNum :: LispVal -> ThrowsError LispNum
unpackNum (Number (Integer n)) = return $ Integer n
unpackNum (Number (Float n)) = return $ Float n
unpackNum notNum = throwError $ TypeMismatch "number" notNum

unpackInt :: LispVal -> ThrowsError Integer
unpackInt (Number (Integer n)) = return n
unpackInt (List [n]) = unpackInt n
unpackInt notInt = throwError $ TypeMismatch "integer" notInt

unpackFloat :: LispVal -> ThrowsError Float
unpackFloat (Number (Float f)) = return f
unpackFloat (Number (Integer f)) = return $ fromInteger f
unpackFloat (List [f]) = unpackFloat f
unpackFloat notFloat = throwError $ TypeMismatch "float" notFloat
```

The initial work of separating integers and floats into the <code>LispNum</code> abstraction, and the code I said would be handy shortly, are going to be really handy here.  There's relatively no change in <code>numericBinop</code> except for the type signature.  <code>integralBinop</code> and <code>floatBinop</code> are just specific versions of the same function.  I'm sure there's a nice Haskelly way of doing this with less repetition, and I welcome such corrections.

```haskell
numericBinop :: (LispNum -> LispNum -> LispNum) -> [LispVal] -> ThrowsError LispVal
numericBinop op singleVal@[_] = throwError $ NumArgs 2 singleVal
numericBinop op params = mapM unpackNum params >>= return . Number . foldl1 op

integralBinop :: (LispInt -> LispInt -> LispInt) -> [LispVal] -> ThrowsError LispVal
integralBinop op singleVal@[_] = throwError $ NumArgs 2 singleVal
integralBinop op params = mapM unpackInt params >>= return . Number . Integer . foldl1 op

floatBinop :: (LispFloat -> LispFloat -> LispFloat) -> [LispVal] -> ThrowsError LispVal
floatBinop op singleVal@[_] = throwError $ NumArgs 2 singleVal
floatBinop op params = mapM unpackFloat params >>= return . Number . Float . foldl1 op

subtractOp :: [LispVal] -> ThrowsError LispVal
subtractOp num@[_] = unpackNum (head num) >>= return . Number . negate
subtractOp params = numericBinop (-) params

numBoolBinop :: (LispNum -> LispNum -> Bool) -> [LispVal] -> ThrowsError LispVal
numBoolBinop op params = boolBinop unpackNum op params
```

That was a bit of work but now ElSchemo supports floating point numbers, and if you're following along then your Scheme might too if I haven't missed any important details!

Next time I'll go over some of the special forms I have added, including short-circuiting <code>and</code> and <code>or</code> forms and the full repetoire of <code>let</code>, <code>let*</code>, and <code>letrec</code>. Stay tuned!
