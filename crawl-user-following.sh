#!/bin/sh
sqlite3 -csv twitter_data.db > user-following.csv <<-SQL
SELECT F.follower_name, F.followee_name, F.followee_followers_count
 FROM Followers F JOIN Users U
 ON F.follower_name = U.username
 ORDER BY U.username, F.followee_followers_count;
SQL
cut -d, -f1 < user-following.csv | uniq > user-following-users.csv
while read user; do
	grep "^$user,[^,]*,[1-9]" < user-following.csv | head -12
done < user-following-users.csv  | cut -d, -f2 | sort -n | uniq > user-crawl.csv
echo "Crawling `wc -l user-crawl.csv` Followers:"
for step in following followers; do
	for user in `cat user-crawl.csv`; do
		echo "Inspecting Follower ($step step): @$user"
		(cd .. && inspector-$step.sh $user)
		test ! -h ./@$user && ln -s ../@$user
	done
done
