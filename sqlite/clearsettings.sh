#!/bin/sh
f=`find ~/Library -name 'settings.plist' -print | grep Documents`;
if [ -f "$f" ];  then
echo "removing $f"
rm "$f"
fi