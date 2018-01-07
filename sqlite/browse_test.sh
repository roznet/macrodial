#!/bin/sh
f=`find ~/Library -name 'macros_test.db' -print | grep Documents`
echo "sqlite3 $f"
sqlite3 "$f"