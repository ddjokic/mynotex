#!/bin/sh

set -v
set -e
cd "/home/massimo/Sorgenti/MyNotex_1.2.3"
mkdir -p /tmp/mynotex-1.2.3.0
cp *.lpi /tmp/mynotex-1.2.3.0/
cp *.pas /tmp/mynotex-1.2.3.0/
cp *.lfm /tmp/mynotex-1.2.3.0/
cp *.ico /tmp/mynotex-1.2.3.0/
cp *.lrs /tmp/mynotex-1.2.3.0/
cp *.png /tmp/mynotex-1.2.3.0/
cp *.desktop /tmp/mynotex-1.2.3.0/
cp Manuals/*.pdf /tmp/mynotex-1.2.3.0/
cp Translations/*.lng /tmp/mynotex-1.2.3.0/



cd /tmp/mynotex-1.2.3.0
rm -rf DEBUILD
rm -f DEBUILD.sh

cd ..
tar czf mynotex_1.2.3.0.orig.tar.gz mynotex-1.2.3.0
mv mynotex-1.2.3.0 "/home/massimo/Sorgenti/MyNotex_1.2.3/DEBUILD"
mv mynotex_1.2.3.0.orig.tar.gz "/home/massimo/Sorgenti/MyNotex_1.2.3/DEBUILD"

cd "/home/massimo/Sorgenti/MyNotex_1.2.3/DEBUILD/mynotex-1.2.3.0"
mkdir -p debian/source
echo "1.0" > debian/source/format
echo "8" > debian/compat
mv ../control debian/
mv ../rules debian/
chmod +x debian/rules
mv ../changelog debian/
mv ../copyright debian/
debuild -us -uc -d -b
cd ..
xterm -e "debsign *.changes"
