#!/bin/sh
workdir=`pwd`
export PATH=$PATH:$workdir

for u in $@; do
	inspector-tweets.sh $u
	m=inspector-media-$u.txt
	jq -r "..|.media_url_https?|strings" < @$u/user_tweets_and_replies.json |
		sed 's;https://\(.*\);-o\1 &;' |
		tee $m |
		xargs -n 144 curl -ZR --create-dirs --remove-on-error
	# mirror the subdirectories but link the actual media files
	cut -d' ' -f2 < $m | cut -d/ -f3- | (cd @$u &&
		while read relarch; do
			relarchsubdir=`dirname $relarch`
			(mkdir -p $relarchsubdir &&
				cd $relarchsubdir &&
				ln -fs $workdir/$relarch)
		done)
done
