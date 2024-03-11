#!/bin/sh
u="$1"
mkdir -p @"$u"

o=@"$u"/user.json
test ! -f "$o" &&
  twscrape user_by_login "$u" > "$o"
uid=`cut -d' ' -f2 @"$u"/user.json | cut -d , -f1`

test -n "$CRAWL_FOLLOWERS_LIMIT" &&
  limit="--limit $CRAWL_FOLLOWERS_LIMIT"
o=@"$u"/followers.json
test ! -f "$o" &&
  twscrape followers $limit $uid > "$o"
