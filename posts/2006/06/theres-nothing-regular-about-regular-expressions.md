---
Title: There's nothing regular about regular expressions
Author: Sami Samhuri
Date: 10th June, 2006
Timestamp: 2006-06-10T01:28:00-07:00
Tags: technology, book, regex
---

I'm almost half way reading Jeffrey Friedl's book <a href="http://www.oreilly.com/catalog/regex2/">Mastering Regular Expressions</a> and I have to say that for a book on something that could potentially bore you to tears, he really does an excellent job of keeping it interesting. Even though a lot of the examples are contrived (I'm sure out of necessity), he also uses real examples of regexes that he's actually used at <a href="http://www.yahoo.com/">Yahoo!</a>.

As someone who has to know how everything works it's also an excellent lesson in patience, as he frequently says "here, take this knowledge and just accept it for now until I can explain why in the next chapter (or in 3 chapters!)". But it's all with good reason and when he does explain he does it well.

Reading about the different NFA and DFA engines and which tools use which made me go "ahhh, /that's/ why I can't do that in grep!" It's not just that I like to know how things work either, he's 100% correct about having to know information like that to wield the power of regexes in all situations. This book made me realize that regex implementations can be wildly different and that you really need to consider the job before jumping into using a specific regex flavour, as he calls them. I'm fascinated by learning why DFA regex implementations would successfully allow `^\w+=.(\\\n.)*` to match certain lines, allowing for trailing backslashes to mean continuation but why NFA engines would fail to do the same without tweaking it a bit.

It requires more thinking than the last 2 computer books I read, *Programming Ruby* (the "pixaxe" book) and *Agile Web Development With Rails* so it's noticeably slower reading. It's also the kind of book I will read more than once, for sure. There's just no way I can glean everything from it in one reading. If you use regular expressions at all then you need this book. This is starting to sound like an advertisement so I'll say no more.

QOTD, p. 329, about matching nested pairs of parens:

    \(([^()]|\(([^()]|\(([^()]|\(([^()])*\))*\))*\))*\)
    Wow, that's ugly.

(Don't worry, there's a much better solution on the next 2 pages after that quote.)

