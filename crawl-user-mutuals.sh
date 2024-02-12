#!/bin/sh
sqlite3 -csv twitter_data.db > user-mutuals.csv <<-SQL
SELECT DISTINCT F1.follower_name
 FROM Followers F1 JOIN Followers F2
 ON F1.follower_name = F2.followee_name AND F2.follower_name = F1.followee_name
 ORDER BY F1.follower_followers_count ASC;
SQL
for user in `cat user-mutuals.csv`; do
	(cd .. && ./inspector.sh $user)
	ln -s ../@$user
done
