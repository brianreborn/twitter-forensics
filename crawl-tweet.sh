#!/bin/sh
# Usage: crawl-tweet.sh <tweet-id>
# Outputs: +<tweet-id>/
# 			tweet.json
# 			replies.json
# 			references.json
# Optional settings:
# 	$CRAWL_TWEET_DEPTH_MAXIMUM [0 = no recursion]
t=$1
set -e
workdir=`pwd`

if [ "x$CRAWL_TWEET_DEPTH" = "x" ]; then # Top-level initialization:
	CRAWL_TWEET_DEPTH=0
	export PATH="$PATH:`pwd`"
	export CRAWL_TWEET_ORIGIN=$t
	true >crawl-tweet+$CRAWL_TWEET_ORIGIN.txt
fi
if [ "x$CRAWL_TWEET_DEPTH_MAXIMUM" != "x" ]; then
	if [ $CRAWL_TWEET_DEPTH -ge $CRAWL_TWEET_DEPTH_MAXIMUM ]; then
		exit 0
	fi
else
	CRAWL_TWEET_DEPTH_MAXIMUM=12
fi
crawl_tweet_depth_prefix=`printf %${CRAWL_TWEET_DEPTH}s ''`
decho() {
	echo "${crawl_tweet_depth_prefix}$@"
}
export CRAWL_TWEET_DEPTH=`expr $CRAWL_TWEET_DEPTH + 1`

grep ^+$t\$ crawl-tweet+$CRAWL_TWEET_ORIGIN.txt >/dev/null && exit 0 # break loops
mkdir -p +$t

o=+$t/tweet.json
if [ ! -e $o ]; then
	decho "Fetching Tweet for $t."
	twscrape tweet_details --raw $t > $o
fi

o=+$t/replies.json
if [ ! -e $o ]; then
	decho "Fetching Replies for Tweet $t."
	twscrape search --raw conversation_id:$t > $o
fi

o=+$t/references.json
if [ ! -e $o ]; then
	decho "Fetching Replies, Quotes and Embeds for Tweet $t."
	twscrape search --raw quoted_tweet_id:$t > $o
fi

mirror_media_files() {
	xargs -n 144 curl -ZR --create-dirs --remove-on-error < $1
	# mirror the subdirectories but link the actual media files
	cut -d' ' -f2 < $1 | cut -d/ -f3- | (cd +$t &&
		while read relarch; do
			relarchsubdir=`dirname $relarch`
#			decho "linkin $relarch"
			(mkdir -p $relarchsubdir &&
				cd $relarchsubdir &&
				ln -f $workdir/$relarch)
		done)
}

mirror_media() {
	m=crawl-media+$t-$1.txt
	if [ ! -e $m ]; then
		jq -r "..|.media_url_https?|strings" < +$t/$1.json |
			sed 's;https://\(.*\);-o\1 &;' |
			sort |
			uniq > $m
		n=`wc -l < $m`
		if [ $n -gt 0 ]; then
			decho "Fetching $n media files for $t's $1."
			mirror_media_files $m
		fi
	fi
}

echo +$t >> crawl-tweet+$CRAWL_TWEET_ORIGIN.txt

mirror_media tweet
mirror_media replies
mirror_media references

if [ $CRAWL_TWEET_DEPTH -ge $CRAWL_TWEET_DEPTH_MAXIMUM ]; then
	exit 0
fi

jq -r '..|.legacy?|objects|.id_str?|strings' +$t/replies.json +$t/references.json | while read ot; do
	[ $ot = $t ] && continue # skip self-reference
	crawl-tweet.sh $ot
	(cd +$t && ln -fs ../+$ot)
done
