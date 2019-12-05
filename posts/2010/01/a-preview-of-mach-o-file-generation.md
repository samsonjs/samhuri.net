---
Title: A preview of Mach-O file generation
Author: Sami Samhuri
Date: 20th January, 2010
Timestamp: 1263974400
Tags: ruby, mach-o, os x, compiler
---

This month I got back into an x86 compiler I started last May. It lives
[on github](https://github.com/samsonjs/compiler).

The code is a bit of a mess but it mostly works. It generates Mach object
files that are linked with gcc to produce executable binaries.

The Big Refactoring of January 2010 has come to an end and the tests pass
again, even if printing is broken it prints *something*, and more
importantly compiles test/test_huge.code into something that works.

After print is fixed I can clean up the code before implementing anything
new. I wasn't sure if I'd get back into this or not and am pretty excited
about it. I'm learning a lot from this project.

If you are following the Mach-O posts you might want to look at
asm/machofile.rb, a library for creating Mach-O files. Using it is quite
straightforward, an example is in asm/binary.rb, in the #output method.

Definitely time for bed now!

