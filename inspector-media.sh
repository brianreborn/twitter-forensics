#!/bin/sh
workdir=`pwd`
export PATH=$PATH:$workdir
for u in $@; do
	inspector-tweets.sh $u
	m=inspector-media-$u.txt
	jq -r "..|.media_url_https?|strings" < @$u/user_tweets_and_replies.json |
		tee $m |
		xargs wget -mi
	# mirror the subdirectories but link the actual media files
	cut -d/ -f3- < $m | (cd @$u &&
		while read relarch; do
			relarchsubdir=`dirname $relarch`
			(mkdir -p $relarchsubdir &&
				cd $relarchsubdir &&
				ln -s $workdir/$relarch)
		done)
done
