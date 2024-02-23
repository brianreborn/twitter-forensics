#!/bin/sh
mkdir -p Lost+Found
for i in @*; do
	if cmp $i/user.json user-not-found.json >/dev/null; then
		mv $i Lost+Found
	fi
done	
