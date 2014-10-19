*This post is the last of a triplet on generating basic x86 Mach-O files
with Ruby. The first post](/posts/2010/01/working-with-c-style-structs-in-ruby) introduced CStruct,
a Ruby class used to serialize simple struct-like objects, while the second describes
[the structure of a simple Mach-O file](/posts/2010/01/basics-of-the-mach-o-file-format).*

## Symbol Tables

TODO


### N-List structures

TODO


### Load Command

TODO


## Relocation Tables

TODO


## Putting it all together

As promised I'll show you how to create a very basic Mach-O binary
that you can execute on a machine running OS X (well, any x86 machine
running Darwin but at least 99% of the time that is OS X).
