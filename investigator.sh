#!/bin/bash
if [ $# -lt 1 ]; then
	echo "Usage: investigator.sh user1 [user2...]"
	exit 1
fi
export PATH=$PATH:`pwd`
path=${*// /+} # user1+[user2...]
mkdir -p $path
cd $path
test -h venv || ln -s ../venv
test -h accounts.db || ln -s ../accounts.db
crawl-user.sh $*
(for user in $*; do
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
done) &
if [ ! -e twitter_data.db ]; then
	gephi-ingest.py .
	gephi-digest.py
fi
for stage in 12 40 ''; do
	if [ -n "$stage" ]; then
		echo "Crawling mutuals with limit: $stage..."
	else
		echo "Crawling any remaining mutuals..."
	fi
	crawl-user-mutuals.sh $stage
done
echo "Crawling all accounts that $path is following..."
crawl-user-following.sh
fg
echo "Done crawling public data for these Twitter users:"
for user in $*; do echo "@$user"; done
echo "Don't forget to \"cd $path && ../gephi-ingest.py . &&"
echo " ../gephi-digest.py\" before launching Gephi!"
