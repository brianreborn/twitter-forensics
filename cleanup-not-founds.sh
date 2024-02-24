#!/bin/sh
mkdir -p Lost+Found
for i in @*; do
	if [ -e $i/user.json -a ! -s $i/user.json ] || cmp $i/user.json user-not-found.json >/dev/null; then
		mv $i Lost+Found
	fi
done	
