---
Title: Basics of the Mach-O file format
Author: Sami Samhuri
Date: 18th January, 2010
Timestamp: 2010-01-18T00:00:00-08:00
Tags: mach-o, os x, compiler
---

<p><i>This post is part of a series on generating basic x86 Mach-O files
with Ruby.  The
<a href="/posts/2010/01/working-with-c-style-structs-in-ruby">
first post</a> introduced CStruct, a Ruby class used to serialize
simple struct-like objects.</i></p>

<p>Please note that the best way to learn about Mach-O properly is to
read Apple's
<a href="http://developer.apple.com/Mac/library/documentation/DeveloperTools/Conceptual/MachORuntime/Reference/reference.html#//apple_ref/doc/uid/TP40000895-CH248-SW3">
documentation on Mach-O</a>, which is pretty good combined with the
comments in /usr/include/mach-o/*.h.  These posts will only cover
the basics necessary to generate a simple object file for linking with
ld or gcc, and are not meant to be comprehensive.</p>

<h2>Mach-O File Format Overview</h2>

<p>A Mach-O file consists of 2 main pieces: the <b>header</b> and
the <b>data</b>.  The header is basically a map of the file describing
what it contains and the position of everything contained in it.  The
data comes directly after the header and consists of a number of
binary blobs of data, one after the other.</p>

<p>The header contains 3 types of records: the <b>Mach header</b>,
<b>segments</b>, and <b>sections</b>.  Each binary blob is described
by a named section in the header.  Sections are grouped into one or
more named segments.  The Mach header is just one part of the header
and should not be confused with the entire header.  It contains
information about the file as a whole, and specifies the number of
segments as well.</p>

<p>Take a quick look at <b>Figure 1</b> in
<a href="http://developer.apple.com/Mac/library/documentation/DeveloperTools/Conceptual/MachORuntime/Reference/reference.html#//apple_ref/doc/uid/TP40000895-CH248-SW3">
Apple's Mach-O overview</a>, which illustrates this quite nicely.</p>

<p>A very basic Mach object file consists of a header followed by single
blob of machine code.  That blob could be described by a single
section named \_\_text, inside a single nameless segment.  Here's a
diagram showing the layout of such a file:</p>

<pre>

            ,---------------------------,
  Header    |  Mach header              |
            |    Segment 1              |
            |      Section 1 (__text)   | --,
            |---------------------------|   |
  Data      |           blob            | &lt;-'
            '---------------------------'
</pre>


<h2>The Mach Header</h2>

<p>The Mach header contains the architecture (cpu type), the type of
file (object in our case), and the number of segments.  There is more
to it but that's about all we care about.  To see exactly what's in a
Mach header fire up a shell and type <code>otool -h /bin/zsh</code> (on a
Mac).</p>

<p>Using
<a href="/posts/2010/01/working-with-c-style-structs-in-ruby">
CStruct</a> we define the Mach header like so:</p>

<script src="https://gist.github.com/280635.js" integrity="mDxjhIjSzfTrTGCoJEal7X5EowTQWcPyyE9xuDaRH4Al5wWVemvfjJr3WT0QCOGA" crossorigin="anonymous"></script>


<h2>Segments</h2>

<p>Segments, or <b>segment commands</b>, specify where in memory the
segment should be loaded by the OS, and the number of bytes to
allocate for that segment.  They also specify which bytes inside the
file are part of that segment, and how many sections it contains.</p>

<p>One benefit to generating an object file rather than an executable is
that we let the linker worry about some details.  One of those details
is where in memory segments will ultimately end up.</p>

<p>Names are optional and can be arbitrary, but the convention is to
name segments with uppercase letters preceded by two underscores,
e.g. \_\_DATA or \_\_TEXT </p>

<p>The code exposes some more details about segment commands, but should
be easy enough to follow.</p>

<script src="https://gist.github.com/280642.js" integrity="eY3t12vnVg5AdETSbfxWASVlAMXw8Ti7m7V2siEe9AmPncn5rckLDlh5jWBGYBbJ" crossorigin="anonymous"></script>


<h2>Sections</h2>

<p>All sections within a segment are described one after the other
directly after each segment command.  Sections define their name,
address in memory, size, offset of section data within the file, and
segment name.  The segment name might seem redundant but in the next
post we'll see why this is useful information to have in the section
header.</p>

<p>Sections can optionally specify a map to addresses within their
binary blob, called a <b>relocation table</b>.  This is used by the
linker.  Since we're letting the linker work out where to place
everything in memory the addresses inside our machine code will need
to be updated.</p>

<p>By convention segments are named with lowercase letters preceded by
two underscores, e.g. \_\_bss or \_\_text</p>

<p>Finally, the Ruby code describing section structs:</p>

<script src="https://gist.github.com/280643.js" integrity="TTawOAzAxNuDvbcDU7DXvkoK6vBygkHd1Web2mk2sKx9iCK1ZOnWUPU9tZUDFzig" crossorigin="anonymous"></script>


<h2>macho.rb</h2>

<p>As much of the Mach-O format as we need is defined in
<a href="http://github.com/samsonjs/compiler/blob/20c758ae85daa5cfa0ad9276c6633b78e982f8b4/asm/macho.rb">
asm/macho.rb</a>.  The Mach header, Segment commands, sections,
relocation tables, and symbol table structs are all there, with a few
constants as well.</p>

<p>I'll cover symbol tables and relocation tables in my next post.</p>


<h2>Looking at real Mach-O files</h2>

<p>To see the segments and sections of an object file, run
<code>otool -l /usr/lib/crt1.o</code>.  <b>-l</b> is for load commands.
If you want to see why we stick to generating object files instead of
executables run <code>otool -l /bin/zsh</code>.  They are complicated
beasts.</p>

<p>If you want to see the actual data for a section otool provides a
couple of ways to do this.  The first is to use
<code>otool -d &lt;segment&gt; &lt;section&gt;</code> for an arbitrary
section.  To see the contents of a well-known section, such as \_\_text
in the \_\_TEXT segment, use <code>otool -t /usr/bin/true</code>.  You can
also disassemble the \_\_text section with
<code>otool -tv /usr/bin/true</code>.</p>

<p>You'll get to know otool quite well if you work with Mach-O.</p>


<h2>Take a break</h2>

<p>That was probably a lot to digest, and to make real sense of it you
might need to read some of the
<a href="http://developer.apple.com/Mac/library/documentation/DeveloperTools/Conceptual/MachORuntime/Reference/reference.html#//apple_ref/doc/uid/TP40000895-CH248-SW3">
official documentation</a>.</p>

<p>We're close to being able to describe a minimal Mach object file
that can be linked, and the resulting binary executed.  By the end of
the next post we'll be there.</p>

<p><i>(You can almost do that with what we know now.  If you
create a Mach file with a Mach header (ncmds=1), a single unnamed
segment (nsects=1), and then a section named \_\_text with a segment
name of \_\_TEXT, and some x86 machine code as the section data, you
would almost have a useful Mach object file.)</i></p>

<p>Until next time, happy hacking!</p>

