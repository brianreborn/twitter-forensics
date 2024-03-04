#!/bin/sh
u="$1"
mkdir -p @"$u"

o=@"$u"/user.json
test ! -f "$o" &&
  twscrape user_by_login "$u" | tee "$o"
uid=`cut -d' ' -f2 @"$u"/user.json | cut -d , -f1`

# Renew Likes daily.
o=@"$u"/liked_tweets.`date +%Y-%m-%d`.js
test ! -f "$o" &&
  twscrape liked_tweets --raw $uid > "$o"
