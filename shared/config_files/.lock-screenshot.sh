#!/bin/bash

PICTURE=/tmp/lock.png
SCREENSHOT="scrot $PICTURE"

$SCREENSHOT
betterlockscreen -u $PICTURE
