#!/bin/sh
for user in $*; do
	echo "Gathering extended public data for @$user..."
	echo "Gathering Tweets for @$user..."
	inspector-tweets.sh $user
	echo "Done gathering Tweets for @$user..."
	echo "Gathering Tweets toward @$user..."
	inspector-tweet-references.sh $user
	echo "Done gathering Tweets toward @$user."
	echo "Gathering Likes from @$user..."
	inspector-likes.sh $user
	echo "Done gathering Likes from @$user."
	echo "Done gathering extended public data for @$user."
done
