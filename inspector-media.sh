#!/bin/sh
u="$1"
inspector-tweets.sh "$u"
jq -r "..|.media_url_https?|strings" < "@$u/user_tweets_and_replies.json" |
	xargs wget -mi
