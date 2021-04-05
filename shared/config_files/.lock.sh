#!/bin/bash

#PICTURE=/tmp/lock.png
#SCREENSHOT="scrot $PICTURE"

#$SCREENSHOT
#betterlockscreen -u $PICTURE

if [ "$1" == "1" ]; then
	betterlockscreen -l dimblur
fi

if [ "$1" == "2" ]; then
	betterlockscreen -s dimblur
fi

rm $PICTURE
