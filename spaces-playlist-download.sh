#!/bin/sh
url="$1"
CURL="curl -JZ"
$CURL -O "$url"
baseurl=`echo "$url" | cut -d/ -f1-11`
playlist=`echo "$url" | cut -d/ -f12`
chopit=`echo "$playlist" | cut -d'?' -f1`
mv "$playlist" "$chopit"
playlist="$chopit"
grep ^chunk_ $playlist | while read chunkname; do echo -O "$baseurl/$chunkname"; done | xargs -n 100 $CURL
