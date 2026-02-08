---
Title: "Working with C-style structs in Ruby"
Author: Sami Samhuri
Date: "17th January, 2010"
Timestamp: 2010-01-17T00:00:00-08:00
Tags: [ruby, cstruct, compiler]
---

This is the beginning of a series on generating Mach-O object files in Ruby. We start small by introducing some Ruby tools that are useful when working with binary data. Subsequent articles will cover a subset of the Mach-O file format, then generating Mach object files suitable for linking with ld or gcc to produce working executables. A basic knowledge of Ruby and C are assumed. You can likely wing it on the Ruby side of things if you know any similar languages.

First we need to read and write structured binary files with Ruby. [Array#pack](http://ruby-doc.org/core/classes/Array.html#M002222) and [String#unpack](http://ruby-doc.org/core/classes/String.html#M000760) get the job done at a low level, but every time I use them I have to look up the documentation. It would also be nice to encapsulate serializing and deserializing into classes describing the various binary data structures. The built-in [Struct class](http://ruby-doc.org/core/classes/Struct.html) sounds promising but did not meet my needs, nor was it easily extended to meet them.

Meet [CStruct](https://github.com/samsonjs/compiler/blob/20c758ae85daa5cfa0ad9276c6633b78e982f8b4/asm/cstruct.rb#files), a class that you can use to describe a binary structure, somewhat similar to how you would do it in C. Subclassing CStruct results in a class whose instances can be serialized, and unserialized, with little effort. You can subclass descendants of CStruct to extend them with additional members. CStruct does not implement much more than is necessary for the compiler. For example there is no support for floating point. If you want to use this for more general purpose tasks be warned that it may require some work. Anything supported by Array#pack is fairly easy to add though.

First a quick example and then we'll get into the CStruct class itself. In C you may write the following to have one struct "inherit" from another:

<script src="https://gist.github.com/279790.js" integrity="YxFzbbrt2TOJJW0q8lfvUTM8cYYau3pFyLY6rO2lTP88bfioQJmTcboCd+i2QHCZ" crossorigin="anonymous"></script>

With CStruct in Ruby that translates to:

<script src="https://gist.github.com/279794.js" integrity="FlnBwix8W7tFGWzEAMuLWxw5n7mYpeIQ1ka50tSODtlveSO/pwsl79nJvSTjx1dE" crossorigin="anonymous"></script>

CStructs act like Ruby's built-in Struct to a certain extent. They are instantiated the same way, by passing values to #new in the same order they are defined in the class. You can find out the size (in bytes) of a CStruct instance using the #bytesize method, or of any member using #sizeof(name).

The most important method (for us) is #serialize, which returns a binary string representing the contents of the CStruct.

(I know that CStruct.new_from_bin should be called CStruct.unserialize, you can see where my focus was when I wrote it.)

CStruct#serialize automatically creates a "pack pattern", which is an array of strings used to pack each member in turn. The pack pattern is mapped to the result of calling Array#pack on each corresponding member, and then the resulting strings are joined together. Serializing strings complicates matters so we cannot build up a pack pattern string and then serialize it in one go, but conceptually it's quite similar.

Unserializing is the same process in reverse, and was mainly added for completeness and testing purposes.

That's about all you need to know to use CStruct. The code needs some work but I decided to just go with what I have already so I can get on with the more interesting and fun tasks.

*Next in this series: [Basics of the Mach-O file format](/posts/2010/01/basics-of-the-mach-o-file-format)*
