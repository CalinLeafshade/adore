#!/bin/sh
dir1=.
echo "Waiting for changes"
while inotifywait -qqre modify "$dir1"; do
    busted
    echo "Waiting for changes"
done
