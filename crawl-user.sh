#!/bin/sh
# Usage: crawl-user.sh user1 [user2]...
for step in following followers; do
	for user in "$@"; do
		(cd .. && ./inspector-$step.sh $user)
		test ! -h ./@$user && ln -s ../@$user
	done
done
