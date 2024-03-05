#!/bin/bash
if [ $# -lt 1 ]; then
	echo "Usage: investigator.sh user1 [user2...]"
	exit 1
fi
export PATH=$PATH:`pwd`
components="$*"
path=${components// /+} # user1+[user2...]
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
crawl_mutuals() {
	stage=$1
	if [ -n "$stage" ]; then
		echo "Crawling mutuals with limit: $stage..."
	else
		echo "Crawling any remaining mutuals..."
	fi
	crawl-user-mutuals.sh $stage
}
# Do a dozen early if we are crawling all mutuals.
[ -n "$CRAWL_MUTUALS_MAXIMUM" ] && crawl_mutuals 12
crawl-user-following.sh
crawl_mutuals $CRAWL_MUTUALS_MAXIMUM
fg
echo "Done crawling public data for these Twitter users:"
for user in $*; do echo "@$user"; done
echo "Don't forget to \"cd $path && ../gephi-ingest.py . &&"
echo " ../gephi-digest.py\" before launching Gephi!"
