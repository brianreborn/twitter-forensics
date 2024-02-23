#!/bin/sh
u=user-mutuals.csv
if [ -e $u ]; then
	echo "WARN: continuing; remove $u if you wish to recurse" >&2
	ls -l $u >&2
else
	sqlite3 -csv twitter_data.db > $u <<-SQL
	SELECT DISTINCT F1.follower_name
	 FROM Followers F1 JOIN Followers F2
	 ON F1.follower_name = F2.followee_name AND F2.follower_name = F1.followee_name
	 ORDER BY F1.follower_followers_count ASC;
	SQL
fi
for step in following followers; do
	for user in `cat $u`; do
		(cd .. && ./inspector-$step.sh $user)
		test ! -h ./@$user && ln -s ../@$user
	done
done
