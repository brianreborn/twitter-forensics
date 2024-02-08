#!/bin/sh
# A "protected" account still has public references to its Tweets
# and itself. We can easily find QRT's and mentions even if we are
# not able to access the protected Tweets themselves trivially.
u="$1"
mkdir -p @"$u"

o=@"$u"/user.json
test ! -f "$o" &&
  twscrape user_by_login "$u" | tee "$o"
uid=`cut -d' ' -f2 @"$u"/user.json | cut -d , -f1`

o=@"$u"/user_tweet_references.json
test ! -f "$o" &&
  twscrape search --raw "quoted_user_id:$uid or to:$u or @$u"> "$o"
