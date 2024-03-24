#!/bin/sh
# Usage: crawl-tweet.sh <tweet-id>
# Outputs: +<tweet-id>/
# 			tweet.json
# 			replies.json
# 			references.json
t=$1
set -e
workdir=`pwd`
#export PATH=$PATH:`pwd`
mkdir -p +$t

o=+$t/tweet.json
if [ ! -e $o ]; then
	echo "Fetching Tweet for $t."
	twscrape tweet_details --raw $t > $o
fi

o=+$t/replies.json
if [ ! -e $o ]; then
	echo "Fetching Replies for Tweet $t."
	twscrape search --raw conversation_id:$t > $o
fi

o=+$t/references.json
if [ ! -e $o ]; then
	echo "Fetching Quotes/Embeds for Tweet $t."
	twscrape search --raw quoted_tweet_id:$t > $o
fi

mirror_media_files() {
	xargs -n 144 curl -ZR --create-dirs --remove-on-error < $1
	# mirror the subdirectories but link the actual media files
	cut -d' ' -f2 < $1 | cut -d/ -f3- | (cd +$t &&
		while read relarch; do
			relarchsubdir=`dirname $relarch`
			(mkdir -p $relarchsubdir &&
				cd $relarchsubdir &&
				ln -fs $workdir/$relarch)
		done)
}

mirror_media() {
	m=crawl-media+$t-$1.txt
	if [ ! -e $m ]; then
		jq -r "..|.media_url_https?|strings" < +$t/$1.json |
			sed 's;https://\(.*\);-o\1 &;' > $m
		n=`wc -l < $m`
		if [ $n -gt 0 ]; then
			echo "Fetching $n media files for $t's $1."
			mirror_media_files $m
		fi
	fi
}

mirror_media tweet
mirror_media replies
