#!/bin/sh
u=user-followers
sqlite3 -csv twitter_data.db > $u.csv <<-SQL
SELECT F.followee_name, F.follower_name, F.follower_followers_count
 FROM Followers F JOIN Users U
 ON F.followee_name = U.username
 ORDER BY U.username, F.follower_followers_count;
SQL
cut -d, -f1 < $u.csv | uniq > $u-users.csv
while read user; do
	grep "^$user,[^,]*,[1-9]" < $u.csv | head -12
done < $u-users.csv  | cut -d, -f2 | sort -n | uniq > $u-crawl.csv
for step in following followers; do
	for user in `cat $u-crawl.csv`; do
		(cd .. && inspector-$step.sh $user)
		test ! -h ./@$user && ln -s ../@$user
	done
done
