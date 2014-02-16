#!/bin/sh

mkdir /tmp/gtkpod-fix
cd /tmp/gtkpod-fix
wget http://ftp.uni-kl.de/debian-multimedia/pool/main/libm/libmpeg4ip/libmp4v2-0_1.5.0.1-0.3_amd64.deb
wget http://ftp.uni-kl.de/debian-multimedia/pool/main/libm/libmpeg4ip/libmp4v2-dev_1.5.0.1-0.3_amd64.deb
wget http://ftp.uni-kl.de/debian-multimedia/pool/main/libm/libmpeg4ip/libmpeg4ip-0_1.5.0.1-0.3_amd64.deb
wget http://ftp.uni-kl.de/debian-multimedia/pool/main/libm/libmpeg4ip/libmpeg4ip-dev_1.5.0.1-0.3_amd64.deb
for f in *.deb; do sudo gdebi -n "$f"; done
svn co https://gtkpod.svn.sourceforge.net/svnroot/gtkpod/gtkpod/trunk gtkpod
cd gtkpod
./autogen.sh --with-mp4v2 && make && sudo make install
cd
rm -rf /tmp/gtkpod-fix
