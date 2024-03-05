#!/bin/bash
if [ $# -lt 1 ]; then
	echo "Usage: investigator-recurse.sh user1 [user2...]"
	exit 1
fi
export PATH=$PATH:`pwd`
components="$*"
path=${components// /+} # user1+[user2...]
set -e
cd $path
rm -f user-*.csv
gephi-ingest.py .
gephi-digest.py
cd -
exec investigator.sh $components
