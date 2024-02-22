#!/bin/sh
u=user-mutuals.csv
[ ! -e $u ] && sqlite3 -csv twitter_data.db > $u <<-SQL
SELECT DISTINCT F1.follower_name
 FROM Followers F1 JOIN Followers F2
 ON F1.follower_name = F2.followee_name AND F2.follower_name = F1.followee_name
 ORDER BY F1.follower_followers_count ASC;
SQL
for step in following followers; do
	for user in `cat $u`; do
		(cd .. && ./inspector-$step.sh $user) &&
			test ! -l "./@$user" &&
			ln -s ../@$user
	done
done
