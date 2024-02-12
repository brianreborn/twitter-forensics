#!/bin/sh
u="$1"
mkdir -p @"$u"

o=@"$u"/user.json
test ! -f "$o" &&
  twscrape user_by_login "$u" | tee "$o"
uid=`cut -d' ' -f2 @"$u"/user.json | cut -d , -f1`

o=@"$u"/user_tweets_and_replies.json
test ! -f "$o" &&
  twscrape user_tweets_and_replies --raw $uid > "$o"
