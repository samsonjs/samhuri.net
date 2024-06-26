---
Title: Gtkpod in Gutsy Got You Groaning?
Author: Sami Samhuri
Date: 29th October, 2007
Timestamp: 2007-10-29T14:14:00-07:00
Tags: broken, gtkpod, linux, ubuntu
---

I recently upgraded the <a href="http://www.ubuntu.com/">Ubuntu</a> installation on my workstation from Feisty Fawn to Gutsy Gibbon and for the most part I am happy with the changes.  One thing I don't care much for is the fact that gtkpod-aac is a sham.  Ubuntu provides the gtkpod-aac package for one to transfer aac files, and thus mp4 files with aac audio tracks, to their iPod.  The version in the Gutsy repos is broken.  This shows a weakness in Ubuntu, and though it's rather small it is one that will piss off a lot of people who expect things to just work.  The kind of people who would buy an iPod.  The kind of people who use Linux.  The kind of Linux users that use Ubuntu.  The kicker is that <a href="https://bugs.launchpad.net/ubuntu/+source/gtkpod-aac/+bug/135178/comments/6">it doesn't look like</a> they will ship a working version of gtkpod-aac for Gutsy at all.  I know it's only 6 months but that seems like an eternity when you have the same old crap to watch on your iPod for that long.

All is not lost.  A kind soul left <a href="https://bugs.launchpad.net/ubuntu/+source/gtkpod-aac/+bug/135178/comments/7">a helpful comment</a> on the <a href="https://bugs.launchpad.net/ubuntu/+source/gtkpod-aac/+bug/135178">bug report</a> explaining how he got it to work.  It's a pretty simple fix.  Just <a href="http://www.google.ca/search?q=libmpeg4ip">google for libmpeg4ip</a> and find a <a href="http://ftp.uni-kl.de/debian-multimedia/pool/main/libm/libmpeg4ip/">Debian repo that has the following packages</a> for your architecture:

 * libmpeg4ip-0
 * libmpeg4ip-dev
 * libmp4v2-0
 * libmp4v2-dev

Download those 4 .deb files and install them.  You can ignore any advice to use an older version in the official repo.  Once you have those installed, download and build the latest version of gtkpod from their <a href="http://sourceforge.net/svn/?group_id=67873">Subversion repo</a>.

Now that you know what to do I'll give you what you probably wanted at the beginning.  As long as you have wget, subversion, and use a Bourne-like shell this should work for you.

&darr; <a href="/f/gtkpod-aac-fix.sh">gtkpod-aac-fix.sh</a>

<pre class="line-numbers">1
2
3
4
5
6
7
8
9
10
11
12
</pre>

<pre ondblclick="with (this.style) { overflow = (overflow == 'auto' || overflow == '') ? 'visible' : 'auto' }"><code>mkdir /tmp/gtkpod-fix
cd /tmp/gtkpod-fix
wget http://ftp.uni-kl.de/debian-multimedia/pool/main/libm/libmpeg4ip/libmp4v2-0_1.5.0.1-0.3_amd64.deb
wget http://ftp.uni-kl.de/debian-multimedia/pool/main/libm/libmpeg4ip/libmp4v2-dev_1.5.0.1-0.3_amd64.deb
wget http://ftp.uni-kl.de/debian-multimedia/pool/main/libm/libmpeg4ip/libmpeg4ip-0_1.5.0.1-0.3_amd64.deb
wget http://ftp.uni-kl.de/debian-multimedia/pool/main/libm/libmpeg4ip/libmpeg4ip-dev_1.5.0.1-0.3_amd64.deb
for f in *.deb; do sudo gdebi -n "$f"; done
svn co https://gtkpod.svn.sourceforge.net/svnroot/gtkpod/gtkpod/trunk gtkpod
cd gtkpod
./autogen.sh --with-mp4v2 &amp;&amp; make &amp;&amp; sudo make install
cd
rm -rf /tmp/gtkpod-fix</code></pre>
